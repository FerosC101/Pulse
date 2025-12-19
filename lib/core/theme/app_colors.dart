import 'package:flutter/material.dart';

/// App color palette following the Pulse brand identity
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFF7444E); // Coral Red - Primary accent
  static const Color background = Color(0xFFF7F8F3); // Off-white background
  static const Color secondary = Color(0xFF78BCC4); // Teal/Cyan
  static const Color darkText = Color(0xFF002C3E); // Dark blue for text

  // Additional Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color cardBackground = Color(0xFFF5F5F5);

  // Gradient Colors (for logo/decorative elements)
  static const Color gradientStart = Color(0xFFF7444E);
  static const Color gradientEnd = Color(0xFF78BCC4);

  // Prevent instantiation
  AppColors._();
}
