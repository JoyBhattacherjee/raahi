import 'package:flutter/material.dart';

import '../../state/app_scope.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length < 2) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final completed = s.history.where((t) => !t.cancelled).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            'Profile',
            style: context.tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Avatar(initials: _initials(s.userName), size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.userName,
                      style: context.tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(s.phone, style: TextStyle(color: context.muted)),
                    const SizedBox(height: 8),
                    const Pill(
                      label: '4.9 rider rating',
                      icon: Icons.star_rounded,
                      color: AppColors.amber,
                      filled: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _StatCard(value: '$completed', label: 'Rides')),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(value: money(s.wallet), label: 'Wallet')),
              const SizedBox(width: 10),
              const Expanded(child: _StatCard(value: '2 yrs', label: 'Member')),
            ],
          ),
          const SizedBox(height: 24),

          _Group(
            title: 'Preferences',
            children: [
              _SwitchRow(
                icon: Icons.dark_mode_rounded,
                title: 'Dark mode',
                subtitle: 'Easier on the eyes at night',
                value: s.themeMode == ThemeMode.dark,
                onChanged: s.setDarkMode,
              ),
              _SwitchRow(
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Ride updates and offers',
                value: s.notificationsOn,
                onChanged: s.setNotifications,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Group(
            title: 'Account',
            children: [
              _NavRow(
                icon: Icons.bookmark_rounded,
                title: 'Saved places',
                onTap: () => showSnack(context, 'Home and Work are saved.'),
              ),
              _NavRow(
                icon: Icons.shield_rounded,
                title: 'Safety centre',
                onTap: () => showSnack(
                  context,
                  'Trusted contacts and trip sharing live here.',
                ),
              ),
              _NavRow(
                icon: Icons.headset_mic_rounded,
                title: 'Help & support',
                onTap: () => showSnack(context, 'Support is online 24x7.'),
              ),
              _NavRow(
                icon: Icons.info_rounded,
                title: 'About Raahi',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Raahi',
                  applicationVersion: '1.0.0',
                  applicationIcon: const RaahiLogo(size: 48),
                  children: const [
                    SizedBox(height: 12),
                    Text(
                      'A portfolio project showcasing a ride-sharing experience built with Flutter. All data is simulated.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GhostButton(
            label: 'Log out',
            icon: Icons.logout_rounded,
            color: AppColors.red,
            onPressed: s.signOut,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: context.cardColor2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: context.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: context.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.indigo.o(0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 20, color: context.cs.primary),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _IconBadge(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  subtitle,
                  style: TextStyle(color: context.muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _IconBadge(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.muted),
          ],
        ),
      ),
    );
  }
}
