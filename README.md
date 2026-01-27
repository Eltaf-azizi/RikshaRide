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

1. Passenger App (Android) – for booking rides
2. Driver App (Android) – for accepting and completing rides
3. Firebase Backend – for real-time data and ride management

This repository contains the core logic and structure required to run the MVP.


## ✨ Key Features (MVP)
### Passenger App

 - Select pickup area from a predefined list
 - Select destination area from a predefined list
 - View estimated fare before booking
 - Request a rickshaw ride
 - Real-time ride status updates
 - Call the assigned driver directly

### Driver App

 - Simple driver profile
 - Toggle availability (online/offline)
 - Receive nearby ride requests
 - Accept or reject ride requests
 - Call the passenger
 - Mark the ride as completed


### Admin / Backend

 - Manage users and rides through Firebase
 - Monitor ride status in real time
 - Fixed pricing logic based on pickup and destination areas


## 🚫 What This MVP Does NOT Include

To keep the project realistic and maintainable, the following features are intentionally excluded from the MVP:

 - In-app payments or wallets UI
 - Ratings and reviews
 - Chat system
 - Push notifications
 - Promo codes or surge pricing
 - Live GPS maps or navigation
 - These can be added later once the core system


## 🛠 Tech Stack

 - **Frontend:** Flutter
 - **Backend:** Firebase
    - Firestore (database)
    - Firebase Authentication (optional / future)
 - **Platform:** Android (Android-first approach)

The stack was chosen for fast development, scalability, and suitability for solo developers.


## 🗂 Firestore Database Schema
### Users Collection

 - uid (string)
 - name (string)
 - phone (string)
 - role (rider/driver)
 - status (online / offline)
 - current_lat (number)
 - current_lng (number)
 - rating (number)

### Rides Collection

 - ride_id (string)
 - rider_id (string)
 - driver_id (string or null)
 - pickup_address (string)
 - destination_address (string)
 - pickup_geopoint (map: lat, lng)
 - destination_geopoint (map: lat, lng)
 - rider_fare_offer (number)
 - final_price (number)
 - status (searching / accepted / on_the_way / completed)

### Wallets Collection

 - user_id (string)
 - balance (number)
 - transaction_history (array of maps)


## 🔄 Ride Flow (Simplified)

 1. Passenger selects pickup and destination areas
 2. App shows fixed estimated fare
 3. Passenger requests a ride
 4. Ride status is set to searching
 5. Nearby online drivers receive the request
 6. The first driver to accept is assigned
 7. Ride progresses through states:
    - searching → accepted → on_the_way → completed

## 📱 Design & UX Principles

 - Minimal UI with large buttons
 - Simple English/Urdu-friendly labels
 - Low data usage
 - Fast load times
 - Works well on low-end Android phones

The app prioritizes usability over visual polish.

## 🚀 Getting Started (Development)

 1. Install Flutter (latest stable)
 2. Install Android Studio (for SDK & emulator)
 3. Clone this repository
 4. Configure the Firebase project
 5. Connect Firestore to the app
 6. Run on a real Android device or emulator

**Note:** For early testing, APK distribution is preferred over Play Store deployment


## 📈 Future Improvements

Once the MVP is validated, future versions may include:

 - Maps and live driver tracking
 - Ratings and reviews
 - Digital wallet and payments
 - Notifications
 - Expansion to taxis and delivery services

These features are intentionally postponed until real user demand is proven.


## 🧠 Philosophy Behind RikshaRide

RikshaRide is built with a local-first mindset:

 - Solve small, real problems
 - Start with one area, then scale
 - Build trust before adding complexity

The project values execution, feedback, and iteration over perfection.


## 📄 License

This project is currently for educational and startup MVP purposes. Licensing can be defined later based on deployment and commercialization plans.
