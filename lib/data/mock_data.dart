import 'package:flutter/material.dart';

import '../models/models.dart';

/// All demo data lives here so the app runs without any backend.
/// Replace these with repository calls when you plug in a real API.
class MockData {
  MockData._();

  static const double kmPerGridUnit = 1.1;

  static const current = Place(
    id: 'current',
    name: 'Current location',
    subtitle: 'Ballygunge Circular Rd',
    grid: Offset(3, 6),
    icon: Icons.my_location_rounded,
  );

  static const home = Place(
    id: 'home',
    name: 'Home',
    subtitle: '12, Gariahat Road',
    grid: Offset(2, 8),
    icon: Icons.home_rounded,
  );

  static const work = Place(
    id: 'work',
    name: 'Work',
    subtitle: 'Sector V, Salt Lake',
    grid: Offset(7, 3),
    icon: Icons.work_rounded,
  );

  static const places = <Place>[
    home,
    work,
    Place(
      id: 'victoria',
      name: 'Victoria Memorial',
      subtitle: "Queen's Way, Maidan",
      grid: Offset(4, 4),
      icon: Icons.account_balance_rounded,
    ),
    Place(
      id: 'park',
      name: 'Park Street',
      subtitle: 'Mullick Bazar',
      grid: Offset(5, 5),
      icon: Icons.restaurant_rounded,
    ),
    Place(
      id: 'howrah',
      name: 'Howrah Station',
      subtitle: 'Howrah, Railway Hub',
      grid: Offset(1, 2),
      icon: Icons.train_rounded,
    ),
    Place(
      id: 'science',
      name: 'Science City',
      subtitle: 'JBS Haldane Avenue',
      grid: Offset(6, 7),
      icon: Icons.science_rounded,
    ),
    Place(
      id: 'esplanade',
      name: 'Esplanade',
      subtitle: 'Dharmatala Crossing',
      grid: Offset(3, 3),
      icon: Icons.storefront_rounded,
    ),
    Place(
      id: 'airport',
      name: 'Netaji Subhas Airport',
      subtitle: 'Dum Dum',
      grid: Offset(7, 0),
      icon: Icons.flight_rounded,
    ),
    Place(
      id: 'ecopark',
      name: 'Eco Park',
      subtitle: 'New Town, Action Area II',
      grid: Offset(8, 2),
      icon: Icons.park_rounded,
    ),
    Place(
      id: 'mall',
      name: 'South City Mall',
      subtitle: 'Prince Anwar Shah Rd',
      grid: Offset(1, 9),
      icon: Icons.shopping_bag_rounded,
    ),
  ];

  static const rideTypes = <RideType>[
    RideType(
      id: 'go',
      name: 'Raahi Go',
      tagline: 'Affordable everyday rides',
      seats: 4,
      baseFare: 40,
      perKm: 11,
      etaMin: 3,
      icon: Icons.directions_car_filled_rounded,
      color: Color(0xFF4F46E5),
    ),
    RideType(
      id: 'bike',
      name: 'Raahi Bike',
      tagline: 'Beat the traffic',
      seats: 1,
      baseFare: 20,
      perKm: 6,
      etaMin: 2,
      icon: Icons.two_wheeler_rounded,
      color: Color(0xFF10B981),
    ),
    RideType(
      id: 'auto',
      name: 'Raahi Auto',
      tagline: 'Quick auto-rickshaw',
      seats: 3,
      baseFare: 30,
      perKm: 8,
      etaMin: 4,
      icon: Icons.electric_rickshaw_rounded,
      color: Color(0xFFF59E0B),
    ),
    RideType(
      id: 'premier',
      name: 'Raahi Premier',
      tagline: 'Top-rated drivers, premium cars',
      seats: 4,
      baseFare: 70,
      perKm: 18,
      etaMin: 5,
      icon: Icons.local_taxi_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];

  static const drivers = <Driver>[
    Driver(
      name: 'Rahul Das',
      rating: 4.92,
      trips: 2340,
      car: 'White Maruti Dzire',
      plate: 'WB 02 AB 4821',
      phone: '+91 98300 12345',
    ),
    Driver(
      name: 'Sourav Mondal',
      rating: 4.87,
      trips: 1820,
      car: 'Silver Hyundai Aura',
      plate: 'WB 06 CD 1190',
      phone: '+91 98310 22110',
    ),
    Driver(
      name: 'Imran Sheikh',
      rating: 4.95,
      trips: 3105,
      car: 'Grey Toyota Etios',
      plate: 'WB 04 EF 7733',
      phone: '+91 98320 77881',
    ),
    Driver(
      name: 'Anita Roy',
      rating: 4.98,
      trips: 960,
      car: 'Blue Tata Tiago',
      plate: 'WB 08 GH 5602',
      phone: '+91 98330 55442',
    ),
  ];

  static const offers = <PromoOffer>[
    PromoOffer(
      code: 'RAAHI50',
      title: '50% off, up to ₹80',
      description: 'On your next 3 rides',
    ),
    PromoOffer(
      code: 'FIRSTRIDE',
      title: 'Flat ₹40 off',
      description: 'Valid on any ride this week',
    ),
    PromoOffer(
      code: 'WEEKEND25',
      title: '25% off, up to ₹60',
      description: 'Saturday & Sunday only',
    ),
  ];

  static List<Trip> seedTrips() {
    final now = DateTime.now();
    return [
      Trip(
        id: 'RH-10482',
        from: 'Current location',
        to: 'Park Street',
        rideType: 'Raahi Go',
        fare: 118,
        date: now.subtract(const Duration(days: 1, hours: 3)),
        km: 6.6,
        minutes: 24,
        driver: 'Rahul Das',
        rating: 5,
      ),
      Trip(
        id: 'RH-10431',
        from: 'Home',
        to: 'Sector V, Salt Lake',
        rideType: 'Raahi Premier',
        fare: 284,
        date: now.subtract(const Duration(days: 3, hours: 6)),
        km: 11.0,
        minutes: 38,
        driver: 'Anita Roy',
        rating: 5,
        payment: PaymentMethod.upi,
      ),
      Trip(
        id: 'RH-10377',
        from: 'Esplanade',
        to: 'Howrah Station',
        rideType: 'Raahi Auto',
        fare: 96,
        date: now.subtract(const Duration(days: 5, hours: 1)),
        km: 4.4,
        minutes: 19,
        driver: 'Sourav Mondal',
        rating: 4,
        payment: PaymentMethod.cash,
      ),
      Trip(
        id: 'RH-10312',
        from: 'Current location',
        to: 'South City Mall',
        rideType: 'Raahi Bike',
        fare: 64,
        date: now.subtract(const Duration(days: 8, hours: 5)),
        km: 4.4,
        minutes: 15,
        driver: 'Imran Sheikh',
        rating: 5,
      ),
      Trip(
        id: 'RH-10290',
        from: 'Victoria Memorial',
        to: 'Science City',
        rideType: 'Raahi Go',
        fare: 0,
        date: now.subtract(const Duration(days: 11, hours: 2)),
        km: 5.5,
        minutes: 0,
        driver: '-',
        cancelled: true,
      ),
      Trip(
        id: 'RH-10244',
        from: 'Home',
        to: 'Netaji Subhas Airport',
        rideType: 'Raahi Premier',
        fare: 462,
        date: now.subtract(const Duration(days: 14, hours: 7)),
        km: 18.7,
        minutes: 52,
        driver: 'Rahul Das',
        rating: 5,
        payment: PaymentMethod.upi,
      ),
    ];
  }

  static List<WalletTx> seedTransactions() {
    final now = DateTime.now();
    return [
      WalletTx(
        title: 'Ride to Park Street',
        amount: -118,
        date: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      WalletTx(
        title: 'Added via UPI',
        amount: 500,
        date: now.subtract(const Duration(days: 2)),
      ),
      WalletTx(
        title: 'Cashback · RAAHI50',
        amount: 45,
        date: now.subtract(const Duration(days: 6)),
      ),
      WalletTx(
        title: 'Ride to South City Mall',
        amount: -64,
        date: now.subtract(const Duration(days: 8, hours: 5)),
      ),
    ];
  }
}
