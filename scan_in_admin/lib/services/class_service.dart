// Classes, students, lecturers, and roster API service.
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

  static const List<String> presetGenerations = [
    'ជំនាន់ទី ១៤ (Gen 14)',
    'ជំនាន់ទី ១៥ (Gen 15)',
    'ជំនាន់ទី ១៦ (Gen 16)',
    'ជំនាន់ទី ១៧ (Gen 17)',
    'ជំនាន់ទី ១៨ (Gen 18)',
    'ជំនាន់ទី ១៩ (Gen 19)',
  ];

  static const List<String> presetIntakeYears = [
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
  ];

  static const List<int> yearLevels = [1, 2, 3, 4, 5];

  static String yearLevelLabel(int? level) {
    switch (level) {
      case 1:
        return 'ឆ្នាំទី ១ (Year 1)';
      case 2:
        return 'ឆ្នាំទី ២ (Year 2)';
      case 3:
        return 'ឆ្នាំទី ៣ (Year 3)';
      case 4:
        return 'ឆ្នាំទី ៤ (Year 4)';
      case 5:
        return 'ឆ្នាំទី ៥ (Year 5)';
      default:
        return 'មិនទាន់កំណត់ឆ្នាំទី';
    }
  }

  static const List<String> presetStatuses = [
    'active',
    'graduated',
    'inactive',
  ];

  static String studentStatusLabel(String? status) {
    switch ((status ?? 'active').toLowerCase()) {
      case 'graduated':
        return 'រៀនចប់ (Graduated)';
      case 'inactive':
        return 'ឈប់រៀន / ផ្អាក (Inactive)';
      case 'active':
      default:
        return 'កំពុងរៀន (Active)';
    }
  }

  static int suggestYearLevelFromIntake(String intakeYear) {
    final start = int.tryParse(intakeYear.trim());
    if (start == null) return 1;
    final currentYear = DateTime.now().year;
    final diff = currentYear - start + 1;
    if (diff < 1) return 1;
    if (diff > 5) return 5;
    return diff;
  }

  static List<String> buildIntakeYearOptions([Iterable<String> extra = const []]) {
    final nowYear = DateTime.now().year;
    final set = <String>{
      for (int y = nowYear - 12; y <= nowYear + 8; y++) '$y',
      ...extra.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  static List<String> buildAcademicYearOptions([Iterable<String> extra = const []]) {
    final nowYear = DateTime.now().year;
    final set = <String>{
      for (int y = nowYear - 6; y <= nowYear + 8; y++) '$y-${y + 1}',
      ...extra.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  static List<String> buildGenerationOptions([Iterable<String> extra = const []]) {
    final set = <String>{
      for (int g = 10; g <= 30; g++) 'ជំនាន់ទី $g (Gen $g)',
      ...extra.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };
    return set.toList();
  }

  static String normalizeDepartment(String? dept) {
    if (dept == null) return presetDepartments.first;
    final trimmed = dept.trim();
    if (trimmed.isEmpty) return presetDepartments.first;
    final lower = trimmed.toLowerCase();
    if (lower.contains('information technology') || lower == 'it') {
      return 'ព័ត៌មានវិទ្យា (IT)';
    } else if (lower.contains('computer science') || lower == 'cs') {
      return 'វិទ្យាសាស្ត្រកុំព្យូទ័រ (CS)';
    } else if (lower.contains('software engineering') || lower == 'se') {
      return 'វិស្វកម្មសូហ្វវែរ (SE)';
    } else if (lower.contains('business') || lower == 'bba') {
      return 'គ្រប់គ្រងពាណិជ្ជកម្ម (BBA)';
    } else if (lower.contains('accounting') || lower.contains('finance')) {
      return 'គណនេយ្យ និងហិរញ្ញវត្ថុ (Accounting)';
    } else if (lower.contains('english')) {
      return 'ភាសាអង់គ្លេស (English)';
    } else if (lower.contains('civil')) {
      return 'វិស្វកម្មសំណង់ស៊ីវិល (Civil Engineering)';
    }
    for (final p in presetDepartments) {
      if (p.toLowerCase() == lower || p.contains(trimmed)) {
        return p;
      }
    }
    return trimmed;
  }

  static final Set<String> _dynamicCustomDepartments = <String>{};
  static List<String>? _cachedDepartments;

  static void registerCustomDepartment(String? dept) {
    if (dept != null) {
      final trimmed = dept.trim();
      if (trimmed.isNotEmpty) {
        _dynamicCustomDepartments.add(trimmed);
      }
    }
  }

  static List<String> buildDepartmentOptions([Iterable<String?> extra = const []]) {
    final set = <String>{
      ...presetDepartments,
      ..._dynamicCustomDepartments,
    };
    if (_cachedDepartments != null) {
      set.addAll(_cachedDepartments!);
    }
    if (_cachedClasses != null) {
      for (final c in _cachedClasses!) {
        if (c.department != null && c.department!.trim().isNotEmpty) {
          set.add(c.department!.trim());
        }
      }
    }
    if (_cachedStudents != null) {
      for (final s in _cachedStudents!) {
        final d = s['department']?.toString().trim();
        if (d != null && d.isNotEmpty) {
          set.add(d);
        }
      }
    }
    if (_cachedLecturers != null) {
      for (final l in _cachedLecturers!) {
        final d = l['department']?.toString().trim();
        if (d != null && d.isNotEmpty) {
          set.add(d);
        }
      }
    }
    for (final e in extra) {
      if (e != null) {
        final trimmed = e.trim();
        if (trimmed.isNotEmpty) {
          set.add(trimmed);
        }
      }
    }
    return set.toList();
  }

  static Future<List<String>> fetchDepartments() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.departmentsUrl),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          final list = (data['data'] as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
          _cachedDepartments = list;
          return buildDepartmentOptions(list);
        }
      }
    } catch (_) {}
    return buildDepartmentOptions();
  }

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
    _cachedDepartments = null;
  }

  static Future<List<ClassModel>> getLecturerClasses({String? date}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final uri = date != null && date.isNotEmpty
          ? Uri.parse(ApiConfig.classesUrl).replace(queryParameters: {'date': date})
          : Uri.parse(ApiConfig.classesUrl);

      final response = await http.get(
        uri,
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
        if (date == null) _cachedClasses = classes;
        return classes;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<ClassModel>> getStudentClasses({String? date}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final uri = date != null && date.isNotEmpty
          ? Uri.parse(ApiConfig.studentClassesUrl).replace(queryParameters: {'date': date})
          : Uri.parse(ApiConfig.studentClassesUrl);

      final response = await http.get(
        uri,
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
        if (date == null) _cachedClasses = classes;
        return classes;
      }
    } catch (_) {}
    return [];
  }

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
          _cachedClasses = null;
          _cachedLecturers = null;
          final data = jsonDecode(response.body);
          if (data['data'] != null) {
            return ClassModel.fromJson(data['data'] as Map<String, dynamic>);
          }
        }
      }
    } catch (_) {}
    return newClass;
  }

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

  static Future<List<Map<String, dynamic>>> getClassStudents(int classId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.classStudentsUrl(classId)),
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

  static Future<Map<String, dynamic>> createLecturer({
    required String name,
    String? latinName,
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
        'latin_name': latinName?.trim() ?? '',
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

  static Future<Map<String, dynamic>> updateLecturer({
    required int id,
    required String name,
    String? latinName,
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
        'latin_name': latinName?.trim() ?? '',
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

  static Future<Map<String, dynamic>> createStudent({
    required String name,
    String? latinName,
    required String email,
    required String password,
    required String studentCode,
    String? gender,
    String? dateOfBirth,
    String? department,
    String? generation,
    String? intakeYear,
    int? yearLevel,
    String? status,
    String? phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        'name': name.trim(),
        'latin_name': latinName?.trim() ?? '',
        'email': email.trim().toLowerCase(),
        'password': password,
        'student_code': studentCode.trim().toUpperCase(),
        'gender': gender ?? '',
        'date_of_birth': dateOfBirth ?? '',
        'department': department ?? '',
        'generation': generation ?? '',
        'intake_year': intakeYear ?? '',
        'year_level': ?yearLevel,
        'status': status ?? 'active',
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

  static Future<Map<String, dynamic>> updateStudent({
    required int id,
    required String name,
    String? latinName,
    required String email,
    required String studentCode,
    String? gender,
    String? dateOfBirth,
    String? password,
    String? department,
    String? generation,
    String? intakeYear,
    int? yearLevel,
    String? status,
    String? phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = <String, dynamic>{
        'name': name.trim(),
        'latin_name': latinName?.trim() ?? '',
        'email': email.trim().toLowerCase(),
        'student_code': studentCode.trim().toUpperCase(),
        'gender': gender ?? '',
        'date_of_birth': dateOfBirth ?? '',
        'department': department ?? '',
        'generation': generation ?? '',
        'intake_year': intakeYear ?? '',
        'year_level': ?yearLevel,
        'status': ?status,
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

  static Future<Map<String, dynamic>> resetStudentDevice(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(ApiConfig.resetStudentDeviceUrl(id)),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['status'] == true,
        'message': data['message'] ?? 'បាន Reset Device ID ជោគជ័យ',
      };
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  static Future<Map<String, dynamic>> promoteStudents({
    String? generation,
    String? intakeYear,
    String? department,
    int? fromYearLevel,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = <String, dynamic>{
        if (generation != null && generation.isNotEmpty) 'generation': generation,
        if (intakeYear != null && intakeYear.isNotEmpty) 'intake_year': intakeYear,
        if (department != null && department.isNotEmpty) 'department': department,
        'from_year_level': ?fromYearLevel,
      };
      final response = await http.post(
        Uri.parse(ApiConfig.promoteStudentsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        _cachedStudents = null;
        return {
          'success': true,
          'message': data['message'] ?? 'ដំឡើងឆ្នាំសិក្សាជោគជ័យ',
          'promoted_count': data['promoted_count'] ?? 0,
        };
      }
      return {'success': false, 'message': data['message'] ?? 'មិនអាចដំឡើងឆ្នាំសិក្សាបានទេ'};
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  static Future<Map<String, dynamic>> bulkUpdateStudentStatus({
    required String status,
    String? generation,
    String? intakeYear,
    String? department,
    int? yearLevel,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = <String, dynamic>{
        'status': status,
        if (generation != null && generation.isNotEmpty) 'generation': generation,
        if (intakeYear != null && intakeYear.isNotEmpty) 'intake_year': intakeYear,
        if (department != null && department.isNotEmpty) 'department': department,
        'year_level': ?yearLevel,
      };
      final response = await http.post(
        Uri.parse(ApiConfig.bulkStudentStatusUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        _cachedStudents = null;
        return {
          'success': true,
          'message': data['message'] ?? 'បានប្តូរស្ថានភាពជោគជ័យ',
          'updated_count': data['updated_count'] ?? 0,
        };
      }
      return {'success': false, 'message': data['message'] ?? 'មិនអាចប្តូរស្ថានភាពបានទេ'};
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាតភ្ជាប់៖ $e'};
    }
  }

  static Future<Map<String, dynamic>?> getAdminStudentStats({
    String? intakeYear,
    String? department,
    String? generation,
    String? status,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final params = <String, String>{
        if (intakeYear != null && intakeYear.isNotEmpty) 'intake_year': intakeYear,
        if (department != null && department.isNotEmpty) 'department': department,
        if (generation != null && generation.isNotEmpty) 'generation': generation,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final uri = Uri.parse(ApiConfig.adminStudentStatsUrl).replace(
        queryParameters: params.isEmpty ? null : params,
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> createClassAdmin({
    required String subjectName,
    required String subjectCode,
    required int lecturerId,
    required String academicYear,
    required String semester,
    String? department,
    String? generation,
    int? yearLevel,
    String? room,
    String? dayOfWeek,
    String? time,
    String? classDate,
    int? totalSessions,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        'subject_name': subjectName,
        'subject_code': subjectCode,
        'department': department ?? '',
        'generation': generation ?? '',
        'year_level': ?yearLevel,
        'lecturer_id': lecturerId,
        'academic_year': academicYear,
        'semester': semester,
        'room': room ?? '',
        'day_of_week': dayOfWeek ?? '',
        'time': time ?? '',
        'class_date': ?classDate,
        'total_sessions': ?totalSessions,
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
        _cachedLecturers = null;
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> updateClassAdmin({
    required int id,
    required String subjectName,
    required String subjectCode,
    required int lecturerId,
    required String academicYear,
    required String semester,
    String? department,
    String? generation,
    int? yearLevel,
    String? room,
    String? dayOfWeek,
    String? time,
    String? classDate,
    int? totalSessions,
    int? completedSessions,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        'subject_name': subjectName,
        'subject_code': subjectCode,
        'department': department ?? '',
        'generation': generation ?? '',
        'year_level': ?yearLevel,
        'lecturer_id': lecturerId,
        'academic_year': academicYear,
        'semester': semester,
        'room': room ?? '',
        'day_of_week': dayOfWeek ?? '',
        'time': time ?? '',
        'class_date': ?classDate,
        'total_sessions': ?totalSessions,
        'completed_sessions': ?completedSessions,
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
        _cachedLecturers = null;
        return true;
      }
      return false;
    } catch (_) {}
    return false;
  }

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
        _cachedLecturers = null;
        return true;
      }
      return false;
    } catch (_) {}
    return false;
  }
}
