import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/shared/constants/app_enums.dart';
import 'package:loboko/app/routes/routes_generator.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/provider/provider_dashboard_page.dart';
import 'package:loboko/features/provider/provider_profile_edit_page.dart';
import 'package:loboko/features/provider/provider_profile_page.dart';
import 'package:loboko/features/auth/register_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(_resetProfile);

  testWidgets(
    'displays shared professional details and explicit missing data',
    (tester) async {
      await tester.pumpWidget(_app(const ProviderProfilePage()));
      expect(find.text('Jean-Marc Matingou'), findsOneWidget);
      expect(find.text('Plombier'), findsOneWidget);
      expect(find.text('5 ans'), findsOneWidget);
      expect(find.text('Bacongo'), findsOneWidget);
      expect(find.text('À domicile'), findsOneWidget);
      expect(find.text('Non vérifié'), findsOneWidget);
      expect(find.textContaining('Profil de démonstration'), findsOneWidget);
      expect(find.text('Non renseigné'), findsNWidgets(2));
      expect(find.text('Adresse de l’atelier'), findsNothing);
    },
  );

  testWidgets('shows missing workshop address only for workshop service mode', (
    tester,
  ) async {
    MockData.updateProviderDashboardProfile(
      firstName: 'Jean-Marc',
      lastName: 'Matingou',
      phone: '',
      email: null,
      profession: 'Plombier',
      specialty: null,
      yearsOfExperience: 5,
      experienceLabel: null,
      description: null,
      serviceAreas: [],
      interventionMode: MockCatalogInterventionMode.workshop,
      workshopAddress: null,
      avatarIcon: Icons.handyman_outlined,
      isDemo: true,
    );
    await tester.pumpWidget(_app(const ProviderProfilePage()));
    expect(find.text('Adresse de l’atelier'), findsOneWidget);
    expect(find.text('Non renseigné'), findsNWidgets(5));
  });

  testWidgets('validates required profile fields', (tester) async {
    await tester.pumpWidget(_app(const ProviderProfileEditPage()));
    await tester.pumpAndSettle();
    await tester.enterText(_field('Prénom'), '');
    await tester.enterText(_field('Téléphone'), '');
    await tester.ensureVisible(find.text('Enregistrer les modifications'));
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();
    expect(find.text('Le prénom est obligatoire.'), findsOneWidget);
    expect(
      find.text('Veuillez saisir un numéro de téléphone valide.'),
      findsOneWidget,
    );

    await tester.enterText(_field('Prénom'), 'Jean-Marc');
    await tester.enterText(_field('Téléphone'), '06 123 45 67');
    await tester.enterText(
      _field('Adresse e-mail (facultative)'),
      'adresse-invalide',
    );
    await tester.ensureVisible(find.text('Enregistrer les modifications'));
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();
    expect(
      find.text('Veuillez saisir une adresse e-mail valide'),
      findsOneWidget,
    );
  });

  testWidgets(
    'provider registration fills the shared profile without verification',
    (tester) async {
      await tester.pumpWidget(
        _app(const RegisterPage(selectedProfile: UserProfile.provider)),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Okemba');
      await tester.enterText(find.byType(TextFormField).at(1), 'Amina');
      await _tapContinue(tester);
      expect(tester.takeException(), isNull, reason: 'étape coordonnées');

      await tester.enterText(find.byType(TextFormField).at(0), '06 123 45 67');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'amina@example.cg',
      );
      await _tapContinue(tester);
      expect(tester.takeException(), isNull, reason: 'étape professionnelle');

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plomberie').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2 à 5 ans').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Plomberie résidentielle et sanitaire.',
      );
      await _tapContinue(tester);
      expect(tester.takeException(), isNull, reason: 'étape intervention');
      await _tapContinue(tester);
      expect(tester.takeException(), isNull, reason: 'étape récapitulatif');

      await tester.enterText(find.byType(TextFormField).at(0), 'secret123');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      final terms = find.textContaining("J'accepte les conditions");
      await tester.ensureVisible(terms);
      await tester.tap(terms);
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await tester.ensureVisible(find.text('Terminer mon inscription'));
      await tester.tap(find.text('Terminer mon inscription'));
      await tester.pumpAndSettle();

      expect(MockData.providerDashboardProfile.fullName, 'Amina Okemba');
      expect(MockData.providerDashboardProfile.profession, 'Plomberie');
      expect(MockData.providerDashboardProfile.experienceLabel, '2 à 5 ans');
      expect(MockData.providerDashboardProfile.phone, '06 123 45 67');
      expect(MockData.providerDashboardProfile.email, 'amina@example.cg');
      expect(
        MockData.providerDashboardProfile.verificationStatus,
        MockProviderVerificationStatus.unverified,
      );
    },
  );

  testWidgets('requires an atelier address when editing intervention mode', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const ProviderProfileEditPage()));
    await tester.ensureVisible(
      find.byType(DropdownButtonFormField<MockCatalogInterventionMode>),
    );
    await tester.tap(
      find.byType(DropdownButtonFormField<MockCatalogInterventionMode>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('En atelier').last);
    await tester.pumpAndSettle();
    expect(find.text('Adresse de l’atelier'), findsOneWidget);
    await tester.ensureVisible(find.text('Enregistrer les modifications'));
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();
    expect(
      find.text('L’adresse de l’atelier est obligatoire pour ce mode.'),
      findsOneWidget,
    );
  });

  testWidgets('saves edits to shared profile and updates dashboard identity', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const ProviderDashboardPage()));
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Jean-Marc Matingou'), findsOneWidget);
    final editButton = find.text('Modifier mon profil');
    await tester.ensureVisible(editButton);
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    await tester.enterText(_field('Prénom'), 'Amina');
    await tester.enterText(_field('Nom'), 'Okemba');
    await tester.enterText(_field('Téléphone'), '06 123 45 67');
    await tester.enterText(
      _field('Adresse e-mail (facultative)'),
      'amina@example.cg',
    );
    await tester.enterText(_field('Profession'), 'Électricienne');
    await tester.enterText(_field('Années d’expérience ou fourchette'), '8');
    await tester.enterText(_field('Zones d’intervention'), 'Moungali, Bacongo');
    await tester.ensureVisible(find.text('Enregistrer les modifications'));
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();

    expect(MockData.providerDashboardProfile.fullName, 'Amina Okemba');
    expect(MockData.providerDashboardProfile.profession, 'Électricienne');
    expect(MockData.providerDashboardProfile.yearsOfExperience, 8);
    expect(MockData.providerDashboardProfile.serviceAreas, [
      'Moungali',
      'Bacongo',
    ]);
    expect(
      MockData.providerDashboardProfile.verificationStatus,
      MockProviderVerificationStatus.unverified,
    );
    expect(find.text('Amina Okemba'), findsOneWidget);
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour, Amina'), findsOneWidget);
  });

  testWidgets(
    'verification status is preserved and not editable in profile form',
    (tester) async {
      await tester.pumpWidget(_app(const ProviderProfilePage()));
      expect(find.text('Non vérifié'), findsOneWidget);
      final editButton = find.text('Modifier mon profil');
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.text('Vérifié'), findsNothing);
      expect(find.text('En attente de vérification'), findsNothing);
      expect(
        find.byType(DropdownButtonFormField<MockProviderVerificationStatus>),
        findsNothing,
      );
    },
  );

  testWidgets(
    'account shortcuts, service navigation and confirmed logout work',
    (tester) async {
      await tester.pumpWidget(_app(const ProviderProfilePage()));
      await tester.ensureVisible(find.text('Mes services'));
      await tester.tap(find.text('Mes services'));
      await tester.pumpAndSettle();
      expect(find.text('Mes services'), findsOneWidget);
      await _scrollToText(tester, 'Dépannage plomberie sanitaire');
      expect(find.text('Dépannage plomberie sanitaire'), findsOneWidget);
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Mes disponibilités'));
      await tester.tap(find.text('Mes disponibilités'));
      await tester.pumpAndSettle();
      expect(find.text('Mes disponibilités'), findsOneWidget);
      expect(find.text('Jours et horaires d’intervention'), findsOneWidget);
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Paramètres du compte'));
      await tester.tap(find.text('Paramètres du compte'));
      await tester.pumpAndSettle();
      expect(find.text('Paramètres du compte'), findsOneWidget);
      expect(find.text('Modifier le mot de passe'), findsOneWidget);
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Se déconnecter'));
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Quitter l’espace prestataire ?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Se connecter'), findsOneWidget);
    },
  );

  testWidgets('profile and edit form fit 320x568 and 390x844', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    for (final size in const [Size(320, 568), Size(390, 844)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(_app(const ProviderProfilePage()));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'Profil à $size');
      await tester.pumpWidget(_app(const ProviderProfileEditPage()));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'Modification à $size');
    }
  });
}

void _resetProfile() {
  MockData.updateProviderDashboardProfile(
    firstName: 'Jean-Marc',
    lastName: 'Matingou',
    phone: '',
    email: null,
    profession: 'Plombier',
    specialty: 'Plomberie sanitaire & tuyauterie',
    yearsOfExperience: 5,
    experienceLabel: null,
    description:
        'Jean-Marc propose des interventions de plomberie sanitaire et de tuyauterie dans le cadre de cette démonstration.',
    serviceAreas: ['Bacongo'],
    interventionMode: MockCatalogInterventionMode.home,
    workshopAddress: null,
    avatarIcon: Icons.handyman_outlined,
    isDemo: true,
  );
}

Finder _field(String label) {
  const indexes = {
    'Prénom': 0,
    'Nom': 1,
    'Téléphone': 2,
    'Adresse e-mail (facultative)': 3,
    'Profession': 4,
    'Années d’expérience ou fourchette': 5,
    'Présentation professionnelle': 6,
    'Zones d’intervention': 7,
  };
  return find.byType(TextFormField).at(indexes[label]!);
}

Future<void> _scrollToText(WidgetTester tester, String label) async {
  final target = find.text(label);
  final scrollable = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
  await tester.scrollUntilVisible(target, 120, scrollable: scrollable.first);
  await tester.pumpAndSettle();
}

MaterialApp _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  onGenerateRoute: RoutesGenerator.onGenerateRoute,
  home: home,
);

Future<void> _tapContinue(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Continuer'));
  await tester.tap(find.text('Continuer'));
  await tester.pumpAndSettle();
}
