import 'package:flutter/material.dart';

/// App color palette following the Pulse brand identity
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFF7444E); // Coral Red - Primary accent
  static const Color primaryRed = Color(0xFFF7444E); // Same as primary - for consistency
  static const Color mutedBlue = Color(0xFF78BCC4); // Same as secondary
  static const Color darkNavy = Color(0xFF002C3E); // Same as darkText
  static const Color background = Color(0xFFF7F8F3); // Off-white background
  static const Color secondary = Color(0xFF78BCC4); // Teal/Cyan
  static const Color darkText = Color(0xFF002C3E); // Dark blue for text

  // Additional Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color cardBackground = Color(0xFFF5F5F5);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF002C3E); // Same as darkText
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Gradient Colors (for logo/decorative elements)
  static const Color gradientStart = Color(0xFFF7444E);
  static const Color gradientEnd = Color(0xFF78BCC4);

  // Prevent instantiation
  AppColors._();
}
