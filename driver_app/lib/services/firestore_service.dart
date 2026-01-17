import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/user.dart';
import '../../../../models/ride.dart';
import '../../../../models/wallet.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users collection
  Future<void> createUser(User user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _db.collection('users').doc(uid).update({'status': status});
  }

  Future<User?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Rides collection
  Future<String> createRide(Ride ride) async {
    try {
      DocumentReference docRef = await _db.collection('rides').add(ride.toMap());
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
    await _db.collection('rides').doc(rideId).update(update);
  }

  // Listen for nearby ride requests
  Stream<List<Ride>> listenForRideRequests() {
    return _db.collection('rides').where('status', isEqualTo: 'searching').snapshots().map((snapshot) {
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
}