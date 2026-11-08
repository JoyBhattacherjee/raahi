import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colours for Raahi.
class AppColors {
  static const indigo = Color(0xFF4F46E5);
  static const violet = Color(0xFF7C3AED);
  static const amber = Color(0xFFF59E0B);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const ink = Color(0xFF0F172A);
  static const slate = Color(0xFF64748B);

  static const brandGradient = LinearGradient(
    colors: [indigo, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunsetGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

extension ColorOpacityX on Color {
  /// Opacity helper that works on every Flutter version.
  Color o(double opacity) =>
      withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get cardColor2 => isDark ? const Color(0xFF151C2F) : Colors.white;
  Color get muted => isDark ? const Color(0xFF94A3B8) : AppColors.slate;
  Color get border =>
      isDark ? const Color(0xFF263149) : const Color(0xFFE2E8F0);
  Color get soft => isDark ? const Color(0xFF1C2540) : const Color(0xFFF1F5F9);
  Color get textStrong => isDark ? Colors.white : AppColors.ink;
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.indigo,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF818CF8) : AppColors.indigo,
      surface: isDark ? const Color(0xFF111827) : Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );

    final textColor = isDark ? Colors.white : AppColors.ink;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: textColor, displayColor: textColor);

    // Built through the constructor (not copyWith) so it keeps compiling as
    // Flutter migrates component themes to their *ThemeData variants.
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0B1020) : const Color(0xFFF8FAFC),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: textColor,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1C2540) : const Color(0xFFF1F5F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.indigo, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF263149) : AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerColor: isDark ? const Color(0xFF263149) : const Color(0xFFE2E8F0),
    );
  }
}
