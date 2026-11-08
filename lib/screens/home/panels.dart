import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_scope.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/sheets.dart';
import 'search_screen.dart';

// ======================================================================= IDLE
class IdlePanel extends StatelessWidget {
  const IdlePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final firstName = s.userName.split(' ').first;

    return PanelCard(
      extraBottom: 84, // room for the floating navigation bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${greeting()},',
                      style: TextStyle(
                        color: context.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      firstName,
                      style: context.tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Avatar(initials: _initials(s.userName), size: 46),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => openDestinationSearch(context),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.soft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: context.cs.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Where to?',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: context.cardColor2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: context.textStrong,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Now',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SavedChip(place: MockData.home)),
              const SizedBox(width: 10),
              Expanded(child: _SavedChip(place: MockData.work)),
            ],
          ),
          const SizedBox(height: 14),
          _PromoBanner(
            onTap: () {
              s.applyPromo('RAAHI50');
              showSnack(context, 'RAAHI50 saved. It will apply at checkout.');
            },
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length < 2) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _SavedChip extends StatelessWidget {
  const _SavedChip({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        AppScope.read(context).setDestination(place);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.border, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.indigo.o(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(place.icon, size: 19, color: context.cs.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  Text(
                    place.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.muted, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: AppColors.sunsetGradient,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -4,
              top: -6,
              child: Icon(
                Icons.local_offer_rounded,
                size: 64,
                color: Colors.white.o(0.2),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '50% off your next 3 rides',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Use code ',
                      style: TextStyle(
                        color: Colors.white.o(0.9),
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.o(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'RAAHI50',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================== CHOOSING
class ChoosingPanel extends StatelessWidget {
  const ChoosingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final dest = s.destination;
    if (dest == null) return const SizedBox.shrink();

    final ride = s.selectedRide;
    final fare = s.currentFare;

    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route summary
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(width: 2, height: 16, color: context.border),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: context.textStrong,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.pickup.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dest.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Pill(
                label: '${s.distanceKm} km · ${s.tripMinutes} min',
                icon: Icons.route_rounded,
                color: context.cs.primary,
                filled: true,
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: s.closeBooking,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: context.soft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: context.textStrong),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ride options
          for (final r in MockData.rideTypes)
            _RideTile(
              ride: r,
              selected: r.id == ride.id,
              base: s.baseFareFor(r),
              fare: s.fareFor(r),
              onTap: () {
                HapticFeedback.selectionClick();
                s.selectRide(r);
              },
            ),
          const SizedBox(height: 4),

          // Payment + promo
          Row(
            children: [
              Expanded(
                child: _MiniButton(
                  icon: s.payment.icon,
                  label: s.payment == PaymentMethod.wallet
                      ? 'Wallet · ${money(s.wallet)}'
                      : s.payment.label,
                  onTap: () => showPaymentSheet(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniButton(
                  icon: Icons.local_offer_rounded,
                  label: s.promoCode ?? 'Add promo',
                  highlight: s.promoCode != null,
                  onTap: () => showPromoSheet(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Book ${ride.name} · ${money(fare)}',
            onPressed: () {
              final error = s.bookRide();
              if (error != null) showSnack(context, error);
            },
          ),
        ],
      ),
    );
  }
}

class _RideTile extends StatelessWidget {
  const _RideTile({
    required this.ride,
    required this.selected,
    required this.base,
    required this.fare,
    required this.onTap,
  });

  final RideType ride;
  final bool selected;
  final double base;
  final double fare;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? ride.color.o(0.09) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? ride.color : context.border,
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: ride.color.o(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(ride.icon, color: ride.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ride.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.person_rounded, size: 13, color: context.muted),
                      Text(
                        '${ride.seats}',
                        style: TextStyle(
                          color: context.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ride.etaMin} min away · ${ride.tagline}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(fare),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (fare < base)
                  Text(
                    money(base),
                    style: TextStyle(
                      color: context.muted,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.green : context.textStrong;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: highlight ? AppColors.green.o(0.1) : context.soft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: context.muted),
          ],
        ),
      ),
    );
  }
}

// ================================================================= SEARCHING
class SearchingPanel extends StatefulWidget {
  const SearchingPanel({super.key});

  @override
  State<SearchingPanel> createState() => _SearchingPanelState();
}

class _SearchingPanelState extends State<SearchingPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final ride = s.selectedRide;

    return PanelCard(
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) => CustomPaint(
                painter: _RadarPainter(_c.value, ride.color),
                child: child,
              ),
              child: Center(
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.indigo.o(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(ride.icon, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Finding your driver',
            style: context.tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Connecting you with the nearest ${ride.name} captain…',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 5,
              backgroundColor: context.soft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '${ride.name} · ${s.distanceKm} km',
                style: TextStyle(
                  color: context.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                money(s.currentFare),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GhostButton(
            label: 'Cancel',
            color: AppColors.red,
            onPressed: s.cancelRide,
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.t, this.color);

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.width / 2;
    for (var i = 0; i < 3; i++) {
      final f = (t + i / 3) % 1.0;
      final r = 31 + (maxR - 31) * f;
      canvas.drawCircle(
        c,
        r,
        Paint()..color = color.o((1 - f) * 0.18),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = color.o((1 - f) * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.t != t || old.color != color;
}
