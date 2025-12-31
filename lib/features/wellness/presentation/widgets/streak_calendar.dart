import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/colors.dart';
import '../../domain/models/focus_streak.dart';
import '../providers/wellness_providers.dart';

/// A calendar widget showing focus streaks
class StreakCalendar extends ConsumerStatefulWidget {
  const StreakCalendar({super.key});

  @override
  ConsumerState<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends ConsumerState<StreakCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_currentMonth.year < now.year ||
        (_currentMonth.year == now.year && _currentMonth.month < now.month)) {
      setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final streaks = ref.watch(monthlyStreaksProvider(_currentMonth));
    final now = DateTime.now();

    // Calendar calculations
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    // Check if we can go to next month
    final canGoNext = _currentMonth.year < now.year ||
        (_currentMonth.year == now.year && _currentMonth.month < now.month);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                _formatMonth(_currentMonth),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: canGoNext ? _nextMonth : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: canGoNext ? null : Colors.grey.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: (firstWeekday + daysInMonth),
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox();
              }

              final day = index - firstWeekday + 1;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);

              // Find streak for this date
              final streak = streaks.cast<FocusStreak?>().firstWhere(
                    (s) => s!.isForDate(date),
                    orElse: () => null,
                  );

              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              final isFuture = date.isAfter(now);

              return _CalendarDay(
                day: day,
                streak: streak,
                isToday: isToday,
                isFuture: isFuture,
                isDark: isDark,
              );
            },
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: theme.colorScheme.primary,
                label: 'Goal Met',
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: Colors.orange,
                label: 'Partial',
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: isDark ? Colors.white24 : Colors.black12,
                label: 'No Activity',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final FocusStreak? streak;
  final bool isToday;
  final bool isFuture;
  final bool isDark;

  const _CalendarDay({
    required this.day,
    required this.streak,
    required this.isToday,
    required this.isFuture,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? backgroundColor;
    Color textColor;

    if (isFuture) {
      textColor = isDark ? Colors.white24 : Colors.black26;
    } else if (streak != null) {
      if (streak!.goalMet) {
        backgroundColor = theme.colorScheme.primary;
        textColor = Colors.white;
      } else if (streak!.focusMinutes > 0) {
        backgroundColor = Colors.orange;
        textColor = Colors.white;
      } else {
        textColor = isDark ? Colors.white70 : Colors.black87;
      }
    } else {
      textColor = isDark ? Colors.white70 : Colors.black87;
    }

    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: isToday
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: isToday ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
