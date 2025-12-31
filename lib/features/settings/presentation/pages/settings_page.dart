import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../premium/presentation/providers/premium_providers.dart' hide isPremiumProvider;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    final themeMode = ref.watch(themeModeProvider);

    // Auth state
    final currentUser = ref.watch(currentUserProvider);
    final isLoggedIn = currentUser != null;

    // Premium state
    final isPremium = ref.watch(isPremiumProvider);

    // Sync state
    final syncStatus = ref.watch(syncStatusProvider);
    final lastSyncTime = ref.watch(lastSyncTimeProvider);

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

              // Account Section (if logged in)
              if (isLoggedIn) ...[
                _AccountCard(
                  user: currentUser,
                  isPremium: isPremium,
                  onTap: () {
                    // Could navigate to account details page
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Premium Banner (only show if not premium)
              if (!isPremium) ...[
                _PremiumBanner(
                  onUpgrade: () => context.push(AppRoutes.premium),
                ),
                const SizedBox(height: 24),
              ] else ...[
                // Cloud Sync Status Card
                _SyncStatusCard(
                  syncStatus: syncStatus,
                  lastSyncTime: lastSyncTime,
                  onSyncTap: () async {
                    // Trigger manual sync
                    // TODO: Implement sync trigger
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Account Section (if not logged in)
              if (!isLoggedIn) ...[
                _SectionHeader(title: 'Account'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: 'assets/icons/profile.svg',
                      title: 'Sign In',
                      subtitle: 'Sync your data across devices',
                      onTap: () => context.push(AppRoutes.login),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

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

              // Wellness Section
              _SectionHeader(title: 'Wellness'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: 'assets/icons/zap.svg',
                    title: 'Wellness Dashboard',
                    subtitle: 'Streaks, goals & habits',
                    onTap: () => context.push(AppRoutes.wellness),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Premium Section (if premium)
              if (isPremium) ...[
                _SectionHeader(title: 'Premium'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: 'assets/icons/zap.svg',
                      title: 'Manage Subscription',
                      onTap: () => context.push(AppRoutes.premium),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // About Section
              _SectionHeader(title: 'About'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: 'assets/icons/shield.svg',
                    title: 'Privacy Policy',
                    onTap: () async {
                      final url = Uri.parse(AppConstants.privacyPolicyUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: 'assets/icons/info.svg',
                    title: 'Terms of Service',
                    onTap: () async {
                      final url = Uri.parse(AppConstants.termsOfServiceUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: 'assets/icons/email.svg',
                    title: 'Contact Support',
                    onTap: () async {
                      final url = Uri.parse('mailto:${AppConstants.supportEmail}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: 'assets/icons/info.svg',
                    title: 'Version',
                    trailing: Text(
                      AppConstants.appVersion,
                      style: AppTypography.bodyMedium(
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              // Sign Out Button (if logged in)
              if (isLoggedIn) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showSignOutDialog(context, ref),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) {
        context.go(AppRoutes.timer);
      }
    }
  }
}

class _AccountCard extends StatelessWidget {
  final dynamic user;
  final bool isPremium;
  final VoidCallback? onTap;

  const _AccountCard({
    required this.user,
    required this.isPremium,
    this.onTap,
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
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: accentColor.withValues(alpha: 0.1),
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      (user?.displayName?.isNotEmpty == true
                              ? user!.displayName![0]
                              : user?.email?[0] ?? '?')
                          .toUpperCase(),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'User',
                    style: AppTypography.titleMedium(
                      isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: AppTypography.bodySmall(
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Premium Badge
            if (isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'PRO',
                      style: AppTypography.labelSmall(Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _PremiumBanner({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Container(
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
                  'Unlock all features & cloud sync',
                  style: AppTypography.bodyMedium(
                    Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: accentColor,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  final SyncStatus syncStatus;
  final DateTime? lastSyncTime;
  final VoidCallback? onSyncTap;

  const _SyncStatusCard({
    required this.syncStatus,
    this.lastSyncTime,
    this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    String statusText;
    IconData statusIcon;
    Color statusColor;

    switch (syncStatus) {
      case SyncStatus.syncing:
        statusText = 'Syncing...';
        statusIcon = Icons.sync;
        statusColor = accentColor;
        break;
      case SyncStatus.synced:
        statusText = lastSyncTime != null
            ? 'Synced ${_formatSyncTime(lastSyncTime!)}'
            : 'Synced';
        statusIcon = Icons.cloud_done;
        statusColor = AppColors.success;
        break;
      case SyncStatus.error:
        statusText = 'Sync failed';
        statusIcon = Icons.cloud_off;
        statusColor = AppColors.error;
      case SyncStatus.offline:
        statusText = 'Offline';
        statusIcon = Icons.cloud_off;
        statusColor = AppColors.warning;
      case SyncStatus.idle:
        statusText = 'Cloud sync enabled';
        statusIcon = Icons.cloud_queue;
        statusColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: syncStatus == SyncStatus.syncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  )
                : Icon(statusIcon, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cloud Sync',
                  style: AppTypography.titleSmall(
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  statusText,
                  style: AppTypography.bodySmall(statusColor),
                ),
              ],
            ),
          ),
          if (syncStatus != SyncStatus.syncing)
            IconButton(
              onPressed: onSyncTap,
              icon: Icon(
                Icons.refresh,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
        ],
      ),
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
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
