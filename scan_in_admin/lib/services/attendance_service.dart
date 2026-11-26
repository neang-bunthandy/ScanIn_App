// QR scan, Face ID check-in, export, and attendance API service.
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/attendance_model.dart';
import 'auth_service.dart';

class AttendanceService {

  static Future<List<AttendanceModel>> getClassAttendances(int classId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.classAttendancesUrl(classId)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = (data['data'] ?? data['attendances'] ?? data) as List;
        final List<AttendanceModel> attendances = [];
        for (var item in list) {
          attendances.add(AttendanceModel.fromJson(item as Map<String, dynamic>));
        }
        return attendances;
      }
    } catch (_) {}
    return [];
  }

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
          body: jsonEncode({'qr_token': qrToken.trim()}),
        ).timeout(const Duration(seconds: 8));

        final data = jsonDecode(response.body);
        final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) && data['status'] == true;
        return {
          'success': isSuccess,
          'message': data['message'] ?? (isSuccess ? 'បានកត់វត្តមានជោគជ័យ' : 'មិនអាចកត់វត្តមានបានទេ'),
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
      'success': false,
      'message': 'សូមចូលគណនីជាសិស្សជាមុនសិន!',
    };
  }

  static Future<List<AttendanceModel>> getMyAttendanceHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.studentAttendancesUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = (data['data'] ?? data['attendances'] ?? data) as List;
        final List<AttendanceModel> attendances = [];
        for (var item in list) {
          attendances.add(AttendanceModel.fromJson(item as Map<String, dynamic>));
        }
        return attendances;
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> updateAttendanceStatus(
    int id,
    String status, {
    String? note,
  }) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'status': status,
      };
      if (note != null) body['note'] = note;

      final response = await http
          .put(
            Uri.parse(ApiConfig.updateAttendanceUrl(id)),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> recordManualAttendance({
    required int classId,
    required int studentId,
    required String status,
    String? date,
    String? note,
  }) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'class_id': classId,
        'student_id': studentId,
        'status': status,
      };
      if (date != null) body['date'] = date;
      if (note != null) body['note'] = note;

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/attendances/manual'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['status'] == true,
        'message': data['message'] ?? 'បានកែប្រែវត្តមានជោគជ័យ',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាការតភ្ជាប់៖ $e'};
    }
  }

  static Future<Uint8List?> fetchExportCsvBytes({int? classId}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.attendanceExportUrl(classId: classId, format: 'csv')),
        headers: {
          'Accept': 'text/csv',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }
}
