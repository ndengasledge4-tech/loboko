import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/app_routes.dart';
import 'package:loboko/app/routes/routes_generator.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/auth/login_page.dart';
import 'package:loboko/features/provider/provider_dashboard_page.dart';
import 'package:loboko/shared/constants/app_enums.dart';

void main() {
  testWidgets('Provider dashboard fits small and standard phones', (
    tester,
  ) async {
    const sizes = [Size(320, 568), Size(390, 844)];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const ProviderDashboardPage()),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull, reason: 'Écran $size');
      expect(find.text('Demandes récentes'), findsOneWidget);
      expect(find.text('Actions rapides'), findsOneWidget);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  test('provider dashboard is registered in the centralized routes', () {
    expect(AppRoutes.contains(AppRoutes.providerDashboard), isTrue);
  });

  testWidgets('centralized provider route opens the dashboard', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: RoutesGenerator.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.providerDashboard),
              child: const Text('Open dashboard'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour, Jean-Marc'), findsOneWidget);
    expect(
      find.textContaining('Aucune demande réelle n’a été transmise'),
      findsOneWidget,
    );
  });

  testWidgets('provider demo login opens its dashboard', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: RoutesGenerator.onGenerateRoute,
        home: const LoginPage(selectedProfile: UserProfile.provider),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'prestataire@example.com');
    await tester.enterText(fields.at(1), 'demo1234');
    await tester.tap(find.text('Se connecter'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour, Jean-Marc'), findsOneWidget);
    expect(find.textContaining('Profil et demandes fictifs'), findsOneWidget);
  });
}
