# RikshaRide - Setup & Deployment Guide

## Quick Start for Developers

This guide will help you set up RikshaRide for development, testing, and deployment.

---

## ✅ Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** 3.0+ → [Download](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **VS Code** with Flutter extension
- **Git** for version control
- **Firebase Account** → [Sign up](https://firebase.google.com)
- **Java Development Kit (JDK)** 11 or higher

### Verify Installation
```bash
flutter --version
flutter doctor
```

---

## 🔧 Step 1: Clone & Setup Project

```bash
# Clone repository
git clone https://github.com/yourusername/RikshaRide.git
cd RikshaRide

# Update Flutter
flutter upgrade

# Get dependencies for Driver App
cd driver_app
flutter pub get

# Get dependencies for Passenger App
cd ../passenger_app
flutter pub get
```

---

## 🔥 Step 2: Setup Firebase Project

### 2.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create Project"
3. Name it: `RikshaRide`
4. Select region (Pakistan - Asia Southeast 1)
5. Click "Create Project"

### 2.2 Enable Services

**Enable Firestore Database:**
- Go to Build → Firestore Database
- Click "Create Database"
- Select "Start in test mode"
- Select region: `asia-southeast1` (Singapore - nearest to Pakistan)
- Click "Create"

**Enable Authentication:**
- Go to Build → Authentication
- Click "Get Started"
- Select "Phone" as sign-in method
- Enable it

### 2.3 Download Configuration Files

**For Android:**
1. Go to Project Settings → Your Apps
2. Select Android app (or create if doesn't exist)
3. Download `google-services.json`
4. Place in:
   - `driver_app/android/app/`
   - `passenger_app/android/app/`

**For iOS (Optional for now):**
1. Download `GoogleService-Info.plist`
2. Place in `Runner` folder

---

## 📝 Step 3: Configure Firestore Security Rules

```bash
# In Firebase Console: Build → Firestore Database → Rules
```

**For Development (Allow all - testing only):**
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

**For Production:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Rides
    match /rides/{rideId} {
      allow read: if request.auth.uid == resource.data.rider_id || 
                     request.auth.uid == resource.data.driver_id;
      allow create: if request.auth.uid == request.resource.data.rider_id;
      allow update: if request.auth.uid == resource.data.driver_id;
    }
    
    // Wallets
    match /wallets/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Ratings
    match /ratings/{ratingId} {
      allow read: if request.auth.uid == resource.data.from_user_id || 
                     request.auth.uid == resource.data.to_user_id;
      allow create: if request.auth.uid == request.resource.data.from_user_id;
    }
  }
}
```

Click "Publish"

---

## 🚀 Step 4: Run the Application

### Start Android Emulator
```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch emulator_name

# Or open Android Studio and launch from there
```

### Run Driver App
```bash
cd driver_app
flutter run
```

### Run Passenger App (in another terminal)
```bash
cd passenger_app
flutter run
```

### Run on Physical Device
```bash
# Enable USB Debugging on Android device
# Connect via USB cable

flutter devices  # Verify device is detected
flutter run      # Choose device when prompted
```

---

## 🧪 Step 5: Test the Application

### Test Scenario 1: Register as Passenger

1. Open **Passenger App** on device
2. Enter phone: `+923005551234` (any valid format)
3. Click "Send OTP"
4. Enter code: `123456` (any 6 digits in dev mode)
5. Enter name: `Ali Khan`
6. Click "Sign In"

### Test Scenario 2: Register as Driver

1. Open **Driver App** on same or different device
2. Enter phone: `+923005555678` (different from passenger)
3. Click "Send OTP"
4. Enter code: `123456`
5. Enter name: `Ahmed Driver`
6. Click "Sign In"

### Test Scenario 3: Book a Ride

1. In **Passenger App**:
   - Select Pickup: "Downtown"
   - Select Destination: "Airport"
   - See Fare: "450 Rs"
   - Click "Request Rickshaw"
   - Status shows: "Finding a Driver"

2. In **Driver App**:
   - Toggle "Online" status
   - See new ride request
   - Click to accept
   - See passenger details and ride info

3. Back in **Passenger App**:
   - Status updates to "Driver Accepted"
   - Can call driver
   - Can view driver details

### Test Scenario 4: Complete Ride

1. In **Driver App**:
   - Click "Start Ride" → status becomes "On The Way"
   - Click "Complete Ride" → status becomes "Completed"
   - Rate Passenger (1-5 stars)
   - Add optional comment
   - Submit

2. In **Passenger App**:
   - Automatically shows completion
   - Can rate driver

---

## 📦 Build for Release

### Build APK (for testing distribution)

```bash
cd driver_app
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

cd ../passenger_app
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (for Play Store)

```bash
cd driver_app
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab

cd ../passenger_app
flutter build appbundle --release
```

### Install APK on Device

```bash
flutter install

# Or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔐 Prepare for Play Store Deployment

### 1. Create Signing Key

```bash
keytool -genkey -v -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

### 2. Configure Signing in Flutter

Create `android/key.properties`:
```properties
storePassword=<from_keytool>
keyPassword=<from_keytool>
keyAlias=my-key-alias
storeFile=/path/to/my-release-key.jks
```

### 3. Build Signed Bundle

```bash
flutter build appbundle --release
```

### 4. Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill in app details
4. Upload app bundle
5. Set pricing and distribution
6. Submit for review

---

## 🐛 Troubleshooting

### Problem: "Gradle build failed"
```bash
# Solution:
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Problem: "Cannot connect to Firestore"
- Check internet connection
- Verify Firebase project is created
- Check `google-services.json` is in correct location
- Verify Firestore security rules allow access

### Problem: "OTP not being sent"
- In development, use any 6-digit code (doesn't send real SMS)
- For production, you need to complete Firebase phone verification setup
- Add phone numbers to test numbers in Firebase Auth settings

### Problem: "App crashes on startup"
```bash
# Clean everything and rebuild:
flutter clean
flutter pub get
cd ios && rm -rf Pods && pod install && cd ..
flutter run
```

### Problem: "No device found"
```bash
# List devices
flutter devices

# If no devices, start emulator
flutter emulators --launch <emulator_name>
```

---

## 📊 Database Initialization

After first run, the database collections are created automatically when:
- Users sign up (creates `users` collection)
- Rides are booked (creates `rides` collection)
- Wallets are accessed (creates `wallets` collection)
- Ratings are submitted (creates `ratings` collection)

You can verify this in Firebase Console → Firestore Database

---

## 🔄 Development Workflow

### Daily Development
```bash
# Start day
flutter clean
flutter pub get
flutter run

# Make changes
# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal

# Test changes
# End day: Commit to git
```

### Before Commit
```bash
# Format code
dart format lib/

# Check for issues
flutter analyze

# Run tests (if any)
flutter test

# Commit
git add .
git commit -m "Feature: your feature description"
```

---

## 🎯 Next Steps After Setup

1. **Test thoroughly** - Try all features on real devices
2. **Gather feedback** - Share APK with testers
3. **Fix bugs** - Prioritize based on feedback
4. **Optimize performance** - Monitor app startup time, battery usage
5. **Prepare for launch** - Set up Play Store listing
6. **Deploy** - Submit to Google Play Store

---

## 📱 Device Recommendations for Testing

- **Low-end**: Samsung J2, Redmi 5 (minimum specs)
- **Mid-range**: Redmi Note 8, A50 (typical users)
- **High-end**: Pixel 5, OnePlus 9 (reference)

Test on at least 2-3 devices with different specifications.

---

## 📞 Getting Help

- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs
- **Stack Overflow**: Tag questions with `flutter` and `firebase`
- **Community**: Flutter Discord, Reddit r/flutter

---

## ✅ Deployment Checklist

Before going live:

- [ ] Test on 3+ real devices
- [ ] Test all ride scenarios
- [ ] Verify offline handling
- [ ] Check data privacy/security
- [ ] Enable production Firestore rules
- [ ] Set up analytics
- [ ] Create support email
- [ ] Prepare privacy policy
- [ ] Prepare terms of service
- [ ] Build signed APK/AAB
- [ ] Create Play Store listing
- [ ] Set up crash reporting
- [ ] Create user documentation

---

**Good luck with RikshaRide! 🚀**

For updates and support, visit: https://github.com/yourusername/RikshaRide
