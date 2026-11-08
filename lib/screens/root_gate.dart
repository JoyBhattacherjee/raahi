import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/app_state.dart';
import 'auth/login_screen.dart';
import 'auth/onboarding_screen.dart';
import 'auth/splash_screen.dart';
import 'home_shell.dart';

/// Chooses which top-level screen to show based on [AppStage].
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = AppScope.of(context).stage;

    final Widget child;
    switch (stage) {
      case AppStage.splash:
        child = const SplashScreen(key: ValueKey('splash'));
        break;
      case AppStage.onboarding:
        child = const OnboardingScreen(key: ValueKey('onboarding'));
        break;
      case AppStage.login:
        child = const LoginScreen(key: ValueKey('login'));
        break;
      case AppStage.main:
        child = const HomeShell(key: ValueKey('main'));
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }
}
