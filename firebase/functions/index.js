const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Stripe = require("stripe");

// Initialize Firebase Admin
admin.initializeApp();

// Define secrets
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

// Price IDs
const MONTHLY_PRICE_ID = "price_1Sjggy4KmkIrfz5IKZYTeD92";
const YEARLY_PRICE_ID = "price_1Sjgiu4KmkIrfz5I9Agqw9N6";

/**
 * Stripe Webhook Handler (Gen 2)
 */
exports.stripeWebhook = onRequest(
  { 
    secrets: [stripeSecretKey, stripeWebhookSecret],
    cors: true,
  },
  async (req, res) => {
    const stripe = new Stripe(stripeSecretKey.value(), {
      apiVersion: "2023-10-16",
    });
    
    const sig = req.headers["stripe-signature"];
    let event;

    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody, 
        sig, 
        stripeWebhookSecret.value()
      );
    } catch (err) {
      console.error(`Webhook signature verification failed: ${err.message}`);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    console.log(`Received event: ${event.type}`);

    try {
      switch (event.type) {
        case "checkout.session.completed":
          await handleCheckoutComplete(event.data.object, stripe);
          break;

        case "customer.subscription.created":
        case "customer.subscription.updated":
          await handleSubscriptionUpdate(event.data.object);
          break;

        case "customer.subscription.deleted":
          await handleSubscriptionDeleted(event.data.object);
          break;

        case "invoice.paid":
          console.log(`Invoice paid for subscription ${event.data.object.subscription}`);
          break;

        case "invoice.payment_failed":
          await handlePaymentFailed(event.data.object);
          break;

        default:
          console.log(`Unhandled event type: ${event.type}`);
      }

      return res.status(200).json({ received: true });
    } catch (error) {
      console.error("Error processing webhook:", error);
      return res.status(500).json({ error: "Webhook processing failed" });
    }
  }
);

/**
 * Handle checkout session completed
 */
async function handleCheckoutComplete(session, stripe) {
  const userId = session.client_reference_id;
  const customerId = session.customer;
  const subscriptionId = session.subscription;

  if (!userId) {
    console.error("No user ID in checkout session");
    return;
  }

  console.log(`Checkout completed for user ${userId}`);

  // Get subscription details from Stripe
  const subscription = await stripe.subscriptions.retrieve(subscriptionId);
  
  // Determine plan type
  const priceId = subscription.items.data[0]?.price.id;
  const plan = determinePlanType(priceId);

  // Save to Firestore
  const subscriptionData = {
    userId: userId,
    customerId: customerId,
    subscriptionId: subscriptionId,
    plan: plan,
    status: subscription.status,
    currentPeriodStart: admin.firestore.Timestamp.fromMillis(subscription.current_period_start * 1000),
    currentPeriodEnd: admin.firestore.Timestamp.fromMillis(subscription.current_period_end * 1000),
    cancelAtPeriodEnd: subscription.cancel_at_period_end,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await admin.firestore()
    .collection("subscriptions")
    .doc(subscriptionId)
    .set(subscriptionData);

  // Update user document
  await admin.firestore()
    .collection("users")
    .doc(userId)
    .set({
      isPremium: true,
      premiumPlan: plan,
      premiumExpiry: admin.firestore.Timestamp.fromMillis(subscription.current_period_end * 1000),
      stripeCustomerId: customerId,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

  console.log(`Subscription ${subscriptionId} created for user ${userId}`);
}

/**
 * Handle subscription updates
 */
async function handleSubscriptionUpdate(subscription) {
  const subscriptionId = subscription.id;

  // Get existing subscription to find user ID
  const existingDoc = await admin.firestore()
    .collection("subscriptions")
    .doc(subscriptionId)
    .get();

  let userId;
  
  if (existingDoc.exists) {
    userId = existingDoc.data().userId;
  } else {
    // Try to find by customer ID
    const customer = await stripe.customers.retrieve(subscription.customer);
    // Customer metadata might have userId
    console.log(`Subscription ${subscriptionId} not found, customer: ${subscription.customer}`);
    return;
  }

  const priceId = subscription.items.data[0]?.price.id;
  const plan = determinePlanType(priceId);

  // Update subscription document
  await admin.firestore()
    .collection("subscriptions")
    .doc(subscriptionId)
    .update({
      status: subscription.status,
      plan: plan,
      currentPeriodStart: admin.firestore.Timestamp.fromMillis(subscription.current_period_start * 1000),
      currentPeriodEnd: admin.firestore.Timestamp.fromMillis(subscription.current_period_end * 1000),
      cancelAtPeriodEnd: subscription.cancel_at_period_end,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  // Update user document
  if (userId) {
    const isActive = subscription.status === "active" || subscription.status === "trialing";
    
    await admin.firestore()
      .collection("users")
      .doc(userId)
      .set({
        isPremium: isActive,
        premiumPlan: isActive ? plan : null,
        premiumExpiry: isActive 
          ? admin.firestore.Timestamp.fromMillis(subscription.current_period_end * 1000)
          : null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
  }

  console.log(`Subscription ${subscriptionId} updated: ${subscription.status}`);
}

/**
 * Handle subscription deleted
 */
async function handleSubscriptionDeleted(subscription) {
  const subscriptionId = subscription.id;

  const existingDoc = await admin.firestore()
    .collection("subscriptions")
    .doc(subscriptionId)
    .get();

  if (!existingDoc.exists) {
    console.log(`Subscription ${subscriptionId} not found in Firestore`);
    return;
  }

  const userId = existingDoc.data().userId;

  // Update subscription status
  await admin.firestore()
    .collection("subscriptions")
    .doc(subscriptionId)
    .update({
      status: "canceled",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  // Check for other active subscriptions
  if (userId) {
    const otherSubs = await admin.firestore()
      .collection("subscriptions")
      .where("userId", "==", userId)
      .where("status", "in", ["active", "trialing"])
      .limit(1)
      .get();

    if (otherSubs.empty) {
      await admin.firestore()
        .collection("users")
        .doc(userId)
        .set({
          isPremium: false,
          premiumPlan: null,
          premiumExpiry: null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
    }
  }

  console.log(`Subscription ${subscriptionId} deleted`);
}

/**
 * Handle payment failed
 */
async function handlePaymentFailed(invoice) {
  const subscriptionId = invoice.subscription;
  
  if (!subscriptionId) return;

  console.log(`Payment failed for subscription ${subscriptionId}`);

  const existingDoc = await admin.firestore()
    .collection("subscriptions")
    .doc(subscriptionId)
    .get();

  if (!existingDoc.exists) return;

  await admin.firestore()
    .collection("subscriptions")
    .doc(subscriptionId)
    .update({
      paymentIssue: true,
      lastPaymentError: invoice.last_finalization_error?.message || "Payment failed",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

/**
 * Determine plan type from price ID
 */
function determinePlanType(priceId) {
  if (priceId === MONTHLY_PRICE_ID) {
    return "monthly";
  } else if (priceId === YEARLY_PRICE_ID) {
    return "yearly";
  }
  return "monthly";
}
