import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_scope.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/sheets.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _filter = 0; // 0 all, 1 completed, 2 cancelled

  static const _filters = ['All', 'Completed', 'Cancelled'];

  RideType _rideTypeFor(String name) => MockData.rideTypes.firstWhere(
        (r) => r.name == name,
        orElse: () => MockData.rideTypes.first,
      );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final all = s.history;

    final trips = all.where((t) {
      if (_filter == 1) return !t.cancelled;
      if (_filter == 2) return t.cancelled;
      return true;
    }).toList();

    final done = all.where((t) => !t.cancelled).toList();
    final spent = done.fold<double>(0, (sum, t) => sum + t.fare);
    final km = done.fold<double>(0, (sum, t) => sum + t.km);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            'Your rides',
            style: context.tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Everything you have booked with Raahi.',
            style: TextStyle(color: context.muted),
          ),
          const SizedBox(height: 18),

          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.indigo.o(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                _stat('Rides', '${done.length}'),
                _divider(),
                _stat('Spent', money(spent)),
                _divider(),
                _stat('Distance', '${km.toStringAsFixed(0)} km'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filters
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.indigo : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.indigo : context.border,
                        width: 1.3,
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: selected ? Colors.white : context.muted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          if (trips.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 56, color: context.muted),
                  const SizedBox(height: 12),
                  Text(
                    'No rides here yet',
                    style: context.tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your trips will show up as soon as you take one.',
                    style: TextStyle(color: context.muted),
                  ),
                ],
              ),
            )
          else
            for (final t in trips) _TripCard(trip: t, type: _rideTypeFor(t.rideType)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.o(0.8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: Colors.white.o(0.25),
      );
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.type});

  final Trip trip;
  final RideType type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showTripSheet(context, trip),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: type.color.o(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, color: type.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.to,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${dateTime(trip.date)} · ${trip.rideType}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.muted, fontSize: 12.5),
                  ),
                  if (trip.rating != null) ...[
                    const SizedBox(height: 6),
                    StarRating(rating: trip.rating!, size: 15),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (trip.cancelled)
              const Pill(
                label: 'Cancelled',
                color: AppColors.red,
                filled: true,
              )
            else
              Text(
                money(trip.fare),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
