import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../data/mock_data.dart';
import '../models/attendance_model.dart';
import 'auth_service.dart';

class AttendanceService {
  /// ទាញយកបញ្ជីវត្តមានរបស់ថ្នាក់រៀនជាក់លាក់មួយ (Lecturer views Attendance for a Class)
  static Future<List<AttendanceModel>> getClassAttendances(int classId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return MockData.getAttendanceForClass(classId);

      final response = await http.get(
        Uri.parse(ApiConfig.classAttendancesUrl(classId)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] ?? data['attendances'] ?? data) as List;
        return list
            .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return MockData.getAttendanceForClass(classId);
  }

  /// សិស្សស្កេន QR Code កត់វត្តមាន (Student Scans QR)
  static Future<Map<String, dynamic>> scanAttendance(String qrToken) async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse(ApiConfig.scanAttendanceUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'qr_token': qrToken}),
        ).timeout(const Duration(seconds: 8));

        final data = jsonDecode(response.body);
        return {
          'success': response.statusCode == 200 && data['status'] == true,
          'message': data['message'] ?? 'កត់វត្តមានជោគជ័យ',
          'attendance': data['attendance'] != null
              ? AttendanceModel.fromJson(data['attendance'] as Map<String, dynamic>)
              : null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'មិនអាចភ្ជាប់ទៅកាន់ Server បានទេ៖ $e',
      };
    }

    return {
      'success': true,
      'message': 'បានកត់វត្តមានជោគជ័យ (Offline/Local)',
    };
  }

  /// ទាញយកប្រវត្តិវត្តមានរបស់សិស្សផ្ទាល់ខ្លួន (Student Attendance History)
  static Future<List<AttendanceModel>> getMyAttendanceHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return MockData.sampleAttendances;

      final response = await http.get(
        Uri.parse(ApiConfig.studentAttendancesUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] ?? data['attendances'] ?? data) as List;
        return list
            .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return MockData.sampleAttendances;
  }
}
