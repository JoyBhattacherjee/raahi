import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../utils/geo.dart';

enum AppStage { splash, onboarding, login, main }

enum RidePhase { idle, choosing, searching, arriving, arrived, onTrip, completed }

/// Single source of truth for the whole app.
///
/// Kept dependency-free on purpose (plain [ChangeNotifier]) so the project is
/// easy to read. For a production app you could swap this for Riverpod/Bloc —
/// the public API below maps cleanly onto either.
class AppState extends ChangeNotifier {
  // ---------------------------------------------------------------- app shell
  AppStage stage = AppStage.splash;
  ThemeMode themeMode = ThemeMode.light;
  bool notificationsOn = true;

  // --------------------------------------------------------------------- user
  String userName = 'Ananya Roy';
  String phone = '+91 98765 43210';

  // -------------------------------------------------------------------- money
  double wallet = 450;
  PaymentMethod payment = PaymentMethod.wallet;
  String? promoCode;
  final List<WalletTx> transactions = MockData.seedTransactions();

  // --------------------------------------------------------------------- ride
  final Place pickup = MockData.current;
  Place? destination;
  RideType selectedRide = MockData.rideTypes.first;
  RidePhase phase = RidePhase.idle;
  Driver? driver;
  String otp = '0000';
  Trip? lastTrip;
  final List<Trip> history = MockData.seedTrips();

  /// Animation progress (0..1) for the current leg. Kept in a separate
  /// notifier so the map can repaint at 30fps without rebuilding the UI.
  final ValueNotifier<double> progress = ValueNotifier<double>(0);

  List<Offset> _routeToPickup = const [];
  Timer? _searchTimer;
  Timer? _progressTimer;
  Timer? _arrivedTimer;
  final math.Random _rng = math.Random();

  static const _driverStartOffsets = <Offset>[
    Offset(-2, -2),
    Offset(2, -2),
    Offset(-2, 2),
    Offset(2, 2),
  ];

  // ------------------------------------------------------------------ app shell
  void completeSplash() {
    if (stage != AppStage.splash) return;
    stage = AppStage.onboarding;
    notifyListeners();
  }

  void finishOnboarding() {
    stage = AppStage.login;
    notifyListeners();
  }

  void signIn(String phoneNumber) {
    if (phoneNumber.trim().isNotEmpty) {
      phone = '+91 ${phoneNumber.trim()}';
    }
    stage = AppStage.main;
    notifyListeners();
  }

  void signOut() {
    _cancelTimers();
    destination = null;
    driver = null;
    phase = RidePhase.idle;
    progress.value = 0;
    stage = AppStage.login;
    notifyListeners();
  }

  void setDarkMode(bool dark) {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setNotifications(bool on) {
    notificationsOn = on;
    notifyListeners();
  }

  // ---------------------------------------------------------------- fares
  double get distanceKm {
    final dest = destination;
    if (dest == null) return 0;
    final km = manhattan(pickup.grid, dest.grid) * MockData.kmPerGridUnit;
    return double.parse(km.toStringAsFixed(1));
  }

  int get tripMinutes => (distanceKm * 3.2 + 4).round();

  int get pickupEtaMin => selectedRide.etaMin + 1;

  double baseFareFor(RideType ride) => ride.fare(distanceKm);

  double discountFor(double fare) {
    switch (promoCode) {
      case 'RAAHI50':
        return math.min(fare * 0.5, 80.0).roundToDouble();
      case 'FIRSTRIDE':
        return math.min(40.0, fare);
      case 'WEEKEND25':
        return math.min(fare * 0.25, 60.0).roundToDouble();
      default:
        return 0;
    }
  }

  double fareFor(RideType ride) {
    final base = baseFareFor(ride);
    return base - discountFor(base);
  }

  double get currentFare => fareFor(selectedRide);

  bool applyPromo(String code) {
    final c = code.trim().toUpperCase();
    final valid = MockData.offers.any((o) => o.code == c);
    if (!valid) return false;
    promoCode = c;
    notifyListeners();
    return true;
  }

  void removePromo() {
    promoCode = null;
    notifyListeners();
  }

  void setPayment(PaymentMethod method) {
    payment = method;
    notifyListeners();
  }

  void topUp(double amount, {String via = 'UPI'}) {
    wallet += amount;
    transactions.insert(
      0,
      WalletTx(title: 'Added via $via', amount: amount, date: DateTime.now()),
    );
    notifyListeners();
  }

  // ------------------------------------------------------------------ routes
  List<Offset> get tripRoute {
    final dest = destination;
    if (dest == null) return const [];
    final horizontalFirst = (pickup.grid.dx + dest.grid.dy).toInt().isEven;
    return manhattanRoute(pickup.grid, dest.grid,
        horizontalFirst: horizontalFirst);
  }

  List<Offset> get routeToPickup => _routeToPickup;

  /// The polyline the map should currently highlight.
  List<Offset> get mapRoute {
    switch (phase) {
      case RidePhase.idle:
        return const [];
      case RidePhase.choosing:
      case RidePhase.searching:
      case RidePhase.onTrip:
      case RidePhase.completed:
        return tripRoute;
      case RidePhase.arriving:
      case RidePhase.arrived:
        return _routeToPickup;
    }
  }

  // ------------------------------------------------------------- ride flow
  void setDestination(Place place) {
    destination = place;
    phase = RidePhase.choosing;
    notifyListeners();
  }

  void selectRide(RideType ride) {
    selectedRide = ride;
    notifyListeners();
  }

  /// Returns an error message when the ride can't be booked.
  String? bookRide() {
    if (destination == null) return 'Choose a destination first.';
    if (payment == PaymentMethod.wallet && wallet < currentFare) {
      return 'Not enough balance in Raahi Wallet. Add money or pick another payment method.';
    }
    _cancelTimers();
    driver = null;
    phase = RidePhase.searching;
    notifyListeners();
    _searchTimer = Timer(const Duration(milliseconds: 3200), _assignDriver);
    return null;
  }

  void _assignDriver() {
    final index = _rng.nextInt(MockData.drivers.length);
    driver = MockData.drivers[index];
    otp = (1000 + _rng.nextInt(9000)).toString();

    final start = pickup.grid + _driverStartOffsets[index % 4];
    _routeToPickup = manhattanRoute(start, pickup.grid, horizontalFirst: false);

    phase = RidePhase.arriving;
    progress.value = 0;
    notifyListeners();
    _runProgress(const Duration(seconds: 9), _driverArrived);
  }

  void _driverArrived() {
    phase = RidePhase.arrived;
    notifyListeners();
    _arrivedTimer = Timer(const Duration(seconds: 4), _startTrip);
  }

  void _startTrip() {
    phase = RidePhase.onTrip;
    progress.value = 0;
    notifyListeners();
    final seconds = (10 + distanceKm).round().clamp(10, 20).toInt();
    _runProgress(Duration(seconds: seconds), _completeTrip);
  }

  void _completeTrip() {
    final dest = destination;
    if (dest == null) return;
    final fare = currentFare;

    final trip = Trip(
      id: 'RH-${10500 + history.length}',
      from: pickup.name,
      to: dest.name,
      rideType: selectedRide.name,
      fare: fare,
      date: DateTime.now(),
      km: distanceKm,
      minutes: tripMinutes,
      driver: driver?.name ?? '-',
      payment: payment,
    );

    if (payment == PaymentMethod.wallet) {
      wallet -= fare;
      transactions.insert(
        0,
        WalletTx(title: 'Ride to ${dest.name}', amount: -fare, date: trip.date),
      );
    }

    history.insert(0, trip);
    lastTrip = trip;
    phase = RidePhase.completed;
    notifyListeners();
  }

  void _runProgress(Duration duration, VoidCallback onDone) {
    _progressTimer?.cancel();
    progress.value = 0;
    final watch = Stopwatch()..start();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      final v = watch.elapsedMilliseconds / duration.inMilliseconds;
      if (v >= 1) {
        timer.cancel();
        progress.value = 1;
        onDone();
      } else {
        progress.value = v;
      }
    });
  }

  /// Cancels the ride while keeping the chosen destination.
  void cancelRide() {
    final hadDriver = driver != null;
    _cancelTimers();

    final dest = destination;
    if (hadDriver && dest != null) {
      history.insert(
        0,
        Trip(
          id: 'RH-${10500 + history.length}',
          from: pickup.name,
          to: dest.name,
          rideType: selectedRide.name,
          fare: 0,
          date: DateTime.now(),
          km: distanceKm,
          minutes: 0,
          driver: '-',
          cancelled: true,
        ),
      );
    }

    driver = null;
    progress.value = 0;
    phase = destination == null ? RidePhase.idle : RidePhase.choosing;
    notifyListeners();
  }

  /// Leaves the booking sheet and returns to the idle map.
  void closeBooking() {
    destination = null;
    phase = RidePhase.idle;
    notifyListeners();
  }

  void submitRating(int stars, double tip) {
    final trip = lastTrip;
    if (trip != null) {
      final i = history.indexWhere((t) => t.id == trip.id);
      if (i != -1) history[i] = history[i].copyWith(rating: stars);
    }
    if (tip > 0 && payment == PaymentMethod.wallet && wallet >= tip) {
      wallet -= tip;
      transactions.insert(
        0,
        WalletTx(
          title: 'Tip for ${driver?.name ?? 'driver'}',
          amount: -tip,
          date: DateTime.now(),
        ),
      );
    }
    _cancelTimers();
    destination = null;
    driver = null;
    promoCode = null;
    lastTrip = null;
    progress.value = 0;
    phase = RidePhase.idle;
    notifyListeners();
  }

  void _cancelTimers() {
    _searchTimer?.cancel();
    _progressTimer?.cancel();
    _arrivedTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    progress.dispose();
    super.dispose();
  }
}
