import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_hospital_app/core/themes/app_theme.dart';
import 'package:smart_hospital_app/presentation/providers/auth_provider.dart';
import 'package:smart_hospital_app/presentation/screens/auth/welcome_screen.dart';
import 'package:smart_hospital_app/presentation/screens/home/home_screen.dart';
import 'package:smart_hospital_app/presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
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
            return const HomeScreen();
          }
          return const WelcomeScreen();
        },
        loading: () => const SplashScreen(),
        error: (error, stack) {
          print('Auth error: $error');
          return const WelcomeScreen();
        },
      ),
    );
  }
}