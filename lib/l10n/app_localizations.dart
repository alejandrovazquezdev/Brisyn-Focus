import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Brisyn Focus'**
  String get appName;

  /// The tagline of the application
  ///
  /// In en, this message translates to:
  /// **'Stay focused. Achieve more.'**
  String get appTagline;

  /// No description provided for @navigation_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigation_home;

  /// No description provided for @navigation_timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navigation_timer;

  /// No description provided for @navigation_tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navigation_tasks;

  /// No description provided for @navigation_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navigation_statistics;

  /// No description provided for @navigation_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigation_profile;

  /// No description provided for @navigation_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigation_settings;

  /// No description provided for @timer_focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get timer_focus;

  /// No description provided for @timer_shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get timer_shortBreak;

  /// No description provided for @timer_longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get timer_longBreak;

  /// No description provided for @timer_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timer_start;

  /// No description provided for @timer_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timer_pause;

  /// No description provided for @timer_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get timer_resume;

  /// No description provided for @timer_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get timer_stop;

  /// No description provided for @timer_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get timer_reset;

  /// No description provided for @timer_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get timer_skip;

  /// No description provided for @timer_sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session Complete!'**
  String get timer_sessionComplete;

  /// No description provided for @timer_breakComplete.
  ///
  /// In en, this message translates to:
  /// **'Break Complete!'**
  String get timer_breakComplete;

  /// No description provided for @timer_minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String timer_minutes(int count);

  /// No description provided for @timer_seconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String timer_seconds(int count);

  /// No description provided for @timer_sessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String timer_sessions(int count);

  /// No description provided for @timer_preset_quick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get timer_preset_quick;

  /// No description provided for @timer_preset_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get timer_preset_standard;

  /// No description provided for @timer_preset_deep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get timer_preset_deep;

  /// No description provided for @timer_preset_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get timer_preset_custom;

  /// No description provided for @tasks_title.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks_title;

  /// No description provided for @tasks_addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get tasks_addTask;

  /// No description provided for @tasks_editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get tasks_editTask;

  /// No description provided for @tasks_deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get tasks_deleteTask;

  /// No description provided for @tasks_taskName.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get tasks_taskName;

  /// No description provided for @tasks_taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get tasks_taskDescription;

  /// No description provided for @tasks_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tasks_category;

  /// No description provided for @tasks_priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get tasks_priority;

  /// No description provided for @tasks_dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get tasks_dueDate;

  /// No description provided for @tasks_noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get tasks_noTasks;

  /// No description provided for @tasks_noTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first task to get started'**
  String get tasks_noTasksDescription;

  /// No description provided for @tasks_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tasks_completed;

  /// No description provided for @tasks_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get tasks_pending;

  /// No description provided for @tasks_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tasks_all;

  /// No description provided for @tasks_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tasks_today;

  /// No description provided for @tasks_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tasks_upcoming;

  /// No description provided for @tasks_overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get tasks_overdue;

  /// No description provided for @tasks_priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get tasks_priorityHigh;

  /// No description provided for @tasks_priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get tasks_priorityMedium;

  /// No description provided for @tasks_priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tasks_priorityLow;

  /// No description provided for @tasks_priorityNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get tasks_priorityNone;

  /// No description provided for @tasks_deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get tasks_deleteConfirmTitle;

  /// No description provided for @tasks_deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get tasks_deleteConfirmMessage;

  /// No description provided for @tasks_markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get tasks_markComplete;

  /// No description provided for @tasks_markIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as incomplete'**
  String get tasks_markIncomplete;

  /// No description provided for @statistics_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics_title;

  /// No description provided for @statistics_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statistics_today;

  /// No description provided for @statistics_thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get statistics_thisWeek;

  /// No description provided for @statistics_thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get statistics_thisMonth;

  /// No description provided for @statistics_allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get statistics_allTime;

  /// No description provided for @statistics_focusTime.
  ///
  /// In en, this message translates to:
  /// **'Focus Time'**
  String get statistics_focusTime;

  /// No description provided for @statistics_sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get statistics_sessions;

  /// No description provided for @statistics_tasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get statistics_tasksCompleted;

  /// No description provided for @statistics_currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get statistics_currentStreak;

  /// No description provided for @statistics_longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get statistics_longestStreak;

  /// No description provided for @statistics_totalXP.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get statistics_totalXP;

  /// No description provided for @statistics_level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get statistics_level;

  /// No description provided for @statistics_hours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String statistics_hours(int count);

  /// No description provided for @statistics_days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String statistics_days(int count);

  /// No description provided for @statistics_averageDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get statistics_averageDaily;

  /// No description provided for @statistics_mostProductiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most Productive Day'**
  String get statistics_mostProductiveDay;

  /// No description provided for @statistics_mostProductiveTime.
  ///
  /// In en, this message translates to:
  /// **'Most Productive Time'**
  String get statistics_mostProductiveTime;

  /// No description provided for @gamification_level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String gamification_level(int level);

  /// No description provided for @gamification_xp.
  ///
  /// In en, this message translates to:
  /// **'{count} XP'**
  String gamification_xp(int count);

  /// No description provided for @gamification_streak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String gamification_streak(int count);

  /// No description provided for @gamification_achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get gamification_achievements;

  /// No description provided for @gamification_badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get gamification_badges;

  /// No description provided for @gamification_leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get gamification_leaderboard;

  /// No description provided for @gamification_challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get gamification_challenges;

  /// No description provided for @gamification_levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get gamification_levelBeginner;

  /// No description provided for @gamification_levelApprentice.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get gamification_levelApprentice;

  /// No description provided for @gamification_levelFocused.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get gamification_levelFocused;

  /// No description provided for @gamification_levelDedicated.
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get gamification_levelDedicated;

  /// No description provided for @gamification_levelExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get gamification_levelExpert;

  /// No description provided for @gamification_levelMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get gamification_levelMaster;

  /// No description provided for @gamification_levelGrandmaster.
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get gamification_levelGrandmaster;

  /// No description provided for @gamification_levelLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get gamification_levelLegend;

  /// No description provided for @gamification_levelMythic.
  ///
  /// In en, this message translates to:
  /// **'Mythic'**
  String get gamification_levelMythic;

  /// No description provided for @gamification_levelTranscendent.
  ///
  /// In en, this message translates to:
  /// **'Transcendent'**
  String get gamification_levelTranscendent;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get settings_timer;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// No description provided for @settings_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_account;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_themeDark;

  /// No description provided for @settings_themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_themeLight;

  /// No description provided for @settings_themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_themeSystem;

  /// No description provided for @settings_accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settings_accentColor;

  /// No description provided for @settings_focusDuration.
  ///
  /// In en, this message translates to:
  /// **'Focus Duration'**
  String get settings_focusDuration;

  /// No description provided for @settings_shortBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Short Break Duration'**
  String get settings_shortBreakDuration;

  /// No description provided for @settings_longBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Long Break Duration'**
  String get settings_longBreakDuration;

  /// No description provided for @settings_sessionsBeforeLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Sessions Before Long Break'**
  String get settings_sessionsBeforeLongBreak;

  /// No description provided for @settings_autoStartBreaks.
  ///
  /// In en, this message translates to:
  /// **'Auto-start Breaks'**
  String get settings_autoStartBreaks;

  /// No description provided for @settings_autoStartNextSession.
  ///
  /// In en, this message translates to:
  /// **'Auto-start Next Session'**
  String get settings_autoStartNextSession;

  /// No description provided for @settings_keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen On'**
  String get settings_keepScreenOn;

  /// No description provided for @settings_sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settings_sound;

  /// No description provided for @settings_soundEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sound Enabled'**
  String get settings_soundEnabled;

  /// No description provided for @settings_notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get settings_notificationSound;

  /// No description provided for @settings_vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settings_vibration;

  /// No description provided for @settings_dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get settings_dailyReminder;

  /// No description provided for @settings_reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get settings_reminderTime;

  /// No description provided for @settings_weeklyReview.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review'**
  String get settings_weeklyReview;

  /// No description provided for @settings_privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacyPolicy;

  /// No description provided for @settings_termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_termsOfService;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get settings_rateApp;

  /// No description provided for @settings_shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get settings_shareApp;

  /// No description provided for @settings_contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settings_contactSupport;

  /// No description provided for @settings_logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settings_logout;

  /// No description provided for @settings_deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settings_deleteAccount;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get auth_login;

  /// No description provided for @auth_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_signup;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get auth_logout;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirmPassword;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get auth_resetPassword;

  /// No description provided for @auth_orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get auth_orContinueWith;

  /// No description provided for @auth_google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get auth_google;

  /// No description provided for @auth_apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get auth_apple;

  /// No description provided for @auth_alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_alreadyHaveAccount;

  /// No description provided for @auth_dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_dontHaveAccount;

  /// No description provided for @auth_createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_createAccount;

  /// No description provided for @auth_welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get auth_welcomeBack;

  /// No description provided for @auth_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get auth_getStarted;

  /// No description provided for @premium_title.
  ///
  /// In en, this message translates to:
  /// **'Brisyn Pro'**
  String get premium_title;

  /// No description provided for @premium_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock your full potential'**
  String get premium_subtitle;

  /// No description provided for @premium_monthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'\$4.99/month'**
  String get premium_monthlyPrice;

  /// No description provided for @premium_yearlyPrice.
  ///
  /// In en, this message translates to:
  /// **'\$39.99/year'**
  String get premium_yearlyPrice;

  /// No description provided for @premium_yearlySavings.
  ///
  /// In en, this message translates to:
  /// **'Save 33%'**
  String get premium_yearlySavings;

  /// No description provided for @premium_subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get premium_subscribe;

  /// No description provided for @premium_restore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get premium_restore;

  /// No description provided for @premium_feature_cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get premium_feature_cloudSync;

  /// No description provided for @premium_feature_cloudSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync your data across all devices'**
  String get premium_feature_cloudSyncDesc;

  /// No description provided for @premium_feature_advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get premium_feature_advancedAnalytics;

  /// No description provided for @premium_feature_advancedAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed reports and insights'**
  String get premium_feature_advancedAnalyticsDesc;

  /// No description provided for @premium_feature_advancedTasks.
  ///
  /// In en, this message translates to:
  /// **'Advanced Tasks'**
  String get premium_feature_advancedTasks;

  /// No description provided for @premium_feature_advancedTasksDesc.
  ///
  /// In en, this message translates to:
  /// **'Recurring tasks, subtasks, and Kanban view'**
  String get premium_feature_advancedTasksDesc;

  /// No description provided for @premium_feature_smartReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get premium_feature_smartReminders;

  /// No description provided for @premium_feature_smartRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'AI-powered optimal focus time suggestions'**
  String get premium_feature_smartRemindersDesc;

  /// No description provided for @premium_feature_leaderboards.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get premium_feature_leaderboards;

  /// No description provided for @premium_feature_leaderboardsDesc.
  ///
  /// In en, this message translates to:
  /// **'Compete with friends and global users'**
  String get premium_feature_leaderboardsDesc;

  /// No description provided for @premium_feature_challenges.
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenges'**
  String get premium_feature_challenges;

  /// No description provided for @premium_feature_challengesDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete challenges for bonus XP'**
  String get premium_feature_challengesDesc;

  /// No description provided for @premium_currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get premium_currentPlan;

  /// No description provided for @premium_expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String premium_expiresOn(String date);

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get common_noResults;

  /// No description provided for @common_seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get common_seeAll;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get common_yesterday;

  /// No description provided for @common_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get common_tomorrow;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_generic;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get error_network;

  /// No description provided for @error_auth_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get error_auth_invalidEmail;

  /// No description provided for @error_auth_weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get error_auth_weakPassword;

  /// No description provided for @error_auth_emailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get error_auth_emailInUse;

  /// No description provided for @error_auth_wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get error_auth_wrongCredentials;

  /// No description provided for @error_auth_userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get error_auth_userNotFound;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Brisyn Focus'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_description.
  ///
  /// In en, this message translates to:
  /// **'Your personal productivity companion for focused work and better time management.'**
  String get onboarding_welcome_description;

  /// No description provided for @onboarding_timer_title.
  ///
  /// In en, this message translates to:
  /// **'Powerful Timer'**
  String get onboarding_timer_title;

  /// No description provided for @onboarding_timer_description.
  ///
  /// In en, this message translates to:
  /// **'Use the Pomodoro technique to stay focused and take regular breaks.'**
  String get onboarding_timer_description;

  /// No description provided for @onboarding_tasks_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Tasks'**
  String get onboarding_tasks_title;

  /// No description provided for @onboarding_tasks_description.
  ///
  /// In en, this message translates to:
  /// **'Organize your work with tasks, categories, and priorities.'**
  String get onboarding_tasks_description;

  /// No description provided for @onboarding_gamification_title.
  ///
  /// In en, this message translates to:
  /// **'Stay Motivated'**
  String get onboarding_gamification_title;

  /// No description provided for @onboarding_gamification_description.
  ///
  /// In en, this message translates to:
  /// **'Earn XP, level up, and unlock achievements as you focus.'**
  String get onboarding_gamification_description;

  /// No description provided for @onboarding_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_getStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
