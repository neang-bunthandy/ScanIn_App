import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // កំណត់ IP កុំព្យូទ័ររបស់អ្នក សម្រាប់ពេលតេស្តលើទូរស័ព្ទពិតតាម Wi-Fi
  // (បើប្រើ Android Emulator វានឹងប្រើ 10.0.2.2 ដោយស្វ័យប្រវត្តិ)
  static const String physicalDeviceHost = '192.168.42.165';
  static const String emulatorHost = '10.0.2.2';
  static const String localhost = '127.0.0.1';
  static const String port = '8000';

  // បើអ្នកចង់បង្ខំប្រើ IP ជាក់លាក់មួយ អាចដាក់នៅទីនេះ (null = ជ្រើសរើសដោយស្វ័យប្រវត្តិ)
  static String? customHost;

  static String get host {
    if (customHost != null && customHost!.isNotEmpty) {
      return customHost!;
    }

    if (kIsWeb) {
      return localhost;
    }

    try {
      if (Platform.isAndroid) {
        // Android Emulator ប្រើ 10.0.2.2 ដើម្បីទាក់ទងមក Host PC
        return emulatorHost;
      } else if (Platform.isIOS) {
        return localhost;
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return localhost;
      }
    } catch (_) {}

    return localhost;
  }

  static String get baseUrl => 'http://$host:$port/api';

  // Endpoints
  static String get loginUrl => '$baseUrl/login';
  static String get meUrl => '$baseUrl/me';
  static String get logoutUrl => '$baseUrl/logout';
}
