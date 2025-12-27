import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/activity_category.dart';
import '../../domain/models/activity_session.dart';

/// Activities state
class ActivitiesState {
  final List<ActivityCategory> categories;
  final List<ActivitySession> sessions;
  final bool isLoading;
  final String? error;
  final String? selectedCategoryId;

  const ActivitiesState({
    this.categories = const [],
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
  });

  ActivitiesState copyWith({
    List<ActivityCategory>? categories,
    List<ActivitySession>? sessions,
    bool? isLoading,
    String? error,
    String? selectedCategoryId,
  }) {
    return ActivitiesState(
      categories: categories ?? this.categories,
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  /// Get sessions for current week
  List<ActivitySession> get thisWeekSessions {
    return sessions.where((s) => s.isThisWeek).toList();
  }

  /// Get sessions for today
  List<ActivitySession> get todaySessions {
    return sessions.where((s) => s.isToday).toList();
  }

  /// Get weekly progress for each category (for radar chart)
  Map<String, WeeklyProgress> getWeeklyProgress() {
    final progress = <String, WeeklyProgress>{};

    for (final category in categories) {
      final categorySessions =
          thisWeekSessions.where((s) => s.categoryId == category.id).toList();
      
      // Count unique days with sessions
      final uniqueDays = <String>{};
      for (final session in categorySessions) {
        uniqueDays.add(
          '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}',
        );
      }

      final completed = uniqueDays.length;
      final goal = category.weeklyGoal;
      final percentage = goal > 0 ? (completed / goal).clamp(0.0, 1.0) : 0.0;

      progress[category.id] = WeeklyProgress(
        category: category,
        completedDays: completed,
        goalDays: goal,
        percentage: percentage,
        totalMinutes: categorySessions.fold(
          0,
          (sum, s) => sum + s.durationMinutes,
        ),
        totalSessions: categorySessions.length,
      );
    }

    return progress;
  }

  /// Get total focus time today
  int get todayFocusMinutes {
    return todaySessions.fold(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Get total focus time this week
  int get weekFocusMinutes {
    return thisWeekSessions.fold(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Get current week number
  int get currentWeekNumber {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final daysDifference = now.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}

/// Weekly progress data for a category
class WeeklyProgress {
  final ActivityCategory category;
  final int completedDays;
  final int goalDays;
  final double percentage;
  final int totalMinutes;
  final int totalSessions;

  const WeeklyProgress({
    required this.category,
    required this.completedDays,
    required this.goalDays,
    required this.percentage,
    required this.totalMinutes,
    required this.totalSessions,
  });

  /// Status based on progress
  ProgressStatus get status {
    if (percentage >= 1.0) return ProgressStatus.complete;
    if (percentage >= 0.5) return ProgressStatus.partial;
    return ProgressStatus.behind;
  }
}

enum ProgressStatus { complete, partial, behind }

/// Activities notifier
class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  static const String _categoriesBoxName = 'activity_categories';
  static const String _sessionsBoxName = 'activity_sessions';
  
  late Box<ActivityCategory> _categoriesBox;
  late Box<ActivitySession> _sessionsBox;
  final _uuid = const Uuid();

  ActivitiesNotifier() : super(const ActivitiesState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      _categoriesBox = await Hive.openBox<ActivityCategory>(_categoriesBoxName);
      _sessionsBox = await Hive.openBox<ActivitySession>(_sessionsBoxName);

      var categories = _categoriesBox.values.toList();
      
      // Initialize with defaults if empty
      if (categories.isEmpty) {
        final defaults = getDefaultCategories();
        for (final category in defaults) {
          await _categoriesBox.put(category.id, category);
        }
        categories = defaults;
      }

      // Sort by sortOrder
      categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final sessions = _sessionsBox.values.toList();

      state = state.copyWith(
        categories: categories,
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a new category
  Future<ActivityCategory> addCategory({
    required String name,
    required ActivityIcon icon,
    required String colorHex,
    int weeklyGoal = 7,
  }) async {
    final category = ActivityCategory(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      colorHex: colorHex,
      weeklyGoal: weeklyGoal,
      sortOrder: state.categories.length,
    );

    await _categoriesBox.put(category.id, category);
    state = state.copyWith(categories: [...state.categories, category]);
    return category;
  }

  /// Update a category
  Future<void> updateCategory(ActivityCategory category) async {
    await _categoriesBox.put(category.id, category);
    final categories =
        state.categories.map((c) => c.id == category.id ? category : c).toList();
    state = state.copyWith(categories: categories);
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    final category = state.categories.firstWhere((c) => c.id == id);
    if (category.isDefault) return; // Can't delete defaults

    await _categoriesBox.delete(id);
    
    // Also delete sessions for this category
    final sessionsToDelete =
        state.sessions.where((s) => s.categoryId == id).toList();
    for (final session in sessionsToDelete) {
      await _sessionsBox.delete(session.id);
    }

    state = state.copyWith(
      categories: state.categories.where((c) => c.id != id).toList(),
      sessions: state.sessions.where((s) => s.categoryId != id).toList(),
    );
  }

  /// Add a new session
  Future<ActivitySession> addSession({
    required String categoryId,
    required int durationMinutes,
    String? taskId,
    String? notes,
    int pomodorosCompleted = 1,
    DateTime? startTime,
  }) async {
    final session = ActivitySession(
      id: _uuid.v4(),
      categoryId: categoryId,
      startTime: startTime ?? DateTime.now(),
      durationMinutes: durationMinutes,
      taskId: taskId,
      notes: notes,
      pomodorosCompleted: pomodorosCompleted,
    );

    await _sessionsBox.put(session.id, session);
    state = state.copyWith(sessions: [...state.sessions, session]);
    return session;
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    await _sessionsBox.delete(id);
    state = state.copyWith(
      sessions: state.sessions.where((s) => s.id != id).toList(),
    );
  }

  /// Select a category
  void selectCategory(String? id) {
    state = state.copyWith(selectedCategoryId: id);
  }

  /// Get sessions by date range
  List<ActivitySession> getSessionsInRange(DateTime start, DateTime end) {
    return state.sessions.where((s) {
      return s.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
          s.startTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get daily stats for last N days
  List<DailyStats> getDailyStats(int days) {
    final stats = <DailyStats>[];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final daySessions = state.sessions.where((s) {
        return s.startTime.year == date.year &&
            s.startTime.month == date.month &&
            s.startTime.day == date.day;
      }).toList();

      stats.add(DailyStats(
        date: date,
        totalMinutes: daySessions.fold(0, (sum, s) => sum + s.durationMinutes),
        sessionCount: daySessions.length,
        categoryCounts: _getCategoryCounts(daySessions),
      ));
    }

    return stats;
  }

  Map<String, int> _getCategoryCounts(List<ActivitySession> sessions) {
    final counts = <String, int>{};
    for (final session in sessions) {
      counts[session.categoryId] = (counts[session.categoryId] ?? 0) + 1;
    }
    return counts;
  }
}

/// Daily stats summary
class DailyStats {
  final DateTime date;
  final int totalMinutes;
  final int sessionCount;
  final Map<String, int> categoryCounts;

  const DailyStats({
    required this.date,
    required this.totalMinutes,
    required this.sessionCount,
    required this.categoryCounts,
  });
}

/// Activities provider
final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, ActivitiesState>((ref) {
  return ActivitiesNotifier();
});

/// Weekly progress provider
final weeklyProgressProvider = Provider<Map<String, WeeklyProgress>>((ref) {
  final activitiesState = ref.watch(activitiesProvider);
  return activitiesState.getWeeklyProgress();
});
