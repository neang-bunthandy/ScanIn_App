import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

/// ថ្នាក់គ្រប់គ្រង Theme (Light Mode និង Dark Mode)
/// ប្រើប្រាស់ `ValueNotifier<bool>` សាមញ្ញ ងាយស្រួលយល់ និងងាយស្រួលពន្យល់
class AppTheme {
  // ស្ថានភាព Dark Mode (true = Dark, false = Light)
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  // ផ្ទុកទិន្នន័យពី SharedPreferences ពេលបើក App
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
    } catch (_) {}
  }

  // ប្តូរ Theme ទៅ Dark ឬ Light
  static Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', value);
    } catch (_) {}
  }

  // Light Theme (ពណ៌ភ្លឺ)
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
  );

  // Dark Theme (ពណ៌ងងឹត)
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
  );
}
