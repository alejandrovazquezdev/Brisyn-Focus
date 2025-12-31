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

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
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

  // Initialize Purchase Service (RevenueCat)
  // If user is logged in, pass their ID for cross-device sync
  final currentUser = FirebaseAuth.instance.currentUser;
  await PurchaseService.instance.initialize(
    userId: currentUser?.uid,
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
