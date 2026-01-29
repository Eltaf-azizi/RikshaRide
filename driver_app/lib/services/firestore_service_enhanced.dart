import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/utils/logger.dart';
import 'package:driver_app/utils/exceptions.dart';
import 'package:driver_app/utils/constants.dart';

/// Enhanced Firestore Service with error handling
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  
  factory FirestoreService() {
    return _instance;
  }
  
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tag = 'FirestoreService';

  /// Create or update user document
  Future<void> createUser({
    required String userId,
    required String phoneNumber,
    required String name,
    required String role,
  }) async {
    try {
      AppLogger.info(_tag, 'Creating user document for $userId');
      
      await _firestore.collection(AppConstants.usersCollection).doc(userId).set({
        'id': userId,
        'phoneNumber': phoneNumber,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      
      AppLogger.success(_tag, 'User document created successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error creating user document', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to create user profile',
        code: 'CREATE_USER_ERROR',
      );
    }
  }

  /// Get user document
  Future<DocumentSnapshot> getUser(String userId) async {
    try {
      AppLogger.info(_tag, 'Fetching user document: $userId');
      
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        throw FirestoreException(
          message: 'User not found',
          code: 'USER_NOT_FOUND',
        );
      }
      
      AppLogger.success(_tag, 'User document fetched successfully');
      return doc;
    } catch (e) {
      AppLogger.error(_tag, 'Error fetching user document', exception: e as Exception?);
      if (e is FirestoreException) rethrow;
      throw FirestoreException(
        message: 'Failed to fetch user data',
        code: 'FETCH_USER_ERROR',
      );
    }
  }

  /// Update user document
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      AppLogger.info(_tag, 'Updating user document: $userId');
      
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data);
      
      AppLogger.success(_tag, 'User document updated successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error updating user document', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to update user profile',
        code: 'UPDATE_USER_ERROR',
      );
    }
  }

  /// Create ride
  Future<String> createRide({
    required String driverId,
    required String passengerId,
    required String pickupLocation,
    required String dropoffLocation,
    required double fare,
  }) async {
    try {
      AppLogger.info(_tag, 'Creating new ride');
      
      final rideRef = _firestore.collection(AppConstants.ridesCollection).doc();
      
      await rideRef.set({
        'id': rideRef.id,
        'driverId': driverId,
        'passengerId': passengerId,
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation,
        'fare': fare,
        'status': AppConstants.rideStatusAvailable,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.success(_tag, 'Ride created successfully: ${rideRef.id}');
      return rideRef.id;
    } catch (e) {
      AppLogger.error(_tag, 'Error creating ride', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to create ride',
        code: 'CREATE_RIDE_ERROR',
      );
    }
  }

  /// Update ride status
  Future<void> updateRideStatus(String rideId, String status) async {
    try {
      AppLogger.info(_tag, 'Updating ride status: $rideId to $status');
      
      await _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.success(_tag, 'Ride status updated successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error updating ride status', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to update ride status',
        code: 'UPDATE_RIDE_STATUS_ERROR',
      );
    }
  }

  /// Listen to user rides
  Stream<QuerySnapshot> getUserRides(String userId) {
    try {
      AppLogger.info(_tag, 'Setting up stream for user rides: $userId');
      
      return _firestore
          .collection(AppConstants.ridesCollection)
          .where('driverId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      AppLogger.error(_tag, 'Error setting up rides stream', exception: e as Exception?);
      rethrow;
    }
  }

  /// Get available rides
  Future<List<DocumentSnapshot>> getAvailableRides() async {
    try {
      AppLogger.info(_tag, 'Fetching available rides');
      
      final snapshot = await _firestore
          .collection(AppConstants.ridesCollection)
          .where('status', isEqualTo: AppConstants.rideStatusAvailable)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      AppLogger.success(_tag, 'Fetched ${snapshot.docs.length} available rides');
      return snapshot.docs;
    } catch (e) {
      AppLogger.error(_tag, 'Error fetching available rides', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to fetch available rides',
        code: 'FETCH_RIDES_ERROR',
      );
    }
  }

  /// Rate user
  Future<void> rateUser({
    required String userId,
    required String ratedById,
    required double rating,
    required String comment,
  }) async {
    try {
      AppLogger.info(_tag, 'Rating user: $userId with rating $rating');
      
      await _firestore.collection(AppConstants.ratingsCollection).add({
        'userId': userId,
        'ratedById': ratedById,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.success(_tag, 'User rated successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error rating user', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to submit rating',
        code: 'RATE_USER_ERROR',
      );
    }
  }

  /// Batch write operation
  Future<void> batchWrite(Function(WriteBatch) updates) async {
    try {
      AppLogger.info(_tag, 'Starting batch write operation');
      
      final batch = _firestore.batch();
      updates(batch);
      await batch.commit();
      
      AppLogger.success(_tag, 'Batch write completed successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error in batch write', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to save changes',
        code: 'BATCH_WRITE_ERROR',
      );
    }
  }

  /// Transaction
  Future<T> transaction<T>(Future<T> Function(Transaction) updates) async {
    try {
      AppLogger.info(_tag, 'Starting transaction');
      
      final result = await _firestore.runTransaction(updates);
      
      AppLogger.success(_tag, 'Transaction completed successfully');
      return result;
    } catch (e) {
      AppLogger.error(_tag, 'Error in transaction', exception: e as Exception?);
      throw FirestoreException(
        message: 'Transaction failed',
        code: 'TRANSACTION_ERROR',
      );
    }
  }

  /// Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      AppLogger.info(_tag, 'Deleting document: $docId from $collection');
      
      await _firestore.collection(collection).doc(docId).delete();
      
      AppLogger.success(_tag, 'Document deleted successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error deleting document', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to delete document',
        code: 'DELETE_ERROR',
      );
    }
  }
}
