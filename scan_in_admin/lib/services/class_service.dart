import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/class_model.dart';
import 'auth_service.dart';

class ClassService {
  static const List<String> presetDepartments = [
    'ព័ត៌មានវិទ្យា (IT)',
    'វិទ្យាសាស្ត្រកុំព្យូទ័រ (CS)',
    'វិស្វកម្មសូហ្វវែរ (SE)',
    'គ្រប់គ្រងពាណិជ្ជកម្ម (BBA)',
    'គណនេយ្យ និងហិរញ្ញវត្ថុ (Accounting)',
    'ភាសាអង់គ្លេស (English)',
    'វិស្វកម្មសំណង់ស៊ីវិល (Civil Engineering)',
    'ទូទៅ (General)',
  ];

  static List<ClassModel>? _cachedClasses;
  static List<Map<String, dynamic>>? _cachedLecturers;
  static List<Map<String, dynamic>>? _cachedStudents;

  static List<ClassModel>? get cachedClasses => _cachedClasses;
  static List<Map<String, dynamic>>? get cachedLecturers => _cachedLecturers;
  static List<Map<String, dynamic>>? get cachedStudents => _cachedStudents;

  static void clearCache() {
    _cachedClasses = null;
    _cachedLecturers = null;
    _cachedStudents = null;
  }

  /// ទាញយកបញ្ជីថ្នាក់រៀនរបស់គ្រូ (Lecturer Classes)
  static Future<List<ClassModel>> getLecturerClasses() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

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
        _cachedClasses = classes;
        return classes;
      }
    } catch (_) {}
    return [];
  }

  /// ទាញយកបញ្ជីថ្នាក់រៀនរបស់សិស្ស / Admin (Classes List)
  static Future<List<ClassModel>> getStudentClasses() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

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
        _cachedClasses = classes;
        return classes;
      }
    } catch (_) {}
    return [];
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
          final lecs = List<Map<String, dynamic>>.from(data['data']);
          _cachedLecturers = lecs;
          return lecs;
        }
      }
    } catch (_) {}
    return [];
  }

  /// Admin បង្កើតគណនីគ្រូបង្រៀនថ្មី (Name, Email, Password, Department, StaffId, Phone)
  static Future<Map<String, dynamic>> createLecturer({
    required String name,
    required String email,
    required String password,
    String? department,
    String? staffId,
    String? phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'department': department ?? '',
        'staff_id': staffId ?? '',
        'phone': phone ?? '',
      };

      final response = await http.post(
        Uri.parse(ApiConfig.lecturersUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _cachedLecturers = null;
        return {'success': true, 'message': data['message'] ?? 'បានបង្កើតគណនីគ្រូជោគជ័យ', 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'មិនអាចបង្កើតគណនីគ្រូបានទេ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  /// Admin កែសម្រួលគណនីគ្រូបង្រៀន
  static Future<Map<String, dynamic>> updateLecturer({
    required int id,
    required String name,
    required String email,
    String? password,
    String? department,
    String? staffId,
    String? phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'department': department ?? '',
        'staff_id': staffId ?? '',
        'phone': phone ?? '',
      };
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
        Uri.parse(ApiConfig.lecturerDetailUrl(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _cachedLecturers = null;
        return {'success': true, 'message': data['message'] ?? 'បានកែប្រែគណនីគ្រូជោគជ័យ', 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'មិនអាចកែប្រែគណនីគ្រូបានទេ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  /// Admin លុបគណនីគ្រូបង្រៀន
  static Future<Map<String, dynamic>> deleteLecturer(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse(ApiConfig.lecturerDetailUrl(id)),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _cachedLecturers = null;
        return {'success': true, 'message': data['message'] ?? 'បានលុបគណនីគ្រូជោគជ័យ'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'មិនអាចលុបគណនីគ្រូបានទេ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  /// ទាញយកបញ្ជីសិស្សទាំងអស់សម្រាប់ Admin គ្រប់គ្រង
  static Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.studentsUrl),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final stus = List<Map<String, dynamic>>.from(data['data']);
          _cachedStudents = stus;
          return stus;
        }
      }
    } catch (_) {}
    return [];
  }

  /// Admin បង្កើតគណនីសិស្សថ្មី (Name, Email, Password, StudentCode, Gender, DOB, Department, Phone)
  static Future<Map<String, dynamic>> createStudent({
    required String name,
    required String email,
    required String password,
    required String studentCode,
    String? gender,
    String? dateOfBirth,
    String? department,
    String? phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'student_code': studentCode.trim().toUpperCase(),
        'gender': gender ?? '',
        'date_of_birth': dateOfBirth ?? '',
        'department': department ?? '',
        'phone': phone ?? '',
      };

      final response = await http.post(
        Uri.parse(ApiConfig.studentsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _cachedStudents = null;
        return {'success': true, 'message': data['message'] ?? 'បានបង្កើតគណនីសិស្សជោគជ័យ', 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'មិនអាចបង្កើតគណនីសិស្សបានទេ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  /// Admin កែសម្រួលគណនីសិស្ស
  static Future<Map<String, dynamic>> updateStudent({
    required int id,
    required String name,
    required String email,
    required String studentCode,
    String? gender,
    String? dateOfBirth,
    String? password,
    String? department,
    String? phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'student_code': studentCode.trim().toUpperCase(),
        'gender': gender ?? '',
        'date_of_birth': dateOfBirth ?? '',
        'department': department ?? '',
        'phone': phone ?? '',
      };
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
        Uri.parse(ApiConfig.studentDetailUrl(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _cachedStudents = null;
        return {'success': true, 'message': data['message'] ?? 'បានកែប្រែគណនីសិស្សជោគជ័យ', 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'មិនអាចកែប្រែគណនីសិស្សបានទេ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  /// Admin Import បញ្ជីសិស្សជាក្រុមពី Excel/CSV (Bulk Import)
  static Future<Map<String, dynamic>> importStudents(List<Map<String, dynamic>> studentsList) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(ApiConfig.studentsImportUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'students': studentsList}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _cachedStudents = null;
        return {
          'success': true,
          'message': data['message'] ?? 'Import ជោគជ័យ',
          'imported_count': data['imported_count'] ?? 0,
          'skipped_count': data['skipped_count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'បរាជ័យក្នុងការ Import',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  /// Admin លុបគណនីសិស្ស
  static Future<Map<String, dynamic>> deleteStudent(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse(ApiConfig.studentDetailUrl(id)),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _cachedStudents = null;
        return {'success': true, 'message': data['message'] ?? 'បានលុបគណនីសិស្សជោគជ័យ'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'មិនអាចលុបគណនីសិស្សបានទេ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  /// Admin បង្កើតថ្នាក់រៀនថ្មី និងចាត់តាំងគ្រូបង្រៀន (កំណត់ ឆ្នាំ, ឆមាស, កូដ, ឈ្មោះ, បន្ទប់, ថ្ងៃ, ម៉ោង)
  static Future<bool> createClassAdmin({
    required String subjectName,
    required String subjectCode,
    required int lecturerId,
    required String academicYear,
    required String semester,
    String? department,
    String? room,
    String? dayOfWeek,
    String? time,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        'subject_name': subjectName,
        'subject_code': subjectCode,
        'department': department ?? '',
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
        _cachedClasses = null;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Admin កែសម្រួលព័ត៌មានថ្នាក់រៀន
  static Future<bool> updateClassAdmin({
    required int id,
    required String subjectName,
    required String subjectCode,
    required int lecturerId,
    required String academicYear,
    required String semester,
    String? department,
    String? room,
    String? dayOfWeek,
    String? time,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        'subject_name': subjectName,
        'subject_code': subjectCode,
        'department': department ?? '',
        'lecturer_id': lecturerId,
        'academic_year': academicYear,
        'semester': semester,
        'room': room ?? '',
        'day_of_week': dayOfWeek ?? '',
        'time': time ?? '',
      };

      final response = await http.put(
        Uri.parse(ApiConfig.classDetailUrl(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        _cachedClasses = null;
        return true;
      }
      return false;
    } catch (_) {}
    return false;
  }

  /// Admin លុបថ្នាក់រៀន
  static Future<bool> deleteClassAdmin(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse(ApiConfig.classDetailUrl(id)),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        _cachedClasses = null;
        return true;
      }
      return false;
    } catch (_) {}
    return false;
  }
}
