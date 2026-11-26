// Bilingual Khmer/English localization helper.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {

  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>('km');

  static bool get isKhmer => currentLanguage.value == 'km';
  static bool get isEnglish => currentLanguage.value == 'en';

  static String get displayName => isKhmer ? 'ខ្មែរ (Khmer)' : 'English (US)';

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('app_language');
      if (savedLang != null && (savedLang == 'km' || savedLang == 'en')) {
        currentLanguage.value = savedLang;
      }
    } catch (_) {}
  }

  static Future<void> changeLanguage(String code) async {
    if (code != 'km' && code != 'en') return;
    currentLanguage.value = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', code);
    } catch (_) {}
  }

  static String tr(String km, String en) {
    return isKhmer ? km : en;
  }
}
