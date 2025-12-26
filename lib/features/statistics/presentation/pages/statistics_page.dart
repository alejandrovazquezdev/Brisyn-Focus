import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Statistics',
                style: AppTypography.headlineMedium(
                  isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // Streak Card
              _StatCard(
                icon: 'assets/icons/flame.svg',
                iconColor: AppColors.streakFlame,
                title: 'Current Streak',
                value: '0',
                subtitle: 'days',
              ),

              const SizedBox(height: 16),

              // Main stats grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: 'assets/icons/timer.svg',
                      iconColor: accentColor,
                      title: 'Focus Time',
                      value: '0h',
                      subtitle: 'today',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: 'assets/icons/check-circle.svg',
                      iconColor: AppColors.success,
                      title: 'Sessions',
                      value: '0',
                      subtitle: 'completed',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: 'assets/icons/tasks.svg',
                      iconColor: AppColors.accentPurple,
                      title: 'Tasks',
                      value: '0',
                      subtitle: 'completed',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: 'assets/icons/star.svg',
                      iconColor: AppColors.xpGold,
                      title: 'Total XP',
                      value: '0',
                      subtitle: 'Level 1',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Weekly overview header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'This Week',
                    style: AppTypography.titleLarge(
                      isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: See all stats
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(color: accentColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Placeholder chart area
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/statistics.svg',
                        width: 48,
                        height: 48,
                        colorFilter: ColorFilter.mode(
                          isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start focusing to see your stats',
                        style: AppTypography.bodyMedium(
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.labelMedium(
                  isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.statValue(
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall(
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
