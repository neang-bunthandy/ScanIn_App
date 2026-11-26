// Device GPS location and anti-fake-GPS service.
import 'package:geolocator/geolocator.dart';

class GpsLocationResult {
  final double? latitude;
  final double? longitude;
  final bool isMocked;
  final String? errorMessage;

  const GpsLocationResult({
    this.latitude,
    this.longitude,
    this.isMocked = false,
    this.errorMessage,
  });

  bool get hasLocation => latitude != null && longitude != null;
}

class LocationService {

  static Future<GpsLocationResult> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const GpsLocationResult(
          errorMessage: 'សូមបើកទីតាំង GPS (Location) លើទូរស័ព្ទរបស់អ្នកជាមុនសិន!',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const GpsLocationResult(
            errorMessage: 'សូមអនុញ្ញាតសិទ្ធិប្រើប្រាស់ GPS ដើម្បីកត់វត្តមានក្នុងបរិវេណសាលា!',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const GpsLocationResult(
          errorMessage: 'សិទ្ធិ GPS ត្រូវបានបិទជាអចិន្ត្រៃយ៍។ សូមចូលទៅបើកក្នុង Settings ទូរស័ព្ទ!',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return GpsLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        isMocked: position.isMocked,
      );
    } catch (e) {
      return GpsLocationResult(
        errorMessage: 'មិនអាចចាប់សញ្ញា GPS បានទេ៖ $e',
      );
    }
  }
}
