import 'package:flutter/material.dart';

/// Brisyn Focus Color System
/// Professional color palette with dark/light themes and user-selectable accent colors.

class AppColors {
  AppColors._();

  // ============================================
  // DARK THEME COLORS
  // ============================================

  static const darkBackground = Color(0xFF0D0D0D);
  static const darkBackgroundSecondary = Color(0xFF1A1A1A);
  static const darkSurface = Color(0xFF242424);
  static const darkSurfaceVariant = Color(0xFF2A2A2A);
  static const darkBorder = Color(0xFF333333);
  static const darkBorderSubtle = Color(0xFF2A2A2A);

  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA0A0A0);
  static const darkTextTertiary = Color(0xFF666666);
  static const darkTextDisabled = Color(0xFF4A4A4A);

  // ============================================
  // LIGHT THEME COLORS
  // ============================================

  static const lightBackground = Color(0xFFFFFFFF);
  static const lightBackgroundSecondary = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFAFAFA);
  static const lightSurfaceVariant = Color(0xFFF0F0F0);
  static const lightBorder = Color(0xFFE0E0E0);
  static const lightBorderSubtle = Color(0xFFEEEEEE);

  static const lightTextPrimary = Color(0xFF0D0D0D);
  static const lightTextSecondary = Color(0xFF666666);
  static const lightTextTertiary = Color(0xFF999999);
  static const lightTextDisabled = Color(0xFFBBBBBB);

  // ============================================
  // ACCENT COLORS (User Selectable)
  // ============================================

  static const accentBlue = Color(0xFF3B82F6);
  static const accentGreen = Color(0xFF10B981);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentRed = Color(0xFFEF4444);
  static const accentCyan = Color(0xFF06B6D4);
  static const accentPink = Color(0xFFEC4899);

  /// Default accent color
  static const defaultAccent = accentBlue;

  /// List of all available accent colors for user selection
  static const List<Color> accentOptions = [
    accentBlue,
    accentGreen,
    accentPurple,
    accentOrange,
    accentRed,
    accentCyan,
    accentPink,
  ];

  /// Accent color names for display
  static final Map<Color, String> accentNames = {
    accentBlue: 'Blue',
    accentGreen: 'Green',
    accentPurple: 'Purple',
    accentOrange: 'Orange',
    accentRed: 'Red',
    accentCyan: 'Cyan',
    accentPink: 'Pink',
  };

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF34D399);
  static const successDark = Color(0xFF059669);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFBBF24);
  static const warningDark = Color(0xFFD97706);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFF87171);
  static const errorDark = Color(0xFFDC2626);

  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFF60A5FA);
  static const infoDark = Color(0xFF2563EB);

  // ============================================
  // GAMIFICATION COLORS
  // ============================================

  static const xpGold = Color(0xFFFFD700);
  static const streakFlame = Color(0xFFFF6B35);
  static const levelBronze = Color(0xFFCD7F32);
  static const levelSilver = Color(0xFFC0C0C0);
  static const levelGold = Color(0xFFFFD700);
  static const levelPlatinum = Color(0xFFE5E4E2);
  static const levelDiamond = Color(0xFFB9F2FF);

  // ============================================
  // TIMER COLORS
  // ============================================

  static const timerFocus = Color(0xFF3B82F6);
  static const timerShortBreak = Color(0xFF10B981);
  static const timerLongBreak = Color(0xFF8B5CF6);

  // ============================================
  // PRIORITY COLORS
  // ============================================

  static const priorityHigh = Color(0xFFEF4444);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityLow = Color(0xFF10B981);
  static const priorityNone = Color(0xFF6B7280);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get a slightly transparent version of a color
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get accent color with appropriate opacity for backgrounds
  static Color accentBackground(Color accent) {
    return accent.withOpacity(0.1);
  }

  /// Get accent color with appropriate opacity for hover states
  static Color accentHover(Color accent) {
    return accent.withOpacity(0.15);
  }

  /// Get accent color with appropriate opacity for pressed states
  static Color accentPressed(Color accent) {
    return accent.withOpacity(0.2);
  }
}

/// Extension for easier color manipulation
extension ColorExtension on Color {
  /// Darken a color by a percentage (0.0 to 1.0)
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Lighten a color by a percentage (0.0 to 1.0)
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
