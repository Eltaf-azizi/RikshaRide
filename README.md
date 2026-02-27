<h1 align="center"> RikshaRide MVP</h1>

RikshaRide is a lightweight, Android-first rickshaw booking application designed for cities like Quetta, where rickshaws are a primary mode of transport and digital ride-hailing solutions are limited or overcomplicated.

The project focuses on simplicity, trust, and reliability rather than flashy features. It is built to work smoothly on low-end Android devices and unstable internet connections.


## 🎯 Project Vision

The goal of RikshaRide is to solve real, local transportation problems:

 - No fixed or transparent pricing
 - Difficulty finding trusted rickshaw drivers
 - Lack of digital booking solutions tailored for small cities

RikshaRide provides a simple request-and-accept system with fixed area-based pricing, making rides predictable and fair for both passengers and drivers.


## 🧱 System Overview

RikshaRide consists of three main components:

1. **Passenger App (Android)** – for booking rides
2. **Driver App (Android)** – for accepting and completing rides
3. **Firebase Backend** – for real-time data and ride management

---

## 📱 Areas Supported (Quetta)

The app includes predefined pricing for these areas:
- Downtown
- Airport
- Railway Station
- Market
- Hospital
- Bus Stand

Each area pair has fixed pricing (in Pakistani Rupees).

---

## 🗂 Firestore Database Schema

### Users Collection
```
- uid (string) - Primary Key
- name (string)
- phone (string)
- role (string) - "driver" or "passenger"
- status (string) - "online" or "offline"
- current_lat (number)
- current_lng (number)
- rating (number) - Average user rating
```

### Rides Collection
```
- ride_id (string) - Primary Key
- rider_id (string) - Passenger UID
- driver_id (string) - Driver UID (null if searching)
- pickup_address (string)
- destination_address (string)
- pickup_geopoint (map) - {lat, lng}
- destination_geopoint (map) - {lat, lng}
- rider_fare_offer (number)
- final_price (number)
- status (string) - "searching" | "accepted" | "on_the_way" | "completed" | "cancelled"
- created_at (timestamp)
- accepted_at (timestamp)
- completed_at (timestamp)
```

### Wallets Collection
```
- user_id (string) - Primary Key
- balance (number)
- transaction_history (array of maps)
  - amount (number)
  - timestamp (timestamp)
  - type (string) - "credit" or "debit"
```

### Ratings Collection
```
- ride_id (string)
- from_user_id (string)
- to_user_id (string)
- rating (number) - 1 to 5
- comment (string)
- created_at (timestamp)
```

---

## 🔄 Ride Flow

1. **Passenger** selects pickup and destination areas
2. App calculates and shows **estimated fare**
3. Passenger **requests a ride** (status: searching)
4. Nearby **online drivers** receive the request notification
5. **First driver to accept** gets assigned (status: accepted)
6. Driver navigates to pickup location (status: on_the_way)
7. Driver **marks ride as completed** (status: completed)
8. Both **passenger and driver** rate each other
9. **Fare is processed** and added to driver's wallet

---

## 🛠 Tech Stack

- **Frontend:** Flutter 3.0+
- **Language:** Dart
- **Backend:** Firebase
  - Firestore (NoSQL Database)
  - Firebase Authentication (Phone OTP)
  - Cloud Functions (Optional - for advanced features)
- **Platform:** Android (Android-first), Web Ready
- **State Management:** Provider
- **Local Storage:** SharedPreferences
- **Location Services:** Geolocator
- **Networking:** Connectivity Plus

---

## 📁 Project Structure

```
RikshaRide/
├── driver_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── firebase_options.dart
│   │   ├── config/
│   │   │   └── environment.dart
│   │   ├── models/
│   │   │   ├── ride.dart
│   │   │   ├── user.dart
│   │   │   └── wallet.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── ride_control_screen.dart
│   │   │   └── driver_profile_screen.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── firestore_service.dart
│   │   │   ├── firestore_service_enhanced.dart
│   │   │   └── network_service.dart
│   │   └── utils/
│   │       ├── constants.dart
│   │       ├── exceptions.dart
│   │       ├── extensions.dart
│   │       ├── logger.dart
│   │       ├── theme.dart
│   │       └── validators.dart
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── passenger_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── firebase_options.dart
│   │   ├── config/
│   │   │   └── environment.dart
│   │   ├── models/
│   │   │   ├── ride.dart
│   │   │   ├── user.dart
│   │   │   └── wallet.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── ride_status_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── ride_history_screen.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── firestore_service.dart
│   │   │   ├── firestore_service_enhanced.dart
│   │   │   └── network_service.dart
│   │   └── utils/
│   │       ├── constants.dart
│   │       ├── exceptions.dart
│   │       ├── extensions.dart
│   │       ├── logger.dart
│   │       ├── theme.dart
│   │       └── validators.dart
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
└── README.md
```

---

## 🚀 Getting Started (Development Setup)

### Prerequisites
- Flutter SDK 3.0+ (Get from [flutter.dev](https://flutter.dev))
- Android Studio or VS Code with Flutter extension
- Java Development Kit (JDK 11+)
- Git

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/RikshaRide.git
   cd RikshaRide
   ```

2. **Setup Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project named "RikshaRide"
   - Enable Firestore Database
   - Enable Phone Authentication
   - Download `google-services.json` and `GoogleService-Info.plist`
   - Place `google-services.json` in both `driver_app/android/app/` and `passenger_app/android/app/`

3. **Install Flutter Dependencies**
   ```bash
   # For Driver App
   cd driver_app
   flutter pub get
   
   # For Passenger App
   cd ../passenger_app
   flutter pub get
   ```

4. **Configure Firebase (Flutter)**
   - The `firebase_options.dart` files are already configured
   - Update with your Firebase project credentials if needed

5. **Run the Apps**
   ```bash
   # Get list of available devices
   flutter devices
   
   # Run Driver App
   cd driver_app
   flutter run
   
   # Run Passenger App (in another terminal)
   cd passenger_app
   flutter run
   ```

---

## 🧪 Testing the App

### Test Scenarios

**Scenario 1: Passenger Books a Ride**
1. Login with phone number (use any number with +92 country code)
2. Enter OTP (for testing, any 6 digits work)
3. Select pickup area (e.g., Downtown)
4. Select destination area (e.g., Airport)
5. View estimated fare (e.g., 450 Rs)
6. Tap "Request Rickshaw"
7. Ride status updates to "searching"

**Scenario 2: Driver Accepts Ride**
1. Login as driver with different phone number
2. Toggle "Online" status
3. View incoming ride requests
4. Tap to accept a ride
5. View passenger details
6. Complete the ride after reaching destination

**Scenario 3: Rate and Review**
1. After ride completion
2. Passenger rates driver
3. Driver rates passenger
4. Both ratings saved to database

**Scenario 4: View History**
1. Open profile (tap person icon)
2. Tap "Ride History"
3. View all past rides with details

---

## 📊 Database Rules (Firestore Security)

**Current Setup (Development):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all users (Development only!)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Production Rules (Recommended):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Rides - passengers can read their own, drivers can read assigned
    match /rides/{rideId} {
      allow read: if request.auth.uid == resource.data.rider_id || 
                     request.auth.uid == resource.data.driver_id;
      allow create: if request.auth.uid == request.resource.data.rider_id;
      allow update: if request.auth.uid == resource.data.driver_id;
    }
    
    // Wallets - users can only read their own
    match /wallets/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## 📦 Building for Release

### Android APK Build
```bash
cd driver_app
flutter build apk

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle

# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🔐 Security Considerations

Before deploying to production:

1. **Enable Firestore Security Rules** (see above)
2. **Restrict Firebase APIs** - Whitelist only necessary services
3. **Enable Billing** - To prevent abuse quotas
4. **Add Rate Limiting** - On Cloud Functions (if used)
5. **Hash Sensitive Data** - Phone numbers and personal info
6. **Use HTTPS** - All API calls should be secure
7. **Implement Verification** - For phone numbers and user identity

---

## 🚫 Known Limitations (MVP)

- **No Maps/GPS Integration** - Uses predefined area pricing instead of distance-based
- **No Real-time Notifications** - Check app for updates manually
- **No Payment Integration** - Earnings tracked but not paid out automatically
- **No Admin Dashboard** - Management through Firestore console
- **No Chat System** - Users can only call via phone
- **Single City** - Only Quetta areas included
- **No Driver Documents** - No verification system implemented
- **No Insurance/Safety** - Features to be added in future versions

These limitations are intentional for the MVP phase and will be addressed in future updates.

---

## 📈 Future Roadmap

**Phase 2 (Next Iteration):**
- [ ] Real-time GPS tracking with maps
- [ ] Push notifications
- [ ] In-app payment system
- [ ] Admin dashboard
- [ ] Driver document verification
- [ ] Emergency contact feature
- [ ] Multiple language support (Urdu)

**Phase 3 (Scaling):**
- [ ] Expand to multiple cities
- [ ] Taxi and delivery services
- [ ] Corporate accounts
- [ ] Scheduled rides
- [ ] Ride sharing (multiple passengers)
- [ ] AI-based pricing surge

---

## 🐛 Troubleshooting

### Common Issues

**Q: OTP not arriving?**
- In development, use any 6-digit code
- Make sure phone number format is +92XXXXXXXXXX

**Q: Firestore connection error?**
- Check Firebase project is created and Firestore is enabled
- Verify `google-services.json` is in correct location
- Check network connectivity

**Q: App crashes on startup?**
- Clear app data: `flutter clean`
- Reinstall dependencies: `flutter pub get`
- Rebuild: `flutter run`

**Q: Can't find drivers?**
- Make sure driver account is set to "Online"
- Check both apps are running simultaneously
- Verify Firestore rules allow read access

---

## 📞 Support & Contact

For issues, questions, or feedback:
- Create an issue on GitHub
- Email: support@riksharide.app
- WhatsApp: +92-XXX-XXXXXXX

---

## 👥 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 🙏 Acknowledgments

- Built for the residents of Quetta
- Thanks to the Flutter and Firebase communities
- Special thanks to all testers and feedback providers

---

**Made with ❤️ for Quetta Transportation**

Last Updated: January 30, 2026
Version: 1.0.0 (MVP Complete)
