import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/screens.dart';
import 'services/services.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Default App (Personal Firebase Auth & TODOs)
  await Firebase.initializeApp(
    options: FirebaseConfigs.personal,
  );

  // 2. Initialize Named App (Instructor's Firebase for Grades)
  // TODO: Uncomment this when you have the instructor's API keys
  // await Firebase.initializeApp(
  //   name: 'instructor',
  //   options: FirebaseConfigs.instructor,
  // );

  runApp(const LumenApp());
}

class LumenApp extends StatefulWidget {
  const LumenApp({super.key});

  @override
  State<LumenApp> createState() => _LumenAppState();
}

class _LumenAppState extends State<LumenApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Lumen',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8B5CF6),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF3F0FF),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8B5CF6),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0F0A1E),
          ),
          home: StreamBuilder<User?>(
            stream: AuthService().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  ),
                );
              }
              
              if (snapshot.hasData) {
                return const HomeScreen();
              }
              
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
