import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/desktop_auth_service.dart';
import '../../../../core/services/purchase_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Check if we're on desktop platform
bool get _isDesktop {
  if (kIsWeb) return false;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

enum SubscriptionPlan { monthly, yearly }

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;
  bool _isLoading = false;

  String get _planName =>
      _selectedPlan == SubscriptionPlan.yearly ? 'Yearly' : 'Monthly';

  String get _planPrice =>
      _selectedPlan == SubscriptionPlan.yearly ? '\$9.99' : '\$1.99';

  String get _planPeriod =>
      _selectedPlan == SubscriptionPlan.yearly ? '/year' : '/month';

  Future<void> _subscribe() async {
    // Check if user is logged in - use DesktopAuthService on desktop
    bool isUserLoggedIn;
    if (_isDesktop) {
      isUserLoggedIn = DesktopAuthService.instance.isLoggedIn;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      isUserLoggedIn = user != null;
    }
    
    if (!isUserLoggedIn) {
      // Show login required dialog
      await _showLoginRequiredDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use PurchaseService
      final purchaseService = PurchaseService.instance;
      final productId = _selectedPlan == SubscriptionPlan.yearly
          ? 'brisyn_pro_yearly'
          : 'brisyn_pro_monthly';

      final result = await purchaseService.purchase(productId);

      if (!mounted) return;

      if (result.success) {
        // Show success dialog
        await _showSuccessDialog();
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Purchase failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showLoginRequiredDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: AppColors.warning),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Login Required'),
            ),
          ],
        ),
        content: const Text(
          'You need to sign in to subscribe to Brisyn Pro. Your subscription will be linked to your account so you can use it across all your devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.login);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
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
        content: Text(
          'Your $_planName subscription is now active. Enjoy unlimited access to all premium features!',
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

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final purchaseService = PurchaseService.instance;
      final result = await purchaseService.restorePurchases();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Restore completed'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (result.success) {
        // Close page if restored successfully
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final isPremium = PurchaseService.instance.isPremium;

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
        actions: const [],
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

                  // Premium Features List (only 2 main features)
                  const _FeatureItem(
                    icon: 'assets/icons/cloud.svg',
                    title: 'Cloud Sync',
                    description: 'Sync your data across all devices automatically',
                  ),
                  const _FeatureItem(
                    icon: 'assets/icons/layers.svg',
                    title: 'Advanced Tasks',
                    description: 'Recurring tasks, subtasks, and Kanban view',
                  ),

                  const SizedBox(height: 32),

                  // Login warning if not logged in
                  if (!isLoggedIn) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sign in to subscribe and sync across devices',
                              style: AppTypography.bodySmall(
                                isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Show different content based on Premium status
                  if (isPremium) ...[
                    // Already Premium - show status
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.15),
                            accentColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: accentColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You\'re a Pro!',
                            style: AppTypography.titleLarge(
                              isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thank you for supporting Brisyn Focus. Enjoy all premium features!',
                            style: AppTypography.bodyMedium(
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Not Premium - show plan selection
                    // Plan Selection Cards
                    Row(
                      children: [
                        Expanded(
                          child: _PlanCard(
                            title: 'Monthly',
                            price: '\$1.99',
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
                            price: '\$9.99',
                            period: '/year',
                            isSelected: _selectedPlan == SubscriptionPlan.yearly,
                            savings: 'Save 58%',
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
                      onPressed: _isLoading ? null : _restorePurchases,
                      child: const Text('Restore Purchases'),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Subscribe Button - only show if not premium
          if (!isPremium)
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
                        onPressed: _isLoading ? null : _subscribe,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isLoggedIn
                                    ? 'Subscribe $_planName for $_planPrice$_planPeriod'
                                    : 'Sign in to Subscribe',
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
                colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
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
    this.savings,
    required this.onTap,
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
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Selected indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
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
