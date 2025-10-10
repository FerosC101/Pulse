import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated file
import 'package:smart_hospital_app/core/themes/app_theme.dart';
import 'package:smart_hospital_app/presentation/screens/splash/splash_screen.dart';
import 'package:smart_hospital_app/presentation/screens/auth/welcome_screen.dart';
import 'package:smart_hospital_app/presentation/screens/home/home_screen.dart';
import 'package:smart_hospital_app/presentation/providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize Firebase before app starts
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing Firebase: ${snapshot.error}'),
              ),
            ),
          );
        }

        // Once complete, show app
        if (snapshot.connectionState == ConnectionState.done) {
          return const ProviderScope(
            child: AppRoot(),
          );
        }

        // Otherwise, show loading indicator
        return const MaterialApp(
          home: SplashScreen(),
        );
      },
    );
  }
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

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
            return const HomeScreen();
          }
          return const WelcomeScreen();
        },
        loading: () => const SplashScreen(),
        error: (error, stack) {
          return Scaffold(
            body: Center(
              child: Text('Auth error: $error'),
            ),
          );
        },
      ),
    );
  }
}
