import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/app.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/profile/client_profile_page.dart';
import 'package:loboko/features/provider/provider_account_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LobokoApp.themeModeNotifier.value = ThemeMode.light;
  });

  testWidgets('defaults to light theme when no preference is saved', (
    tester,
  ) async {
    await tester.pumpWidget(const LobokoApp());
    await tester.pumpAndSettle();

    expect(_themeMode(tester), ThemeMode.light);
  });

  testWidgets('saves dark theme and restores it after app recreation', (
    tester,
  ) async {
    await tester.pumpWidget(const LobokoApp());
    await tester.pumpAndSettle();

    expect(await LobokoApp.toggleTheme(ThemeMode.dark), isTrue);
    await tester.pumpAndSettle();
    expect(_themeMode(tester), ThemeMode.dark);
    expect(
      (await SharedPreferences.getInstance()).getString('theme_mode'),
      'dark',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const LobokoApp());
    await tester.pumpAndSettle();

    expect(_themeMode(tester), ThemeMode.dark);
  });

  testWidgets('client theme choice is shared with provider settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ClientProfilePage(onBookings: () {}, onFavorites: () {}),
      ),
    );
    await _tapThemeSwitch(tester);

    expect(LobokoApp.themeModeNotifier.value, ThemeMode.dark);
    expect(
      (await SharedPreferences.getInstance()).getString('theme_mode'),
      'dark',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ProviderAccountSettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    final providerSwitch = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Thème sombre'),
    );
    expect(providerSwitch.value, isTrue);
  });

  testWidgets('provider theme choice is shared with client profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ProviderAccountSettingsPage(),
      ),
    );
    await _tapThemeSwitch(tester);

    expect(LobokoApp.themeModeNotifier.value, ThemeMode.dark);
    expect(
      (await SharedPreferences.getInstance()).getString('theme_mode'),
      'dark',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ClientProfilePage(onBookings: () {}, onFavorites: () {}),
      ),
    );
    await tester.pumpAndSettle();

    final clientSwitch = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Thème sombre'),
    );
    expect(clientSwitch.value, isTrue);
  });

  testWidgets('saving light theme replaces a previous dark preference', (
    tester,
  ) async {
    expect(await LobokoApp.toggleTheme(ThemeMode.dark), isTrue);
    expect(await LobokoApp.toggleTheme(ThemeMode.light), isTrue);

    expect(LobokoApp.themeModeNotifier.value, ThemeMode.light);
    expect(
      (await SharedPreferences.getInstance()).getString('theme_mode'),
      'light',
    );
  });
}

ThemeMode? _themeMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;

Future<void> _tapThemeSwitch(WidgetTester tester) async {
  final switchTile = find.widgetWithText(SwitchListTile, 'Thème sombre');
  await tester.ensureVisible(switchTile);
  await tester.tap(switchTile);
  await tester.pumpAndSettle();
}
