import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'desktop_auth_service.dart';

/// Configuration for purchases
class PurchaseConfig {
  // RevenueCat API keys (for mobile)
  static const String revenueCatAppleKey = 'test_GBhmZCfwUisAAVspwnTFEdfokUM';
  static const String revenueCatGoogleKey = 'test_GBhmZCfwUisAAVspwnTFEdfokUM';
  
  // Stripe configuration (for desktop)
  static const String stripePublishableKey = 'pk_live_51SjflX4KmkIrfz5Idrjrbw279vzG5NvdMzRdsdRrw799hOqiizWnyDVPiKY58ygUlP25dhcD9v13Ait5TYz3sVmC008F9S9Py3';
  
  // Stripe Payment Links
  static const String monthlyPaymentLink = 'https://buy.stripe.com/3cIeV6equeVs9os6DFb3q00';
  static const String yearlyPaymentLink = 'https://buy.stripe.com/dRmfZa6Y2aFccAE7HJb3q01';
  
  // Stripe Price IDs
  static const String monthlyPriceId = 'price_1Sjggy4KmkIrfz5IKZYTeD92';
  static const String yearlyPriceId = 'price_1Sjgiu4KmkIrfz5I9Agqw9N6';
  
  /// Entitlement identifier for premium access
  static const String premiumEntitlementId = 'premium';
  
  /// Product identifiers
  static const String monthlyProductId = 'brisyn_pro_monthly';
  static const String yearlyProductId = 'brisyn_pro_yearly';
  
  /// Prices for display
  static const String monthlyPrice = '\$1.99';
  static const String yearlyPrice = '\$9.99';
}

/// Subscription info from Firestore (for desktop users)
class SubscriptionInfo {
  final String subId;
  final String userId;
  final String plan;
  final String status;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  
  SubscriptionInfo({
    required this.subId,
    required this.userId,
    required this.plan,
    required this.status,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
  });
  
  factory SubscriptionInfo.fromFirestore(Map<String, dynamic> data, String subId) {
    return SubscriptionInfo(
      subId: subId,
      userId: data['userId'] ?? '',
      plan: data['plan'] ?? 'monthly',
      status: data['status'] ?? 'inactive',
      currentPeriodEnd: data['currentPeriodEnd'] != null 
          ? (data['currentPeriodEnd'] as Timestamp).toDate()
          : null,
      cancelAtPeriodEnd: data['cancelAtPeriodEnd'] ?? false,
    );
  }
  
  bool get isActive => status == 'active' || status == 'trialing';
}

/// Purchase result wrapper
class PurchaseResult {
  final bool success;
  final String? error;
  final String? message;
  final CustomerInfo? customerInfo;

  const PurchaseResult({
    required this.success,
    this.error,
    this.message,
    this.customerInfo,
  });

  factory PurchaseResult.success(CustomerInfo? info, {String? message}) {
    return PurchaseResult(success: true, customerInfo: info, message: message);
  }

  factory PurchaseResult.failure(String error) {
    return PurchaseResult(success: false, error: error, message: error);
  }
}

/// Service for handling in-app purchases
/// Uses RevenueCat for mobile (iOS/Android) and Stripe for desktop (Windows/Linux/macOS)
class PurchaseService {
  static PurchaseService? _instance;
  bool _isInitialized = false;
  String? _userId;
  
  // Developer mode flag
  bool _devModeEnabled = false;
  bool get isDevModeEnabled => _devModeEnabled;

  // Stream controller for premium status changes
  final _premiumStatusController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  // Current premium status
  bool _isPremium = false;
  bool get isPremium => _isPremium || _devModeEnabled;

  // Current customer info (RevenueCat)
  CustomerInfo? _customerInfo;
  CustomerInfo? get customerInfo => _customerInfo;

  // Subscription info (Firestore/Stripe)
  SubscriptionInfo? _subscriptionInfo;
  SubscriptionInfo? get subscriptionInfo => _subscriptionInfo;

  // Available packages (RevenueCat)
  List<Package> _packages = [];
  List<Package> get packages => _packages;

  // Firestore subscription listener
  StreamSubscription? _firestoreSubscription;

  PurchaseService._();

  /// Get singleton instance
  static PurchaseService get instance {
    _instance ??= PurchaseService._();
    return _instance!;
  }

  /// Check if we're on a desktop platform
  bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  /// Check if we're on a mobile platform with RevenueCat support
  bool get isMobileWithRevenueCat {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Update user ID after login (useful for desktop where auth happens after app launch)
  Future<void> setUserId(String userId) async {
    _userId = userId;
    debugPrint('PurchaseService: User ID set to $userId');
    
    // Start listening to Firestore for subscription status
    if (isDesktop || kIsWeb) {
      await _startFirestoreListener(userId);
    }
  }

  /// Initialize the purchase service
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;

    _userId = userId;

    try {
      if (kIsWeb) {
        // Web: Just use Firestore for premium status
        if (userId != null) {
          await _startFirestoreListener(userId);
        }
        _isInitialized = true;
        return;
      }

      if (isDesktop) {
        // Desktop: Use Firestore/Stripe
        if (userId != null) {
          await _startFirestoreListener(userId);
        }
        _isInitialized = true;
        debugPrint('PurchaseService: Initialized for desktop (Stripe)');
        return;
      }

      // Mobile: Use RevenueCat
      await _initializeRevenueCat(userId);
      
      _isInitialized = true;
      debugPrint('PurchaseService: Initialized successfully');
    } catch (e) {
      debugPrint('PurchaseService: Initialization error - $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Initialize RevenueCat for mobile platforms
  Future<void> _initializeRevenueCat(String? userId) async {
    late PurchasesConfiguration configuration;
    
    if (Platform.isIOS) {
      configuration = PurchasesConfiguration(PurchaseConfig.revenueCatAppleKey);
    } else if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(PurchaseConfig.revenueCatGoogleKey);
    } else {
      return;
    }

    if (userId != null) {
      configuration.appUserID = userId;
    }

    await Purchases.configure(configuration);
    
    // Listen for customer info updates
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);

    // Get initial customer info
    await _refreshCustomerInfo();

    // Load available packages
    await _loadPackages();
  }

  /// Start listening to Firestore for subscription status (desktop/web)
  Future<void> _startFirestoreListener(String oderId) async {
    _firestoreSubscription?.cancel();
    
    _firestoreSubscription = FirebaseFirestore.instance
        .collection('subscriptions')
        .where('userId', isEqualTo: oderId)
        .where('status', whereIn: ['active', 'trialing'])
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            _subscriptionInfo = SubscriptionInfo.fromFirestore(
              doc.data(),
              doc.id,
            );
            _updatePremiumStatus(true);
          } else {
            _subscriptionInfo = null;
            _updatePremiumStatus(false);
          }
        }, onError: (e) {
          debugPrint('PurchaseService: Firestore listener error - $e');
        });
    
    // Also check immediately
    await _checkFirestoreSubscription(oderId);
  }

  /// Check Firestore subscription status immediately
  Future<void> _checkFirestoreSubscription(String userId) async {
    try {
      // First, check the users collection (direct user document)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          final isPremium = data['isPremium'] == true;
          final status = data['subscriptionStatus'] as String?;
          
          if (isPremium || status == 'active' || status == 'trialing') {
            _subscriptionInfo = SubscriptionInfo(
              subId: userDoc.id,
              userId: userId,
              plan: data['productId'] as String? ?? 'pro_monthly',
              status: status ?? 'active',
              currentPeriodEnd: data['subscriptionEndDate'] != null
                  ? (data['subscriptionEndDate'] as Timestamp).toDate()
                  : DateTime.now().add(const Duration(days: 365)),
              cancelAtPeriodEnd: false,
            );
            _updatePremiumStatus(true);
            debugPrint('PurchaseService: Found premium status in users collection');
            return;
          }
        }
      }
      
      // Fallback: check subscriptions collection
      final snapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['active', 'trialing'])
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _subscriptionInfo = SubscriptionInfo.fromFirestore(
          doc.data(),
          doc.id,
        );
        _updatePremiumStatus(true);
        debugPrint('PurchaseService: Found premium status in subscriptions collection');
      } else {
        _subscriptionInfo = null;
        _updatePremiumStatus(false);
        debugPrint('PurchaseService: No premium status found');
      }
    } catch (e) {
      debugPrint('PurchaseService: Error checking Firestore subscription - $e');
      // On desktop, try REST API as fallback when SDK auth fails
      if (isDesktop) {
        await _checkFirestoreViaRestApi(userId);
      }
    }
  }

  /// Check Firestore using REST API (for Desktop when SDK auth fails)
  Future<void> _checkFirestoreViaRestApi(String userId) async {
    try {
      final idToken = DesktopAuthService.instance.currentIdToken;
      if (idToken == null) {
        debugPrint('PurchaseService: No idToken available for REST API');
        return;
      }

      // Firestore REST API URL
      const projectId = 'brisyn-focus';
      final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$userId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fields = data['fields'] as Map<String, dynamic>?;
        
        if (fields != null) {
          final isPremium = fields['isPremium']?['booleanValue'] == true;
          final status = fields['subscriptionStatus']?['stringValue'] as String?;
          
          debugPrint('PurchaseService: REST API - isPremium: $isPremium, status: $status');
          
          if (isPremium || status == 'active' || status == 'trialing') {
            // Parse subscriptionEndDate if present
            DateTime? endDate;
            final endDateValue = fields['subscriptionEndDate']?['timestampValue'] as String?;
            if (endDateValue != null) {
              endDate = DateTime.tryParse(endDateValue);
            }
            
            _subscriptionInfo = SubscriptionInfo(
              subId: userId,
              userId: userId,
              plan: fields['productId']?['stringValue'] as String? ?? 'pro_monthly',
              status: status ?? 'active',
              currentPeriodEnd: endDate ?? DateTime.now().add(const Duration(days: 365)),
              cancelAtPeriodEnd: false,
            );
            _updatePremiumStatus(true);
            debugPrint('PurchaseService: Found premium status via REST API');
            return;
          }
        }
      } else {
        debugPrint('PurchaseService: REST API error - ${response.statusCode}: ${response.body}');
      }
      
      _subscriptionInfo = null;
      _updatePremiumStatus(false);
    } catch (e) {
      debugPrint('PurchaseService: REST API error - $e');
    }
  }

  /// Update premium status and notify listeners
  void _updatePremiumStatus(bool isPremium) {
    if (_isPremium != isPremium) {
      _isPremium = isPremium;
      _premiumStatusController.add(_isPremium);
    }
  }

  /// Handle customer info updates (RevenueCat)
  void _onCustomerInfoUpdate(CustomerInfo info) {
    _customerInfo = info;
    final isPremium = _checkRevenueCatPremium(info);
    _updatePremiumStatus(isPremium);
  }

  /// Check if customer has premium entitlement (RevenueCat)
  bool _checkRevenueCatPremium(CustomerInfo info) {
    return info.entitlements.active.containsKey(PurchaseConfig.premiumEntitlementId);
  }

  /// Refresh customer info (RevenueCat)
  Future<void> _refreshCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      final isPremium = _checkRevenueCatPremium(_customerInfo!);
      _updatePremiumStatus(isPremium);
    } catch (e) {
      debugPrint('PurchaseService: Error refreshing customer info - $e');
    }
  }

  /// Load available packages (RevenueCat)
  Future<void> _loadPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        _packages = offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint('PurchaseService: Error loading packages - $e');
    }
  }

  /// Get monthly package (RevenueCat)
  Package? get monthlyPackage {
    try {
      return _packages.firstWhere(
        (p) => p.packageType == PackageType.monthly,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get yearly package (RevenueCat)
  Package? get yearlyPackage {
    try {
      return _packages.firstWhere(
        (p) => p.packageType == PackageType.annual,
      );
    } catch (_) {
      return null;
    }
  }

  /// Purchase subscription
  /// On mobile: Uses RevenueCat
  /// On desktop: Opens Stripe checkout in browser
  Future<PurchaseResult> purchase(String productId) async {
    final isYearly = productId.contains('yearly');
    
    if (kIsWeb) {
      return PurchaseResult.failure('Please use the desktop app to subscribe');
    }

    if (isDesktop) {
      // Desktop: Open Stripe payment link
      return await _purchaseViaStripe(isYearly: isYearly);
    }

    // Mobile: Use RevenueCat
    final package = isYearly ? yearlyPackage : monthlyPackage;
    if (package == null) {
      return PurchaseResult.failure('Package not available');
    }
    return await purchasePackage(package);
  }

  /// Purchase via Stripe (desktop)
  Future<PurchaseResult> _purchaseViaStripe({required bool isYearly}) async {
    if (_userId == null) {
      return PurchaseResult.failure('Please sign in to subscribe');
    }

    final paymentLink = isYearly 
        ? PurchaseConfig.yearlyPaymentLink 
        : PurchaseConfig.monthlyPaymentLink;
    
    // Add user ID to payment link for webhook to identify user
    final urlWithUserId = '$paymentLink?client_reference_id=$_userId';
    
    try {
      final uri = Uri.parse(urlWithUserId);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return PurchaseResult.success(null, message: 'Payment page opened. Complete your purchase in the browser.');
      } else {
        return PurchaseResult.failure('Could not open payment page');
      }
    } catch (e) {
      return PurchaseResult.failure('Error opening payment page: $e');
    }
  }

  /// Purchase a RevenueCat package (mobile)
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (kIsWeb || isDesktop) {
      return PurchaseResult.failure('Use purchase() method instead');
    }

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _onCustomerInfoUpdate(customerInfo);
      
      if (_checkRevenueCatPremium(customerInfo)) {
        return PurchaseResult.success(customerInfo);
      } else {
        return PurchaseResult.failure('Purchase completed but premium not activated');
      }
    } on PurchasesErrorCode catch (e) {
      return PurchaseResult.failure(_getErrorMessage(e));
    } catch (e) {
      return PurchaseResult.failure('Purchase failed: ${e.toString()}');
    }
  }

  /// Restore purchases
  Future<PurchaseResult> restorePurchases() async {
    if (kIsWeb) {
      return PurchaseResult.failure('Not available on web');
    }

    if (isDesktop) {
      // Desktop: Just refresh from Firestore
      if (_userId != null) {
        await _checkFirestoreSubscription(_userId!);
        if (_isPremium) {
          return PurchaseResult.success(null, message: 'Subscription restored successfully!');
        }
      }
      return PurchaseResult.failure('No active subscription found. Please sign in with your account.');
    }

    // Mobile: Use RevenueCat
    try {
      final customerInfo = await Purchases.restorePurchases();
      _onCustomerInfoUpdate(customerInfo);
      
      if (_checkRevenueCatPremium(customerInfo)) {
        return PurchaseResult.success(customerInfo, message: 'Subscription restored successfully!');
      } else {
        return PurchaseResult.failure('No active subscriptions found');
      }
    } on PurchasesErrorCode catch (e) {
      return PurchaseResult.failure(_getErrorMessage(e));
    } catch (e) {
      return PurchaseResult.failure('Restore failed: ${e.toString()}');
    }
  }

  /// Login user
  Future<void> login(String userId) async {
    _userId = userId;
    
    if (isDesktop || kIsWeb) {
      await _startFirestoreListener(userId);
      return;
    }

    // Mobile: Login to RevenueCat
    try {
      final result = await Purchases.logIn(userId);
      _onCustomerInfoUpdate(result.customerInfo);
    } catch (e) {
      debugPrint('PurchaseService: Login error - $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    _userId = null;
    _subscriptionInfo = null;
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _updatePremiumStatus(false);

    if (!isDesktop && !kIsWeb) {
      // Mobile: Logout from RevenueCat
      try {
        final customerInfo = await Purchases.logOut();
        _onCustomerInfoUpdate(customerInfo);
      } catch (e) {
        debugPrint('PurchaseService: Logout error - $e');
      }
    }
  }

  /// Get premium expiration date
  DateTime? get premiumExpirationDate {
    if (isDesktop || kIsWeb) {
      return _subscriptionInfo?.currentPeriodEnd;
    }
    
    final entitlement = _customerInfo?.entitlements.active[PurchaseConfig.premiumEntitlementId];
    if (entitlement?.expirationDate != null) {
      return DateTime.parse(entitlement!.expirationDate!);
    }
    return null;
  }

  /// Check if subscription will renew
  bool get willRenew {
    if (isDesktop || kIsWeb) {
      return _subscriptionInfo != null && !_subscriptionInfo!.cancelAtPeriodEnd;
    }
    
    final entitlement = _customerInfo?.entitlements.active[PurchaseConfig.premiumEntitlementId];
    return entitlement?.willRenew ?? false;
  }

  /// Get subscription management URL
  Future<String?> getManagementUrl() async {
    if (isDesktop || kIsWeb) {
      // For Stripe, direct to customer portal
      return 'https://billing.stripe.com/p/login/YOUR_PORTAL_LINK';
    }
    
    try {
      final info = await Purchases.getCustomerInfo();
      return info.managementURL;
    } catch (_) {
      return null;
    }
  }

  /// Refresh subscription status
  Future<void> refresh() async {
    if (_userId != null && (isDesktop || kIsWeb)) {
      await _checkFirestoreSubscription(_userId!);
    } else if (isMobileWithRevenueCat) {
      await _refreshCustomerInfo();
    }
  }

  /// Convert error code to user-friendly message
  String _getErrorMessage(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Purchase was cancelled';
      case PurchasesErrorCode.storeProblemError:
        return 'There was a problem with the store. Please try again.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are not allowed on this device';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'The purchase was invalid';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'This product is not available for purchase';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'You already own this product';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'This receipt is already in use';
      case PurchasesErrorCode.invalidReceiptError:
        return 'Invalid receipt';
      case PurchasesErrorCode.missingReceiptFileError:
        return 'Receipt file is missing';
      case PurchasesErrorCode.networkError:
        return 'Network error. Please check your connection.';
      case PurchasesErrorCode.invalidCredentialsError:
        return 'Invalid credentials';
      case PurchasesErrorCode.unexpectedBackendResponseError:
        return 'Unexpected server response';
      case PurchasesErrorCode.invalidAppUserIdError:
        return 'Invalid user ID';
      case PurchasesErrorCode.operationAlreadyInProgressError:
        return 'Operation already in progress';
      case PurchasesErrorCode.unknownBackendError:
        return 'Unknown server error';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Enable developer mode (only works in debug builds)
  /// This unlocks all premium features for testing without requiring payment
  Future<void> enableDevMode() async {
    if (kDebugMode) {
      _devModeEnabled = true;
      _premiumStatusController.add(true);
      debugPrint('PurchaseService: Developer mode enabled - All premium features unlocked');
    }
  }

  /// Disable developer mode
  Future<void> disableDevMode() async {
    _devModeEnabled = false;
    _premiumStatusController.add(_isPremium);
    debugPrint('PurchaseService: Developer mode disabled');
  }

  /// Dispose resources
  void dispose() {
    _firestoreSubscription?.cancel();
    _premiumStatusController.close();
  }
}
