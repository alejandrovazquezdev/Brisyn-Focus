import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brisyn Focus Typography System
/// Using Inter for UI and JetBrains Mono for timer displays.

class AppTypography {
  AppTypography._();

  // ============================================
  // FONT FAMILIES
  // ============================================

  static String get primaryFontFamily => 'Inter';
  static String get monoFontFamily => 'JetBrainsMono';

  // ============================================
  // TEXT STYLES - HEADINGS
  // ============================================

  /// Display Large - 57px
  /// Used for: Hero sections, large feature text
  static TextStyle displayLarge(Color color) => GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.12,
        color: color,
      );

  /// Display Medium - 45px
  /// Used for: Section headers on large screens
  static TextStyle displayMedium(Color color) => GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.16,
        color: color,
      );

  /// Display Small - 36px
  /// Used for: Important callouts
  static TextStyle displaySmall(Color color) => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.22,
        color: color,
      );

  /// Headline Large - 32px
  /// Used for: Page titles
  static TextStyle headlineLarge(Color color) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
        color: color,
      );

  /// Headline Medium - 28px
  /// Used for: Section titles
  static TextStyle headlineMedium(Color color) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.29,
        color: color,
      );

  /// Headline Small - 24px
  /// Used for: Card titles, important labels
  static TextStyle headlineSmall(Color color) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: color,
      );

  // ============================================
  // TEXT STYLES - TITLES
  // ============================================

  /// Title Large - 22px
  /// Used for: Navigation titles, prominent labels
  static TextStyle titleLarge(Color color) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: color,
      );

  /// Title Medium - 16px
  /// Used for: List item titles, tab labels
  static TextStyle titleMedium(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
        color: color,
      );

  /// Title Small - 14px
  /// Used for: Small titles, emphasized captions
  static TextStyle titleSmall(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  // ============================================
  // TEXT STYLES - BODY
  // ============================================

  /// Body Large - 16px
  /// Used for: Primary body text
  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
        color: color,
      );

  /// Body Medium - 14px
  /// Used for: Secondary body text
  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: color,
      );

  /// Body Small - 12px
  /// Used for: Captions, helper text
  static TextStyle bodySmall(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: color,
      );

  // ============================================
  // TEXT STYLES - LABELS
  // ============================================

  /// Label Large - 14px
  /// Used for: Buttons, prominent labels
  static TextStyle labelLarge(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  /// Label Medium - 12px
  /// Used for: Smaller buttons, tags
  static TextStyle labelMedium(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: color,
      );

  /// Label Small - 11px
  /// Used for: Tiny labels, timestamps
  static TextStyle labelSmall(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: color,
      );

  // ============================================
  // TEXT STYLES - TIMER (MONOSPACE)
  // ============================================

  /// Timer Display - 72px
  /// Used for: Main timer countdown
  static TextStyle timerDisplay(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 72,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        height: 1.0,
        color: color,
      );

  /// Timer Display Large - 96px
  /// Used for: Full-screen timer
  static TextStyle timerDisplayLarge(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 96,
        fontWeight: FontWeight.w500,
        letterSpacing: 4,
        height: 1.0,
        color: color,
      );

  /// Timer Display Small - 48px
  /// Used for: Compact timer view
  static TextStyle timerDisplaySmall(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 48,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        height: 1.0,
        color: color,
      );

  /// Timer Label - 14px
  /// Used for: Timer labels (e.g., "FOCUS", "BREAK")
  static TextStyle timerLabel(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        height: 1.0,
        color: color,
      );

  // ============================================
  // TEXT STYLES - STATISTICS
  // ============================================

  /// Stat Value - 36px
  /// Used for: Large statistic numbers
  static TextStyle statValue(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.0,
        color: color,
      );

  /// Stat Value Small - 24px
  /// Used for: Smaller statistic numbers
  static TextStyle statValueSmall(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.0,
        color: color,
      );

  // ============================================
  // TEXT THEME BUILDER
  // ============================================

  /// Build a complete TextTheme with the given colors
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: displayLarge(primary),
      displayMedium: displayMedium(primary),
      displaySmall: displaySmall(primary),
      headlineLarge: headlineLarge(primary),
      headlineMedium: headlineMedium(primary),
      headlineSmall: headlineSmall(primary),
      titleLarge: titleLarge(primary),
      titleMedium: titleMedium(primary),
      titleSmall: titleSmall(primary),
      bodyLarge: bodyLarge(primary),
      bodyMedium: bodyMedium(secondary),
      bodySmall: bodySmall(secondary),
      labelLarge: labelLarge(primary),
      labelMedium: labelMedium(secondary),
      labelSmall: labelSmall(secondary),
    );
  }
}
