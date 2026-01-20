import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'RikshaRide/passenger_app/lib/services/firestore_service.dart';
import 'RikshaRide/passenger_app/lib/models/ride.dart';

class RideStatusScreen extends StatefulWidget {
  final String rideId;

  const RideStatusScreen({super.key, required this.rideId});

  @override
  State<RideStatusScreen> createState() => _RideStatusScreenState();
}

class _RideStatusScreenState extends State<RideStatusScreen> {
  Ride? currentRide;

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Status')),
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
            case 'searching':
              statusText = 'Searching for driver...';
              break;
            case 'accepted':
              statusText = 'Driver accepted: ${currentRide!.driverId}';
              actionButton = ElevatedButton(
                onPressed: () => _callDriver(currentRide!.driverId!),
                child: const Text('Call Driver'),
              );
              break;
            case 'on_the_way':
              statusText = 'Driver is on the way';
              actionButton = ElevatedButton(
                onPressed: () => _callDriver(currentRide!.driverId!),
                child: const Text('Call Driver'),
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
                Text(statusText, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 32),
                if (actionButton != null) actionButton,
              ],
            ),
          );
        },
      ),
    );
  }

  void _callDriver(String driverId) async {
    // Assume we have driver's phone from user collection, but for simplicity, placeholder
    final Uri url = Uri(scheme: 'tel', path: '1234567890'); // Placeholder phone
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}