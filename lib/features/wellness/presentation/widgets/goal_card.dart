import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/colors.dart';
import '../../domain/models/personal_goal.dart';
import '../providers/wellness_providers.dart';

/// Card widget for displaying a personal goal
class GoalCard extends ConsumerWidget {
  final PersonalGoal goal;
  final bool isDark;

  const GoalCard({
    super.key,
    required this.goal,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCompletedToday = goal.isCompletedToday;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompletedToday
              ? goal.color.withOpacity(0.5)
              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          width: isCompletedToday ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref
                .read(personalGoalsProvider.notifier)
                .toggleGoalCompletionToday(goal.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox/Icon
                _CheckboxIcon(
                  isCompleted: isCompletedToday,
                  color: goal.color,
                  icon: goal.icon,
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompletedToday ? TextDecoration.lineThrough : null,
                          color: isCompletedToday
                              ? (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)
                              : null,
                        ),
                      ),
                      if (goal.description != null &&
                          goal.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          goal.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Stats row
                      _GoalStats(goal: goal, isDark: isDark),
                    ],
                  ),
                ),

                // Status indicator
                if (isCompletedToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckboxIcon extends StatelessWidget {
  final bool isCompleted;
  final Color color;
  final IconData icon;

  const _CheckboxIcon({
    required this.isCompleted,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isCompleted ? color : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isCompleted ? Icons.check : icon,
        color: isCompleted ? Colors.white : color,
        size: 24,
      ),
    );
  }
}

class _GoalStats extends ConsumerWidget {
  final PersonalGoal goal;
  final bool isDark;

  const _GoalStats({required this.goal, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(wellnessRepositoryProvider);
    final completionRate = repo.getGoalCompletionRate(goal.id);
    final streak = _calculateStreak(goal);

    return Row(
      children: [
        // Streak
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 12,
                color: Colors.orange,
              ),
              const SizedBox(width: 2),
              Text(
                '$streak',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Completion rate
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: goal.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${(completionRate * 100).toInt()}% this week',
            style: theme.textTheme.labelSmall?.copyWith(
              color: goal.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  int _calculateStreak(PersonalGoal goal) {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final dateStr = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      ).toIso8601String();

      if (goal.dailyCompletions.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (i == 0) {
        // Today not completed yet, check yesterday
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
