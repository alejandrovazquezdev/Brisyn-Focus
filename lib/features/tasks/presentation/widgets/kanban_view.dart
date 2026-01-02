import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../domain/models/task.dart';
import '../providers/tasks_providers.dart';

/// Kanban board view for tasks with drag-and-drop support
class KanbanView extends ConsumerWidget {
  const KanbanView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - 48) / 3;
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KanbanColumn(
                title: 'To Do',
                status: TaskStatus.todo,
                width: columnWidth.clamp(200, 350),
                color: AppColors.warning,
              ),
              const SizedBox(width: 16),
              _KanbanColumn(
                title: 'In Progress',
                status: TaskStatus.inProgress,
                width: columnWidth.clamp(200, 350),
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              _KanbanColumn(
                title: 'Done',
                status: TaskStatus.done,
                width: columnWidth.clamp(200, 350),
                color: AppColors.success,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  final String title;
  final TaskStatus status;
  final double width;
  final Color color;

  const _KanbanColumn({
    required this.title,
    required this.status,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tasksState = ref.watch(tasksProvider);
    final tasks = tasksState.getTasksByStatus(status);

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        ref.read(tasksProvider.notifier).updateTaskStatus(details.data.id, status);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          decoration: BoxDecoration(
            color: isHighlighted
                ? color.withValues(alpha: 0.1)
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted
                  ? color
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Column header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: AppTypography.titleSmall(
                            isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tasks list
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 300,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _KanbanCard(
                      task: tasks[index],
                      color: color,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanCard extends ConsumerWidget {
  final Task task;
  final Color color;

  const _KanbanCard({
    required this.task,
    required this.color,
  });

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(task.priority);
    final subtasks = ref.watch(subtasksProvider(task.id));
    final subtaskProgress = subtasks.isEmpty 
        ? 0.0 
        : subtasks.where((t) => t.isCompleted).length / subtasks.length;

    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            task.title,
            style: AppTypography.bodyMedium(
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(context, ref, isDark, priorityColor, subtasks, subtaskProgress),
      ),
      child: _buildCard(context, ref, isDark, priorityColor, subtasks, subtaskProgress),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color priorityColor,
    List<Task> subtasks,
    double subtaskProgress,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => ref.read(tasksProvider.notifier).selectTask(task.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority indicator and title
            Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: task.isCompleted
                          ? (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary)
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Subtasks progress (if any)
            if (subtasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: subtaskProgress,
                        backgroundColor: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${subtasks.where((t) => t.isCompleted).length}/${subtasks.length}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ],

            // Meta info
            const SizedBox(height: 12),
            Row(
              children: [
                // Pomodoros
                if (task.estimatedPomodoros > 0) ...[
                  SvgPicture.asset(
                    'assets/icons/timer.svg',
                    width: 12,
                    height: 12,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.completedPomodoros}/${task.estimatedPomodoros}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Recurring indicator
                if (task.isRecurring) ...[
                  Icon(
                    Icons.repeat,
                    size: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 12),
                ],

                // Due date
                if (task.dueDate != null) ...[
                  SvgPicture.asset(
                    'assets/icons/calendar.svg',
                    width: 12,
                    height: 12,
                    colorFilter: ColorFilter.mode(
                      task.isOverdue
                          ? AppColors.error
                          : (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDueDate(task.dueDate!),
                    style: TextStyle(
                      fontSize: 11,
                      color: task.isOverdue
                          ? AppColors.error
                          : (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
