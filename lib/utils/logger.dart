import 'package:flutter/foundation.dart';

/// Simple logger utility for the application
/// In production, this can be extended to use Firebase Crashlytics or other logging services
class AppLogger {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
        if (stackTrace != null) {
          debugPrint('[STACK] $stackTrace');
        }
      }
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
    // In production, send to logging service
  }

  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
      }
    }
    // In production, send to logging service
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('[ERROR DETAILS] $error');
      if (stackTrace != null) {
        debugPrint('[STACK TRACE] $stackTrace');
      }
    }
    // In production, send to Crashlytics or logging service
  }

  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[FATAL] $message');
    if (error != null) {
      debugPrint('[ERROR DETAILS] $error');
      if (stackTrace != null) {
        debugPrint('[STACK TRACE] $stackTrace');
      }
    }
    // In production, send to Crashlytics
  }
}
