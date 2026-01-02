import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activities/domain/models/activity_category.dart';
import '../../../activities/presentation/providers/activities_providers.dart';
import '../../../wellness/presentation/providers/wellness_providers.dart';
import 'timer_providers.dart';

/// Service class to handle focus session completion
/// Connects timer completion to activities and goals
class TimerSessionHandler {
  final Ref _ref;
  bool _isInitialized = false;

  TimerSessionHandler(this._ref);

  /// Initialize the handler by setting up the callback
  void initialize() {
    if (_isInitialized) return;
    
    final timerNotifier = _ref.read(timerProvider.notifier);
    timerNotifier.onFocusSessionComplete = _handleFocusSessionComplete;
    _isInitialized = true;
  }

  /// Handle when a focus session completes
  void _handleFocusSessionComplete(int durationMinutes, String? categoryId) {
    // 1. Always record focus time for streaks (even without category)
    _ref.read(focusStreaksProvider.notifier).recordFocusTime(
      focusMinutes: durationMinutes,
      sessionsCompleted: 1,
      dailyGoalMinutes: 60,
    );

    // If no category selected ("Just Focus"), don't log to activities
    if (categoryId == null) {
      return;
    }

    // 2. Add session to activities
    _ref.read(activitiesProvider.notifier).addSession(
      categoryId: categoryId,
      durationMinutes: durationMinutes,
      pomodorosCompleted: 1,
    );

    // 3. Check if category has a linked goal
    final categories = _ref.read(activitiesProvider).categories;
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => ActivityCategory(
        id: '',
        name: '',
        icon: ActivityIcon.work,
        colorHex: '000000',
      ),
    );

    if (category.id.isEmpty) return;

    final linkedGoalId = category.linkedGoalId;
    if (linkedGoalId == null || linkedGoalId.isEmpty) return;

    // 4. Update the linked goal's currentValue
    final goals = _ref.read(personalGoalsProvider);
    final goalIndex = goals.indexWhere((g) => g.id == linkedGoalId);

    if (goalIndex == -1) return;

    final goal = goals[goalIndex];
    final updatedGoal = goal.copyWith(
      currentValue: goal.currentValue + durationMinutes,
    );

    _ref.read(personalGoalsProvider.notifier).updateGoal(updatedGoal);
  }
}

/// Provider for the timer session handler
final timerSessionHandlerProvider = Provider<TimerSessionHandler>((ref) {
  final handler = TimerSessionHandler(ref);
  handler.initialize();
  return handler;
});
