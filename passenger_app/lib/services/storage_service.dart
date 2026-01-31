import 'package:passenger_app/utils/logger.dart';

/// Local storage service using in-memory cache
class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  factory StorageService() {
    return _instance;
  }
  
  StorageService._internal();

  final Map<String, dynamic> _cache = {};
  
  /// Initialize storage service
  Future<void> init() async {
    try {
      AppLogger.success('StorageService', 'Storage initialized');
    } catch (e) {
      AppLogger.error('StorageService', 'Error initializing storage', exception: e as Exception?);
      rethrow;
    }
  }

  /// Save string
  Future<void> saveString(String key, String value) async {
    try {
      _cache[key] = value;
      AppLogger.debug('StorageService', 'Saved string: $key');
    } catch (e) {
      AppLogger.error('StorageService', 'Error saving string: $key', exception: e as Exception?);
      rethrow;
    }
  }

  /// Get string
  String? getString(String key) {
    try {
      return _cache[key] as String?;
    } catch (e) {
      AppLogger.error('StorageService', 'Error getting string: $key', exception: e as Exception?);
      return null;
    }
  }

  /// Save boolean
  Future<void> saveBoolean(String key, bool value) async {
    try {
      _cache[key] = value;
      AppLogger.debug('StorageService', 'Saved boolean: $key');
    } catch (e) {
      AppLogger.error('StorageService', 'Error saving boolean: $key', exception: e as Exception?);
      rethrow;
    }
  }

  /// Get boolean
  bool getBoolean(String key, {bool defaultValue = false}) {
    try {
      return (_cache[key] as bool?) ?? defaultValue;
    } catch (e) {
      AppLogger.error('StorageService', 'Error getting boolean: $key', exception: e as Exception?);
      return defaultValue;
    }
  }

  /// Save integer
  Future<void> saveInteger(String key, int value) async {
    try {
      _cache[key] = value;
      AppLogger.debug('StorageService', 'Saved integer: $key');
    } catch (e) {
      AppLogger.error('StorageService', 'Error saving integer: $key', exception: e as Exception?);
      rethrow;
    }
  }

  /// Get integer
  int getInteger(String key, {int defaultValue = 0}) {
    try {
      return (_cache[key] as int?) ?? defaultValue;
    } catch (e) {
      AppLogger.error('StorageService', 'Error getting integer: $key', exception: e as Exception?);
      return defaultValue;
    }
  }

  /// Save double
  Future<void> saveDouble(String key, double value) async {
    try {
      _cache[key] = value;
      AppLogger.debug('StorageService', 'Saved double: $key');
    } catch (e) {
      AppLogger.error('StorageService', 'Error saving double: $key', exception: e as Exception?);
      rethrow;
    }
  }

  /// Get double
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return (_cache[key] as double?) ?? defaultValue;
    } catch (e) {
      AppLogger.error('StorageService', 'Error getting double: $key', exception: e as Exception?);
      return defaultValue;
    }
  }

  /// Remove key
  Future<void> remove(String key) async {
    try {
      _cache.remove(key);
      AppLogger.debug('StorageService', 'Removed key: $key');
    } catch (e) {
      AppLogger.error('StorageService', 'Error removing key: $key', exception: e as Exception?);
      rethrow;
    }
  }

  /// Clear all
  Future<void> clear() async {
    try {
      _cache.clear();
      AppLogger.success('StorageService', 'Storage cleared');
    } catch (e) {
      AppLogger.error('StorageService', 'Error clearing storage', exception: e as Exception?);
      rethrow;
    }
  }
}

/// Storage keys
class StorageKeys {
  static const String userId = 'user_id';
  static const String phoneNumber = 'phone_number';
  static const String userName = 'user_name';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';
  static const String authToken = 'auth_token';
  static const String userPhotoUrl = 'user_photo_url';
  static const String userRating = 'user_rating';
  static const String lastSearchLocation = 'last_search_location';
  static const String savedPaymentMethod = 'saved_payment_method';
}
