import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration loaded from environment variables
class AppConfig {
  static bool _initialized = false;

  /// Initialize configuration from .env file
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
    } catch (e) {
      // .env file is optional - use defaults
      _initialized = true;
    }
  }

  /// Get environment (dev, staging, prod)
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'dev';

  /// Check if running in production
  static bool get isProduction => environment == 'prod';

  /// Check if running in development
  static bool get isDevelopment => environment == 'dev';

  /// Check if running in staging
  static bool get isStaging => environment == 'staging';

  /// Get Firebase project ID
  static String? get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'];

  /// Get API base URL (if needed)
  static String? get apiBaseUrl => dotenv.env['API_BASE_URL'];

  /// Get any custom config value
  static String? getValue(String key) => dotenv.env[key];
}
