# RikshaRide MVP

A Flutter-based ride-hailing app for passengers and drivers, designed for low-end Android devices and unstable internet in Quetta.

## Features

### Passenger App
- Select pickup and destination from predefined areas
- View estimated fare based on fixed pricing
- Request rickshaw and track ride status in real-time
- Call driver during ride

### Driver App
- Toggle online/offline status
- Receive and accept ride requests
- Control ride status (start, complete)
- Call passenger

## Setup

1. Install Flutter (latest stable)
2. Set up Firebase project
3. Add google-services.json to both apps' android/app/ directories
4. Run `flutter pub get` in each app directory
5. Build and run on Android

## Firebase Configuration

- Enable Firestore and Authentication (Phone)
- Create collections: users, rides, wallets
- Add security rules as needed

## Architecture

- Clean, modular code with Provider for state management
- Real-time Firestore listeners for ride updates
- Fixed pricing table for fares
- No GPS tracking, cash payments only

## Notes

- Apps are independently runnable
- Designed for low-end devices: large buttons, minimal screens
- Handles network loss gracefully with error messages
- Phone auth preferred but not fully integrated in UI (assume logged in)