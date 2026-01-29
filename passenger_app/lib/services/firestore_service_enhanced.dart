import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passenger_app/utils/logger.dart';
import 'package:passenger_app/utils/exceptions.dart';
import 'package:passenger_app/utils/constants.dart';

/// Enhanced Firestore Service with error handling
class FirestoreServiceEnhanced {
  static final FirestoreServiceEnhanced _instance = FirestoreServiceEnhanced._internal();
  
  factory FirestoreServiceEnhanced() {
    return _instance;
  }
  
  FirestoreServiceEnhanced._internal();

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

  /// Book a ride
  Future<String> bookRide({
    required String passengerId,
    required String pickupLocation,
    required String dropoffLocation,
    required double estimatedFare,
  }) async {
    try {
      AppLogger.info(_tag, 'Booking new ride for passenger: $passengerId');
      
      final rideRef = _firestore.collection(AppConstants.ridesCollection).doc();
      
      await rideRef.set({
        'id': rideRef.id,
        'passengerId': passengerId,
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation,
        'estimatedFare': estimatedFare,
        'status': AppConstants.rideStatusAvailable,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.success(_tag, 'Ride booked successfully: ${rideRef.id}');
      return rideRef.id;
    } catch (e) {
      AppLogger.error(_tag, 'Error booking ride', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to book ride',
        code: 'BOOK_RIDE_ERROR',
      );
    }
  }

  /// Listen to ride status
  Stream<DocumentSnapshot> getRideStatus(String rideId) {
    try {
      AppLogger.info(_tag, 'Setting up stream for ride status: $rideId');
      
      return _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId)
          .snapshots();
    } catch (e) {
      AppLogger.error(_tag, 'Error setting up ride status stream', exception: e as Exception?);
      rethrow;
    }
  }

  /// Get ride history
  Future<List<DocumentSnapshot>> getRideHistory(String passengerId) async {
    try {
      AppLogger.info(_tag, 'Fetching ride history for: $passengerId');
      
      final snapshot = await _firestore
          .collection(AppConstants.ridesCollection)
          .where('passengerId', isEqualTo: passengerId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      
      AppLogger.success(_tag, 'Fetched ${snapshot.docs.length} rides from history');
      return snapshot.docs;
    } catch (e) {
      AppLogger.error(_tag, 'Error fetching ride history', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to fetch ride history',
        code: 'FETCH_HISTORY_ERROR',
      );
    }
  }

  /// Cancel ride
  Future<void> cancelRide(String rideId) async {
    try {
      AppLogger.info(_tag, 'Cancelling ride: $rideId');
      
      await _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId)
          .update({
        'status': AppConstants.rideStatusCancelled,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.success(_tag, 'Ride cancelled successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error cancelling ride', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to cancel ride',
        code: 'CANCEL_RIDE_ERROR',
      );
    }
  }

  /// Rate driver
  Future<void> rateDriver({
    required String driverId,
    required String passengerId,
    required String rideId,
    required double rating,
    required String comment,
  }) async {
    try {
      AppLogger.info(_tag, 'Rating driver: $driverId with rating $rating');
      
      await _firestore.collection(AppConstants.ratingsCollection).add({
        'driverId': driverId,
        'passengerId': passengerId,
        'rideId': rideId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.success(_tag, 'Driver rated successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error rating driver', exception: e as Exception?);
      throw FirestoreException(
        message: 'Failed to submit rating',
        code: 'RATE_DRIVER_ERROR',
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
