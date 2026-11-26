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

  static String get classesUrl => '$baseUrl/classes';
  static String get lecturersUrl => '$baseUrl/lecturers';
  static String get studentsUrl => '$baseUrl/students';
  static String classDetailUrl(int id) => '$baseUrl/classes/$id';
  static String classStudentsUrl(int id) => '$baseUrl/classes/$id/students';
  static String classToggleQrUrl(int id) => '$baseUrl/classes/$id/toggle-qr';
  static String get studentClassesUrl => '$baseUrl/student/classes';

  static String get attendancesUrl => '$baseUrl/attendances';
  static String classAttendancesUrl(int classId) => '$baseUrl/classes/$classId/attendances';
  static String updateAttendanceUrl(int id) => '$baseUrl/attendances/$id';
  static String get scanAttendanceUrl => '$baseUrl/attendances/scan';
  static String get faceCheckInUrl => '$baseUrl/attendances/face-checkin';
  static String get studentAttendancesUrl => '$baseUrl/student/attendances';
}
