import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';

// ====================================================================== RIDE
/// Shown while the driver is arriving, waiting, and during the trip.
class RidePanel extends StatelessWidget {
  const RidePanel({super.key});

  Future<void> _confirmCancel(BuildContext context, AppState s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Cancel this ride?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your driver is already on the way. Cancelling now may cost a small fee.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep ride'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Cancel ride',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) s.cancelRide();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final driver = s.driver;
    final dest = s.destination;
    if (driver == null || dest == null) return const SizedBox.shrink();

    final phase = s.phase;
    final onTrip = phase == RidePhase.onTrip;
    final arrived = phase == RidePhase.arrived;

    final String headline;
    final String subline;
    if (onTrip) {
      headline = 'Heading to ${dest.name}';
      subline = '${s.distanceKm} km · ${money(s.currentFare)}';
    } else if (arrived) {
      headline = 'Your driver has arrived';
      subline = 'Share the PIN below to start your trip';
    } else {
      headline = 'Driver is on the way';
      subline = '${driver.car} · ${driver.plate}';
    }

    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: context.tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subline,
                      style: TextStyle(color: context.muted, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<double>(
                valueListenable: s.progress,
                builder: (context, p, _) {
                  if (arrived) {
                    return const Pill(
                      label: 'Here',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.green,
                      filled: true,
                    );
                  }
                  final total = onTrip ? s.tripMinutes : s.pickupEtaMin;
                  final left = (total * (1 - p)).ceil().clamp(1, 999).toInt();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$left',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          onTrip ? 'min left' : 'min away',
                          style: TextStyle(
                            color: Colors.white.o(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<double>(
            valueListenable: s.progress,
            builder: (context, p, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: arrived ? 1 : p,
                minHeight: 6,
                backgroundColor: context.soft,
                valueColor: AlwaysStoppedAnimation<Color>(
                  arrived ? AppColors.green : AppColors.indigo,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _DriverCard(driver: driver),
          const SizedBox(height: 14),
          if (!onTrip)
            _PinRow(pin: s.otp)
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.soft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(s.payment.icon, color: context.cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Paying with ${s.payment.label}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    money(s.currentFare),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          if (onTrip)
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    label: 'Share trip',
                    icon: Icons.ios_share_rounded,
                    onPressed: () => showSnack(
                      context,
                      'Live trip link copied (demo).',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GhostButton(
                    label: 'SOS',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.red,
                    onPressed: () => showSnack(
                      context,
                      'In a real app this would alert your emergency contacts.',
                    ),
                  ),
                ),
              ],
            )
          else
            GhostButton(
              label: 'Cancel ride',
              color: AppColors.red,
              onPressed: () => _confirmCancel(context, s),
            ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.soft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Avatar(initials: driver.initials, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: AppColors.amber),
                    const SizedBox(width: 3),
                    Text(
                      '${driver.rating} · ${driver.trips} trips',
                      style: TextStyle(
                        color: context.muted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.cardColor2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.border),
                  ),
                  child: Text(
                    driver.plate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          RoundIconButton(
            icon: Icons.chat_bubble_rounded,
            size: 42,
            onTap: () => showSnack(context, 'Chat opens here in the full app.'),
          ),
          const SizedBox(width: 8),
          RoundIconButton(
            icon: Icons.call_rounded,
            size: 42,
            iconColor: Colors.white,
            background: AppColors.green,
            onTap: () => showSnack(context, 'Calling ${driver.name} (demo)…'),
          ),
        ],
      ),
    );
  }
}

class _PinRow extends StatelessWidget {
  const _PinRow({required this.pin});

  final String pin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trip PIN',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              Text(
                'Tell this to your driver',
                style: TextStyle(color: context.muted, fontSize: 12.5),
              ),
            ],
          ),
        ),
        for (var i = 0; i < pin.length; i++)
          Container(
            width: 42,
            height: 48,
            margin: const EdgeInsets.only(left: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.indigo.o(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.indigo.o(0.3)),
            ),
            child: Text(
              pin[i],
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: context.cs.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ================================================================= COMPLETED
class CompletedPanel extends StatefulWidget {
  const CompletedPanel({super.key});

  @override
  State<CompletedPanel> createState() => _CompletedPanelState();
}

class _CompletedPanelState extends State<CompletedPanel> {
  int _rating = 5;
  int _tip = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final trip = s.lastTrip;
    if (trip == null) return const SizedBox.shrink();

    final base = s.baseFareFor(s.selectedRide);
    final discount = s.discountFor(base);
    final driverName = s.driver?.name.split(' ').first ?? 'your driver';

    return PanelCard(
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, v, child) =>
                Transform.scale(scale: v, child: child),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.green.o(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 38,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You've arrived!",
            style: context.tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${trip.km} km with $driverName · ${trip.minutes} min',
            style: TextStyle(color: context.muted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.soft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _line(context, 'Ride fare', money(base)),
                if (discount > 0)
                  _line(
                    context,
                    'Promo ${s.promoCode ?? ''}',
                    '-${money(discount)}',
                    color: AppColors.green,
                  ),
                _line(context, 'Paid with', trip.payment.label),
                Divider(color: context.border, height: 20),
                _line(context, 'Total', money(trip.fare), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'How was your ride with $driverName?',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          StarRating(
            rating: _rating,
            size: 38,
            onChanged: (v) => setState(() => _rating = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Add a tip',
                style: TextStyle(
                  color: context.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              for (final t in const [0, 10, 20, 50])
                GestureDetector(
                  onTap: () => setState(() => _tip = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _tip == t ? AppColors.indigo : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _tip == t ? AppColors.indigo : context.border,
                        width: 1.3,
                      ),
                    ),
                    child: Text(
                      t == 0 ? 'No tip' : money(t),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: _tip == t ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Submit & done',
            onPressed: () {
              showSnack(context, 'Thanks for riding with Raahi!');
              s.submitRating(_rating, _tip.toDouble());
            },
          ),
        ],
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String k,
    String v, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            k,
            style: TextStyle(color: context.muted, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            v,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              fontSize: bold ? 20 : 14.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
