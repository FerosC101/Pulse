// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_hospital_app/core/themes/app_theme.dart';
import 'package:smart_hospital_app/data/models/user_type.dart';
import 'package:smart_hospital_app/presentation/providers/auth_provider.dart';
import 'package:smart_hospital_app/presentation/screens/auth/welcome_screen.dart';
import 'package:smart_hospital_app/presentation/screens/home/home_screen.dart';
import 'package:smart_hospital_app/presentation/screens/staff/staff_dashboard_screen.dart';
import 'package:smart_hospital_app/presentation/screens/splash/splash_screen.dart';
import 'firebase_options.dart'; // ✅ Make sure this exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Firebase with correct platform-specific config
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('🔥 Firebase initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'MedMap AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return Consumer(
              builder: (context, ref, child) {
                final userDataAsync = ref.watch(currentUserProvider);

                return userDataAsync.when(
                  data: (userData) {

                    debugPrint('User data loaded: ${userData?.toMap()}');
                    debugPrint('User type: ${userData?.userType}');
                    if (userData == null) {
                      debugPrint('⚠️ User data is null, redirecting to welcome');
                      return const WelcomeScreen();
                    }

                    // ✅ Route based on user type
                    switch (userData.userType) {
                      case UserType.hospitalStaff:
                        return StaffDashboardScreen();
                      case UserType.doctor:
                        return const StaffDashboardScreen();
                      case UserType.patient:
                        return const HomeScreen();
                    }
                  },
                  loading: () => const SplashScreen(),
                  error: (error, stack) {
                    debugPrint('User data error: $error');
                    return const WelcomeScreen();
                  },
                );
              },
            );
          }
          return const WelcomeScreen();
        },
        loading: () => const SplashScreen(),
        error: (error, stack) {
          debugPrint('Auth error: $error');
          return const WelcomeScreen();
        },
      ),
    );
  }
}
