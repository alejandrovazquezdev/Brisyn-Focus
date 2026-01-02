import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../domain/models/task.dart';
import '../providers/tasks_providers.dart';

/// Widget for displaying and managing subtasks
class SubtasksList extends ConsumerStatefulWidget {
  final String parentTaskId;
  final bool canAdd;

  const SubtasksList({
    super.key,
    required this.parentTaskId,
    this.canAdd = true,
  });

  @override
  ConsumerState<SubtasksList> createState() => _SubtasksListState();
}

class _SubtasksListState extends ConsumerState<SubtasksList> {
  final _controller = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    ref.read(tasksProvider.notifier).addSubtask(
          parentId: widget.parentTaskId,
          title: title,
        );

    _controller.clear();
    setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtasks = ref.watch(subtasksProvider(widget.parentTaskId));
    final progress = subtasks.isEmpty
        ? 0.0
        : subtasks.where((t) => t.isCompleted).length / subtasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with progress
        Row(
          children: [
            Text(
              'Subtasks',
              style: AppTypography.labelLarge(
                isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(width: 8),
            if (subtasks.isNotEmpty) ...[
              Text(
                '${subtasks.where((t) => t.isCompleted).length}/${subtasks.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const Spacer(),
            if (widget.canAdd && !_isAdding)
              IconButton(
                onPressed: () => setState(() => _isAdding = true),
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),

        // Progress bar
        if (subtasks.isNotEmpty) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              minHeight: 6,
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Subtasks list
        ...subtasks.map((subtask) => _SubtaskItem(
              subtask: subtask,
              onToggle: () =>
                  ref.read(tasksProvider.notifier).toggleSubtaskComplete(subtask.id),
              onDelete: () =>
                  ref.read(tasksProvider.notifier).deleteTask(subtask.id),
            )),

        // Add subtask input
        if (_isAdding) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Add subtask...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addSubtask,
                icon: Icon(
                  Icons.check,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {
                  _controller.clear();
                  setState(() => _isAdding = false);
                },
                icon: Icon(
                  Icons.close,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ],

        // Empty state
        if (subtasks.isEmpty && !_isAdding)
          GestureDetector(
            onTap: widget.canAdd ? () => setState(() => _isAdding = true) : null,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add subtask',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SubtaskItem extends StatelessWidget {
  final Task subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubtaskItem({
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(subtask.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline,
          size: 18,
          color: AppColors.error,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: subtask.isCompleted
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: subtask.isCompleted
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 2,
                  ),
                ),
                child: subtask.isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),

              // Title
              Expanded(
                child: Text(
                  subtask.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtask.isCompleted
                        ? (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary)
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                    decoration:
                        subtask.isCompleted ? TextDecoration.lineThrough : null,
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
