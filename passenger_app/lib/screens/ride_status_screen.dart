import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/ride.dart';
import 'home_screen.dart';

class RideStatusScreen extends StatefulWidget {
  final String rideId;

  const RideStatusScreen({super.key, required this.rideId});

  @override
  State<RideStatusScreen> createState() => _RideStatusScreenState();
}

class _RideStatusScreenState extends State<RideStatusScreen> {
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ride Status'),
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
            String statusSubtext = '';
            Widget? actionButton;
            IconData statusIcon;
            Color statusColor;

            switch (currentRide!.status) {
              case 'searching':
                statusText = 'Finding a Driver';
                statusSubtext = 'Please wait while we search for available drivers...';
                statusIcon = Icons.search;
                statusColor = Colors.orange;
                actionButton = OutlinedButton.icon(
                  onPressed: () => _cancelRide(firestoreService),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Cancel Ride', style: TextStyle(color: Colors.red)),
                );
                break;
              case 'accepted':
                statusText = 'Driver Accepted';
                statusSubtext = 'Your driver is on the way to pick you up';
                statusIcon = Icons.check_circle;
                statusColor = Colors.blue;
                actionButton = ElevatedButton.icon(
                  onPressed: () => _callDriver(firestoreService, currentRide!.driverId!),
                  icon: const Icon(Icons.call),
                  label: const Text('Call Driver'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                );
                break;
              case 'on_the_way':
                statusText = 'Driver is on the Way';
                statusSubtext = 'Your driver will arrive soon';
                statusIcon = Icons.directions_car;
                statusColor = Colors.green;
                actionButton = ElevatedButton.icon(
                  onPressed: () => _callDriver(firestoreService, currentRide!.driverId!),
                  icon: const Icon(Icons.call),
                  label: const Text('Call Driver'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                );
                break;
              case 'completed':
                statusText = 'Ride Completed';
                statusSubtext = 'Thank you for using RikshaRide!';
                statusIcon = Icons.done_all;
                statusColor = Colors.green;
                actionButton = !_showRatingDialog
                    ? ElevatedButton.icon(
                        onPressed: () => setState(() => _showRatingDialog = true),
                        icon: const Icon(Icons.star),
                        label: const Text('Rate Driver'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                      )
                    : null;
                break;
              case 'cancelled':
                statusText = 'Ride Cancelled';
                statusSubtext = 'This ride has been cancelled';
                statusIcon = Icons.cancel;
                statusColor = Colors.red;
                actionButton = ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
                  child: const Text('Book Another Ride'),
                );
                break;
              default:
                statusText = 'Unknown Status';
                statusSubtext = '';
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
                      color: statusColor.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 32),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                      if (statusSubtext.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          statusSubtext,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
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
                    if (actionButton != null)
                      SizedBox(
                        width: double.infinity,
                        child: actionButton,
                      ),
                    // Rating Dialog
                    if (_showRatingDialog && currentRide!.status == 'completed')
                      Column(
                        children: [
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text('Rate Your Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              ),
                              child: const Text('Back to Home'),
                            ),
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

  void _callDriver(FirestoreService firestoreService, String driverId) async {
    try {
      final user = await firestoreService.getUser(driverId);
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
      final passengerId = authService.currentUser?.uid;
      if (passengerId != null && currentRide != null) {
        await firestoreService.rateRide(
          widget.rideId,
          passengerId,
          currentRide!.driverId!,
          _rating,
          _commentController.text,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating submitted')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}