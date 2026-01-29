/// Environment Configuration
class AppEnvironment {
  static const String environment = 'production'; // development, staging, production
  
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';

  /// Firebase Configuration
  static const String firebaseProjectId = 'riksharide';
  static const String firebaseDomain = 'riksharide.firebaseapp.com';
  
  /// App Configuration
  static const String appVersion = '1.0.0';
  static const String minimumSupportedVersion = '1.0.0';
  
  /// API Configuration
  static const String apiBaseUrl = 'https://api.riksharide.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  /// Feature Flags
  static const bool enableLogging = true;
  static const bool enableCrashlytics = true;
  static const bool enableAnalytics = true;
}
