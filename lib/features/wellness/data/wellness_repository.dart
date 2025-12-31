import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/models/focus_streak.dart';
import '../domain/models/custom_counter.dart';
import '../domain/models/personal_goal.dart';

/// Repository for wellness data (streaks, counters, goals)
class WellnessRepository {
  static const String _streaksBoxName = 'focus_streaks';
  static const String _countersBoxName = 'custom_counters';
  static const String _counterEntriesBoxName = 'counter_entries';
  static const String _goalsBoxName = 'personal_goals';

  Box<FocusStreak>? _streaksBox;
  Box<CustomCounter>? _countersBox;
  Box<CounterEntry>? _counterEntriesBox;
  Box<PersonalGoal>? _goalsBox;

  bool _isInitialized = false;

  /// Initialize the repository
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _streaksBox = await Hive.openBox<FocusStreak>(_streaksBoxName);
      _countersBox = await Hive.openBox<CustomCounter>(_countersBoxName);
      _counterEntriesBox = await Hive.openBox<CounterEntry>(_counterEntriesBoxName);
      _goalsBox = await Hive.openBox<PersonalGoal>(_goalsBoxName);
      _isInitialized = true;
      debugPrint('WellnessRepository: Initialized successfully');
    } catch (e) {
      debugPrint('WellnessRepository: Failed to initialize: $e');
      rethrow;
    }
  }

  // =========================================================================
  // FOCUS STREAKS
  // =========================================================================

  /// Get all focus streaks
  List<FocusStreak> getAllStreaks() {
    return _streaksBox?.values.toList() ?? [];
  }

  /// Get streaks for a specific month
  List<FocusStreak> getStreaksForMonth(int year, int month) {
    return getAllStreaks().where((streak) {
      return streak.date.year == year && streak.date.month == month;
    }).toList();
  }

  /// Get streak for a specific date
  FocusStreak? getStreakForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return getAllStreaks().cast<FocusStreak?>().firstWhere(
          (streak) => streak!.isForDate(dateOnly),
          orElse: () => null,
        );
  }

  /// Calculate current streak count
  int getCurrentStreakCount() {
    final streaks = getAllStreaks()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (streaks.isEmpty) return 0;

    int count = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (final streak in streaks) {
      final streakDate = DateTime(
        streak.date.year,
        streak.date.month,
        streak.date.day,
      );

      // Check if this streak is for today or the day we're checking
      if (streakDate == checkDate && streak.goalMet) {
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (streakDate == checkDate.subtract(const Duration(days: 1)) &&
          streak.goalMet) {
        // Allow yesterday if today hasn't been completed yet
        count++;
        checkDate = streakDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return count;
  }

  /// Record focus time for today
  Future<void> recordFocusTime({
    required int focusMinutes,
    required int sessionsCompleted,
    required int dailyGoalMinutes,
  }) async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final existingStreak = getStreakForDate(todayOnly);

    final streak = FocusStreak(
      id: todayOnly.toIso8601String(),
      date: todayOnly,
      focusMinutes: focusMinutes,
      sessionsCompleted: sessionsCompleted,
      goalMet: focusMinutes >= dailyGoalMinutes,
    );

    if (existingStreak != null) {
      await _streaksBox?.put(existingStreak.key, streak);
    } else {
      await _streaksBox?.add(streak);
    }
  }

  // =========================================================================
  // CUSTOM COUNTERS
  // =========================================================================

  /// Get all custom counters
  List<CustomCounter> getAllCounters() {
    return _countersBox?.values.toList() ?? [];
  }

  /// Add a new counter
  Future<void> addCounter(CustomCounter counter) async {
    await _countersBox?.add(counter);
  }

  /// Update a counter
  Future<void> updateCounter(CustomCounter counter) async {
    final key = _countersBox?.values
        .toList()
        .indexWhere((c) => c.id == counter.id);
    if (key != null && key >= 0) {
      await _countersBox?.putAt(key, counter);
    }
  }

  /// Delete a counter
  Future<void> deleteCounter(String counterId) async {
    final key = _countersBox?.values
        .toList()
        .indexWhere((c) => c.id == counterId);
    if (key != null && key >= 0) {
      await _countersBox?.deleteAt(key);
    }
    // Also delete all entries for this counter
    final entriesToDelete = _counterEntriesBox?.values
        .where((e) => e.counterId == counterId)
        .toList();
    for (final entry in entriesToDelete ?? []) {
      await entry.delete();
    }
  }

  /// Get entries for a counter
  List<CounterEntry> getEntriesForCounter(String counterId) {
    return _counterEntriesBox?.values
            .where((e) => e.counterId == counterId)
            .toList() ??
        [];
  }

  /// Get today's count for a counter
  int getTodayCountForCounter(String counterId) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final entries = getEntriesForCounter(counterId).where((e) {
      final entryDate = DateTime(
        e.timestamp.year,
        e.timestamp.month,
        e.timestamp.day,
      );
      return entryDate == todayOnly;
    });
    return entries.fold(0, (sum, e) => sum + e.count);
  }

  /// Get this week's count for a counter
  int getWeekCountForCounter(String counterId) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final entries = getEntriesForCounter(counterId).where((e) {
      final entryDate = DateTime(
        e.timestamp.year,
        e.timestamp.month,
        e.timestamp.day,
      );
      return !entryDate.isBefore(weekStartOnly);
    });
    return entries.fold(0, (sum, e) => sum + e.count);
  }

  /// Get total count for a counter
  int getTotalCountForCounter(String counterId) {
    final entries = getEntriesForCounter(counterId);
    return entries.fold(0, (sum, e) => sum + e.count);
  }

  /// Add an entry to a counter
  Future<void> addCounterEntry(CounterEntry entry) async {
    await _counterEntriesBox?.add(entry);
  }

  /// Increment counter by 1
  Future<void> incrementCounter(String counterId, {String? note}) async {
    final entry = CounterEntry.create(
      counterId: counterId,
      count: 1,
      note: note,
    );
    await addCounterEntry(entry);
  }

  // =========================================================================
  // PERSONAL GOALS
  // =========================================================================

  /// Get all personal goals
  List<PersonalGoal> getAllGoals() {
    return _goalsBox?.values.toList() ?? [];
  }

  /// Get active (non-completed) goals
  List<PersonalGoal> getActiveGoals() {
    return getAllGoals().where((g) => !g.isCompleted).toList();
  }

  /// Get daily goals
  List<PersonalGoal> getDailyGoals() {
    return getAllGoals()
        .where((g) => g.type == GoalType.daily && !g.isCompleted)
        .toList();
  }

  /// Add a new goal
  Future<void> addGoal(PersonalGoal goal) async {
    await _goalsBox?.add(goal);
  }

  /// Update a goal
  Future<void> updateGoal(PersonalGoal goal) async {
    final key = _goalsBox?.values.toList().indexWhere((g) => g.id == goal.id);
    if (key != null && key >= 0) {
      await _goalsBox?.putAt(key, goal);
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    final key = _goalsBox?.values.toList().indexWhere((g) => g.id == goalId);
    if (key != null && key >= 0) {
      await _goalsBox?.deleteAt(key);
    }
  }

  /// Toggle goal completion for today
  Future<void> toggleGoalCompletionToday(String goalId) async {
    final goal = getAllGoals().firstWhere((g) => g.id == goalId);
    final updatedGoal = goal.isCompletedToday
        ? goal.unmarkCompletedToday()
        : goal.markCompletedToday();
    await updateGoal(updatedGoal);
  }

  /// Get completion rate for a goal (last 7 days)
  double getGoalCompletionRate(String goalId) {
    final goal = getAllGoals().cast<PersonalGoal?>().firstWhere(
          (g) => g!.id == goalId,
          orElse: () => null,
        );
    if (goal == null) return 0.0;

    int completedDays = 0;
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final dateStr = DateTime(checkDate.year, checkDate.month, checkDate.day)
          .toIso8601String();
      if (goal.dailyCompletions.contains(dateStr)) {
        completedDays++;
      }
    }

    return completedDays / 7;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _streaksBox?.close();
    await _countersBox?.close();
    await _counterEntriesBox?.close();
    await _goalsBox?.close();
  }
}
