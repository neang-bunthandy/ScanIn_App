// Device ID binding and Face ID/Biometric authentication service.
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthResult {
  final bool success;
  final String? errorMessage;

  const BiometricAuthResult({required this.success, this.errorMessage});
}

class BiometricService {
  static const String _keyDeviceId = 'scanin_device_id';
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyDeviceId);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final rand = Random.secure();
    final hex = List.generate(8, (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    final newId = 'SCANIN-DEV-${DateTime.now().millisecondsSinceEpoch}-$hex';
    await prefs.setString(_keyDeviceId, newId);
    return newId;
  }

  static Future<BiometricAuthResult> authenticateWithFaceId() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      if (!canCheck && !isSupported) {
        return const BiometricAuthResult(
          success: false,
          errorMessage: 'ទូរស័ព្ទនេះមិនគាំទ្រ Face ID / Biometric ទេ។ សូមប្រើការស្កេន QR Code ជំនួសវិញ!',
        );
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'សូមស្កេន Face ID ដើម្បីបញ្ជាក់អត្តសញ្ញាណ និងកត់វត្តមាន',
        biometricOnly: true,
      );

      if (!didAuthenticate) {
        return const BiometricAuthResult(
          success: false,
          errorMessage: 'ការផ្ទៀងផ្ទាត់ Face ID ត្រូវបានបោះបង់ ឬមិនត្រឹមត្រូវ!',
        );
      }

      return const BiometricAuthResult(success: true);
    } on PlatformException catch (e) {
      return BiometricAuthResult(
        success: false,
        errorMessage: 'មិនអាចបើក Face ID បានទេ៖ ${e.message ?? e.code}',
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        errorMessage: 'មានបញ្ហា Face ID៖ $e',
      );
    }
  }
}
