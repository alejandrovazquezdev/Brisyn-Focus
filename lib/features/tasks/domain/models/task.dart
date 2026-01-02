import 'package:hive/hive.dart';

part 'task.g.dart';

/// Task priority levels
@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

/// Task status for Kanban view
@HiveType(typeId: 16)
enum TaskStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}

/// Recurrence type for recurring tasks
@HiveType(typeId: 17)
enum RecurrenceType {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
}

/// Task model
@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  TaskPriority priority;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? dueDate;

  @HiveField(7)
  int estimatedPomodoros;

  @HiveField(8)
  int completedPomodoros;

  @HiveField(9)
  String? projectId;

  @HiveField(10)
  List<String> tags;

  @HiveField(11)
  int sortOrder;

  // New fields for premium features
  
  /// Task status for Kanban (todo, inProgress, done)
  @HiveField(12)
  TaskStatus status;

  /// Parent task ID for subtasks
  @HiveField(13)
  String? parentTaskId;

  /// Recurrence type (none, daily, weekly, monthly)
  @HiveField(14)
  RecurrenceType recurrenceType;

  /// Last date when recurring task was generated
  @HiveField(15)
  DateTime? lastRecurrenceDate;

  /// Original recurring task ID (for tasks created by recurrence)
  @HiveField(16)
  String? recurringSourceId;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
    this.dueDate,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.projectId,
    List<String>? tags,
    this.sortOrder = 0,
    this.status = TaskStatus.todo,
    this.parentTaskId,
    this.recurrenceType = RecurrenceType.none,
    this.lastRecurrenceDate,
    this.recurringSourceId,
  })  : createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

  /// Check if this is a subtask
  bool get isSubtask => parentTaskId != null;

  /// Check if this is a recurring task
  bool get isRecurring => recurrenceType != RecurrenceType.none;

  /// Check if this task was created from a recurring task
  bool get isFromRecurrence => recurringSourceId != null;

  /// Create a copy with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    int? estimatedPomodoros,
    int? completedPomodoros,
    String? projectId,
    List<String>? tags,
    int? sortOrder,
    TaskStatus? status,
    String? parentTaskId,
    RecurrenceType? recurrenceType,
    DateTime? lastRecurrenceDate,
    String? recurringSourceId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      projectId: projectId ?? this.projectId,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      lastRecurrenceDate: lastRecurrenceDate ?? this.lastRecurrenceDate,
      recurringSourceId: recurringSourceId ?? this.recurringSourceId,
    );
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Get pomodoro progress
  double get pomodoroProgress {
    if (estimatedPomodoros == 0) return 0;
    return completedPomodoros / estimatedPomodoros;
  }

  /// Priority color name for UI
  String get priorityName {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  /// Status name for UI
  String get statusName {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  /// Recurrence name for UI
  String get recurrenceName {
    switch (recurrenceType) {
      case RecurrenceType.none:
        return 'None';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
    }
  }

  /// Calculate next due date for recurring task
  DateTime? getNextRecurrenceDate() {
    if (!isRecurring || dueDate == null) return null;
    
    final baseDate = lastRecurrenceDate ?? dueDate!;
    
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return baseDate.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return baseDate.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
      case RecurrenceType.none:
        return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
