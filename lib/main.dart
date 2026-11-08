import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/root_gate.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const RaahiApp());
}

class RaahiApp extends StatefulWidget {
  const RaahiApp({super.key});

  @override
  State<RaahiApp> createState() => _RaahiAppState();
}

class _RaahiAppState extends State<RaahiApp> {
  final AppState _state = AppState();
  late final ThemeData _light = AppTheme.light();
  late final ThemeData _dark = AppTheme.dark();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          return MaterialApp(
            title: 'Raahi',
            debugShowCheckedModeBanner: false,
            theme: _light,
            darkTheme: _dark,
            themeMode: _state.themeMode,
            home: const RootGate(),
          );
        },
      ),
    );
  }
}
