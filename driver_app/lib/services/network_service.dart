import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_app/utils/exceptions.dart';
import 'package:driver_app/utils/logger.dart';

/// Network service to check connectivity
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  
  factory NetworkService() {
    return _instance;
  }
  
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && result.first != ConnectivityResult.none;
    } catch (e) {
      AppLogger.error('NetworkService', 'Error checking connectivity', exception: e as Exception?);
      throw NetworkException(
        message: 'Unable to check internet connection',
        code: 'CONNECTIVITY_ERROR',
      );
    }
  }

  /// Listen to connectivity changes
  Stream<bool> connectivityStream() {
    return _connectivity.onConnectivityChanged.map((result) {
      return result.isNotEmpty && result.first != ConnectivityResult.none;
    });
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}
