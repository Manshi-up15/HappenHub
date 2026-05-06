import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Palette ──────────────────────────────────────────
  static const Color primary     = Color(0xFF1A1A2E); // deep navy
  static const Color accent      = Color(0xFFE94560);  // vivid coral-red
  static const Color accentGold  = Color(0xFFFFB347);  // warm amber
  static const Color surface     = Color(0xFF16213E);  // dark blue surface
  static const Color cardBg      = Color(0xFF0F3460);  // rich blue card
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B8C9);
  static const Color divider     = Color(0xFF2A2A4A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentGold,
        surface: surface,
        background: primary,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24,
        ),
        titleLarge: GoogleFonts.dmSans(
          color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20,
        ),
        titleMedium: GoogleFonts.dmSans(
          color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: textPrimary, fontSize: 16,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: textSecondary, fontSize: 14,
        ),
        labelLarge: GoogleFonts.dmSans(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: accent,
        labelStyle: GoogleFonts.dmSans(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: divider),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBg,
        contentTextStyle: GoogleFonts.dmSans(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
