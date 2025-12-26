import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pro Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.7)],
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
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Unlock Your Full Potential',
              style: AppTypography.headlineSmall(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
              title: 'Advanced Tasks',
              description: 'Recurring tasks, subtasks, and Kanban view',
            ),
            _FeatureItem(
              icon: 'assets/icons/notification.svg',
              title: 'Smart Reminders',
              description: 'AI-powered optimal focus time suggestions',
            ),
            _FeatureItem(
              icon: 'assets/icons/trophy.svg',
              title: 'Leaderboards & Challenges',
              description: 'Compete with friends and complete weekly challenges',
            ),

            const SizedBox(height: 32),

            // Pricing Cards
            Row(
              children: [
                Expanded(
                  child: _PricingCard(
                    title: 'Monthly',
                    price: '\$4.99',
                    period: '/month',
                    isPopular: false,
                    onTap: () {
                      // TODO: Handle monthly subscription
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PricingCard(
                    title: 'Yearly',
                    price: '\$39.99',
                    period: '/year',
                    isPopular: true,
                    savings: 'Save 33%',
                    onTap: () {
                      // TODO: Handle yearly subscription
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () {
                // TODO: Restore purchases
              },
              child: const Text('Restore Purchases'),
            ),

            const SizedBox(height: 16),

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
              color: accentColor.withOpacity(0.1),
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

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool isPopular;
  final String? savings;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isPopular,
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPopular
              ? accentColor.withOpacity(0.1)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular
                ? accentColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Most Popular',
                  style: AppTypography.labelSmall(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
            ],
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
              const SizedBox(height: 4),
              Text(
                savings!,
                style: AppTypography.labelSmall(AppColors.success),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
