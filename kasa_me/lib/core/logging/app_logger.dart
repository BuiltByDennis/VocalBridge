import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String category, String message) {
    if (kDebugMode) {
      print('[$category] $message');
    }
  }

  static void error(String category, String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$category] ERROR: $message');
      if (error != null) print(error);
      if (stackTrace != null) print(stackTrace);
    }
  }
}
