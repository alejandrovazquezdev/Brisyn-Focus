import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/routes.dart';
import 'app/theme/app_theme.dart';
import 'core/services/firebase_options.dart';
import 'core/services/purchase_service.dart';
import 'core/services/desktop_auth_service.dart';
import 'features/tasks/domain/models/task.dart';
import 'features/activities/domain/models/activity_category.dart';
import 'features/activities/domain/models/activity_session.dart';
import 'features/wellness/domain/models/focus_streak.dart';
import 'features/wellness/domain/models/custom_counter.dart';
import 'features/wellness/domain/models/personal_goal.dart';
import 'shared/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure desktop auth service (avoids keychain issues on macOS)
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    // Initialize our REST API based auth service
    await DesktopAuthService.instance.initialize(sharedPreferences);
  }

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  
  // One-time migration: delete old tasks box that doesn't have new fields
  // This can be removed after all users have migrated
  const migrationKey = 'tasks_v2_migrated';
  final hasMigrated = sharedPreferences.getBool(migrationKey) ?? false;
  if (!hasMigrated) {
    try {
      await Hive.deleteBoxFromDisk('tasks');
      await sharedPreferences.setBool(migrationKey, true);
      print('Tasks migration: Old data cleared');
    } catch (e) {
      print('Tasks migration: $e');
    }
  }
  
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(RecurrenceTypeAdapter());
  Hive.registerAdapter(ActivityCategoryAdapter());
  Hive.registerAdapter(ActivityIconAdapter());
  Hive.registerAdapter(ActivitySessionAdapter());
  // Wellness adapters
  Hive.registerAdapter(FocusStreakAdapter());
  Hive.registerAdapter(CustomCounterAdapter());
  Hive.registerAdapter(CounterTypeAdapter());
  Hive.registerAdapter(CounterEntryAdapter());
  Hive.registerAdapter(PersonalGoalAdapter());
  Hive.registerAdapter(GoalTypeAdapter());

  // Initialize Purchase Service (RevenueCat for mobile, Stripe for desktop)
  // If user is logged in, pass their ID for cross-device sync
  String? currentUserId;
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    // Desktop: get user ID from DesktopAuthService
    currentUserId = DesktopAuthService.instance.currentUserId;
  } else {
    // Mobile/Web: get user ID from Firebase Auth
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }
  
  await PurchaseService.instance.initialize(
    userId: currentUserId,
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const BrisynFocusApp(),
    ),
  );
}

class BrisynFocusApp extends ConsumerWidget {
  const BrisynFocusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Brisyn Focus',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme(accent: accentColor),
      darkTheme: AppTheme.darkTheme(accent: accentColor),
      themeMode: themeMode,

      // Routing
      routerConfig: router,

      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        // TODO: Add AppLocalizations.delegate after running flutter gen-l10n
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
