class Ride {
  final String rideId;
  final String riderId;
  final String? driverId;
  final String pickupAddress;
  final String destinationAddress;
  final Map<String, double> pickupGeopoint;
  final Map<String, double> destinationGeopoint;
  final double riderFareOffer;
  final double finalPrice;
  final String status; // searching, accepted, on_the_way, completed, cancelled
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  Ride({
    required this.rideId,
    required this.riderId,
    this.driverId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupGeopoint,
    required this.destinationGeopoint,
    required this.riderFareOffer,
    required this.finalPrice,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      rideId: map['ride_id'],
      riderId: map['rider_id'],
      driverId: map['driver_id'],
      pickupAddress: map['pickup_address'],
      destinationAddress: map['destination_address'],
      pickupGeopoint: Map<String, double>.from(map['pickup_geopoint']),
      destinationGeopoint: Map<String, double>.from(map['destination_geopoint']),
      riderFareOffer: map['rider_fare_offer'].toDouble(),
      finalPrice: map['final_price'].toDouble(),
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      acceptedAt: map['accepted_at'] != null ? DateTime.parse(map['accepted_at']) : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ride_id': rideId,
      'rider_id': riderId,
      'driver_id': driverId,
      'pickup_address': pickupAddress,
      'destination_address': destinationAddress,
      'pickup_geopoint': pickupGeopoint,
      'destination_geopoint': destinationGeopoint,
      'rider_fare_offer': riderFareOffer,
      'final_price': finalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}