import 'package:flutter/material.dart';

import '../../state/app_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.icon,
    required this.colorA,
    required this.colorB,
    required this.chipA,
    required this.chipB,
    required this.iconA,
    required this.iconB,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color colorA;
  final Color colorB;
  final String chipA;
  final String chipB;
  final IconData iconA;
  final IconData iconB;
}

const _slides = <_Slide>[
  _Slide(
    title: 'Ride in seconds',
    body:
        'Pick a destination, choose your ride and a nearby driver is on the way before you finish your chai.',
    icon: Icons.directions_car_filled_rounded,
    colorA: Color(0xFF4F46E5),
    colorB: Color(0xFF7C3AED),
    chipA: '3 min away',
    chipB: '4.9 rating',
    iconA: Icons.schedule_rounded,
    iconB: Icons.star_rounded,
  ),
  _Slide(
    title: 'Upfront, honest fares',
    body:
        'See the exact price before you book. No surprises, no hidden charges, and offers on every week.',
    icon: Icons.local_offer_rounded,
    colorA: Color(0xFFF59E0B),
    colorB: Color(0xFFEF4444),
    chipA: 'RAAHI50',
    chipB: '₹118 total',
    iconA: Icons.percent_rounded,
    iconB: Icons.receipt_long_rounded,
  ),
  _Slide(
    title: 'Safe, every kilometre',
    body:
        'Verified drivers, trip PINs, live tracking and one-tap sharing keep you and your family protected.',
    icon: Icons.verified_user_rounded,
    colorA: Color(0xFF10B981),
    colorB: Color(0xFF0EA5E9),
    chipA: 'Trip PIN',
    chipB: 'Live share',
    iconA: Icons.pin_rounded,
    iconB: Icons.share_location_rounded,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _slides.length - 1) {
      AppScope.read(context).finishOnboarding();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
              child: Row(
                children: [
                  const RaahiLogo(size: 38),
                  const SizedBox(width: 10),
                  Text(
                    'Raahi',
                    style: context.tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: isLast
                          ? null
                          : () => AppScope.read(context).finishOnboarding(),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: context.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: active ? 28 : 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.indigo : context.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: isLast ? 'Get started' : 'Next',
                    icon: isLast
                        ? Icons.arrow_forward_rounded
                        : null,
                    onPressed: _next,
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

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _circle(280, slide.colorA.o(0.07)),
                _circle(212, slide.colorA.o(0.12)),
                Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [slide.colorA, slide.colorB],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: slide.colorA.o(0.4),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Icon(slide.icon, size: 68, color: Colors.white),
                ),
                Positioned(
                  top: 34,
                  right: 0,
                  child: _Floating(
                    delay: 0,
                    child: _FloatChip(icon: slide.iconA, label: slide.chipA),
                  ),
                ),
                Positioned(
                  bottom: 38,
                  left: 0,
                  child: _Floating(
                    delay: 0.5,
                    child: _FloatChip(icon: slide.iconB, label: slide.chipB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: context.tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: context.tt.bodyLarge?.copyWith(
              color: context.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _FloatChip extends StatelessWidget {
  const _FloatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardColor2,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(context.isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.indigo),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Gently bobs its child up and down.
class _Floating extends StatefulWidget {
  const _Floating({required this.child, required this.delay});

  final Widget child;
  final double delay;

  @override
  State<_Floating> createState() => _FloatingState();
}

class _FloatingState extends State<_Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    _c.value = widget.delay;
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Transform.translate(offset: Offset(0, -8 + 16 * t), child: child);
      },
      child: widget.child,
    );
  }
}
