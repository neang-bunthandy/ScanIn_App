// Campus GPS geofencing settings API service.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'auth_service.dart';

class CampusSettingModel {
  final String campusName;
  final double? campusLat;
  final double? campusLng;
  final int allowedRadiusMeters;
  final bool enforceGps;

  const CampusSettingModel({
    required this.campusName,
    this.campusLat,
    this.campusLng,
    this.allowedRadiusMeters = 65,
    this.enforceGps = false,
  });

  factory CampusSettingModel.fromJson(Map<String, dynamic> json) {
    return CampusSettingModel(
      campusName: json['campus_name'] as String? ?? 'សាកលវិទ្យាល័យ (Main Campus)',
      campusLat: json['campus_lat'] is num
          ? (json['campus_lat'] as num).toDouble()
          : double.tryParse(json['campus_lat']?.toString() ?? ''),
      campusLng: json['campus_lng'] is num
          ? (json['campus_lng'] as num).toDouble()
          : double.tryParse(json['campus_lng']?.toString() ?? ''),
      allowedRadiusMeters: json['allowed_radius_meters'] is int
          ? json['allowed_radius_meters'] as int
          : int.tryParse(json['allowed_radius_meters']?.toString() ?? '65') ?? 65,
      enforceGps: json['enforce_gps'] == true || json['enforce_gps'] == 1,
    );
  }
}

class CampusSettingService {
  static Future<CampusSettingModel?> getSettings() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.campusSettingsUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is Map<String, dynamic>) {
          return CampusSettingModel.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>> updateSettings({
    required String campusName,
    required double? campusLat,
    required double? campusLng,
    required int allowedRadiusMeters,
    required bool enforceGps,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse(ApiConfig.adminCampusSettingsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'campus_name': campusName.trim(),
          'campus_lat': campusLat,
          'campus_lng': campusLng,
          'allowed_radius_meters': allowedRadiusMeters,
          'enforce_gps': enforceGps,
        }),
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['status'] == true,
        'message': data['message'] ?? 'បានរក្សាទុកការកំណត់ GPS!',
      };
    } catch (e) {
      return {'success': false, 'message': 'បញ្ហាការតភ្ជាប់៖ $e'};
    }
  }
}
