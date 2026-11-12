import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../data/mock_data.dart';
import '../models/class_model.dart';
import 'auth_service.dart';

class ClassService {
  /// ទាញយកបញ្ជីថ្នាក់រៀនរបស់គ្រូ (Lecturer Classes)
  static Future<List<ClassModel>> getLecturerClasses() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return MockData.sampleClasses;

      final response = await http.get(
        Uri.parse(ApiConfig.classesUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = (data['data'] ?? data['classes'] ?? data) as List;
        final List<ClassModel> classes = [];
        for (var item in list) {
          classes.add(ClassModel.fromJson(item as Map<String, dynamic>));
        }
        return classes;
      }
    } catch (_) {
      // បើ Server មិនទាន់ដំណើរការ យក MockData ជំនួសដើម្បីកុំឱ្យ Error
    }
    return MockData.sampleClasses;
  }

  /// ទាញយកបញ្ជីថ្នាក់រៀនរបស់សិស្ស (Student Classes)
  static Future<List<ClassModel>> getStudentClasses() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return MockData.sampleClasses;

      final response = await http.get(
        Uri.parse(ApiConfig.studentClassesUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = (data['data'] ?? data['classes'] ?? data) as List;
        final List<ClassModel> classes = [];
        for (var item in list) {
          classes.add(ClassModel.fromJson(item as Map<String, dynamic>));
        }
        return classes;
      }
    } catch (_) {}
    return MockData.sampleClasses;
  }

  /// បើក / បិទ QR Code សម្រាប់ថ្នាក់រៀន (Toggle QR Code & sync Token)
  static Future<bool> toggleQr(int classId, bool activate, {String? qrToken}) async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        final Map<String, dynamic> body = {'is_qr_active': activate};
        if (qrToken != null) {
          body['qr_token'] = qrToken;
        }

        final response = await http.post(
          Uri.parse(ApiConfig.classToggleQrUrl(classId)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// ទាញយកបញ្ជីគ្រូបង្រៀនទាំងអស់សម្រាប់ Admin ជ្រើសរើសចាត់តាំងថ្នាក់រៀន
  static Future<List<Map<String, dynamic>>> getLecturers() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.lecturersUrl),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  /// Admin បង្កើតថ្នាក់រៀនថ្មី និងចាត់តាំងគ្រូបង្រៀន (កំណត់ ឆ្នាំ, ឆមាស, កូដ, ឈ្មោះ, បន្ទប់, ថ្ងៃ, ម៉ោង)
  static Future<bool> createClassAdmin({
    required String subjectName,
    required String subjectCode,
    required int lecturerId,
    required String academicYear,
    required String semester,
    String? room,
    String? dayOfWeek,
    String? time,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        'subject_name': subjectName,
        'subject_code': subjectCode,
        'lecturer_id': lecturerId,
        'academic_year': academicYear,
        'semester': semester,
        'room': room ?? '',
        'day_of_week': dayOfWeek ?? '',
        'time': time ?? '',
      };

      final response = await http.post(
        Uri.parse(ApiConfig.classesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}
