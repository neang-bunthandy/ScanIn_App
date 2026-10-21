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

  /// បង្កើតថ្នាក់រៀនថ្មី (Create Class)
  static Future<ClassModel> createClass(ClassModel newClass) async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse(ApiConfig.classesUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(newClass.toJson()),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          if (data['data'] != null) {
            return ClassModel.fromJson(data['data'] as Map<String, dynamic>);
          }
        }
      }
    } catch (_) {}
    return newClass;
  }

  /// បើក / បិទ QR Code សម្រាប់ថ្នាក់រៀន
  static Future<bool> toggleQr(int classId, bool activate) async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse(ApiConfig.classToggleQrUrl(classId)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'is_qr_active': activate}),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}
