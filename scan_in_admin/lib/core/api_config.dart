// API endpoint URLs, host detection, and image URL resolver.
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {

  static const String localhost = '127.0.0.1';
  static const String androidEmulatorHost = '10.0.2.2';
  static const int defaultPort = 8000;

  static String? customIp;

  static String? get customHost => customIp;
  static set customHost(String? value) => customIp = value;

  static int port = defaultPort;

  static String get host {
    if (customIp != null && customIp!.isNotEmpty) {
      return customIp!;
    }

    if (kIsWeb) {
      return localhost;
    }

    try {
      if (Platform.isAndroid) {

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

  static String get loginUrl => '$baseUrl/login';
  static String get meUrl => '$baseUrl/me';
  static String get logoutUrl => '$baseUrl/logout';
  static String get changePasswordUrl => '$baseUrl/user/change-password';
  static String get uploadAvatarUrl => '$baseUrl/profile/avatar';

  static String? resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    if (cleanPath.startsWith('/storage/avatars/')) {
      final filename = cleanPath.substring('/storage/avatars/'.length);
      return '$baseUrl/avatars/$filename';
    }
    return 'http://$host:$port$cleanPath';
  }

  static String get departmentsUrl => '$baseUrl/departments';
  static String get classesUrl => '$baseUrl/classes';
  static String get lecturersUrl => '$baseUrl/lecturers';
  static String get subAdminsUrl => '$baseUrl/sub-admins';
  static String subAdminDetailUrl(int id) => '$baseUrl/sub-admins/$id';
  static String get studentsUrl => '$baseUrl/students';
  static String get studentsImportUrl => '$baseUrl/students/import';
  static String get promoteStudentsUrl => '$baseUrl/students/promote';
  static String get bulkStudentStatusUrl => '$baseUrl/students/bulk-status';
  static String get adminStudentStatsUrl => '$baseUrl/admin/reports/student-stats';
  static String attendanceExportUrl({int? classId, String format = 'csv'}) {
    final params = <String>['format=$format'];
    if (classId != null) params.add('class_id=$classId');
    return '$baseUrl/reports/attendance/export?${params.join('&')}';
  }
  static String lecturerDetailUrl(int id) => '$baseUrl/lecturers/$id';
  static String studentDetailUrl(int id) => '$baseUrl/students/$id';
  static String classDetailUrl(int id) => '$baseUrl/classes/$id';
  static String classStudentsUrl(int id) => '$baseUrl/classes/$id/students';
  static String classToggleQrUrl(int id) => '$baseUrl/classes/$id/toggle-qr';
  static String get studentClassesUrl => '$baseUrl/student/classes';

  static String get attendancesUrl => '$baseUrl/attendances';
  static String classAttendancesUrl(int classId) => '$baseUrl/classes/$classId/attendances';
  static String updateAttendanceUrl(int id) => '$baseUrl/attendances/$id';
  static String get scanAttendanceUrl => '$baseUrl/attendances/scan';
  static String get studentAttendancesUrl => '$baseUrl/student/attendances';

  static String get campusSettingsUrl => '$baseUrl/campus-settings';
  static String get adminCampusSettingsUrl => '$baseUrl/admin/campus-settings';
  static String resetStudentDeviceUrl(int id) => '$baseUrl/admin/students/$id/reset-device';
}
