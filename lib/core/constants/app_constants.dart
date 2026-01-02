/// App-wide constants for Brisyn Focus

class AppConstants {
  AppConstants._();

  // ============================================
  // APP INFO
  // ============================================

  static const String appName = 'Brisyn Focus';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ============================================
  // TIMER DEFAULTS
  // ============================================

  /// Default focus session duration in minutes
  static const int defaultFocusDuration = 25;

  /// Default short break duration in minutes
  static const int defaultShortBreakDuration = 5;

  /// Default long break duration in minutes
  static const int defaultLongBreakDuration = 15;

  /// Number of focus sessions before a long break
  static const int sessionsBeforeLongBreak = 4;

  /// Minimum timer duration in minutes
  static const int minTimerDuration = 1;

  /// Maximum timer duration in minutes
  static const int maxTimerDuration = 120;

  // Timer presets (in minutes)
  static const List<int> timerPresets = [1, 15, 25, 50, 90];

  // ============================================
  // GAMIFICATION
  // ============================================

  /// XP earned per minute of focus
  static const int xpPerMinute = 1;

  /// Bonus XP for completing a task during focus
  static const int xpBonusTaskComplete = 10;

  /// Bonus XP multiplier for streak (per day)
  static const double xpStreakMultiplier = 0.1;

  /// Maximum streak bonus multiplier
  static const double maxStreakMultiplier = 2.0;

  /// XP thresholds for each level
  static const List<int> levelThresholds = [
    0, // Level 1 - Beginner
    500, // Level 2 - Apprentice
    1500, // Level 3 - Focused
    3500, // Level 4 - Dedicated
    7000, // Level 5 - Expert
    12000, // Level 6 - Master
    20000, // Level 7 - Grandmaster
    35000, // Level 8 - Legend
    60000, // Level 9 - Mythic
    100000, // Level 10 - Transcendent
  ];

  /// Level titles
  static const List<String> levelTitles = [
    'Beginner',
    'Apprentice',
    'Focused',
    'Dedicated',
    'Expert',
    'Master',
    'Grandmaster',
    'Legend',
    'Mythic',
    'Transcendent',
  ];

  // ============================================
  // TASK PRIORITIES
  // ============================================

  static const int priorityHigh = 3;
  static const int priorityMedium = 2;
  static const int priorityLow = 1;
  static const int priorityNone = 0;

  // ============================================
  // UI CONSTANTS
  // ============================================

  /// Standard border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  /// Standard padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  /// Standard icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  /// Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============================================
  // PREMIUM / SUBSCRIPTION
  // ============================================

  static const String proMonthlyId = 'brisyn_pro_monthly';
  static const String proYearlyId = 'brisyn_pro_yearly';
  static const double proMonthlyPrice = 4.99;
  static const double proYearlyPrice = 39.99;

  // ============================================
  // NOTIFICATIONS
  // ============================================

  static const String timerNotificationChannelId = 'brisyn_timer';
  static const String timerNotificationChannelName = 'Timer';
  static const String timerNotificationChannelDescription =
      'Notifications for timer events';

  static const String reminderNotificationChannelId = 'brisyn_reminders';
  static const String reminderNotificationChannelName = 'Reminders';
  static const String reminderNotificationChannelDescription =
      'Notifications for reminders and goals';

  // ============================================
  // FIREBASE COLLECTIONS
  // ============================================

  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String sessionsCollection = 'sessions';
  static const String statisticsCollection = 'statistics';
  static const String achievementsCollection = 'achievements';

  // ============================================
  // DATE/TIME FORMATS
  // ============================================

  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'h:mm a';

  // ============================================
  // LIMITS
  // ============================================

  /// Maximum number of tasks per user (free tier)
  static const int maxTasksFree = 50;

  /// Maximum number of categories (free tier)
  static const int maxCategoriesFree = 5;

  /// Maximum task title length
  static const int maxTaskTitleLength = 100;

  /// Maximum task description length
  static const int maxTaskDescriptionLength = 500;

  /// Maximum category name length
  static const int maxCategoryNameLength = 30;

  // ============================================
  // EXTERNAL LINKS
  // ============================================

  static const String websiteUrl = 'https://brisyn.vazquezalejandro.digital';
  static const String privacyPolicyUrl = 'https://brisyn.vazquezalejandro.digital/privacy.html';
  static const String termsOfServiceUrl = 'https://brisyn.vazquezalejandro.digital/terms.html';
  static const String supportEmail = 'support@brisyn.app';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=app.brisyn.focus';
  static const String appStoreUrl =
      'https://apps.apple.com/app/brisyn-focus/id0000000000';
}
