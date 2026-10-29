import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });
}

class AuthService {
  static const String _keyToken = 'scanin_token';
  static const String _keyUser = 'scanin_user';

  /// ចូលប្រើប្រាស់ (Login API)
  static Future<AuthResult> login({
    required String email,
    required String password,
    String? role,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.loginUrl);
      final payload = <String, dynamic>{
        'email': email.trim(),
        'password': password,
      };
      if (role != null) {
        payload['role'] = role;
      }
      final body = jsonEncode(payload);

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && (data['status'] == true || data['access_token'] != null)) {
        final token = data['access_token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        // រក្សាទុក Token និង User ក្នុង SharedPreferences
        await _saveAuthData(token: token, user: user);

        return AuthResult(
          success: true,
          message: data['message'] as String? ?? 'ចូលប្រើប្រាស់បានជោគជ័យ',
          user: user,
          token: token,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] as String? ?? 'ការចូលប្រើប្រាស់មិនជោគជ័យ',
        );
      }
    } on SocketException catch (_) {
      return const AuthResult(
        success: false,
        message: 'មិនអាចភ្ជាប់ទៅកាន់ Server បានទេ។ សូមប្រាកដថា php artisan serve កំពុងដំណើរការ។',
      );
    } on TimeoutException catch (_) {
      return const AuthResult(
        success: false,
        message: 'ការតភ្ជាប់លើសម៉ោងកំណត់ (Timeout)។ សូមព្យាយាមម្តងទៀត។',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'មានបញ្ហាមិនរំពឹងទុក៖ $e',
      );
    }
  }

  /// រក្សាទុក Token និង User ក្នុង Device
  static Future<void> _saveAuthData({
    required String token,
    required UserModel user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  /// យក Token ដែលបានរក្សាទុក
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// យក User Profile ដែលបានរក្សាទុក
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// ពិនិត្យថាតើបាន Login រួចហើយឬនៅ
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// ចាកចេញពីគណនី (Logout)
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiConfig.logoutUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUser);
    }
  }
}
