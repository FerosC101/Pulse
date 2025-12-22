// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/auth/entry_page.dart';
import 'presentation/screens/auth/role_selection_page.dart';
import 'presentation/screens/auth/register_page.dart';
import 'presentation/screens/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (optional for web)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // ignore: avoid_print
    print('⚠️ .env file not found, using default configuration');
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ignore: avoid_print
    print('✅ Firebase initialized successfully');
  } catch (e) {
    // ignore: avoid_print
    print('❌ Firebase initialization error: $e');
  }
  
  runApp(
    const ProviderScope(
      child: PulseApp(),
    ),
  );
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse - Healthcare Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Define named routes
      initialRoute: AppConstants.entryRoute,
      routes: {
        AppConstants.entryRoute: (context) => const EntryPage(),
        AppConstants.roleSelectionRoute: (context) => const RoleSelectionPage(),
        AppConstants.loginRoute: (context) => const LoginPage(),
      },
      // Handle routes with arguments (like RegisterPage)
      onGenerateRoute: (settings) {
        if (settings.name == AppConstants.registerRoute) {
          final userRole = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => RegisterPage(userRole: userRole),
          );
        }
        return null;
      },
    );
  }
}
