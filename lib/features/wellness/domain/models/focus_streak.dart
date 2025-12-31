import 'package:hive/hive.dart';

part 'focus_streak.g.dart';

/// Represents a daily focus entry for streak tracking
@HiveType(typeId: 10)
class FocusStreak extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int focusMinutes;

  @HiveField(3)
  final int sessionsCompleted;

  @HiveField(4)
  final bool goalMet;

  FocusStreak({
    required this.id,
    required this.date,
    required this.focusMinutes,
    required this.sessionsCompleted,
    required this.goalMet,
  });

  /// Create from today's stats
  factory FocusStreak.fromToday({
    required int focusMinutes,
    required int sessionsCompleted,
    required int dailyGoalMinutes,
  }) {
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    return FocusStreak(
      id: dateOnly.toIso8601String(),
      date: dateOnly,
      focusMinutes: focusMinutes,
      sessionsCompleted: sessionsCompleted,
      goalMet: focusMinutes >= dailyGoalMinutes,
    );
  }

  /// Check if this entry is for a specific date
  bool isForDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }

  FocusStreak copyWith({
    String? id,
    DateTime? date,
    int? focusMinutes,
    int? sessionsCompleted,
    bool? goalMet,
  }) {
    return FocusStreak(
      id: id ?? this.id,
      date: date ?? this.date,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      goalMet: goalMet ?? this.goalMet,
    );
  }
}
