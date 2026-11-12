import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  // Configurable Host & Port
  static const String localhost = '127.0.0.1';
  static const String androidEmulatorHost = '10.0.2.2';
  static const int defaultPort = 8000;

  // Manual IP Override (ពេលតេស្តលើទូរស័ព្ទពិតប្រាកដ ឬបណ្តាញ WiFi ជាក់ស្តែង)
  // ឧទាហរណ៍៖ static String? customIp = '192.168.1.100';
  static String? customIp;

  static String? get customHost => customIp;
  static set customHost(String? value) => customIp = value;

  static int port = defaultPort;

  /// កំណត់ IP ដោយស្វ័យប្រវត្តិតាមឧបករណ៍ដែលកំពុងដំណើរការ (គាំទ្រទាំង Web, Android, iOS, Desktop)
  static String get host {
    if (customIp != null && customIp!.isNotEmpty) {
      return customIp!;
    }

    if (kIsWeb) {
      return localhost;
    }

    try {
      if (Platform.isAndroid) {
        // Android Emulator ប្រើ 10.0.2.2 ដើម្បីទាក់ទងមក localhost របស់ PC
        return androidEmulatorHost;
      } else if (Platform.isIOS) {
        return localhost;
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return localhost;
      }
    } catch (_) {}

    return localhost;
  }

  static String get baseUrl => 'http://$host:$port/api';

  // Auth Endpoints
  static String get loginUrl => '$baseUrl/login';
  static String get meUrl => '$baseUrl/me';
  static String get logoutUrl => '$baseUrl/logout';
  static String get changePasswordUrl => '$baseUrl/user/change-password';

  // Classes & Users Endpoints (Laravel REST API)
  static String get classesUrl => '$baseUrl/classes';
  static String get lecturersUrl => '$baseUrl/lecturers';
  static String get studentsUrl => '$baseUrl/students';
  static String get studentsImportUrl => '$baseUrl/students/import';
  static String get promoteStudentsUrl => '$baseUrl/students/promote';
  static String get bulkStudentStatusUrl => '$baseUrl/students/bulk-status';
  static String get adminStudentStatsUrl => '$baseUrl/admin/reports/student-stats';
  static String lecturerDetailUrl(int id) => '$baseUrl/lecturers/$id';
  static String studentDetailUrl(int id) => '$baseUrl/students/$id';
  static String classDetailUrl(int id) => '$baseUrl/classes/$id';
  static String classStudentsUrl(int id) => '$baseUrl/classes/$id/students';
  static String classToggleQrUrl(int id) => '$baseUrl/classes/$id/toggle-qr';
  static String get studentClassesUrl => '$baseUrl/student/classes';

  // Attendance Endpoints
  static String get attendancesUrl => '$baseUrl/attendances';
  static String classAttendancesUrl(int classId) => '$baseUrl/classes/$classId/attendances';
  static String updateAttendanceUrl(int id) => '$baseUrl/attendances/$id';
  static String get scanAttendanceUrl => '$baseUrl/attendances/scan';
  static String get studentAttendancesUrl => '$baseUrl/student/attendances';
}
