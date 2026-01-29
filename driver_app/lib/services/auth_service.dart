import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver_app/utils/logger.dart';
import 'package:driver_app/utils/exceptions.dart';
import 'package:driver_app/utils/validators.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _tag = 'AuthService';

  /// Verify phone number with OTP
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
  ) async {
    try {
      // Validate phone number
      final validationError = AppValidators.validatePhoneNumber(phoneNumber);
      if (validationError != null) {
        throw ValidationException(message: validationError);
      }

      AppLogger.info(_tag, 'Verifying phone number: $phoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            AppLogger.info(_tag, 'Auto-verification completed');
            await _auth.signInWithCredential(credential);
          } catch (e) {
            AppLogger.error(_tag, 'Auto-verification failed', exception: e as Exception?);
            onError('Verification failed: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.error(_tag, 'Phone verification failed', exception: e);
          final errorMessage = _getErrorMessage(e.code);
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.success(_tag, 'OTP sent successfully');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.warning(_tag, 'Auto-retrieval timeout for verification: $verificationId');
        },
        timeout: const Duration(minutes: 2),
      );
    } on ValidationException catch (e) {
      AppLogger.error(_tag, 'Validation error', exception: e);
      onError(e.message);
    } catch (e) {
      AppLogger.error(_tag, 'Phone verification error', exception: e as Exception?);
      onError('An error occurred. Please try again.');
    }
  }

  /// Sign in with SMS code
  Future<User?> signInWithSmsCode(String verificationId, String smsCode) async {
    try {
      // Validate OTP
      final validationError = AppValidators.validateOTP(smsCode);
      if (validationError != null) {
        throw ValidationException(message: validationError);
      }

      AppLogger.info(_tag, 'Signing in with SMS code');

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      AppLogger.success(_tag, 'User signed in successfully');
      return userCredential.user;
    } on ValidationException catch (e) {
      AppLogger.error(_tag, 'Validation error', exception: e);
      throw AuthException(message: e.message);
    } catch (e) {
      AppLogger.error(_tag, 'Sign in error', exception: e as Exception?);
      throw AuthException(
        message: 'Failed to sign in. Please try again.',
        code: 'SIGN_IN_ERROR',
      );
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user phone
  String? get currentUserPhone => _auth.currentUser?.phoneNumber;

  /// Sign out
  Future<void> signOut() async {
    try {
      AppLogger.info(_tag, 'Signing out user');
      await _auth.signOut();
      AppLogger.success(_tag, 'User signed out successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Sign out error', exception: e as Exception?);
      throw AuthException(
        message: 'Failed to sign out. Please try again.',
        code: 'SIGN_OUT_ERROR',
      );
    }
  }

  /// Reauthenticate user
  Future<void> reauthenticateWithPhone(String phoneNumber) async {
    try {
      AppLogger.info(_tag, 'Reauthenticating user');
      // Implement reauthentication logic if needed
    } catch (e) {
      AppLogger.error(_tag, 'Reauthentication error', exception: e as Exception?);
      throw AuthException(
        message: 'Reauthentication failed',
        code: 'REAUTH_ERROR',
      );
    }
  }

  /// Helper method to get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid.';
      case 'missing-phone-number':
        return 'Phone number is required.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'session-expired':
        return 'Verification session expired. Please try again.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
