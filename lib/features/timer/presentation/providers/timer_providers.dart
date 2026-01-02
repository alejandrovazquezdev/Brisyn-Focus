import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/providers/app_providers.dart';

/// Timer phase types
enum TimerPhase {
  focus,
  shortBreak,
  longBreak,
}

/// Timer status
enum TimerStatus {
  idle,
  running,
  paused,
}

/// Timer state model
class TimerState {
  final TimerPhase phase;
  final TimerStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final int currentSession;
  final int totalSessions;
  final int focusDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final int dailyFocusMinutes;
  final int dailySessionsCompleted;
  final String? selectedCategoryId; // null means "Just Focus"

  const TimerState({
    this.phase = TimerPhase.focus,
    this.status = TimerStatus.idle,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.currentSession = 1,
    this.totalSessions = 4,
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
    this.dailyFocusMinutes = 0,
    this.dailySessionsCompleted = 0,
    this.selectedCategoryId,
  });

  TimerState copyWith({
    TimerPhase? phase,
    TimerStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    int? currentSession,
    int? totalSessions,
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    int? dailyFocusMinutes,
    int? dailySessionsCompleted,
    String? selectedCategoryId,
    bool clearCategory = false,
  }) {
    return TimerState(
      phase: phase ?? this.phase,
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      currentSession: currentSession ?? this.currentSession,
      totalSessions: totalSessions ?? this.totalSessions,
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      dailyFocusMinutes: dailyFocusMinutes ?? this.dailyFocusMinutes,
      dailySessionsCompleted: dailySessionsCompleted ?? this.dailySessionsCompleted,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }

  /// Format remaining time as MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progress {
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  /// Get phase label
  String get phaseLabel {
    switch (phase) {
      case TimerPhase.focus:
        return 'FOCUS';
      case TimerPhase.shortBreak:
        return 'SHORT BREAK';
      case TimerPhase.longBreak:
        return 'LONG BREAK';
    }
  }

  /// Check if currently on a break
  bool get isBreak =>
      phase == TimerPhase.shortBreak || phase == TimerPhase.longBreak;
}

/// Timer notifier with business logic
class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final SharedPreferences _prefs;
  
  /// Callback when a focus session is completed
  void Function(int durationMinutes, String? categoryId)? onFocusSessionComplete;

  TimerNotifier(this._prefs) : super(const TimerState()) {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  void _loadSettings() {
    final focusDuration = _prefs.getInt('focusDuration') ?? 25;
    final shortBreakDuration = _prefs.getInt('shortBreakDuration') ?? 5;
    final longBreakDuration = _prefs.getInt('longBreakDuration') ?? 15;
    final totalSessions = _prefs.getInt('totalSessions') ?? 4;
    final autoStartBreaks = _prefs.getBool('autoStartBreaks') ?? false;
    final autoStartFocus = _prefs.getBool('autoStartFocus') ?? false;

    state = state.copyWith(
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      totalSessions: totalSessions,
      autoStartBreaks: autoStartBreaks,
      autoStartFocus: autoStartFocus,
      remainingSeconds: focusDuration * 60,
      totalSeconds: focusDuration * 60,
    );
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    await _prefs.setInt('focusDuration', state.focusDuration);
    await _prefs.setInt('shortBreakDuration', state.shortBreakDuration);
    await _prefs.setInt('longBreakDuration', state.longBreakDuration);
    await _prefs.setInt('totalSessions', state.totalSessions);
    await _prefs.setBool('autoStartBreaks', state.autoStartBreaks);
    await _prefs.setBool('autoStartFocus', state.autoStartFocus);
  }

  /// Start or resume the timer
  void start() {
    if (state.status == TimerStatus.running) return;

    state = state.copyWith(status: TimerStatus.running);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _onTimerComplete();
      }
    });
  }

  /// Pause the timer
  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// Toggle between start and pause
  void toggle() {
    if (state.status == TimerStatus.running) {
      pause();
    } else {
      start();
    }
  }

  /// Reset current timer
  void reset() {
    _timer?.cancel();
    _timer = null;

    int duration;
    switch (state.phase) {
      case TimerPhase.focus:
        duration = state.focusDuration * 60;
        break;
      case TimerPhase.shortBreak:
        duration = state.shortBreakDuration * 60;
        break;
      case TimerPhase.longBreak:
        duration = state.longBreakDuration * 60;
        break;
    }

    state = state.copyWith(
      status: TimerStatus.idle,
      remainingSeconds: duration,
      totalSeconds: duration,
    );
  }

  /// Skip to next phase
  void skip() {
    _timer?.cancel();
    _timer = null;
    _moveToNextPhase();
  }

  /// Handle timer completion
  void _onTimerComplete() {
    _timer?.cancel();
    _timer = null;

    // If focus session completed, update stats and notify listeners
    if (state.phase == TimerPhase.focus) {
      final durationMinutes = state.focusDuration;
      final categoryId = state.selectedCategoryId;
      
      state = state.copyWith(
        dailyFocusMinutes: state.dailyFocusMinutes + durationMinutes,
        dailySessionsCompleted: state.dailySessionsCompleted + 1,
      );
      
      // Notify listeners about completed focus session
      onFocusSessionComplete?.call(durationMinutes, categoryId);
    }

    _moveToNextPhase();

    // Auto-start if enabled
    if ((state.isBreak && state.autoStartBreaks) ||
        (!state.isBreak && state.autoStartFocus)) {
      start();
    }
  }

  /// Move to the next phase
  void _moveToNextPhase() {
    TimerPhase nextPhase;
    int nextSession = state.currentSession;
    int duration;

    if (state.phase == TimerPhase.focus) {
      // After focus, decide on break type
      if (state.currentSession >= state.totalSessions) {
        nextPhase = TimerPhase.longBreak;
        duration = state.longBreakDuration * 60;
      } else {
        nextPhase = TimerPhase.shortBreak;
        duration = state.shortBreakDuration * 60;
      }
    } else {
      // After break, start new focus
      nextPhase = TimerPhase.focus;
      duration = state.focusDuration * 60;

      if (state.phase == TimerPhase.longBreak) {
        // Reset session counter after long break
        nextSession = 1;
      } else {
        nextSession = state.currentSession + 1;
      }
    }

    state = state.copyWith(
      phase: nextPhase,
      status: TimerStatus.idle,
      currentSession: nextSession,
      remainingSeconds: duration,
      totalSeconds: duration,
    );
  }

  /// Set focus duration (in minutes)
  void setFocusDuration(int minutes) {
    final shouldReset = state.phase == TimerPhase.focus && 
                        state.status == TimerStatus.idle;
    
    state = state.copyWith(
      focusDuration: minutes,
      remainingSeconds: shouldReset ? minutes * 60 : state.remainingSeconds,
      totalSeconds: shouldReset ? minutes * 60 : state.totalSeconds,
    );
    _saveSettings();
  }

  /// Set short break duration (in minutes)
  void setShortBreakDuration(int minutes) {
    final shouldReset = state.phase == TimerPhase.shortBreak && 
                        state.status == TimerStatus.idle;
    
    state = state.copyWith(
      shortBreakDuration: minutes,
      remainingSeconds: shouldReset ? minutes * 60 : state.remainingSeconds,
      totalSeconds: shouldReset ? minutes * 60 : state.totalSeconds,
    );
    _saveSettings();
  }

  /// Set long break duration (in minutes)
  void setLongBreakDuration(int minutes) {
    final shouldReset = state.phase == TimerPhase.longBreak && 
                        state.status == TimerStatus.idle;
    
    state = state.copyWith(
      longBreakDuration: minutes,
      remainingSeconds: shouldReset ? minutes * 60 : state.remainingSeconds,
      totalSeconds: shouldReset ? minutes * 60 : state.totalSeconds,
    );
    _saveSettings();
  }

  /// Set total sessions before long break
  void setTotalSessions(int sessions) {
    state = state.copyWith(totalSessions: sessions);
    _saveSettings();
  }

  /// Toggle auto-start breaks
  void toggleAutoStartBreaks() {
    state = state.copyWith(autoStartBreaks: !state.autoStartBreaks);
    _saveSettings();
  }

  /// Toggle auto-start focus
  void toggleAutoStartFocus() {
    state = state.copyWith(autoStartFocus: !state.autoStartFocus);
    _saveSettings();
  }

  /// Switch to a specific phase manually
  void switchToPhase(TimerPhase phase) {
    _timer?.cancel();
    _timer = null;

    int duration;
    switch (phase) {
      case TimerPhase.focus:
        duration = state.focusDuration * 60;
        break;
      case TimerPhase.shortBreak:
        duration = state.shortBreakDuration * 60;
        break;
      case TimerPhase.longBreak:
        duration = state.longBreakDuration * 60;
        break;
    }

    state = state.copyWith(
      phase: phase,
      status: TimerStatus.idle,
      remainingSeconds: duration,
      totalSeconds: duration,
    );
  }

  /// Quick preset - set focus duration and reset
  void applyPreset(int minutes) {
    _timer?.cancel();
    _timer = null;
    
    state = state.copyWith(
      phase: TimerPhase.focus,
      status: TimerStatus.idle,
      focusDuration: minutes,
      remainingSeconds: minutes * 60,
      totalSeconds: minutes * 60,
    );
    _saveSettings();
  }

  /// Select a category for the focus session (null = Just Focus)
  void selectCategory(String? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Timer state provider
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TimerNotifier(prefs);
});
