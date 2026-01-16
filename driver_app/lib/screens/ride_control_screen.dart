import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/firestore_service.dart';
import 'models/ride.dart';

class RideControlScreen extends StatefulWidget {
  final String rideId;

  const RideControlScreen({super.key, required this.rideId});

  @override
  State<RideControlScreen> createState() => _RideControlScreenState();
}

class _RideControlScreenState extends State<RideControlScreen> {
  Ride? currentRide;

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Control')),
      body: StreamBuilder<Ride?>(
        stream: firestoreService.listenToRide(widget.rideId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          currentRide = snapshot.data;
          if (currentRide == null) {
            return const Center(child: Text('Ride not found'));
          }

          String statusText;
          Widget? actionButton;

          switch (currentRide!.status) {
            case 'accepted':
              statusText = 'Ride accepted. Start ride.';
              actionButton = ElevatedButton(
                onPressed: () => _startRide(),
                child: const Text('Start Ride'),
              );
              break;
            case 'on_the_way':
              statusText = 'On the way to destination';
              actionButton = ElevatedButton(
                onPressed: () => _completeRide(),
                child: const Text('Complete Ride'),
              );
              break;
            case 'completed':
              statusText = 'Ride completed';
              break;
            default:
              statusText = 'Unknown status';
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Pickup: ${currentRide!.pickupAddress}', style: const TextStyle(fontSize: 18)),
                Text('Destination: ${currentRide!.destinationAddress}', style: const TextStyle(fontSize: 18)),
                Text('Fare: \$${currentRide!.finalPrice}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 32),
                Text(statusText, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _callPassenger(currentRide!.riderId),
                  child: const Text('Call Passenger'),
                ),
                if (actionButton != null) ...[
                  const SizedBox(height: 16),
                  actionButton,
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _startRide() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    await firestoreService.updateRideStatus(widget.rideId, 'on_the_way');
  }

  void _completeRide() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    await firestoreService.updateRideStatus(widget.rideId, 'completed');
    Navigator.pop(context);
  }

  void _callPassenger(String riderId) async {
    // Get passenger phone from user collection
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = await firestoreService.getUser(riderId);
    if (user != null) {
      final Uri url = Uri(scheme: 'tel', path: user.phone);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }
}