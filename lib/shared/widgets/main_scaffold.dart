import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/colors.dart';

/// Current navigation index provider
final currentNavIndexProvider = StateProvider<int>((ref) => 0);

/// Main scaffold with bottom navigation
class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: 'assets/icons/timer.svg',
                  label: 'Timer',
                  isSelected: currentIndex == 0,
                  onTap: () {
                    ref.read(currentNavIndexProvider.notifier).state = 0;
                    context.go(AppRoutes.timer);
                  },
                ),
                _NavItem(
                  icon: 'assets/icons/check-circle.svg',
                  label: 'Tasks',
                  isSelected: currentIndex == 1,
                  onTap: () {
                    ref.read(currentNavIndexProvider.notifier).state = 1;
                    context.go(AppRoutes.tasks);
                  },
                ),
                _NavItem(
                  icon: 'assets/icons/statistics.svg',
                  label: 'Stats',
                  isSelected: currentIndex == 2,
                  onTap: () {
                    ref.read(currentNavIndexProvider.notifier).state = 2;
                    context.go(AppRoutes.statistics);
                  },
                ),
                _NavItem(
                  icon: 'assets/icons/settings.svg',
                  label: 'Settings',
                  isSelected: currentIndex == 3,
                  onTap: () {
                    ref.read(currentNavIndexProvider.notifier).state = 3;
                    context.go(AppRoutes.settings);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    final color = isSelected
        ? accentColor
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
