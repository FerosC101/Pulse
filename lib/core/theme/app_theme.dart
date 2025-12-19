import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
        onSurface: AppColors.darkText,
        onPrimary: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // Text Theme using DM Sans for body and Open Sans for titles
      textTheme: TextTheme(
        // Display styles (for logo/titles) - Open Sans
        displayLarge: GoogleFonts.openSans(
          fontSize: 57,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: AppColors.darkText,
        ),
        displayMedium: GoogleFonts.openSans(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: AppColors.darkText,
        ),
        displaySmall: GoogleFonts.openSans(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: AppColors.darkText,
        ),

        // Headline styles - Open Sans
        headlineLarge: GoogleFonts.openSans(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: AppColors.darkText,
        ),
        headlineMedium: GoogleFonts.openSans(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        headlineSmall: GoogleFonts.openSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),

        // Title styles - DM Sans
        titleLarge: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleSmall: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),

        // Body styles - DM Sans
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.darkText,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkText,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),

        // Label styles - DM Sans
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),
        labelMedium: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.grey,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.grey,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.grey,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  // Prevent instantiation
  AppTheme._();
}
