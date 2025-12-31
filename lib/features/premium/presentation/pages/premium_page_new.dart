import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../providers/premium_providers.dart';

enum SubscriptionPlan { monthly, yearly }

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;

  String _getPlanPrice(Package? monthly, Package? yearly) {
    if (_selectedPlan == SubscriptionPlan.yearly) {
      return yearly?.storeProduct.priceString ?? '\$39.99';
    }
    return monthly?.storeProduct.priceString ?? '\$4.99';
  }

  String get _planPeriod =>
      _selectedPlan == SubscriptionPlan.yearly ? '/year' : '/month';

  String get _planName =>
      _selectedPlan == SubscriptionPlan.yearly ? 'Yearly' : 'Monthly';

  Future<void> _subscribe() async {
    final notifier = ref.read(purchaseNotifierProvider.notifier);

    bool success;
    if (_selectedPlan == SubscriptionPlan.yearly) {
      success = await notifier.purchaseYearly();
    } else {
      success = await notifier.purchaseMonthly();
    }

    if (!mounted) return;

    if (success) {
      await _showSuccessDialog();
    }
  }

  Future<void> _restorePurchases() async {
    final notifier = ref.read(purchaseNotifierProvider.notifier);
    final success = await notifier.restorePurchases();

    if (!mounted) return;

    if (success) {
      await _showSuccessDialog();
    } else {
      final error = ref.read(purchaseNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'No previous purchases found'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            const Text('Welcome to Pro!'),
          ],
        ),
        content: const Text(
          'Your subscription is now active. Enjoy unlimited access to all premium features!',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to settings
            },
            child: const Text('Let\'s Go!'),
          ),
        ],
      ),
    );
  }

  Future<void> _manageSubscription() async {
    final url = await ref.read(purchaseServiceProvider).getManagementUrl();
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    // Watch providers
    final isPremium = ref.watch(isPremiumProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final monthlyPackage = ref.watch(monthlyPackageProvider);
    final yearlyPackage = ref.watch(yearlyPackageProvider);
    final expirationDate = ref.watch(premiumExpirationProvider);
    final willRenew = ref.watch(willRenewProvider);

    // Listen for errors
    ref.listen<PurchaseState>(purchaseNotifierProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // If already premium, show management screen
    if (isPremium) {
      return _buildPremiumActiveScreen(
        context,
        isDark,
        accentColor,
        expirationDate,
        willRenew,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brisyn Pro'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pro Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/zap.svg',
                        width: 40,
                        height: 40,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Unlock Your Full Potential',
                    style: AppTypography.headlineSmall(
                      isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Get the most out of Brisyn Focus with Pro features',
                    style: AppTypography.bodyMedium(
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Features List
                  _FeatureItem(
                    icon: 'assets/icons/cloud.svg',
                    title: 'Cloud Sync',
                    description: 'Sync your data across all devices',
                  ),
                  _FeatureItem(
                    icon: 'assets/icons/statistics.svg',
                    title: 'Advanced Analytics',
                    description: 'Detailed reports and productivity insights',
                  ),
                  _FeatureItem(
                    icon: 'assets/icons/layers.svg',
                    title: 'Unlimited Categories',
                    description: 'Create as many activity categories as you want',
                  ),
                  _FeatureItem(
                    icon: 'assets/icons/notification.svg',
                    title: 'Smart Reminders',
                    description: 'AI-powered optimal focus time suggestions',
                  ),
                  _FeatureItem(
                    icon: 'assets/icons/trophy.svg',
                    title: 'Priority Support',
                    description: 'Get help when you need it',
                  ),

                  const SizedBox(height: 32),

                  // Plan Selection Cards
                  Row(
                    children: [
                      Expanded(
                        child: _PlanCard(
                          title: 'Monthly',
                          price: monthlyPackage?.storeProduct.priceString ?? '\$4.99',
                          period: '/month',
                          isSelected: _selectedPlan == SubscriptionPlan.monthly,
                          onTap: () {
                            setState(
                              () => _selectedPlan = SubscriptionPlan.monthly,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _PlanCard(
                          title: 'Yearly',
                          price: yearlyPackage?.storeProduct.priceString ?? '\$39.99',
                          period: '/year',
                          isSelected: _selectedPlan == SubscriptionPlan.yearly,
                          savings: 'Save 33%',
                          onTap: () {
                            setState(
                              () => _selectedPlan = SubscriptionPlan.yearly,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: purchaseState.isLoading ? null : _restorePurchases,
                    child: const Text('Restore Purchases'),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Subscribe Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: purchaseState.isLoading ? null : _subscribe,
                      child: purchaseState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Subscribe $_planName for ${_getPlanPrice(monthlyPackage, yearlyPackage)}$_planPeriod',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cancel anytime. Subscriptions automatically renew unless cancelled.',
                    style: AppTypography.bodySmall(
                      isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActiveScreen(
    BuildContext context,
    bool isDark,
    Color accentColor,
    DateTime? expirationDate,
    bool willRenew,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brisyn Pro'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'You\'re a Pro!',
              style: AppTypography.headlineMedium(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Thank you for supporting Brisyn Focus',
              style: AppTypography.bodyMedium(
                isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Subscription Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Status',
                    style: AppTypography.titleMedium(
                      isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _InfoRow(
                    label: 'Status',
                    value: 'Active',
                    valueColor: AppColors.success,
                  ),

                  if (expirationDate != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: willRenew ? 'Renews on' : 'Expires on',
                      value: _formatDate(expirationDate),
                    ),
                  ],

                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Auto-renew',
                    value: willRenew ? 'Enabled' : 'Disabled',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Features enabled
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        'Premium Features Unlocked',
                        style: AppTypography.titleSmall(accentColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PremiumFeature('Cloud sync across all devices'),
                  _PremiumFeature('Advanced analytics & insights'),
                  _PremiumFeature('Unlimited categories'),
                  _PremiumFeature('Smart reminders'),
                  _PremiumFeature('Priority support'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Manage Subscription Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _manageSubscription,
                child: const Text('Manage Subscription'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  accentColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall(
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall(
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool isSelected;
  final String? savings;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isSelected,
    required this.onTap,
    this.savings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.1)
              : isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall(
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.titleMedium(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTypography.headlineSmall(
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  period,
                  style: AppTypography.bodySmall(
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            if (savings != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  savings!,
                  style: AppTypography.labelSmall(AppColors.success),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium(
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.titleSmall(
            valueColor ??
                (isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  final String text;

  const _PremiumFeature(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium(
                isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
