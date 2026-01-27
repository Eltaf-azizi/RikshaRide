import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/ride.dart';
import '../models/wallet.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users collection
  Future<void> createUser(User user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(User user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _db.collection('users').doc(uid).update({
      'status': status,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  Future<User?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<User?> listenToUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<List<User>> getOnlineDrivers() async {
    QuerySnapshot snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'driver')
        .where('status', isEqualTo: 'online')
        .get();
    return snapshot.docs.map((doc) => User.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // Rides collection
  Future<String> createRide(Ride ride) async {
    try {
      DocumentReference docRef = await _db.collection('rides').add(ride.toMap());
      await docRef.update({'ride_id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create ride: $e');
    }
  }

  Stream<Ride?> listenToRide(String rideId) {
    return _db.collection('rides').doc(rideId).snapshots().map((doc) {
      if (doc.exists) {
        return Ride.fromMap(doc.data()!);
      }
      return null;
    });
  }

  Future<void> updateRideStatus(String rideId, String status, {String? driverId}) async {
    Map<String, dynamic> update = {'status': status};
    if (driverId != null) update['driver_id'] = driverId;
    if (status == 'accepted') {
      update['accepted_at'] = FieldValue.serverTimestamp();
    } else if (status == 'completed') {
      update['completed_at'] = FieldValue.serverTimestamp();
    }
    await _db.collection('rides').doc(rideId).update(update);
  }

  Future<void> cancelRide(String rideId) async {
    await _db.collection('rides').doc(rideId).update({
      'status': 'cancelled',
      'completed_at': FieldValue.serverTimestamp(),
    });
  }

  // Listen for nearby ride requests
  Stream<List<Ride>> listenForRideRequests() {
    return _db.collection('rides').where('status', isEqualTo: 'searching').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Ride.fromMap(doc.data())).toList();
    });
  }

  Stream<List<Ride>> getPassengerRides(String passengerId) {
    return _db.collection('rides').where('rider_id', isEqualTo: passengerId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Ride.fromMap(doc.data())).toList();
    });
  }

  // Wallets collection
  Future<void> createWallet(Wallet wallet) async {
    await _db.collection('wallets').doc(wallet.userId).set(wallet.toMap());
  }

  Future<Wallet?> getWallet(String userId) async {
    DocumentSnapshot doc = await _db.collection('wallets').doc(userId).get();
    if (doc.exists) {
      return Wallet.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateWalletBalance(String userId, double amount) async {
    final wallet = await getWallet(userId);
    if (wallet != null) {
      final newBalance = wallet.balance + amount;
      await _db.collection('wallets').doc(userId).update({
        'balance': newBalance,
        'transaction_history': FieldValue.arrayUnion([
          {
            'amount': amount,
            'timestamp': FieldValue.serverTimestamp(),
            'type': amount > 0 ? 'credit' : 'debit',
          }
        ]),
      });
    }
  }

  Stream<Wallet?> listenToWallet(String userId) {
    return _db.collection('wallets').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return Wallet.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Ratings collection
  Future<void> rateRide(String rideId, String fromUserId, String toUserId, double rating, String comment) async {
    await _db.collection('ratings').add({
      'ride_id': rideId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'rating': rating,
      'comment': comment,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<double> getUserAverageRating(String userId) async {
    QuerySnapshot snapshot = await _db.collection('ratings').where('to_user_id', isEqualTo: userId).get();
    if (snapshot.docs.isEmpty) return 5.0;
    final ratings = snapshot.docs.map((doc) => (doc['rating'] as num).toDouble()).toList();
    final average = ratings.reduce((a, b) => a + b) / ratings.length;
    return double.parse(average.toStringAsFixed(1));
  }
}