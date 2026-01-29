import 'package:flutter/foundation.dart';

/// Logger utility for debugging and error tracking
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  /// Log info messages
  static void info(String tag, String message) {
    if (kDebugMode) {
      print('ℹ️ [$tag] $message');
    }
  }

  /// Log error messages
  static void error(String tag, String message, {Exception? exception, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('❌ [$tag] $message');
      if (exception != null) {
        print('Exception: $exception');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// Log warning messages
  static void warning(String tag, String message) {
    if (kDebugMode) {
      print('⚠️ [$tag] $message');
    }
  }

  /// Log debug messages
  static void debug(String tag, String message) {
    if (kDebugMode) {
      print('🐛 [$tag] $message');
    }
  }

  /// Log success messages
  static void success(String tag, String message) {
    if (kDebugMode) {
      print('✅ [$tag] $message');
    }
  }
}
