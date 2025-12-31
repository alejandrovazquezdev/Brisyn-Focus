import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/wellness_repository.dart';
import '../../domain/models/focus_streak.dart';
import '../../domain/models/custom_counter.dart';
import '../../domain/models/personal_goal.dart';

/// Provider for the wellness repository
final wellnessRepositoryProvider = Provider<WellnessRepository>((ref) {
  return WellnessRepository();
});

/// Provider for whether the repository is initialized
final wellnessInitializedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(wellnessRepositoryProvider);
  await repo.initialize();
  return true;
});

/// Provider for all focus streaks
final focusStreaksProvider =
    StateNotifierProvider<FocusStreaksNotifier, List<FocusStreak>>((ref) {
  final repo = ref.watch(wellnessRepositoryProvider);
  return FocusStreaksNotifier(repo);
});

/// Provider for current streak count
final currentStreakProvider = Provider<int>((ref) {
  ref.watch(focusStreaksProvider);
  final repo = ref.read(wellnessRepositoryProvider);
  return repo.getCurrentStreakCount();
});

/// Provider for streaks in the current month
final monthlyStreaksProvider =
    Provider.family<List<FocusStreak>, DateTime>((ref, month) {
  ref.watch(focusStreaksProvider);
  final repo = ref.read(wellnessRepositoryProvider);
  return repo.getStreaksForMonth(month.year, month.month);
});

/// Provider for all custom counters
final customCountersProvider =
    StateNotifierProvider<CustomCountersNotifier, List<CustomCounter>>((ref) {
  final repo = ref.watch(wellnessRepositoryProvider);
  return CustomCountersNotifier(repo);
});

/// Provider for counter's current count based on type
final counterCurrentValueProvider =
    Provider.family<int, CustomCounter>((ref, counter) {
  ref.watch(customCountersProvider);
  final repo = ref.read(wellnessRepositoryProvider);

  switch (counter.type) {
    case CounterType.daily:
      return repo.getTodayCountForCounter(counter.id);
    case CounterType.weekly:
      return repo.getWeekCountForCounter(counter.id);
    case CounterType.cumulative:
      return repo.getTotalCountForCounter(counter.id);
  }
});

/// Provider for all personal goals
final personalGoalsProvider =
    StateNotifierProvider<PersonalGoalsNotifier, List<PersonalGoal>>((ref) {
  final repo = ref.watch(wellnessRepositoryProvider);
  return PersonalGoalsNotifier(repo);
});

/// Provider for daily goals only
final dailyGoalsProvider = Provider<List<PersonalGoal>>((ref) {
  final goals = ref.watch(personalGoalsProvider);
  return goals.where((g) => g.type == GoalType.daily && !g.isCompleted).toList();
});

/// Provider for today's completion status
final todayGoalsCompletedProvider = Provider<int>((ref) {
  final goals = ref.watch(dailyGoalsProvider);
  return goals.where((g) => g.isCompletedToday).length;
});

// ============================================================================
// STATE NOTIFIERS
// ============================================================================

class FocusStreaksNotifier extends StateNotifier<List<FocusStreak>> {
  final WellnessRepository _repository;

  FocusStreaksNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllStreaks();
  }

  Future<void> recordFocusTime({
    required int focusMinutes,
    required int sessionsCompleted,
    required int dailyGoalMinutes,
  }) async {
    await _repository.recordFocusTime(
      focusMinutes: focusMinutes,
      sessionsCompleted: sessionsCompleted,
      dailyGoalMinutes: dailyGoalMinutes,
    );
    _load();
  }

  void refresh() => _load();
}

class CustomCountersNotifier extends StateNotifier<List<CustomCounter>> {
  final WellnessRepository _repository;

  CustomCountersNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllCounters();
  }

  Future<void> addCounter({
    required String name,
    String? description,
    required IconData icon,
    required Color color,
    required int targetCount,
    required CounterType type,
  }) async {
    final counter = CustomCounter.create(
      name: name,
      description: description,
      icon: icon,
      color: color,
      targetCount: targetCount,
      type: type,
    );
    await _repository.addCounter(counter);
    _load();
  }

  Future<void> updateCounter(CustomCounter counter) async {
    await _repository.updateCounter(counter);
    _load();
  }

  Future<void> deleteCounter(String counterId) async {
    await _repository.deleteCounter(counterId);
    _load();
  }

  Future<void> incrementCounter(String counterId, {String? note}) async {
    await _repository.incrementCounter(counterId, note: note);
    _load();
  }

  void refresh() => _load();
}

class PersonalGoalsNotifier extends StateNotifier<List<PersonalGoal>> {
  final WellnessRepository _repository;

  PersonalGoalsNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllGoals();
  }

  Future<void> addGoal({
    required String title,
    String? description,
    required GoalType type,
    required IconData icon,
    required Color color,
    DateTime? targetDate,
    int? targetValue,
  }) async {
    final goal = PersonalGoal.create(
      title: title,
      description: description,
      type: type,
      icon: icon,
      color: color,
      targetDate: targetDate,
      targetValue: targetValue,
    );
    await _repository.addGoal(goal);
    _load();
  }

  Future<void> updateGoal(PersonalGoal goal) async {
    await _repository.updateGoal(goal);
    _load();
  }

  Future<void> deleteGoal(String goalId) async {
    await _repository.deleteGoal(goalId);
    _load();
  }

  Future<void> toggleGoalCompletionToday(String goalId) async {
    await _repository.toggleGoalCompletionToday(goalId);
    _load();
  }

  void refresh() => _load();
}
