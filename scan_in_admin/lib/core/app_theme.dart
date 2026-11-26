// Light and Dark Material theme definitions.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

class NoTransitionsOnWebBuilder extends PageTransitionsBuilder {
  const NoTransitionsOnWebBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppTheme {

  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
    } catch (_) {}
  }

  static Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', value);
    } catch (_) {}
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFF1F5F9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: NoTransitionsOnWebBuilder(),
        TargetPlatform.iOS: NoTransitionsOnWebBuilder(),
        TargetPlatform.windows: NoTransitionsOnWebBuilder(),
        TargetPlatform.macOS: NoTransitionsOnWebBuilder(),
        TargetPlatform.linux: NoTransitionsOnWebBuilder(),
        TargetPlatform.fuchsia: NoTransitionsOnWebBuilder(),
      },
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    cardColor: const Color(0xFF1E293B),
    dividerColor: const Color(0xFF334155),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: Color(0xFF1E293B),
      onSurface: Colors.white,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: NoTransitionsOnWebBuilder(),
        TargetPlatform.iOS: NoTransitionsOnWebBuilder(),
        TargetPlatform.windows: NoTransitionsOnWebBuilder(),
        TargetPlatform.macOS: NoTransitionsOnWebBuilder(),
        TargetPlatform.linux: NoTransitionsOnWebBuilder(),
        TargetPlatform.fuchsia: NoTransitionsOnWebBuilder(),
      },
    ),
  );
}
