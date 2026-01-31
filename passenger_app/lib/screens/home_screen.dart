import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/ride.dart';
import '../models/user.dart';
import 'ride_status_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> areas = ['Downtown', 'Airport', 'Railway Station', 'Market', 'Hospital', 'Bus Stand'];
  String? selectedPickup;
  String? selectedDestination;
  double estimatedFare = 0.0;
  User? currentPassenger;
  bool _isLoading = false;

  final Map<String, Map<String, double>> pricingTable = {
    'Downtown': {'Airport': 450.0, 'Railway Station': 200.0, 'Market': 150.0, 'Hospital': 250.0, 'Bus Stand': 180.0},
    'Airport': {'Downtown': 450.0, 'Railway Station': 350.0, 'Market': 400.0, 'Hospital': 420.0, 'Bus Stand': 380.0},
    'Railway Station': {'Downtown': 200.0, 'Airport': 350.0, 'Market': 120.0, 'Hospital': 180.0, 'Bus Stand': 100.0},
    'Market': {'Downtown': 150.0, 'Airport': 400.0, 'Railway Station': 120.0, 'Hospital': 200.0, 'Bus Stand': 140.0},
    'Hospital': {'Downtown': 250.0, 'Airport': 420.0, 'Railway Station': 180.0, 'Market': 200.0, 'Bus Stand': 220.0},
    'Bus Stand': {'Downtown': 180.0, 'Airport': 380.0, 'Railway Station': 100.0, 'Market': 140.0, 'Hospital': 220.0},
  };

  @override
  void initState() {
    super.initState();
    _loadPassengerData();
  }

  void _loadPassengerData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final passengerData = await firestoreService.getUser(user.uid);
      setState(() {
        currentPassenger = passengerData;
      });
    }
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid pickup and destination')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    final user = authService.currentUser;
    if (user == null) return;

    try {
      final ride = Ride(
        rideId: '',
        riderId: user.uid,
        pickupAddress: selectedPickup!,
        destinationAddress: selectedDestination!,
        pickupGeopoint: {'lat': 0.0, 'lng': 0.0},
        destinationGeopoint: {'lat': 0.0, 'lng': 0.0},
        riderFareOffer: estimatedFare,
        finalPrice: estimatedFare,
        status: 'searching',
        createdAt: DateTime.now(),
      );

      final rideId = await firestoreService.createRide(ride);
      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RideStatusScreen(rideId: rideId)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RikshaRide Passenger'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              tooltip: 'Profile',
            ),
          ],
        ),
        body: currentPassenger == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Card
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentPassenger!.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    currentPassenger!.phone,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      const Text(
                        'Book Your Ride',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Pickup Selection
                      const Text('Pickup Location', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select Pickup Area'),
                          value: selectedPickup,
                          underline: const SizedBox(),
                          onChanged: (value) {
                            setState(() {
                              selectedPickup = value;
                              _calculateFare();
                            });
                          },
                          items: areas
                              .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Destination Selection
                      const Text('Destination', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select Destination Area'),
                          value: selectedDestination,
                          underline: const SizedBox(),
                          onChanged: (value) {
                            setState(() {
                              selectedDestination = value;
                              _calculateFare();
                            });
                          },
                          items: areas
                              .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Fare Display
                      if (estimatedFare > 0)
                        Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Estimated Fare'),
                                Text(
                                  '\$${estimatedFare.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Request Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _requestRide,
                          icon: const Icon(Icons.directions_car),
                          label: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Request Rickshaw'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info, color: Colors.amber, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Prices shown are estimates. Final price may vary.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}