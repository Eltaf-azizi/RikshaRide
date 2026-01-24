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
