/// Storage keys for SharedPreferences and local storage

class StorageKeys {
  StorageKeys._();

  // ============================================
  // THEME & APPEARANCE
  // ============================================

  /// Theme mode: 'dark', 'light', or 'system'
  static const String themeMode = 'theme_mode';

  /// User-selected accent color (stored as hex string)
  static const String accentColor = 'accent_color';

  // ============================================
  // TIMER SETTINGS
  // ============================================

  /// Focus duration in minutes
  static const String focusDuration = 'focus_duration';

  /// Short break duration in minutes
  static const String shortBreakDuration = 'short_break_duration';

  /// Long break duration in minutes
  static const String longBreakDuration = 'long_break_duration';

  /// Number of sessions before long break
  static const String sessionsBeforeLongBreak = 'sessions_before_long_break';

  /// Auto-start next session
  static const String autoStartNextSession = 'auto_start_next_session';

  /// Auto-start breaks
  static const String autoStartBreaks = 'auto_start_breaks';

  /// Keep screen on during timer
  static const String keepScreenOn = 'keep_screen_on';

  // ============================================
  // NOTIFICATION SETTINGS
  // ============================================

  /// Enable sound notifications
  static const String soundEnabled = 'sound_enabled';

  /// Notification sound name/path
  static const String notificationSound = 'notification_sound';

  /// Notification volume (0.0 - 1.0)
  static const String notificationVolume = 'notification_volume';

  /// Enable vibration
  static const String vibrationEnabled = 'vibration_enabled';

  /// Show notifications
  static const String notificationsEnabled = 'notifications_enabled';

  // ============================================
  // USER & AUTH
  // ============================================

  /// Is user logged in
  static const String isLoggedIn = 'is_logged_in';

  /// User ID (Firebase UID)
  static const String userId = 'user_id';

  /// User email
  static const String userEmail = 'user_email';

  /// User display name
  static const String userName = 'user_name';

  /// Is premium user
  static const String isPremium = 'is_premium';

  /// Premium subscription type
  static const String subscriptionType = 'subscription_type';

  /// Premium expiration date (ISO string)
  static const String subscriptionExpiry = 'subscription_expiry';

  // ============================================
  // GAMIFICATION
  // ============================================

  /// Total XP earned
  static const String totalXp = 'total_xp';

  /// Current level
  static const String currentLevel = 'current_level';

  /// Current streak (days)
  static const String currentStreak = 'current_streak';

  /// Longest streak (days)
  static const String longestStreak = 'longest_streak';

  /// Last focus date (ISO string) - for streak calculation
  static const String lastFocusDate = 'last_focus_date';

  /// List of unlocked achievement IDs (JSON array)
  static const String unlockedAchievements = 'unlocked_achievements';

  // ============================================
  // STATISTICS
  // ============================================

  /// Total focus time in minutes
  static const String totalFocusTime = 'total_focus_time';

  /// Total sessions completed
  static const String totalSessions = 'total_sessions';

  /// Total tasks completed
  static const String totalTasksCompleted = 'total_tasks_completed';

  /// Today's focus time in minutes
  static const String todayFocusTime = 'today_focus_time';

  /// Today's sessions completed
  static const String todaySessions = 'today_sessions';

  /// Today's tasks completed
  static const String todayTasksCompleted = 'today_tasks_completed';

  /// Current date for daily stats (ISO string)
  static const String statsDate = 'stats_date';

  // ============================================
  // SYNC & DATA
  // ============================================

  /// Last sync timestamp (ISO string)
  static const String lastSyncTime = 'last_sync_time';

  /// Pending sync changes (JSON array)
  static const String pendingSyncChanges = 'pending_sync_changes';

  /// Is first launch
  static const String isFirstLaunch = 'is_first_launch';

  /// Onboarding completed
  static const String onboardingCompleted = 'onboarding_completed';

  // ============================================
  // LOCALE
  // ============================================

  /// Selected language code ('en', 'es', etc.)
  static const String languageCode = 'language_code';

  // ============================================
  // DAILY GOAL
  // ============================================

  /// Daily focus goal in minutes
  static const String dailyFocusGoal = 'daily_focus_goal';

  /// Daily task goal (number of tasks)
  static const String dailyTaskGoal = 'daily_task_goal';

  // ============================================
  // REMINDERS (PRO)
  // ============================================

  /// Enable daily reminders
  static const String dailyReminderEnabled = 'daily_reminder_enabled';

  /// Daily reminder time (HH:mm format)
  static const String dailyReminderTime = 'daily_reminder_time';

  /// Enable inactivity alerts
  static const String inactivityAlertEnabled = 'inactivity_alert_enabled';

  /// Inactivity threshold in days
  static const String inactivityThreshold = 'inactivity_threshold';

  /// Enable weekly review
  static const String weeklyReviewEnabled = 'weekly_review_enabled';

  /// Weekly review day (0 = Sunday, 6 = Saturday)
  static const String weeklyReviewDay = 'weekly_review_day';
}
