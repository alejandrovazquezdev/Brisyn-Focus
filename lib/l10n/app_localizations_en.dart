// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Brisyn Focus';

  @override
  String get appTagline => 'Stay focused. Achieve more.';

  @override
  String get navigation_home => 'Home';

  @override
  String get navigation_timer => 'Timer';

  @override
  String get navigation_tasks => 'Tasks';

  @override
  String get navigation_statistics => 'Statistics';

  @override
  String get navigation_profile => 'Profile';

  @override
  String get navigation_settings => 'Settings';

  @override
  String get timer_focus => 'Focus';

  @override
  String get timer_shortBreak => 'Short Break';

  @override
  String get timer_longBreak => 'Long Break';

  @override
  String get timer_start => 'Start';

  @override
  String get timer_pause => 'Pause';

  @override
  String get timer_resume => 'Resume';

  @override
  String get timer_stop => 'Stop';

  @override
  String get timer_reset => 'Reset';

  @override
  String get timer_skip => 'Skip';

  @override
  String get timer_sessionComplete => 'Session Complete!';

  @override
  String get timer_breakComplete => 'Break Complete!';

  @override
  String timer_minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String timer_seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String timer_sessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get timer_preset_quick => 'Quick';

  @override
  String get timer_preset_standard => 'Standard';

  @override
  String get timer_preset_deep => 'Deep';

  @override
  String get timer_preset_custom => 'Custom';

  @override
  String get tasks_title => 'Tasks';

  @override
  String get tasks_addTask => 'Add Task';

  @override
  String get tasks_editTask => 'Edit Task';

  @override
  String get tasks_deleteTask => 'Delete Task';

  @override
  String get tasks_taskName => 'Task name';

  @override
  String get tasks_taskDescription => 'Description (optional)';

  @override
  String get tasks_category => 'Category';

  @override
  String get tasks_priority => 'Priority';

  @override
  String get tasks_dueDate => 'Due date';

  @override
  String get tasks_noTasks => 'No tasks yet';

  @override
  String get tasks_noTasksDescription => 'Add your first task to get started';

  @override
  String get tasks_completed => 'Completed';

  @override
  String get tasks_pending => 'Pending';

  @override
  String get tasks_all => 'All';

  @override
  String get tasks_today => 'Today';

  @override
  String get tasks_upcoming => 'Upcoming';

  @override
  String get tasks_overdue => 'Overdue';

  @override
  String get tasks_priorityHigh => 'High';

  @override
  String get tasks_priorityMedium => 'Medium';

  @override
  String get tasks_priorityLow => 'Low';

  @override
  String get tasks_priorityNone => 'None';

  @override
  String get tasks_deleteConfirmTitle => 'Delete Task';

  @override
  String get tasks_deleteConfirmMessage =>
      'Are you sure you want to delete this task?';

  @override
  String get tasks_markComplete => 'Mark as complete';

  @override
  String get tasks_markIncomplete => 'Mark as incomplete';

  @override
  String get statistics_title => 'Statistics';

  @override
  String get statistics_today => 'Today';

  @override
  String get statistics_thisWeek => 'This Week';

  @override
  String get statistics_thisMonth => 'This Month';

  @override
  String get statistics_allTime => 'All Time';

  @override
  String get statistics_focusTime => 'Focus Time';

  @override
  String get statistics_sessions => 'Sessions';

  @override
  String get statistics_tasksCompleted => 'Tasks Completed';

  @override
  String get statistics_currentStreak => 'Current Streak';

  @override
  String get statistics_longestStreak => 'Longest Streak';

  @override
  String get statistics_totalXP => 'Total XP';

  @override
  String get statistics_level => 'Level';

  @override
  String statistics_hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String statistics_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get statistics_averageDaily => 'Daily Average';

  @override
  String get statistics_mostProductiveDay => 'Most Productive Day';

  @override
  String get statistics_mostProductiveTime => 'Most Productive Time';

  @override
  String gamification_level(int level) {
    return 'Level $level';
  }

  @override
  String gamification_xp(int count) {
    return '$count XP';
  }

  @override
  String gamification_streak(int count) {
    return '$count day streak';
  }

  @override
  String get gamification_achievements => 'Achievements';

  @override
  String get gamification_badges => 'Badges';

  @override
  String get gamification_leaderboard => 'Leaderboard';

  @override
  String get gamification_challenges => 'Challenges';

  @override
  String get gamification_levelBeginner => 'Beginner';

  @override
  String get gamification_levelApprentice => 'Apprentice';

  @override
  String get gamification_levelFocused => 'Focused';

  @override
  String get gamification_levelDedicated => 'Dedicated';

  @override
  String get gamification_levelExpert => 'Expert';

  @override
  String get gamification_levelMaster => 'Master';

  @override
  String get gamification_levelGrandmaster => 'Grandmaster';

  @override
  String get gamification_levelLegend => 'Legend';

  @override
  String get gamification_levelMythic => 'Mythic';

  @override
  String get gamification_levelTranscendent => 'Transcendent';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_general => 'General';

  @override
  String get settings_timer => 'Timer';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_account => 'Account';

  @override
  String get settings_about => 'About';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeSystem => 'System';

  @override
  String get settings_accentColor => 'Accent Color';

  @override
  String get settings_focusDuration => 'Focus Duration';

  @override
  String get settings_shortBreakDuration => 'Short Break Duration';

  @override
  String get settings_longBreakDuration => 'Long Break Duration';

  @override
  String get settings_sessionsBeforeLongBreak => 'Sessions Before Long Break';

  @override
  String get settings_autoStartBreaks => 'Auto-start Breaks';

  @override
  String get settings_autoStartNextSession => 'Auto-start Next Session';

  @override
  String get settings_keepScreenOn => 'Keep Screen On';

  @override
  String get settings_sound => 'Sound';

  @override
  String get settings_soundEnabled => 'Sound Enabled';

  @override
  String get settings_notificationSound => 'Notification Sound';

  @override
  String get settings_vibration => 'Vibration';

  @override
  String get settings_dailyReminder => 'Daily Reminder';

  @override
  String get settings_reminderTime => 'Reminder Time';

  @override
  String get settings_weeklyReview => 'Weekly Review';

  @override
  String get settings_privacyPolicy => 'Privacy Policy';

  @override
  String get settings_termsOfService => 'Terms of Service';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_rateApp => 'Rate App';

  @override
  String get settings_shareApp => 'Share App';

  @override
  String get settings_contactSupport => 'Contact Support';

  @override
  String get settings_logout => 'Log Out';

  @override
  String get settings_deleteAccount => 'Delete Account';

  @override
  String get auth_login => 'Log In';

  @override
  String get auth_signup => 'Sign Up';

  @override
  String get auth_logout => 'Log Out';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_confirmPassword => 'Confirm Password';

  @override
  String get auth_forgotPassword => 'Forgot Password?';

  @override
  String get auth_resetPassword => 'Reset Password';

  @override
  String get auth_orContinueWith => 'Or continue with';

  @override
  String get auth_google => 'Google';

  @override
  String get auth_apple => 'Apple';

  @override
  String get auth_alreadyHaveAccount => 'Already have an account?';

  @override
  String get auth_dontHaveAccount => 'Don\'t have an account?';

  @override
  String get auth_createAccount => 'Create Account';

  @override
  String get auth_welcomeBack => 'Welcome back!';

  @override
  String get auth_getStarted => 'Get Started';

  @override
  String get premium_title => 'Brisyn Pro';

  @override
  String get premium_subtitle => 'Unlock your full potential';

  @override
  String get premium_monthlyPrice => '\$4.99/month';

  @override
  String get premium_yearlyPrice => '\$39.99/year';

  @override
  String get premium_yearlySavings => 'Save 33%';

  @override
  String get premium_subscribe => 'Subscribe';

  @override
  String get premium_restore => 'Restore Purchases';

  @override
  String get premium_feature_cloudSync => 'Cloud Sync';

  @override
  String get premium_feature_cloudSyncDesc =>
      'Sync your data across all devices';

  @override
  String get premium_feature_advancedAnalytics => 'Advanced Analytics';

  @override
  String get premium_feature_advancedAnalyticsDesc =>
      'Detailed reports and insights';

  @override
  String get premium_feature_advancedTasks => 'Advanced Tasks';

  @override
  String get premium_feature_advancedTasksDesc =>
      'Recurring tasks, subtasks, and Kanban view';

  @override
  String get premium_feature_smartReminders => 'Smart Reminders';

  @override
  String get premium_feature_smartRemindersDesc =>
      'AI-powered optimal focus time suggestions';

  @override
  String get premium_feature_leaderboards => 'Leaderboards';

  @override
  String get premium_feature_leaderboardsDesc =>
      'Compete with friends and global users';

  @override
  String get premium_feature_challenges => 'Weekly Challenges';

  @override
  String get premium_feature_challengesDesc =>
      'Complete challenges for bonus XP';

  @override
  String get premium_currentPlan => 'Current Plan';

  @override
  String premium_expiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_done => 'Done';

  @override
  String get common_next => 'Next';

  @override
  String get common_back => 'Back';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_ok => 'OK';

  @override
  String get common_close => 'Close';

  @override
  String get common_search => 'Search';

  @override
  String get common_noResults => 'No results found';

  @override
  String get common_seeAll => 'See All';

  @override
  String get common_today => 'Today';

  @override
  String get common_yesterday => 'Yesterday';

  @override
  String get common_tomorrow => 'Tomorrow';

  @override
  String get error_generic => 'Something went wrong. Please try again.';

  @override
  String get error_network =>
      'No internet connection. Please check your network.';

  @override
  String get error_auth_invalidEmail => 'Please enter a valid email address.';

  @override
  String get error_auth_weakPassword =>
      'Password must be at least 8 characters.';

  @override
  String get error_auth_emailInUse => 'This email is already in use.';

  @override
  String get error_auth_wrongCredentials => 'Invalid email or password.';

  @override
  String get error_auth_userNotFound => 'No account found with this email.';

  @override
  String get onboarding_welcome_title => 'Welcome to Brisyn Focus';

  @override
  String get onboarding_welcome_description =>
      'Your personal productivity companion for focused work and better time management.';

  @override
  String get onboarding_timer_title => 'Powerful Timer';

  @override
  String get onboarding_timer_description =>
      'Use the Pomodoro technique to stay focused and take regular breaks.';

  @override
  String get onboarding_tasks_title => 'Manage Tasks';

  @override
  String get onboarding_tasks_description =>
      'Organize your work with tasks, categories, and priorities.';

  @override
  String get onboarding_gamification_title => 'Stay Motivated';

  @override
  String get onboarding_gamification_description =>
      'Earn XP, level up, and unlock achievements as you focus.';

  @override
  String get onboarding_getStarted => 'Get Started';
}
