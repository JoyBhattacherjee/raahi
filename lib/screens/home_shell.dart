import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'activity/activity_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'wallet/wallet_screen.dart';

/// Hosts the four main tabs and a floating bottom navigation bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    ActivityScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final showNav = _tab != 0 || state.phase == RidePhase.idle;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _tab,
            children: [
              for (var i = 0; i < _pages.length; i++)
                TickerMode(enabled: i == _tab, child: _pages[i]),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12 + bottomSafe,
            child: IgnorePointer(
              ignoring: !showNav,
              child: AnimatedSlide(
                offset: showNav ? Offset.zero : const Offset(0, 1.8),
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: showNav ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: _FloatingNav(
                    index: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = <_NavItem>[
    _NavItem(Icons.near_me_rounded, 'Ride'),
    _NavItem(Icons.receipt_long_rounded, 'Activity'),
    _NavItem(Icons.account_balance_wallet_rounded, 'Wallet'),
    _NavItem(Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.cardColor2,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: context.border.o(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(context.isDark ? 0.5 : 0.14),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: i == index ? AppColors.brandGradient : null,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _items[i].icon,
                        size: 22,
                        color: i == index ? Colors.white : context.muted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _items[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: i == index ? Colors.white : context.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
