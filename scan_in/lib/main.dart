import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ScanInApp());
}

class ScanInApp extends StatelessWidget {
  const ScanInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const LoginScreen(),
    );
  }
}
