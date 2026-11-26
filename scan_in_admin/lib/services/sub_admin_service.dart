// Sub-Admin CRUD management API service.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'auth_service.dart';

class SubAdminService {

  static Future<List<Map<String, dynamic>>> getSubAdmins() async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(ApiConfig.subAdminsUrl);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createSubAdmin({
    required String name,
    String? latinName,
    required String email,
    required String password,
    String? department,
    String? phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(ApiConfig.subAdminsUrl);

      final payload = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        if (latinName != null && latinName.trim().isNotEmpty) 'latin_name': latinName.trim(),
        if (department != null && department.trim().isNotEmpty) 'department': department.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['status'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'បានបង្កើតគណនី Sub-Admin ដោយជោគជ័យ',
          'data': body['data'],
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'ការបង្កើត Sub-Admin មិនជោគជ័យ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'មានបញ្ហាតភ្ជាប់ទៅកាន់ Server៖ $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateSubAdmin({
    required int id,
    String? name,
    String? latinName,
    String? email,
    String? password,
    String? department,
    String? phone,
    String? status,
  }) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(ApiConfig.subAdminDetailUrl(id));

      final payload = <String, dynamic>{
        if (name != null) 'name': name.trim(),
        if (latinName != null) 'latin_name': latinName.trim(),
        if (email != null) 'email': email.trim().toLowerCase(),
        if (password != null && password.isNotEmpty) 'password': password,
        if (department != null) 'department': department.trim(),
        if (phone != null) 'phone': phone.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'បានកែប្រែគណនី Sub-Admin ដោយជោគជ័យ',
          'data': body['data'],
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'ការកែប្រែ Sub-Admin មិនជោគជ័យ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'មានបញ្ហាតភ្ជាប់ទៅកាន់ Server៖ $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteSubAdmin(int id) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(ApiConfig.subAdminDetailUrl(id));

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'បានលុបគណនី Sub-Admin ដោយជោគជ័យ',
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'ការលុប Sub-Admin មិនជោគជ័យ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'មានបញ្ហាតភ្ជាប់ទៅកាន់ Server៖ $e',
      };
    }
  }
}
