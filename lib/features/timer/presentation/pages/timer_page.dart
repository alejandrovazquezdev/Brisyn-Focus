import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../providers/timer_providers.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showTimerSettings() {
    final timerState = ref.read(timerProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimerSettingsSheet(
        initialFocusDuration: timerState.focusDuration,
        initialShortBreak: timerState.shortBreakDuration,
        initialLongBreak: timerState.longBreakDuration,
        initialSessions: timerState.totalSessions,
        autoStartBreaks: timerState.autoStartBreaks,
        autoStartFocus: timerState.autoStartFocus,
        onSave: ({
          required int focus,
          required int shortBreak,
          required int longBreak,
          required int sessions,
          required bool autoBreaks,
          required bool autoFocus,
        }) {
          final notifier = ref.read(timerProvider.notifier);
          notifier.setFocusDuration(focus);
          notifier.setShortBreakDuration(shortBreak);
          notifier.setLongBreakDuration(longBreak);
          notifier.setTotalSessions(sessions);
          if (autoBreaks != timerState.autoStartBreaks) {
            notifier.toggleAutoStartBreaks();
          }
          if (autoFocus != timerState.autoStartFocus) {
            notifier.toggleAutoStartFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    final timerState = ref.watch(timerProvider);
    final isRunning = timerState.status == TimerStatus.running;

    // Get phase color
    Color phaseColor;
    switch (timerState.phase) {
      case TimerPhase.focus:
        phaseColor = accentColor;
        break;
      case TimerPhase.shortBreak:
        phaseColor = AppColors.success;
        break;
      case TimerPhase.longBreak:
        phaseColor = AppColors.info;
        break;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 48,
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Focus Timer',
                      style: AppTypography.headlineMedium(
                        isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: _showTimerSettings,
                      icon: SvgPicture.asset(
                        'assets/icons/settings.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Phase Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PhaseTab(
                    label: 'Focus',
                    isSelected: timerState.phase == TimerPhase.focus,
                    onTap: () => ref
                        .read(timerProvider.notifier)
                        .switchToPhase(TimerPhase.focus),
                  ),
                  const SizedBox(width: 8),
                  _PhaseTab(
                    label: 'Short Break',
                    isSelected: timerState.phase == TimerPhase.shortBreak,
                    onTap: () => ref
                        .read(timerProvider.notifier)
                        .switchToPhase(TimerPhase.shortBreak),
                  ),
                  const SizedBox(width: 8),
                  _PhaseTab(
                    label: 'Long Break',
                    isSelected: timerState.phase == TimerPhase.longBreak,
                    onTap: () => ref
                        .read(timerProvider.notifier)
                        .switchToPhase(TimerPhase.longBreak),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Timer Display with Progress Ring
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = isRunning
                      ? 1.0 + (_pulseController.value * 0.02)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: phaseColor.withValues(alpha: 0.15),
                            width: 12,
                          ),
                        ),
                      ),
                      // Progress ring
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(
                          painter: _ProgressRingPainter(
                            progress: timerState.progress,
                            color: phaseColor,
                            strokeWidth: 12,
                          ),
                        ),
                      ),
                      // Time display
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timerState.formattedTime,
                            style: AppTypography.timerDisplay(
                              isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: phaseColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              timerState.phaseLabel,
                              style: AppTypography.timerLabel(phaseColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Session Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  timerState.totalSessions,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < timerState.currentSession
                          ? phaseColor
                          : phaseColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Session ${timerState.currentSession} of ${timerState.totalSessions}',
                style: AppTypography.bodyMedium(
                  isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Timer Presets (only show when idle and in focus mode)
              if (timerState.phase == TimerPhase.focus &&
                  timerState.status == TimerStatus.idle)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [15, 25, 50, 90].map((minutes) {
                        final isSelected = timerState.focusDuration == minutes;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _PresetChip(
                            label: '$minutes min',
                            isSelected: isSelected,
                            onTap: () =>
                                ref.read(timerProvider.notifier).applyPreset(minutes),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton(
                    onPressed: () => ref.read(timerProvider.notifier).reset(),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/reset.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Play/Pause Button
                  ElevatedButton(
                    onPressed: () => ref.read(timerProvider.notifier).toggle(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: phaseColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          isRunning
                              ? 'assets/icons/pause.svg'
                              : 'assets/icons/play.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isRunning ? 'Pause' : 'Start',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Skip Button
                  IconButton(
                    onPressed: () => ref.read(timerProvider.notifier).skip(),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/chevron-right.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),

              // Daily Stats
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/flame.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        phaseColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today: ${timerState.dailyFocusMinutes} min',
                      style: AppTypography.bodyMedium(
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${timerState.dailySessionsCompleted} sessions',
                      style: AppTypography.bodySmall(
                        isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

/// Phase tab widget
class _PhaseTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhaseTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}

/// Preset chip widget
class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isSelected,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? accentColor
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for progress ring
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw progress arc (starting from top, going clockwise)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Timer settings bottom sheet
class _TimerSettingsSheet extends StatefulWidget {
  final int initialFocusDuration;
  final int initialShortBreak;
  final int initialLongBreak;
  final int initialSessions;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final void Function({
    required int focus,
    required int shortBreak,
    required int longBreak,
    required int sessions,
    required bool autoBreaks,
    required bool autoFocus,
  }) onSave;

  const _TimerSettingsSheet({
    required this.initialFocusDuration,
    required this.initialShortBreak,
    required this.initialLongBreak,
    required this.initialSessions,
    required this.autoStartBreaks,
    required this.autoStartFocus,
    required this.onSave,
  });

  @override
  State<_TimerSettingsSheet> createState() => _TimerSettingsSheetState();
}

class _TimerSettingsSheetState extends State<_TimerSettingsSheet> {
  late int _focus;
  late int _shortBreak;
  late int _longBreak;
  late int _sessions;
  late bool _autoBreaks;
  late bool _autoFocus;

  @override
  void initState() {
    super.initState();
    _focus = widget.initialFocusDuration;
    _shortBreak = widget.initialShortBreak;
    _longBreak = widget.initialLongBreak;
    _sessions = widget.initialSessions;
    _autoBreaks = widget.autoStartBreaks;
    _autoFocus = widget.autoStartFocus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Timer Settings',
              style: AppTypography.titleLarge(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 24),

          // Focus Duration
          _SettingRow(
            label: 'Focus Duration',
            value: '$_focus min',
            onDecrease: () {
              if (_focus > 5) setState(() => _focus -= 5);
            },
            onIncrease: () {
              if (_focus < 120) setState(() => _focus += 5);
            },
          ),

          // Short Break
          _SettingRow(
            label: 'Short Break',
            value: '$_shortBreak min',
            onDecrease: () {
              if (_shortBreak > 1) setState(() => _shortBreak--);
            },
            onIncrease: () {
              if (_shortBreak < 30) setState(() => _shortBreak++);
            },
          ),

          // Long Break
          _SettingRow(
            label: 'Long Break',
            value: '$_longBreak min',
            onDecrease: () {
              if (_longBreak > 5) setState(() => _longBreak -= 5);
            },
            onIncrease: () {
              if (_longBreak < 60) setState(() => _longBreak += 5);
            },
          ),

          // Sessions
          _SettingRow(
            label: 'Sessions before long break',
            value: '$_sessions',
            onDecrease: () {
              if (_sessions > 2) setState(() => _sessions--);
            },
            onIncrease: () {
              if (_sessions < 8) setState(() => _sessions++);
            },
          ),

          const Divider(height: 32),

          // Auto-start toggles
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Auto-start breaks',
              style: AppTypography.bodyMedium(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            value: _autoBreaks,
            onChanged: (value) => setState(() => _autoBreaks = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Auto-start focus sessions',
              style: AppTypography.bodyMedium(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            value: _autoFocus,
            onChanged: (value) => setState(() => _autoFocus = value),
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(
                  focus: _focus,
                  shortBreak: _shortBreak,
                  longBreak: _longBreak,
                  sessions: _sessions,
                  autoBreaks: _autoBreaks,
                  autoFocus: _autoFocus,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Settings'),
            ),
          ),

          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16),
        ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _SettingRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 24,
          ),
          SizedBox(
            width: 60,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium(
                theme.colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}
