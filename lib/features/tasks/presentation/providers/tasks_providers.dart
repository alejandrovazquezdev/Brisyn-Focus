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

/// Tasks state
class TasksState {
  final List<Task> tasks;
  final TaskFilter filter;
  final TaskSort sort;
  final bool isLoading;
  final String? error;
  final String? selectedTaskId;

  const TasksState({
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.sort = TaskSort.priority,
    this.isLoading = false,
    this.error,
    this.selectedTaskId,
  });

  TasksState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    TaskSort? sort,
    bool? isLoading,
    String? error,
    String? selectedTaskId,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
    );
  }

  /// Get filtered and sorted tasks
  List<Task> get filteredTasks {
    List<Task> result = List.from(tasks);

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
          // First by completion status
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          // Then by priority (high first)
          final priorityComparison = b.priority.index.compareTo(a.priority.index);
          if (priorityComparison != 0) return priorityComparison;
          // Then by due date
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

  /// Get active task count
  int get activeCount => tasks.where((t) => !t.isCompleted).length;

  /// Get completed task count
  int get completedCount => tasks.where((t) => t.isCompleted).length;

  /// Get today's tasks count
  int get todayCount => tasks.where((t) => t.isDueToday && !t.isCompleted).length;

  /// Get overdue count
  int get overdueCount => tasks.where((t) => t.isOverdue).length;

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

  TasksNotifier() : super(const TasksState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<Task>(_boxName);
      final tasks = _box.values.toList();
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
  }) async {
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
    );

    await _box.put(task.id, task);
    state = state.copyWith(tasks: [...state.tasks, task]);
    return task;
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
    final tasks = state.tasks.map((t) => t.id == task.id ? task : t).toList();
    state = state.copyWith(tasks: tasks);
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    final tasks = state.tasks.where((t) => t.id != id).toList();
    state = state.copyWith(
      tasks: tasks,
      selectedTaskId: state.selectedTaskId == id ? null : state.selectedTaskId,
    );
  }

  /// Toggle task completion
  Future<void> toggleComplete(String id) async {
    final task = state.tasks.firstWhere((t) => t.id == id);
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updated);
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

  /// Select task (for timer)
  void selectTask(String? id) {
    state = state.copyWith(selectedTaskId: id);
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
