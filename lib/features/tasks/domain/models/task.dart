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
  })  : createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
