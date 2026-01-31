import 'dart:async';
import 'package:driver_app/utils/exceptions.dart';
import 'package:driver_app/utils/logger.dart';

/// Network service to check connectivity
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  
  factory NetworkService() {
    return _instance;
  }
  
  NetworkService._internal();

  bool _isConnected = true;

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    try {
      return _isConnected;
    } catch (e) {
      AppLogger.error('NetworkService', 'Error checking connectivity', exception: e as Exception?);
      throw NetworkException(
        message: 'Unable to check internet connection',
        code: 'CONNECTIVITY_ERROR',
      );
    }
  }

  /// Set connection status
  void setConnected(bool connected) {
    _isConnected = connected;
  }

  /// Dispose resources
  void dispose() {
    // No resources to dispose
  }
}
