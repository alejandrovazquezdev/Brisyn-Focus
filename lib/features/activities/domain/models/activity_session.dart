import 'package:hive/hive.dart';

part 'activity_session.g.dart';

/// Represents a completed activity session
@HiveType(typeId: 4)
class ActivitySession {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final String? taskId; // Optional linked task

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final int pomodorosCompleted;

  ActivitySession({
    required this.id,
    required this.categoryId,
    required this.startTime,
    required this.durationMinutes,
    this.taskId,
    this.notes,
    this.pomodorosCompleted = 1,
  });

  ActivitySession copyWith({
    String? id,
    String? categoryId,
    DateTime? startTime,
    int? durationMinutes,
    String? taskId,
    String? notes,
    int? pomodorosCompleted,
  }) {
    return ActivitySession(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      taskId: taskId ?? this.taskId,
      notes: notes ?? this.notes,
      pomodorosCompleted: pomodorosCompleted ?? this.pomodorosCompleted,
    );
  }

  /// Check if session is from today
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  /// Check if session is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return startTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        startTime.isBefore(endOfWeek);
  }

  /// Get week number of year
  int get weekNumber {
    final firstDayOfYear = DateTime(startTime.year, 1, 1);
    final daysDifference = startTime.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivitySession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
