# RikshaRide - Quick Reference Guide

## 🚀 Quick Start (5 Minutes)

### 1. Setup Firebase
```bash
# Go to: https://console.firebase.google.com
# 1. Create new project "RikshaRide"
# 2. Enable Firestore Database
# 3. Enable Phone Authentication
# 4. Download google-services.json
# 5. Place in: driver_app/android/app/ and passenger_app/android/app/
```

### 2. Setup Flutter
```bash
cd driver_app
flutter pub get
flutter run

# In another terminal:
cd passenger_app
flutter pub get
flutter run
```

### 3. Test
- **Passenger:** Book a ride from Downtown to Airport
- **Driver:** Go online and accept the ride
- **Complete:** Mark ride as done, rate each other

---

## 📱 App Structure at a Glance

### Passenger App Files
```
lib/
├── main.dart                    # App entry point
├── screens/
│   ├── login_screen.dart       # OTP login
│   ├── home_screen.dart        # Book ride
│   ├── ride_status_screen.dart # Track ride
│   ├── profile_screen.dart     # User profile
│   └── ride_history_screen.dart # Past rides
├── services/
│   ├── auth_service.dart       # Phone auth
│   └── firestore_service.dart  # Database
└── models/
    ├── user.dart
    ├── ride.dart
    └── wallet.dart
```

### Driver App Files
```
lib/
├── main.dart                    # App entry point
├── screens/
│   ├── login_screen.dart       # OTP login
│   ├── home_screen.dart        # Ride dashboard
│   ├── ride_control_screen.dart # Active ride
│   └── driver_profile_screen.dart # Driver profile
├── services/
│   ├── auth_service.dart       # Phone auth
│   └── firestore_service.dart  # Database
└── models/
    ├── user.dart
    ├── ride.dart
    └── wallet.dart
```

---

## 🔥 Firebase Collections

### Users
```json
{
  "uid": "abc123",
  "name": "Ali Khan",
  "phone": "+923005551234",
  "role": "passenger",
  "status": "online",
  "rating": 4.8,
  "current_lat": 30.123,
  "current_lng": 67.456
}
```

### Rides
```json
{
  "ride_id": "ride123",
  "rider_id": "passenger_uid",
  "driver_id": "driver_uid",
  "pickup_address": "Downtown",
  "destination_address": "Airport",
  "status": "completed",
  "final_price": 450,
  "created_at": "2026-01-30T10:00:00Z"
}
```

### Wallets
```json
{
  "user_id": "driver_uid",
  "balance": 5000,
  "transaction_history": [
    {"amount": 450, "type": "credit", "timestamp": "..."}
  ]
}
```

### Ratings
```json
{
  "ride_id": "ride123",
  "from_user_id": "passenger_uid",
  "to_user_id": "driver_uid",
  "rating": 5,
  "comment": "Great driver!",
  "created_at": "2026-01-30T10:30:00Z"
}
```

---

## 🎨 Color Scheme

- **Primary (Blue):** #1976D2 - Action buttons
- **Success (Green):** #4CAF50 - Confirmations
- **Warning (Orange):** #FF9800 - Warnings
- **Error (Red):** #F44336 - Errors
- **Background:** #FAFAFA - Light gray

---

## 🔑 Key API Methods

### Authentication
```dart
// Sign up
authService.verifyPhoneNumber(
  "+923005551234",
  onCodeSent,
  onError
);

authService.signInWithSmsCode(verificationId, "123456");
authService.signOut();
```

### Rides
```dart
// Passenger books ride
String rideId = await firestoreService.createRide(ride);

// Driver accepts ride
await firestoreService.updateRideStatus(rideId, 'accepted', driverId: uid);

// Update status
await firestoreService.updateRideStatus(rideId, 'on_the_way');
await firestoreService.updateRideStatus(rideId, 'completed');

// Cancel ride
await firestoreService.cancelRide(rideId);
```

### Ratings
```dart
// Rate a user
await firestoreService.rateRide(
  rideId,
  fromUserId,
  toUserId,
  4.5,
  "Good service"
);

// Get average rating
double rating = await firestoreService.getUserAverageRating(userId);
```

### Wallet
```dart
// Get wallet
Wallet? wallet = await firestoreService.getWallet(userId);

// Update balance (negative for debit, positive for credit)
await firestoreService.updateWalletBalance(userId, 450);
```

---

## 🧪 Quick Test Commands

```bash
# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Format code
dart format lib/

# Analyze code
flutter analyze

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Install on device
flutter install

# Run with verbose logging
flutter run -v
```

---

## ⚠️ Common Errors & Fixes

| Error | Fix |
|-------|-----|
| `Gradle build failed` | `flutter clean && flutter pub get` |
| `Firestore connection error` | Check internet, verify google-services.json |
| `OTP not working` | In dev mode, use any 6 digits |
| `Widget not rebuilding` | Use `setState()` or `Provider.notifyListeners()` |
| `Firebase not initialized` | Check `main.dart` Firebase.initializeApp() |
| `Null pointer exception` | Add null checks, use `??` operator |

---

## 📊 Firestore Security Rules (Development)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **Production Rules:** See SETUP_GUIDE.md

---

## 🎯 Ride Status Flow Diagram

```
           ┌─────────────┐
           │  Searching  │
           └──────┬──────┘
                  │
        Driver Accepts Ride
                  │
           ┌──────▼──────┐
           │  Accepted   │
           └──────┬──────┘
                  │
        Driver Starts Ride
                  │
        ┌─────────▼─────────┐
        │   On The Way      │
        └─────────┬─────────┘
                  │
        Driver Marks Complete
                  │
         ┌────────▼────────┐
         │  Completed      │
         │ (Both Rate)     │
         └─────────────────┘

Alternative: Cancelled
    (at any point before completion)
```

---

## 📱 Predefined Areas & Pricing (PKR)

| From | To | Fare |
|------|----|----|
| Downtown | Airport | 450 |
| Downtown | Railway Station | 200 |
| Downtown | Market | 150 |
| Downtown | Hospital | 250 |
| Downtown | Bus Stand | 180 |
| Airport | Railway Station | 350 |
| Airport | Market | 400 |
| Airport | Hospital | 420 |
| Airport | Bus Stand | 380 |
| Railway Station | Market | 120 |
| Railway Station | Hospital | 180 |
| Railway Station | Bus Stand | 100 |
| Market | Hospital | 200 |
| Market | Bus Stand | 140 |
| Hospital | Bus Stand | 220 |

---

## 🔄 Development Workflow

### Day Start
```bash
cd driver_app (or passenger_app)
flutter clean
flutter pub get
flutter run
```

### Make Changes
- Edit code
- Press `r` for hot reload
- Press `R` for hot restart

### Before Commit
```bash
dart format lib/
flutter analyze
flutter test
git add .
git commit -m "Feature description"
```

---

## 📦 APK Release

```bash
# Build release APK
flutter build apk --release

# Located at:
# build/app/outputs/flutter-apk/app-release.apk

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 Firestore Indexes (Auto-created)

The following indexes are automatically created when needed:
- `rides` collection: `status + created_at`
- `users` collection: `role + status`
- `ratings` collection: `to_user_id + created_at`

---

## 💡 Pro Tips

1. **Testing Multiple Devices:**
   - Run both apps on separate emulators/devices
   - Passenger books, Driver accepts
   - Monitor Firestore in real-time

2. **Debugging:**
   - Use `AppLogger` throughout code
   - Check Firebase Console for data
   - Use Flutter DevTools: `flutter pub global run devtools`

3. **Performance:**
   - Limit real-time listeners (2-3 max)
   - Paginate long lists
   - Cache user data locally

4. **Security:**
   - Never commit google-services.json with real keys
   - Validate data on backend
   - Use production security rules

---

## 📚 Learning Resources

- **Flutter Official:** https://flutter.dev
- **Firebase Guide:** https://firebase.google.com/docs/flutter
- **Dart Language:** https://dart.dev
- **Firestore Best Practices:** https://firebase.google.com/docs/firestore/best-practices

---

## 🚨 Before Going Live Checklist

- [ ] Test on 3+ real devices
- [ ] Set production Firestore rules
- [ ] Create signing certificate
- [ ] Build signed APK/AAB
- [ ] Create Play Store listing
- [ ] Write privacy policy
- [ ] Write terms of service
- [ ] Setup analytics
- [ ] Setup crash reporting
- [ ] Create user documentation
- [ ] Set support contact

---

## 📞 Quick Links

- **Firebase Console:** https://console.firebase.google.com
- **Google Play Console:** https://play.google.com/console
- **Flutter Docs:** https://flutter.dev/docs
- **GitHub Repository:** [Your Repository URL]

---

## 📝 Version History

- **v1.0.0** (Jan 30, 2026) - Initial MVP Release
  - All core features complete
  - Both apps functional
  - Firebase integration complete
  - Ready for deployment

---

**For detailed information, see:**
- [README.md](README.md) - Full documentation
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Setup instructions
- [COMPLETION_SUMMARY.md](COMPLETION_SUMMARY.md) - Project summary

---

**Happy Coding! 🚀**
