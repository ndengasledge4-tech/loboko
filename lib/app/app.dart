import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_routes.dart';
import 'routes/routes_generator.dart';
import 'theme/app_theme.dart';

class LobokoApp extends StatefulWidget {
  const LobokoApp({super.key});

  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static const _themeModePreferenceKey = 'theme_mode';

  static Future<bool> toggleTheme(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    final preferences = await SharedPreferences.getInstance();
    return preferences.setString(_themeModePreferenceKey, mode.name);
  }

  @override
  State<LobokoApp> createState() => _LobokoAppState();
}

class _LobokoAppState extends State<LobokoApp> {
  late final Future<void> _themeInitialization;

  @override
  void initState() {
    super.initState();
    _themeInitialization = _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTheme = preferences.getString(
      LobokoApp._themeModePreferenceKey,
    );
    LobokoApp.themeModeNotifier.value = switch (savedTheme) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _themeInitialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Impossible de charger la préférence de thème.'),
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: LobokoApp.themeModeNotifier,
          builder: (context, currentThemeMode, _) {
            return MaterialApp(
              title: 'LOBOKO',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: currentThemeMode,
              initialRoute: AppRoutes.initial,
              onGenerateRoute: RoutesGenerator.onGenerateRoute,
            );
          },
        );
      },
    );
  }
}
