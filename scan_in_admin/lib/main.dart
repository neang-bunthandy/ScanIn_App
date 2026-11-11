import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.isLoggedIn();
  String initialRoute = AppRoutes.login;
  if (isLoggedIn) {
    final user = await AuthService.getCurrentUser();
    if (user?.role == 'lecturer') {
      initialRoute = AppRoutes.classes;
    } else {
      initialRoute = AppRoutes.dashboard;
    }
  }

  runApp(ScanInAdminApp(initialRoute: initialRoute));
}

class ScanInAdminApp extends StatelessWidget {
  final String initialRoute;

  const ScanInAdminApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanIn Web Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
