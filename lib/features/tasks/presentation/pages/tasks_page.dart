import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../domain/models/task.dart';
import '../providers/tasks_providers.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTaskSheet(
        onAdd: (title, description, priority, dueDate, pomodoros) {
          ref.read(tasksProvider.notifier).addTask(
                title: title,
                description: description,
                priority: priority,
                dueDate: dueDate,
                estimatedPomodoros: pomodoros,
              );
        },
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTaskSheet(
        task: task,
        onAdd: (title, description, priority, dueDate, pomodoros) {
          ref.read(tasksProvider.notifier).updateTask(
                task.copyWith(
                  title: title,
                  description: description,
                  priority: priority,
                  dueDate: dueDate,
                  estimatedPomodoros: pomodoros,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    final tasksState = ref.watch(tasksProvider);
    final filteredTasks = tasksState.filteredTasks;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tasks',
                    style: AppTypography.headlineMedium(
                      isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddTaskDialog(context, ref),
                    icon: SvgPicture.asset(
                      'assets/icons/plus.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        accentColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All (${tasksState.tasks.length})',
                      isSelected: tasksState.filter == TaskFilter.all,
                      onTap: () =>
                          ref.read(tasksProvider.notifier).setFilter(TaskFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Today (${tasksState.todayCount})',
                      isSelected: tasksState.filter == TaskFilter.today,
                      onTap: () =>
                          ref.read(tasksProvider.notifier).setFilter(TaskFilter.today),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Active (${tasksState.activeCount})',
                      isSelected: tasksState.filter == TaskFilter.active,
                      onTap: () =>
                          ref.read(tasksProvider.notifier).setFilter(TaskFilter.active),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Done (${tasksState.completedCount})',
                      isSelected: tasksState.filter == TaskFilter.completed,
                      onTap: () => ref
                          .read(tasksProvider.notifier)
                          .setFilter(TaskFilter.completed),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Task list or empty state
              Expanded(
                child: tasksState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredTasks.isEmpty
                        ? _buildEmptyState(context, ref, isDark, tasksState.filter)
                        : _buildTaskList(context, ref, filteredTasks, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, bool isDark, TaskFilter filter) {
    String message;
    String subMessage;

    switch (filter) {
      case TaskFilter.all:
        message = 'No tasks yet';
        subMessage = 'Add your first task to get started';
        break;
      case TaskFilter.active:
        message = 'All tasks completed!';
        subMessage = 'Great job! Add more tasks when ready';
        break;
      case TaskFilter.completed:
        message = 'No completed tasks';
        subMessage = 'Complete some tasks to see them here';
        break;
      case TaskFilter.today:
        message = 'No tasks for today';
        subMessage = 'Enjoy your free time or add tasks';
        break;
      case TaskFilter.overdue:
        message = 'No overdue tasks';
        subMessage = 'You\'re on track!';
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/check-circle.svg',
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTypography.titleLarge(
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: AppTypography.bodyMedium(
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (filter == TaskFilter.all || filter == TaskFilter.active)
            ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(context, ref),
              icon: SvgPicture.asset(
                'assets/icons/plus.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text('Add Task'),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
      BuildContext context, WidgetRef ref, List<Task> tasks, bool isDark) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TaskItem(
          task: task,
          onToggle: () => ref.read(tasksProvider.notifier).toggleComplete(task.id),
          onEdit: () => _showEditTaskDialog(context, ref, task),
          onDelete: () => ref.read(tasksProvider.notifier).deleteTask(task.id),
          onSelect: () => ref.read(tasksProvider.notifier).selectTask(task.id),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSelect;

  const _TaskItem({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSelect,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(task.priority);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SvgPicture.asset(
          'assets/icons/delete.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            AppColors.error,
            BlendMode.srcIn,
          ),
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onSelect,
        onLongPress: onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? theme.colorScheme.primary
                          : priorityColor,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted
                            ? (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                        decoration:
                            task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.description != null && task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description!,
                          style: AppTypography.bodySmall(
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Pomodoro counter
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/timer.svg',
                                width: 12,
                                height: 12,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.completedPomodoros}/${task.estimatedPomodoros}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Due date
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: task.isOverdue
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : (isDark
                                      ? AppColors.darkBackground
                                      : AppColors.lightBackground),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/calendar.svg',
                                  width: 12,
                                  height: 12,
                                  colorFilter: ColorFilter.mode(
                                    task.isOverdue
                                        ? AppColors.error
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat.MMMd().format(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.isOverdue
                                        ? AppColors.error
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Edit button
              IconButton(
                onPressed: onEdit,
                icon: SvgPicture.asset(
                  'assets/icons/edit.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                    BlendMode.srcIn,
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

/// Add/Edit Task Sheet
class _AddTaskSheet extends StatefulWidget {
  final Task? task;
  final void Function(
    String title,
    String? description,
    TaskPriority priority,
    DateTime? dueDate,
    int pomodoros,
  ) onAdd;

  const _AddTaskSheet({
    this.task,
    required this.onAdd,
  });

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _priority;
  DateTime? _dueDate;
  late int _pomodoros;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
    _pomodoros = widget.task?.estimatedPomodoros ?? 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.task != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
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
              isEditing ? 'Edit Task' : 'Add Task',
              style: AppTypography.titleLarge(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Task title field
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task title',
                hintText: 'What do you need to do?',
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add more details...',
              ),
            ),
            const SizedBox(height: 24),

            // Priority selector
            Text(
              'Priority',
              style: AppTypography.labelLarge(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((priority) {
                final isSelected = _priority == priority;
                Color color;
                switch (priority) {
                  case TaskPriority.high:
                    color = AppColors.error;
                    break;
                  case TaskPriority.medium:
                    color = AppColors.warning;
                    break;
                  case TaskPriority.low:
                    color = AppColors.success;
                    break;
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = priority),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          priority.name[0].toUpperCase() +
                              priority.name.substring(1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? color
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Due date and pomodoros row
            Row(
              children: [
                // Due date
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/calendar.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _dueDate != null
                                ? DateFormat.MMMd().format(_dueDate!)
                                : 'Due date',
                            style: TextStyle(
                              color: _dueDate != null
                                  ? (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary)
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            ),
                          ),
                          if (_dueDate != null) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() => _dueDate = null),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Pomodoro count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _pomodoros > 1
                            ? () => setState(() => _pomodoros--)
                            : null,
                        icon: const Icon(Icons.remove, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/timer.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_pomodoros',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _pomodoros < 10
                            ? () => setState(() => _pomodoros++)
                            : null,
                        icon: const Icon(Icons.add, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _titleController.text.trim().isEmpty
                    ? null
                    : () {
                        widget.onAdd(
                          _titleController.text.trim(),
                          _descriptionController.text.trim().isEmpty
                              ? null
                              : _descriptionController.text.trim(),
                          _priority,
                          _dueDate,
                          _pomodoros,
                        );
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Save Changes' : 'Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
