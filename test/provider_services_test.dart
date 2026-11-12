import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/routes_generator.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/provider/provider_dashboard_page.dart';
import 'package:loboko/features/provider/provider_service_form_page.dart';
import 'package:loboko/features/provider/provider_services_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(_resetServices);

  testWidgets('shows the shared demonstration service catalog', (tester) async {
    await tester.pumpWidget(_app(const ProviderServicesPage()));
    expect(find.textContaining('Catalogue de démonstration'), findsOneWidget);
    expect(find.text('Dépannage plomberie sanitaire'), findsOneWidget);
    expect(find.text('Diagnostic de tuyauterie'), findsOneWidget);
    expect(find.text('15000 FCFA'), findsOneWidget);
    expect(find.text('Sur devis'), findsOneWidget);
    expect(find.text('À domicile'), findsOneWidget);
  });

  testWidgets('shows an empty state and can start adding from it', (
    tester,
  ) async {
    MockData.providerCatalogServices.clear();
    await tester.pumpWidget(_app(const ProviderServicesPage()));
    expect(find.text('Aucun service pour le moment'), findsOneWidget);
    await tester.tap(find.text('Ajouter un service'));
    await tester.pumpAndSettle();
    expect(find.text('Informations de la prestation'), findsOneWidget);
  });

  testWidgets('validates required fields and numeric values', (tester) async {
    await tester.pumpWidget(_app(const ProviderServiceFormPage()));
    await tester.ensureVisible(find.text('Ajouter au catalogue'));
    await tester.tap(find.text('Ajouter au catalogue'));
    await tester.pumpAndSettle();
    expect(find.text('Le nom du service est obligatoire.'), findsOneWidget);
    expect(find.text('La description est obligatoire.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom du service'),
      'Service test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Description test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Prix indicatif en FCFA (facultatif)'),
      '-2',
    );
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Durée estimée en minutes (facultatif)',
      ),
      '1.5',
    );
    await tester.ensureVisible(find.text('Ajouter au catalogue'));
    await tester.tap(find.text('Ajouter au catalogue'));
    await tester.pumpAndSettle();
    expect(find.text('Saisissez un montant supérieur à zéro.'), findsOneWidget);
    expect(
      find.text('Saisissez une durée entière supérieure à zéro.'),
      findsOneWidget,
    );
    expect(MockData.providerCatalogServices, hasLength(2));
  });

  testWidgets(
    'adds a service with a unique id and retains it in shared memory',
    (tester) async {
      await tester.pumpWidget(_app(const ProviderServicesPage()));
      await tester.tap(find.text('Ajouter un service'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nom du service'),
        'Pose de lavabo',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Installation à domicile',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Prix indicatif en FCFA (facultatif)',
        ),
        '12500',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Durée estimée en minutes (facultatif)',
        ),
        '45',
      );
      await tester.ensureVisible(find.text('Ajouter au catalogue'));
      await tester.tap(find.text('Ajouter au catalogue'));
      await tester.pumpAndSettle();

      final added = MockData.providerCatalogServices.singleWhere(
        (service) => service.name == 'Pose de lavabo',
      );
      expect(added.id, isNotEmpty);
      expect(added.price, 12500);
      expect(added.estimatedDurationMinutes, 45);
      await _scrollToService(tester, 'Pose de lavabo');
      expect(find.text('Pose de lavabo'), findsOneWidget);
      await tester.pumpWidget(_app(const ProviderServicesPage()));
      await _scrollToService(tester, 'Pose de lavabo');
      expect(find.text('Pose de lavabo'), findsOneWidget);
    },
  );

  testWidgets('edits and toggles an existing service', (tester) async {
    await tester.pumpWidget(_app(const ProviderServicesPage()));
    await tester.tap(find.byTooltip('Actions sur le service').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom du service'),
      'Plomberie rénovée',
    );
    await tester.ensureVisible(find.text('Enregistrer les modifications'));
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();
    expect(find.text('Plomberie rénovée'), findsOneWidget);
    expect(
      MockData.providerCatalogServiceById('provider_service_demo_001')?.name,
      'Plomberie rénovée',
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(
      MockData.providerCatalogServiceById(
        'provider_service_demo_001',
      )?.isActive,
      isFalse,
    );
    expect(find.text('Service inactif'), findsOneWidget);
  });

  testWidgets('deletes only after confirmation', (tester) async {
    await tester.pumpWidget(_app(const ProviderServicesPage()));
    await tester.tap(find.byTooltip('Actions sur le service').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(MockData.providerCatalogServices, hasLength(2));
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();
    expect(MockData.providerCatalogServices, hasLength(1));
    expect(
      MockData.providerCatalogServiceById('provider_service_demo_001'),
      isNull,
    );
  });

  testWidgets('service catalog opens from provider profile', (tester) async {
    await tester.pumpWidget(_app(const ProviderDashboardPage()));
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mes services'));
    await tester.tap(find.text('Mes services'));
    await tester.pumpAndSettle();
    expect(find.text('Mes services'), findsOneWidget);
    expect(find.text('Dépannage plomberie sanitaire'), findsOneWidget);
  });

  testWidgets('catalog and form fit 320x568 and 390x844', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    for (final size in const [Size(320, 568), Size(390, 844)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(_app(const ProviderServicesPage()));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'Catalogue à $size');
      await tester.pumpWidget(_app(const ProviderServiceFormPage()));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'Formulaire à $size');
    }
  });
}

void _resetServices() {
  MockData.providerCatalogServices
    ..clear()
    ..addAll([
      MockProviderCatalogService(
        id: 'provider_service_demo_001',
        name: 'Dépannage plomberie sanitaire',
        description:
            'Recherche et réparation de fuites, robinetterie et sanitaires.',
        price: 15000,
        pricingType: MockCatalogPricingType.fixed,
        interventionMode: MockCatalogInterventionMode.home,
        estimatedDurationMinutes: 60,
      ),
      MockProviderCatalogService(
        id: 'provider_service_demo_002',
        name: 'Diagnostic de tuyauterie',
        description:
            'Évaluation de l’installation avant proposition d’intervention.',
        pricingType: MockCatalogPricingType.quote,
        interventionMode: MockCatalogInterventionMode.both,
      ),
    ]);
}

MaterialApp _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  onGenerateRoute: RoutesGenerator.onGenerateRoute,
  home: home,
);

Future<void> _scrollToService(WidgetTester tester, String name) async {
  final target = find.text(name);
  final scrollable = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
  await tester.scrollUntilVisible(target, 120, scrollable: scrollable.first);
  await tester.pumpAndSettle();
}
