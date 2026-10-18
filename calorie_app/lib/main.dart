import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/questionnaire_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const CalorieApp(),
    ),
  );
}

class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (!provider.isLoggedIn) {
            return const LoginScreen();
          } else if (!provider.hasCompletedOnboarding) {
            return const QuestionnaireScreen();
          } else {
            return const MainScreen();
          }
        },
      ),
    );
  }
}