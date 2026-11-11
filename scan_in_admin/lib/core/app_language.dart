import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ថ្នាក់គ្រប់គ្រងភាសាក្នុងកម្មវិធី (Khmer / English)
/// ប្រើប្រាស់ `ValueNotifier<String>` ដើម្បី trigger អោយ rebuild UI ភ្លាមៗ
/// កូដសាមញ្ញ ងាយស្រួលយល់ និងងាយស្រួលពន្យល់ពេលធ្វើ Presentation
class AppLanguage {
  // កូដភាសា ('km' = ខ្មែរ, 'en' = English)
  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>('km');

  // ពិនិត្យមើលថាតើកំពុងប្រើភាសាអ្វី
  static bool get isKhmer => currentLanguage.value == 'km';
  static bool get isEnglish => currentLanguage.value == 'en';

  // ឈ្មោះភាសាសម្រាប់បង្ហាញលើ UI
  static String get displayName => isKhmer ? 'ខ្មែរ (Khmer)' : 'English (US)';

  // ផ្ទុកភាសាដែលបាន Save ទុកពីមុនពេលបើក App
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('app_language');
      if (savedLang != null && (savedLang == 'km' || savedLang == 'en')) {
        currentLanguage.value = savedLang;
      }
    } catch (_) {}
  }

  // ផ្លាស់ប្តូរភាសា និង Save ចូលក្នុង SharedPreferences
  static Future<void> changeLanguage(String code) async {
    if (code != 'km' && code != 'en') return;
    currentLanguage.value = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', code);
    } catch (_) {}
  }

  /// Helper សម្រាប់បកប្រែពាក្យ/ប្រយោគ
  /// [km]៖ អត្ថបទជាភាសាខ្មែរ
  /// [en]៖ អត្ថបទជាភាសាអង់គ្លេស
  static String tr(String km, String en) {
    return isKhmer ? km : en;
  }
}
