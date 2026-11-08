import 'package:flutter_test/flutter_test.dart';
import 'package:raahi/data/mock_data.dart';
import 'package:raahi/state/app_state.dart';

void main() {
  group('AppState fares', () {
    test('distance and fare follow the grid', () {
      final state = AppState();
      addTearDown(state.dispose);

      state.setDestination(MockData.places.firstWhere((p) => p.id == 'park'));

      // Current location (3,6) -> Park Street (5,5): 3 grid units * 1.1 km.
      expect(state.distanceKm, 3.3);
      expect(state.phase, RidePhase.choosing);

      final go = MockData.rideTypes.first;
      expect(state.fareFor(go), go.fare(3.3));
    });

    test('RAAHI50 gives 50% off, capped at 80', () {
      final state = AppState();
      addTearDown(state.dispose);
      state.setDestination(MockData.places.firstWhere((p) => p.id == 'airport'));

      final premier =
          MockData.rideTypes.firstWhere((r) => r.id == 'premier');
      final base = state.baseFareFor(premier);

      expect(state.applyPromo('raahi50'), isTrue);
      expect(state.discountFor(base), 80);
      expect(state.fareFor(premier), base - 80);
    });

    test('invalid promo codes are rejected', () {
      final state = AppState();
      addTearDown(state.dispose);
      expect(state.applyPromo('NOPE'), isFalse);
      expect(state.promoCode, isNull);
    });
  });

  group('AppState booking', () {
    test('booking needs a destination', () {
      final state = AppState();
      addTearDown(state.dispose);
      expect(state.bookRide(), isNotNull);
      expect(state.phase, RidePhase.idle);
    });

    test('wallet payment is blocked when the balance is too low', () {
      final state = AppState();
      addTearDown(state.dispose);
      state.wallet = 5;
      state.setDestination(MockData.places.firstWhere((p) => p.id == 'airport'));

      expect(state.bookRide(), isNotNull);
      expect(state.phase, RidePhase.choosing);
    });

    test('cancelling while searching returns to the ride picker', () {
      final state = AppState();
      addTearDown(state.dispose);
      state.setDestination(MockData.places.firstWhere((p) => p.id == 'park'));

      expect(state.bookRide(), isNull);
      expect(state.phase, RidePhase.searching);

      state.cancelRide();
      expect(state.phase, RidePhase.choosing);
      expect(state.driver, isNull);
    });

    test('closing the booking sheet clears the destination', () {
      final state = AppState();
      addTearDown(state.dispose);
      state.setDestination(MockData.places.first);
      state.closeBooking();
      expect(state.destination, isNull);
      expect(state.phase, RidePhase.idle);
    });
  });

  group('Wallet', () {
    test('top up increases balance and logs a transaction', () {
      final state = AppState();
      addTearDown(state.dispose);
      final before = state.wallet;
      final txBefore = state.transactions.length;

      state.topUp(200);

      expect(state.wallet, before + 200);
      expect(state.transactions.length, txBefore + 1);
      expect(state.transactions.first.isCredit, isTrue);
    });
  });
}
