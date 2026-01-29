/// Constants for Passenger App
class AppConstants {
  // App Info
  static const String appName = 'RikshaRide Passenger';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'passengers';
  static const String ridesCollection = 'rides';
  static const String walletsCollection = 'wallets';
  static const String ratingsCollection = 'ratings';

  // Ride Status
  static const String rideStatusAvailable = 'available';
  static const String rideStatusAccepted = 'accepted';
  static const String rideStatusInProgress = 'in_progress';
  static const String rideStatusCompleted = 'completed';
  static const String rideStatusCancelled = 'cancelled';

  // User Roles
  static const String roleDriver = 'driver';
  static const String rolePassenger = 'passenger';

  // Validation
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int otpLength = 6;

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // Ride Pricing
  static const double basefare = 30.0;
  static const double perKmRate = 15.0;
  static const double perMinuteRate = 2.0;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;

  // Messages
  static const String loadingMessage = 'Loading...';
  static const String errorMessage = 'Something went wrong. Please try again.';
  static const String noInternetMessage = 'No internet connection';
  static const String successMessage = 'Success!';

  // Areas
  static const List<String> availableAreas = [
    'Downtown',
    'Uptown',
    'Midtown',
    'Suburbs',
    'Airport',
    'Railway Station',
  ];
}
