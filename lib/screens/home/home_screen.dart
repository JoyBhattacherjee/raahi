import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/geo.dart';
import '../../widgets/city_map.dart';
import '../../widgets/common.dart';
import 'panels.dart';
import 'ride_panels.dart';

/// The map-first home screen. The bottom panel changes with [RidePhase].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Approximate height of the bottom panel for each phase. The map camera uses
  /// this to keep the route visible above the panel.
  static double _panelHeight(RidePhase phase) {
    switch (phase) {
      case RidePhase.idle:
        return 440;
      case RidePhase.choosing:
        return 550;
      case RidePhase.searching:
        return 420;
      case RidePhase.arriving:
      case RidePhase.arrived:
        return 410;
      case RidePhase.onTrip:
        return 410;
      case RidePhase.completed:
        return 600;
    }
  }

  Cam _camera(AppState s, Size size, double inset) {
    final visible = Rect.fromLTRB(
      0,
      110,
      size.width,
      math.max(size.height - inset, 240.0),
    );
    final route = s.mapRoute;

    if (route.length < 2) {
      return Cam(s.pickup.grid, 56, visible.center);
    }

    final b = boundsOf(route);
    const pad = 64.0;
    final bw = math.max(b.width, 1.0);
    final bh = math.max(b.height, 1.0);
    final sx = (visible.width - 2 * pad) / bw;
    final sy = (visible.height - 2 * pad) / bh;
    final scale = math.min(sx, sy).clamp(22.0, 64.0).toDouble();
    return Cam(b.center, scale, visible.center);
  }

  String? _pickupLabel(RidePhase p) {
    switch (p) {
      case RidePhase.idle:
        return 'You are here';
      case RidePhase.choosing:
      case RidePhase.searching:
      case RidePhase.arriving:
      case RidePhase.arrived:
        return 'Pickup';
      case RidePhase.onTrip:
      case RidePhase.completed:
        return null;
    }
  }

  Widget _panelFor(AppState s) {
    switch (s.phase) {
      case RidePhase.idle:
        return const IdlePanel();
      case RidePhase.choosing:
        return const ChoosingPanel();
      case RidePhase.searching:
        return const SearchingPanel();
      case RidePhase.arriving:
      case RidePhase.arrived:
      case RidePhase.onTrip:
        return const RidePanel();
      case RidePhase.completed:
        return const CompletedPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final mq = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        final inset = math.min(_panelHeight(s.phase), size.height * 0.68);
        final cam = _camera(s, size, inset);
        final phase = s.phase;
        final rideActive = phase == RidePhase.arriving ||
            phase == RidePhase.arrived ||
            phase == RidePhase.onTrip;

        return Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<Cam>(
                tween: CamTween(end: cam),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                builder: (context, animatedCam, _) {
                  return CityMap(
                    cam: animatedCam,
                    dark: context.isDark,
                    progress: s.progress,
                    route: s.mapRoute,
                    carOnRoute: rideActive,
                    dimTraveled: phase == RidePhase.onTrip,
                    pickup: s.pickup.grid,
                    destination: s.destination?.grid,
                    pickupLabel: _pickupLabel(phase),
                    destinationLabel: s.destination?.name,
                    showNearby:
                        phase == RidePhase.idle || phase == RidePhase.choosing,
                    pulse: phase == RidePhase.searching,
                  );
                },
              ),
            ),

            // Top bar
            Positioned(
              top: mq.padding.top + 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
                    decoration: BoxDecoration(
                      color: context.cardColor2,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.o(context.isDark ? 0.4 : 0.1),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const RaahiLogo(size: 32),
                        const SizedBox(width: 8),
                        Text(
                          'Raahi',
                          style: context.tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  RoundIconButton(
                    icon: rideActive
                        ? Icons.shield_rounded
                        : Icons.notifications_none_rounded,
                    iconColor: rideActive ? AppColors.green : null,
                    badge: !rideActive && s.notificationsOn,
                    onTap: () => showSnack(
                      context,
                      rideActive
                          ? 'Safety toolkit: share trip, emergency contacts, 24x7 support.'
                          : "You're all caught up!",
                    ),
                  ),
                ],
              ),
            ),

            // Bottom panel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: size.height * 0.82),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.06),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      layoutBuilder: (current, previous) {
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ...previous,
                            if (current != null) current,
                          ],
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<RidePhase>(phase),
                        child: _panelFor(s),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
