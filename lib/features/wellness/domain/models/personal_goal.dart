import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'personal_goal.g.dart';

/// A personal goal that the user sets for themselves
@HiveType(typeId: 14)
class PersonalGoal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final GoalType type;

  @HiveField(4)
  final int iconCodePoint;

  @HiveField(5)
  final int colorValue;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? targetDate;

  @HiveField(8)
  final int? targetValue;

  @HiveField(9)
  final int currentValue;

  @HiveField(10)
  final bool isCompleted;

  @HiveField(11)
  final List<String> dailyCompletions; // ISO date strings when checked

  PersonalGoal({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAt,
    this.targetDate,
    this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
    this.dailyCompletions = const [],
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  /// Progress as percentage (0.0 to 1.0)
  double get progress {
    if (targetValue != null && targetValue! > 0) {
      return (currentValue / targetValue!).clamp(0.0, 1.0);
    }
    return isCompleted ? 1.0 : 0.0;
  }

  /// Check if completed today (for daily goals)
  bool get isCompletedToday {
    final today = DateTime.now();
    final todayStr =
        DateTime(today.year, today.month, today.day).toIso8601String();
    return dailyCompletions.contains(todayStr);
  }

  factory PersonalGoal.create({
    required String title,
    String? description,
    required GoalType type,
    required IconData icon,
    required Color color,
    DateTime? targetDate,
    int? targetValue,
  }) {
    return PersonalGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      iconCodePoint: icon.codePoint,
      colorValue: color.toARGB32(),
      createdAt: DateTime.now(),
      targetDate: targetDate,
      targetValue: targetValue,
    );
  }

  PersonalGoal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    int? iconCodePoint,
    int? colorValue,
    DateTime? createdAt,
    DateTime? targetDate,
    int? targetValue,
    int? currentValue,
    bool? isCompleted,
    List<String>? dailyCompletions,
  }) {
    return PersonalGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      dailyCompletions: dailyCompletions ?? this.dailyCompletions,
    );
  }

  /// Mark as completed today (for daily/recurring goals)
  PersonalGoal markCompletedToday() {
    final today = DateTime.now();
    final todayStr =
        DateTime(today.year, today.month, today.day).toIso8601String();
    if (dailyCompletions.contains(todayStr)) {
      return this;
    }
    return copyWith(
      dailyCompletions: [...dailyCompletions, todayStr],
    );
  }

  /// Unmark completion for today
  PersonalGoal unmarkCompletedToday() {
    final today = DateTime.now();
    final todayStr =
        DateTime(today.year, today.month, today.day).toIso8601String();
    return copyWith(
      dailyCompletions:
          dailyCompletions.where((d) => d != todayStr).toList(),
    );
  }
}

/// Type of personal goal
@HiveType(typeId: 15)
enum GoalType {
  @HiveField(0)
  daily, // Repeats daily (e.g., "Be grateful")

  @HiveField(1)
  milestone, // One-time achievement with target value

  @HiveField(2)
  habit, // Building a habit over time

  @HiveField(3)
  reflection, // Daily reflection/journaling prompt
}

/// Preset goals for common wellness activities
class PresetGoals {
  static List<Map<String, dynamic>> get all => [
        {
          'title': 'Be grateful today',
          'description': 'Take a moment to appreciate something in your life',
          'type': GoalType.daily,
          'icon': Icons.favorite,
          'color': Colors.pink,
        },
        {
          'title': 'Drink water',
          'description': 'Stay hydrated throughout the day',
          'type': GoalType.daily,
          'icon': Icons.water_drop,
          'color': Colors.blue,
        },
        {
          'title': 'Take a break',
          'description': 'Step away from work and relax',
          'type': GoalType.daily,
          'icon': Icons.self_improvement,
          'color': Colors.green,
        },
        {
          'title': 'Move your body',
          'description': 'Exercise or stretch for at least 10 minutes',
          'type': GoalType.daily,
          'icon': Icons.directions_run,
          'color': Colors.orange,
        },
        {
          'title': 'Read something',
          'description': 'Read at least 10 pages today',
          'type': GoalType.daily,
          'icon': Icons.menu_book,
          'color': Colors.purple,
        },
        {
          'title': 'Connect with someone',
          'description': 'Reach out to a friend or family member',
          'type': GoalType.daily,
          'icon': Icons.people,
          'color': Colors.teal,
        },
        {
          'title': 'Meditate',
          'description': 'Take 5-10 minutes for mindfulness',
          'type': GoalType.daily,
          'icon': Icons.spa,
          'color': Colors.indigo,
        },
        {
          'title': 'Get enough sleep',
          'description': 'Aim for 7-8 hours of rest',
          'type': GoalType.daily,
          'icon': Icons.bedtime,
          'color': Colors.deepPurple,
        },
      ];
}
