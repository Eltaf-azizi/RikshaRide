import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/ride.dart';
import '../models/user.dart';
import 'ride_control_screen.dart';
import 'driver_profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = false;
  List<Ride> rideRequests = [];
  User? currentDriver;
  double driverRating = 5.0;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
    _listenForRideRequests();
  }

  void _loadDriverData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final driverData = await firestoreService.getUser(user.uid);
      final rating = await firestoreService.getUserAverageRating(user.uid);
      setState(() {
        currentDriver = driverData;
        driverRating = rating;
      });
    }
  }

  void _listenForRideRequests() {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    firestoreService.listenForRideRequests().listen((rides) {
      setState(() {
        rideRequests = rides;
      });
    });
  }

  void _toggleAvailability() async {
    setState(() {
      isOnline = !isOnline;
    });
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      await firestoreService.updateUserStatus(user.uid, isOnline ? 'online' : 'offline');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isOnline ? 'You are now Online' : 'You are now Offline')),
      );
    }
  }

  void _acceptRide(Ride ride) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      try {
        await firestoreService.updateRideStatus(ride.rideId, 'accepted', driverId: user.uid);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RideControlScreen(rideId: ride.rideId)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      await firestoreService.updateUserStatus(user.uid, 'offline');
    }
    await authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Driver Dashboard'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DriverProfileScreen()),
                );
              },
              tooltip: 'Profile',
            ),
          ],
        ),
        body: currentDriver == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Driver Info Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentDriver!.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(currentDriver!.phone),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text('$driverRating / 5.0', style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Status Toggle
                    Center(
                      child: Column(
                        children: [
                          Text(
                            isOnline ? 'You are Online' : 'You are Offline',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isOnline ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _toggleAvailability,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isOnline ? Colors.green : Colors.grey,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              isOnline ? 'Go Offline' : 'Go Online',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Ride Requests
                    if (isOnline) ...[
                      Text(
                        'Ride Requests (${rideRequests.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: rideRequests.isEmpty
                            ? const Center(
                                child: Text('No ride requests available'),
                              )
                            : ListView.builder(
                                itemCount: rideRequests.length,
                                itemBuilder: (context, index) {
                                  final ride = rideRequests[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(
                                        '${ride.pickupAddress} → ${ride.destinationAddress}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text('\$${ride.finalPrice.toStringAsFixed(2)}'),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () => _acceptRide(ride),
                                        child: const Text('Accept'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ] else ...[
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.power_settings_new, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Go online to receive ride requests'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}