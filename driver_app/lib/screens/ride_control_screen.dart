import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/ride.dart';
import 'home_screen.dart';

class RideControlScreen extends StatefulWidget {
  final String rideId;

  const RideControlScreen({super.key, required this.rideId});

  @override
  State<RideControlScreen> createState() => _RideControlScreenState();
}

class _RideControlScreenState extends State<RideControlScreen> {
  Ride? currentRide;
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _showRatingDialog = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ride Control'),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
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
            IconData statusIcon;
            Color statusColor;

            switch (currentRide!.status) {
              case 'accepted':
                statusText = 'Ride Accepted - Ready to pick up passenger';
                statusIcon = Icons.check_circle;
                statusColor = Colors.blue;
                actionButton = ElevatedButton.icon(
                  onPressed: () => _startRide(firestoreService),
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Start Ride'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                );
                break;
              case 'on_the_way':
                statusText = 'On the way to destination';
                statusIcon = Icons.directions;
                statusColor = Colors.orange;
                actionButton = ElevatedButton.icon(
                  onPressed: () => _completeRide(firestoreService),
                  icon: const Icon(Icons.check),
                  label: const Text('Complete Ride'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                );
                break;
              case 'completed':
                statusText = 'Ride Completed';
                statusIcon = Icons.done_all;
                statusColor = Colors.green;
                actionButton = !_showRatingDialog
                    ? ElevatedButton.icon(
                        onPressed: () => setState(() => _showRatingDialog = true),
                        icon: const Icon(Icons.star),
                        label: const Text('Rate Passenger'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                      )
                    : null;
                break;
              case 'cancelled':
                statusText = 'Ride Cancelled';
                statusIcon = Icons.cancel;
                statusColor = Colors.red;
                break;
              default:
                statusText = 'Unknown status';
                statusIcon = Icons.help;
                statusColor = Colors.grey;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Card(
                      color: statusColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Ride Details
                    const Text('Ride Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.green),
                      title: const Text('Pickup'),
                      subtitle: Text(currentRide!.pickupAddress),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: const Text('Destination'),
                      subtitle: Text(currentRide!.destinationAddress),
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_money, color: Colors.amber),
                      title: const Text('Fare'),
                      subtitle: Text('\$${currentRide!.finalPrice.toStringAsFixed(2)}'),
                    ),
                    const SizedBox(height: 20),
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _callPassenger(firestoreService, currentRide!.riderId),
                        icon: const Icon(Icons.call),
                        label: const Text('Call Passenger'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (actionButton != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: actionButton,
                      ),
                    ],
                    if (currentRide!.status != 'cancelled' && currentRide!.status != 'completed')
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _cancelRide(firestoreService),
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text('Cancel Ride', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    // Rating Dialog
                    if (_showRatingDialog && currentRide!.status == 'completed')
                      Column(
                        children: [
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text('Rate Passenger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Slider(
                            value: _rating,
                            onChanged: (val) => setState(() => _rating = val),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _rating.toStringAsFixed(1),
                          ),
                          Center(
                            child: Text(
                              '${_rating.toStringAsFixed(1)} / 5.0',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment (optional)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            minLines: 3,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _showRatingDialog = false),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _submitRating(firestoreService),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                                  child: const Text('Submit Rating'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startRide(FirestoreService firestoreService) async {
    try {
      await firestoreService.updateRideStatus(widget.rideId, 'on_the_way');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride started')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _completeRide(FirestoreService firestoreService) async {
    try {
      await firestoreService.updateRideStatus(widget.rideId, 'completed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _cancelRide(FirestoreService firestoreService) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await firestoreService.cancelRide(widget.rideId);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _callPassenger(FirestoreService firestoreService, String passengerId) async {
    try {
      final user = await firestoreService.getUser(passengerId);
      if (user != null) {
        final Uri url = Uri(scheme: 'tel', path: user.phone);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _submitRating(FirestoreService firestoreService) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final driverId = authService.currentUser?.uid;
      if (driverId != null && currentRide != null) {
        await firestoreService.rateRide(
          widget.rideId,
          driverId,
          currentRide!.riderId,
          _rating,
          _commentController.text,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}