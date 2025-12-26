import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../shared/providers/app_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: AppTypography.headlineMedium(
                  isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // Premium Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brisyn Pro',
                            style: AppTypography.titleLarge(Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Unlock all features',
                            style: AppTypography.bodyMedium(
                              Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.premium);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: accentColor,
                      ),
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Appearance Section
              _SectionHeader(title: 'Appearance'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: 'assets/icons/moon.svg',
                    title: 'Theme',
                    trailing: DropdownButton<ThemeMode>(
                      value: themeMode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(value);
                        }
                      },
                    ),
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: 'assets/icons/target.svg',
                    title: 'Accent Color',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: AppColors.accentOptions
                          .take(4)
                          .map(
                            (color) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: GestureDetector(
                                onTap: () {
                                  ref
                                      .read(accentColorProvider.notifier)
                                      .setAccentColor(color);
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: accentColor == color
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Timer Section
              _SectionHeader(title: 'Timer'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: 'assets/icons/timer.svg',
                    title: 'Focus Duration',
                    subtitle: '25 minutes',
                    onTap: () {
                      // TODO: Open duration picker
                    },
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: 'assets/icons/break.svg',
                    title: 'Short Break',
                    subtitle: '5 minutes',
                    onTap: () {},
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: 'assets/icons/break.svg',
                    title: 'Long Break',
                    subtitle: '15 minutes',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // About Section
              _SectionHeader(title: 'About'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: 'assets/icons/shield.svg',
                    title: 'Privacy Policy',
                    onTap: () {
                      // TODO: Open privacy policy
                    },
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: 'assets/icons/info.svg',
                    title: 'Version',
                    trailing: Text(
                      '1.0.0',
                      style: AppTypography.bodyMedium(
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      title,
      style: AppTypography.titleMedium(
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: SvgPicture.asset(
        icon,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge(
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodySmall(
                isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? SvgPicture.asset(
                  'assets/icons/chevron-right.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                    BlendMode.srcIn,
                  ),
                )
              : null),
      onTap: onTap,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
    );
  }
}
