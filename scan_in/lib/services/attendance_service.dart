// QR scan, Face ID check-in, export, and attendance API service.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/attendance_model.dart';
import 'auth_service.dart';
import 'biometric_service.dart';
import 'location_service.dart';

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
        final gps = await LocationService.getCurrentPosition();
        if (gps.isMocked) {
          return {
            'success': false,
            'message': 'រកឃើញការប្រើប្រាស់កម្មវិធីបន្លំទីតាំង (Fake GPS)! មិនអាចកត់វត្តមានបានឡើយ។',
          };
        }

        final deviceId = await BiometricService.getOrCreateDeviceId();

        final payload = <String, dynamic>{
          'qr_token': qrToken.trim(),
          'is_mocked': gps.isMocked,
          'device_id': deviceId,
        };
        if (gps.hasLocation) {
          payload['latitude'] = gps.latitude;
          payload['longitude'] = gps.longitude;
        }

        final response = await http.post(
          Uri.parse(ApiConfig.scanAttendanceUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        final data = jsonDecode(response.body);
        final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) && data['status'] == true;
        final String fallbackError = gps.errorMessage ?? (isSuccess ? 'បានកត់វត្តមានជោគជ័យ' : 'មិនអាចកត់វត្តមានបានទេ');
        return {
          'success': isSuccess,
          'message': data['message'] ?? fallbackError,
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

  static Future<Map<String, dynamic>> faceCheckIn(int classId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'សូមចូលគណនីជាសិស្សជាមុនសិន!',
        };
      }

      final bio = await BiometricService.authenticateWithFaceId();
      if (!bio.success) {
        return {
          'success': false,
          'message': bio.errorMessage ?? 'ការផ្ទៀងផ្ទាត់ Face ID មិនបានសម្រេច!',
        };
      }

      final gps = await LocationService.getCurrentPosition();
      if (gps.isMocked) {
        return {
          'success': false,
          'message': 'រកឃើញការប្រើប្រាស់កម្មវិធីបន្លំទីតាំង (Fake GPS)! មិនអាចកត់វត្តមានបានឡើយ។',
        };
      }

      final deviceId = await BiometricService.getOrCreateDeviceId();

      final payload = <String, dynamic>{
        'class_id': classId,
        'biometric_verified': true,
        'device_id': deviceId,
        'is_mocked': gps.isMocked,
      };
      if (gps.hasLocation) {
        payload['latitude'] = gps.latitude;
        payload['longitude'] = gps.longitude;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.faceCheckInUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) && data['status'] == true;
      final String fallbackError = gps.errorMessage ?? (isSuccess ? 'បានកត់វត្តមានដោយ Face ID ជោគជ័យ' : 'មិនអាចកត់វត្តមានបានទេ');
      return {
        'success': isSuccess,
        'message': data['message'] ?? fallbackError,
        'attendance': data['attendance'] != null
            ? AttendanceModel.fromJson(data['attendance'] as Map<String, dynamic>)
            : null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'មិនអាចភ្ជាប់ទៅកាន់ Server បានទេ៖ $e',
      };
    }
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
}
