import 'package:permission_handler/permission_handler.dart';
import '../logging/app_logger.dart';

/// Manages runtime permission requests for Kasa Me.
/// On Android, microphone access requires a runtime permission grant.
class PermissionService {
  /// Requests microphone permission.
  /// Returns true if permission is granted, false otherwise.
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      AppLogger.log('Permission', 'Microphone permission already granted.');
      return true;
    }

    if (status.isPermanentlyDenied) {
      AppLogger.error('Permission', 'Microphone permission permanently denied. Opening settings.');
      await openAppSettings();
      return false;
    }

    final result = await Permission.microphone.request();
    if (result.isGranted) {
      AppLogger.log('Permission', 'Microphone permission granted by user.');
      return true;
    }

    AppLogger.error('Permission', 'Microphone permission denied by user. Status: $result');
    return false;
  }

  /// Returns true if microphone permission is currently granted without requesting.
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }
}
