class User {
  final String uid;
  final String name;
  final String phone;
  final String role; // rider or driver
  final String status; // online or offline
  final double currentLat;
  final double currentLng;
  final double rating;

  User({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.status,
    required this.currentLat,
    required this.currentLng,
    required this.rating,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      name: map['name'],
      phone: map['phone'],
      role: map['role'],
      status: map['status'],
      currentLat: map['current_lat'],
      currentLng: map['current_lng'],
      rating: map['rating'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'role': role,
      'status': status,
      'current_lat': currentLat,
      'current_lng': currentLng,
      'rating': rating,
    };
  }
}
