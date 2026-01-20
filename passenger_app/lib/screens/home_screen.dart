import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/ride.dart';
import '../../../../ride_status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> areas = ['Area A', 'Area B', 'Area C', 'Area D']; // Predefined areas
  String? selectedPickup;
  String? selectedDestination;
  double estimatedFare = 0.0;

  final Map<String, Map<String, double>> pricingTable = {
    'Area A': {'Area B': 50.0, 'Area C': 70.0, 'Area D': 90.0},
    'Area B': {'Area A': 50.0, 'Area C': 60.0, 'Area D': 80.0},
    'Area C': {'Area A': 70.0, 'Area B': 60.0, 'Area D': 40.0},
    'Area D': {'Area A': 90.0, 'Area B': 80.0, 'Area C': 40.0},
  };

  void _calculateFare() {
    if (selectedPickup != null && selectedDestination != null && selectedPickup != selectedDestination) {
      setState(() {
        estimatedFare = pricingTable[selectedPickup]![selectedDestination]!;
      });
    } else {
      setState(() {
        estimatedFare = 0.0;
      });
    }
  }

  void _requestRide() async {
    if (selectedPickup == null || selectedDestination == null || selectedPickup == selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select valid pickup and destination')));
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    final user = authService.currentUser;
    if (user == null) return;

    final ride = Ride(
      rideId: '', // Will be set by Firestore
      riderId: user.uid,
      pickupAddress: selectedPickup!,
      destinationAddress: selectedDestination!,
      pickupGeopoint: {'lat': 0.0, 'lng': 0.0}, // Placeholder, no GPS
      destinationGeopoint: {'lat': 0.0, 'lng': 0.0},
      riderFareOffer: estimatedFare,
      finalPrice: estimatedFare,
      status: 'searching',
    );

    try {
      final rideId = await firestoreService.createRide(ride);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RideStatusScreen(rideId: rideId)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RikshaRide')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text('Select Pickup Area'),
              value: selectedPickup,
              onChanged: (value) {
                setState(() {
                  selectedPickup = value;
                  _calculateFare();
                });
              },
              items: areas.map((area) => DropdownMenuItem(value: area, child: Text(area))).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text('Select Destination Area'),
              value: selectedDestination,
              onChanged: (value) {
                setState(() {
                  selectedDestination = value;
                  _calculateFare();
                });
              },
              items: areas.map((area) => DropdownMenuItem(value: area, child: Text(area))).toList(),
            ),
            const SizedBox(height: 16),
            Text('Estimated Fare: \$${estimatedFare.toStringAsFixed(2)}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _requestRide,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Request Rickshaw'),
            ),
          ],
        ),
      ),
    );
  }
}