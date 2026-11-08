# Raahi

A polished ride-sharing app built with **Flutter** (Material 3). Book a ride, watch your driver arrive on a live animated map, pay, rate and track your wallet. Companion to [Raahi Admin](../raahi-admin).

## Features
- Onboarding, phone + OTP login (demo accepts any 4 digits, or "Skip & explore").
- Home map drawn with `CustomPainter`: pannable camera, animated nearby cars, route line, searching pulse. **No API keys needed.**
- Full ride flow: pick destination → choose Go / Bike / Auto / Premier → searching → driver arriving → on trip → payment → rating.
- Promo codes (`RAAHI50`, `FIRSTRIDE`, `WEEKEND25`), payment methods, wallet top-up.
- Activity history with trip details, profile, light/dark theme.

## Tech
Flutter 3.19+, Dart 3.3+, `google_fonts`, plain `ChangeNotifier` + `InheritedNotifier` state (no heavy dependencies).

## Run
This repo contains the Dart source only; generate the platform folders first:
```bash
flutter create . --project-name raahi --org app.raahi
flutter pub get
flutter analyze
flutter test
flutter run            # or: flutter run -d chrome
```

## Deploy a web demo
Enable **Settings → Pages → Source: GitHub Actions**; `.github/workflows/deploy-web.yml` builds and publishes the Flutter web app. Add the link to your portfolio.

> Rides, drivers and payments are simulated; there is no backend.
