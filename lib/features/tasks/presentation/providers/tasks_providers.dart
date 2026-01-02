import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/task.dart';

/// Task filter options
enum TaskFilter {
  all,
  active,
  completed,
  today,
  overdue,
}

/// Task sort options
enum TaskSort {
  priority,
  dueDate,
  createdAt,
  manual,
}

/// View mode for tasks
enum TaskViewMode {
  list,
  kanban,
}

/// Tasks state
class TasksState {
  final List<Task> tasks;
  final TaskFilter filter;
  final TaskSort sort;
  final TaskViewMode viewMode;
  final bool isLoading;
  final String? error;
  final String? selectedTaskId;
  final String? expandedTaskId; // For showing subtasks

  const TasksState({
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.sort = TaskSort.priority,
    this.viewMode = TaskViewMode.list,
    this.isLoading = false,
    this.error,
    this.selectedTaskId,
    this.expandedTaskId,
  });

  TasksState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    TaskSort? sort,
    TaskViewMode? viewMode,
    bool? isLoading,
    String? error,
    String? selectedTaskId,
    String? expandedTaskId,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      expandedTaskId: expandedTaskId ?? this.expandedTaskId,
    );
  }

  /// Get parent tasks only (not subtasks)
  List<Task> get parentTasks => tasks.where((t) => !t.isSubtask).toList();

  /// Get subtasks for a specific parent
  List<Task> getSubtasks(String parentId) {
    return tasks.where((t) => t.parentTaskId == parentId).toList();
  }

  /// Get filtered and sorted tasks (parent tasks only)
  List<Task> get filteredTasks {
    List<Task> result = parentTasks;

    // Apply filter
    switch (filter) {
      case TaskFilter.all:
        break;
      case TaskFilter.active:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.today:
        result = result.where((t) => t.isDueToday).toList();
        break;
      case TaskFilter.overdue:
        result = result.where((t) => t.isOverdue).toList();
        break;
    }

    // Apply sort
    switch (sort) {
      case TaskSort.priority:
        result.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          final priorityComparison = b.priority.index.compareTo(a.priority.index);
          if (priorityComparison != 0) return priorityComparison;
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          return 0;
        });
        break;
      case TaskSort.dueDate:
        result.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSort.createdAt:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSort.manual:
        result.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        break;
    }

    return result;
  }

  /// Get tasks by Kanban status
  List<Task> getTasksByStatus(TaskStatus status) {
    return parentTasks.where((t) => t.status == status).toList();
  }

  /// Get active task count
  int get activeCount => parentTasks.where((t) => !t.isCompleted).length;

  /// Get completed task count
  int get completedCount => parentTasks.where((t) => t.isCompleted).length;

  /// Get today's tasks count
  int get todayCount => parentTasks.where((t) => t.isDueToday && !t.isCompleted).length;

  /// Get overdue count
  int get overdueCount => parentTasks.where((t) => t.isOverdue).length;

  /// Get recurring tasks count
  int get recurringCount => parentTasks.where((t) => t.isRecurring).length;

  /// Get selected task
  Task? get selectedTask {
    if (selectedTaskId == null) return null;
    try {
      return tasks.firstWhere((t) => t.id == selectedTaskId);
    } catch (_) {
      return null;
    }
  }
}

/// Tasks notifier
class TasksNotifier extends StateNotifier<TasksState> {
  static const String _boxName = 'tasks';
  late Box<Task> _box;
  final _uuid = const Uuid();
  bool _isInitialized = false;

  TasksNotifier() : super(const TasksState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      // First, try to delete any corrupted data from old schema
      // This is a one-time migration for the new Task fields
      final boxExists = await Hive.boxExists(_boxName);
      if (boxExists) {
        // Check if we need migration by trying a test open
        try {
          final testBox = await Hive.openBox<Task>(_boxName);
          // If we got here, the data is compatible
          _box = testBox;
          final tasks = _box.values.toList();
          _isInitialized = true;
          state = state.copyWith(tasks: tasks, isLoading: false);
          await _processRecurringTasks();
          return;
        } catch (e) {
          // Data is incompatible, need to migrate
          print('TasksNotifier: Clearing incompatible data for migration...');
          await Hive.deleteBoxFromDisk(_boxName);
        }
      }
      
      // Open fresh box
      _box = await Hive.openBox<Task>(_boxName);
      _isInitialized = true;
      state = state.copyWith(tasks: [], isLoading: false);
    } catch (e) {
      print('TasksNotifier: Error during init: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Ensure box is initialized before operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _init();
    }
  }

  /// Add a new task
  Future<Task> addTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    int estimatedPomodoros = 1,
    String? projectId,
    List<String>? tags,
    RecurrenceType recurrenceType = RecurrenceType.none,
  }) async {
    await _ensureInitialized();
    
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      estimatedPomodoros: estimatedPomodoros,
      projectId: projectId,
      tags: tags,
      sortOrder: state.tasks.length,
      status: TaskStatus.todo,
      recurrenceType: recurrenceType,
      lastRecurrenceDate: recurrenceType != RecurrenceType.none ? DateTime.now() : null,
    );

    await _box.put(task.id, task);
    state = state.copyWith(tasks: [...state.tasks, task]);
    return task;
  }

  /// Add a subtask to a parent task
  Future<Task> addSubtask({
    required String parentId,
    required String title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
  }) async {
    final parentTask = state.tasks.firstWhere((t) => t.id == parentId);
    
    final subtask = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority ?? parentTask.priority,
      dueDate: dueDate ?? parentTask.dueDate,
      estimatedPomodoros: 1,
      projectId: parentTask.projectId,
      tags: parentTask.tags,
      sortOrder: state.getSubtasks(parentId).length,
      status: TaskStatus.todo,
      parentTaskId: parentId,
    );

    await _box.put(subtask.id, subtask);
    state = state.copyWith(tasks: [...state.tasks, subtask]);
    return subtask;
  }

  /// Get subtasks for a parent task
  List<Task> getSubtasks(String parentId) {
    return state.tasks.where((t) => t.parentTaskId == parentId).toList();
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
    final tasks = state.tasks.map((t) => t.id == task.id ? task : t).toList();
    state = state.copyWith(tasks: tasks);
  }

  /// Update task status (for Kanban)
  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final task = state.tasks.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(
      status: newStatus,
      isCompleted: newStatus == TaskStatus.done,
    );
    await updateTask(updated);
  }

  /// Delete a task and its subtasks
  Future<void> deleteTask(String id) async {
    // Delete subtasks first
    final subtasks = getSubtasks(id);
    for (final subtask in subtasks) {
      await _box.delete(subtask.id);
    }
    
    await _box.delete(id);
    final tasks = state.tasks.where((t) => t.id != id && t.parentTaskId != id).toList();
    state = state.copyWith(
      tasks: tasks,
      selectedTaskId: state.selectedTaskId == id ? null : state.selectedTaskId,
    );
  }

  /// Toggle task completion
  Future<void> toggleComplete(String id) async {
    final task = state.tasks.firstWhere((t) => t.id == id);
    final newCompleted = !task.isCompleted;
    final updated = task.copyWith(
      isCompleted: newCompleted,
      status: newCompleted ? TaskStatus.done : TaskStatus.todo,
    );
    await updateTask(updated);
    
    // If this is a recurring task being completed, create next instance
    if (newCompleted && task.isRecurring) {
      await _createNextRecurringInstance(task);
    }
  }

  /// Toggle subtask completion and update parent progress
  Future<void> toggleSubtaskComplete(String subtaskId) async {
    final subtask = state.tasks.firstWhere((t) => t.id == subtaskId);
    final updated = subtask.copyWith(
      isCompleted: !subtask.isCompleted,
      status: !subtask.isCompleted ? TaskStatus.done : TaskStatus.todo,
    );
    await updateTask(updated);
  }

  /// Create next recurring instance
  Future<void> _createNextRecurringInstance(Task completedTask) async {
    final nextDueDate = completedTask.getNextRecurrenceDate();
    if (nextDueDate == null) return;
    
    final newTask = Task(
      id: _uuid.v4(),
      title: completedTask.title,
      description: completedTask.description,
      priority: completedTask.priority,
      dueDate: nextDueDate,
      estimatedPomodoros: completedTask.estimatedPomodoros,
      projectId: completedTask.projectId,
      tags: completedTask.tags,
      sortOrder: state.tasks.length,
      status: TaskStatus.todo,
      recurrenceType: completedTask.recurrenceType,
      recurringSourceId: completedTask.recurringSourceId ?? completedTask.id,
      lastRecurrenceDate: DateTime.now(),
    );

    await _box.put(newTask.id, newTask);
    state = state.copyWith(tasks: [...state.tasks, newTask]);
  }

  /// Process recurring tasks on startup
  Future<void> _processRecurringTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (final task in state.tasks) {
      if (!task.isRecurring || task.isCompleted) continue;
      
      // Check if we need to create a new instance
      if (task.dueDate != null && task.dueDate!.isBefore(today)) {
        final nextDate = task.getNextRecurrenceDate();
        if (nextDate != null) {
          final updated = task.copyWith(dueDate: nextDate);
          await updateTask(updated);
        }
      }
    }
  }

  /// Increment completed pomodoros
  Future<void> incrementPomodoro(String id) async {
    final task = state.tasks.firstWhere((t) => t.id == id);
    final updated = task.copyWith(
      completedPomodoros: task.completedPomodoros + 1,
    );
    await updateTask(updated);
  }

  /// Set filter
  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Set sort
  void setSort(TaskSort sort) {
    state = state.copyWith(sort: sort);
  }

  /// Set view mode
  void setViewMode(TaskViewMode viewMode) {
    state = state.copyWith(viewMode: viewMode);
  }

  /// Select task (for timer)
  void selectTask(String? id) {
    state = state.copyWith(selectedTaskId: id);
  }

  /// Toggle expanded task (for subtasks)
  void toggleExpandedTask(String? id) {
    state = state.copyWith(
      expandedTaskId: state.expandedTaskId == id ? null : id,
    );
  }

  /// Clear completed tasks
  Future<void> clearCompleted() async {
    final completedIds = state.tasks
        .where((t) => t.isCompleted)
        .map((t) => t.id)
        .toList();
    
    for (final id in completedIds) {
      await _box.delete(id);
    }
    
    final tasks = state.tasks.where((t) => !t.isCompleted).toList();
    state = state.copyWith(tasks: tasks);
  }

  /// Reorder tasks (for manual sort)
  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final tasks = List<Task>.from(state.filteredTasks);
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    // Update sort order for all tasks
    for (int i = 0; i < tasks.length; i++) {
      final updated = tasks[i].copyWith(sortOrder: i);
      await _box.put(updated.id, updated);
      tasks[i] = updated;
    }

    state = state.copyWith(tasks: tasks);
  }

  /// Move task to different Kanban column
  Future<void> moveTaskToStatus(String taskId, TaskStatus newStatus) async {
    await updateTaskStatus(taskId, newStatus);
  }

  /// Get subtask completion progress for a parent task
  double getSubtaskProgress(String parentId) {
    final subtasks = getSubtasks(parentId);
    if (subtasks.isEmpty) return 0.0;
    final completed = subtasks.where((t) => t.isCompleted).length;
    return completed / subtasks.length;
  }
}

/// Tasks provider
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier();
});

/// Selected task provider
final selectedTaskProvider = Provider<Task?>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.selectedTask;
});

/// View mode provider
final taskViewModeProvider = Provider<TaskViewMode>((ref) {
  return ref.watch(tasksProvider).viewMode;
});

/// Kanban tasks by status
final kanbanTodoProvider = Provider<List<Task>>((ref) {
  return ref.watch(tasksProvider).getTasksByStatus(TaskStatus.todo);
});

final kanbanInProgressProvider = Provider<List<Task>>((ref) {
  return ref.watch(tasksProvider).getTasksByStatus(TaskStatus.inProgress);
});

final kanbanDoneProvider = Provider<List<Task>>((ref) {
  return ref.watch(tasksProvider).getTasksByStatus(TaskStatus.done);
});

/// Subtasks provider for a specific task
final subtasksProvider = Provider.family<List<Task>, String>((ref, parentId) {
  return ref.watch(tasksProvider).getSubtasks(parentId);
});

/// Subtask progress provider
final subtaskProgressProvider = Provider.family<double, String>((ref, parentId) {
  return ref.read(tasksProvider.notifier).getSubtaskProgress(parentId);
});
