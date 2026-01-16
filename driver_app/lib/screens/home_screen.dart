import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/ride.dart';
import '../../../../ride_control_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = false;
  List<Ride> rideRequests = [];

  @override
  void initState() {
    super.initState();
    _listenForRideRequests();
  }

  void _listenForRideRequests() {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    firestoreService.listenForRideRequests().listen((rides) {
      setState(() {
        rideRequests = rides;
      });
    });
  }

  void _toggleAvailability() {
    setState(() {
      isOnline = !isOnline;
    });
    // Update user status in Firestore
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      firestoreService.updateUserStatus(user.uid, isOnline ? 'online' : 'offline');
    }
  }

  void _acceptRide(Ride ride) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      await firestoreService.updateRideStatus(ride.rideId, 'accepted', driverId: user.uid);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RideControlScreen(rideId: ride.rideId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Name: Driver Name', style: const TextStyle(fontSize: 18)),
            Text('Phone: 1234567890'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOnline ? Colors.green : Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: Text(isOnline ? 'Online' : 'Offline'),
            ),
            const SizedBox(height: 32),
            if (isOnline) ...[
              const Text('Ride Requests:', style: TextStyle(fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: rideRequests.length,
                  itemBuilder: (context, index) {
                    final ride = rideRequests[index];
                    return ListTile(
                      title: Text('${ride.pickupAddress} to ${ride.destinationAddress}'),
                      subtitle: Text('\$${ride.finalPrice}'),
                      trailing: ElevatedButton(
                        onPressed: () => _acceptRide(ride),
                        child: const Text('Accept'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}