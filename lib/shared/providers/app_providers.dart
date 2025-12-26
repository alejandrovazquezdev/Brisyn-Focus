import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/colors.dart';
import '../../core/constants/storage_keys.dart';

/// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ThemeModeNotifier(prefs);
  },
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final themeString = _prefs.getString(StorageKeys.themeMode);
    switch (themeString) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
        state = ThemeMode.system;
        break;
      default:
        state = ThemeMode.dark; // Default to dark theme
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(StorageKeys.themeMode, mode.name);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

/// Accent color provider
final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccentColorNotifier(prefs);
});

class AccentColorNotifier extends StateNotifier<Color> {
  final SharedPreferences _prefs;

  AccentColorNotifier(this._prefs) : super(AppColors.defaultAccent) {
    _loadAccentColor();
  }

  void _loadAccentColor() {
    final colorHex = _prefs.getString(StorageKeys.accentColor);
    if (colorHex != null) {
      try {
        final colorValue = int.parse(colorHex, radix: 16);
        state = Color(colorValue);
      } catch (_) {
        state = AppColors.defaultAccent;
      }
    }
  }

  Future<void> setAccentColor(Color color) async {
    state = color;
    await _prefs.setString(
      StorageKeys.accentColor,
      color.value.toRadixString(16),
    );
  }
}

/// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(const Locale('en')) {
    _loadLocale();
  }

  void _loadLocale() {
    final languageCode = _prefs.getString(StorageKeys.languageCode);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(StorageKeys.languageCode, locale.languageCode);
  }
}

/// Premium status provider
final isPremiumProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(StorageKeys.isPremium) ?? false;
});

/// User logged in provider
final isLoggedInProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(StorageKeys.isLoggedIn) ?? false;
});

/// First launch provider
final isFirstLaunchProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(StorageKeys.isFirstLaunch) ?? true;
});
