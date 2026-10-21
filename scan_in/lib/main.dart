import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/lecturer/lecturer_home_screen.dart';
import 'core/app_theme.dart';
import 'core/app_language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTheme.init();
  await AppLanguage.init();
  runApp(const ScanInApp());
}

class ScanInApp extends StatelessWidget {
  const ScanInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppLanguage.currentLanguage,
          builder: (context, lang, _) {
            return MaterialApp(
              title: 'ScanIn',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              home: const AuthWrapper(),
            );
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _checking = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final loggedIn = await AuthService.isLoggedIn();
      if (loggedIn) {
        final user = await AuthService.getCurrentUser();
        if (mounted) {
          setState(() {
            _user = user;
            _checking = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_user != null) {
      if (_user!.isStudent) {
        return StudentHomeScreen(user: _user);
      } else {
        return LecturerHomeScreen(user: _user);
      }
    }

    return const LoginScreen();
  }
}
