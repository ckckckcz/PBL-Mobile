import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';

/// Helper class for handling gallery/photo permissions across different Android versions
class PermissionHelper {
  PermissionHelper._();

  /// Check and request gallery/photo permissions
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestGalleryPermission() async {
    // Skip permission check on web
    if (kIsWeb) {
      return true;
    }

    try {
      // Get Android version
      final androidVersion = await _getAndroidVersion();

      // Android 13+ (API 33+) uses granular media permissions
      if (androidVersion >= 33) {
        return await _requestPhotosPermission();
      }
      // Android 10-12 (API 29-32) uses scoped storage
      else if (androidVersion >= 29) {
        return await _requestStoragePermission();
      }
      // Android 9 and below (API 28 and below)
      else {
        return await _requestStoragePermission();
      }
    } catch (e) {
      // Fallback: try both permissions
      return await _requestPhotosPermission() ||
          await _requestStoragePermission();
    }
  }

  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      // Return a safe default (Android 13) if detection fails
      return 33;
    }
  }

  /// Request photos permission (Android 13+)
  static Future<bool> _requestPhotosPermission() async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    // Limited access is still considered granted for read operations
    if (status.isLimited) {
      return true;
    }

    return false;
  }

  /// Request storage permission (Android 12 and below)
  static Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    return false;
  }

  /// Check if permission is permanently denied
  static Future<bool> isGalleryPermissionPermanentlyDenied() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final androidVersion = await _getAndroidVersion();

      if (androidVersion >= 33) {
        final status = await Permission.photos.status;
        return status.isPermanentlyDenied;
      } else {
        final status = await Permission.storage.status;
        return status.isPermanentlyDenied;
      }
    } catch (e) {
      return false;
    }
  }

  /// Check if camera permission is granted
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) {
      return true;
    }

    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    return false;
  }

  /// Check if camera permission is permanently denied
  static Future<bool> isCameraPermissionPermanentlyDenied() async {
    if (kIsWeb) {
      return false;
    }

    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Get permission status string for debugging
  static Future<String> getPermissionDebugInfo() async {
    if (kIsWeb) {
      return 'Web platform - permissions not required';
    }

    try {
      final androidVersion = await _getAndroidVersion();
      final cameraStatus = await Permission.camera.status;
      final photosStatus = await Permission.photos.status;
      final storageStatus = await Permission.storage.status;

      return '''
Android Version: $androidVersion
Camera Permission: $cameraStatus
Photos Permission: $photosStatus
Storage Permission: $storageStatus
''';
    } catch (e) {
      return 'Error getting permission info: $e';
    }
  }
}
