import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../presentation/screens/auth/entry_page.dart';

/// Unified logout utility for consistent logout behavior across the app
class AuthUtils {
  /// Global logout handler that:
  /// - Clears user session data
  /// - Signs out from Firebase
  /// - Clears navigation stack
  /// - Redirects to Entry Page
  static Future<void> handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Sign out from Firebase (clears session)
      final authService = AuthService();
      await authService.signOut();

      // Navigate to Entry Page and clear entire navigation stack
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EntryPage()),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      
      // Even if there's an error, still navigate to entry page
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EntryPage()),
          (route) => false,
        );
      }
    }
  }

  /// Alternative logout using named routes (if app uses named routing)
  static Future<void> handleLogoutWithNamedRoute(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Sign out from Firebase
      final authService = AuthService();
      await authService.signOut();

      // Navigate using named route
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/', // Entry route
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    }
  }

  // Prevent instantiation
  AuthUtils._();
}
