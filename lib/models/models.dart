import 'package:flutter/material.dart';

/// A location on Raahi's (simulated) city grid.
class Place {
  final String id;
  final String name;
  final String subtitle;

  /// Position on the city grid. Whole numbers sit on road intersections.
  final Offset grid;
  final IconData icon;

  const Place({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.grid,
    required this.icon,
  });
}

class RideType {
  final String id;
  final String name;
  final String tagline;
  final int seats;
  final double baseFare;
  final double perKm;
  final int etaMin;
  final IconData icon;
  final Color color;

  const RideType({
    required this.id,
    required this.name,
    required this.tagline,
    required this.seats,
    required this.baseFare,
    required this.perKm,
    required this.etaMin,
    required this.icon,
    required this.color,
  });

  double fare(double km) => (baseFare + perKm * km).roundToDouble();
}

class Driver {
  final String name;
  final double rating;
  final int trips;
  final String car;
  final String plate;
  final String phone;

  const Driver({
    required this.name,
    required this.rating,
    required this.trips,
    required this.car,
    required this.plate,
    required this.phone,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

enum PaymentMethod { wallet, upi, cash }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.wallet:
        return 'Raahi Wallet';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.upi:
        return Icons.qr_code_2_rounded;
      case PaymentMethod.cash:
        return Icons.payments_rounded;
    }
  }
}

class Trip {
  final String id;
  final String from;
  final String to;
  final String rideType;
  final double fare;
  final DateTime date;
  final double km;
  final int minutes;
  final String driver;
  final int? rating;
  final bool cancelled;
  final PaymentMethod payment;

  const Trip({
    required this.id,
    required this.from,
    required this.to,
    required this.rideType,
    required this.fare,
    required this.date,
    required this.km,
    required this.minutes,
    required this.driver,
    this.rating,
    this.cancelled = false,
    this.payment = PaymentMethod.wallet,
  });

  Trip copyWith({int? rating}) => Trip(
        id: id,
        from: from,
        to: to,
        rideType: rideType,
        fare: fare,
        date: date,
        km: km,
        minutes: minutes,
        driver: driver,
        rating: rating ?? this.rating,
        cancelled: cancelled,
        payment: payment,
      );
}

class WalletTx {
  final String title;
  final double amount;
  final DateTime date;

  const WalletTx({
    required this.title,
    required this.amount,
    required this.date,
  });

  bool get isCredit => amount >= 0;
}

class PromoOffer {
  final String code;
  final String title;
  final String description;

  const PromoOffer({
    required this.code,
    required this.title,
    required this.description,
  });
}
