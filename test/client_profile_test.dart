import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/app_routes.dart';
import 'package:loboko/features/profile/client_profile_edit_page.dart';
import 'package:loboko/features/profile/client_profile_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(() {
    MockData.clientProfile = null;
    MockData.clientPreferences.notificationsEnabled = true;
  });

  testWidgets('validates and saves profile details for this session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ClientProfilePage(onBookings: () {}, onFavorites: () {}),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.clientProfileEdit) {
            return MaterialPageRoute<bool>(
              builder: (_) => const ClientProfileEditPage(),
            );
          }
          return null;
        },
      ),
    );
    await tester.tap(find.text('Compléter mon profil'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer les modifications'));
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();
    expect(find.text('Veuillez saisir votre prénom.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Awa');
    await tester.enterText(find.byType(TextFormField).at(1), 'Mbemba');
    await tester.enterText(find.byType(TextFormField).at(2), 'awa@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), '+242123456789');
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller!
          .text,
      'Awa',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      'Mbemba',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer les modifications'));
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();

    expect(MockData.clientProfile?.fullName, 'Awa Mbemba');
    expect(MockData.clientProfile?.email, 'awa@example.com');
    expect(find.text('Awa Mbemba'), findsOneWidget);
    expect(find.text('+242123456789'), findsOneWidget);
  });

  testWidgets('logout asks for confirmation and clears the navigation stack', (
    tester,
  ) async {
    MockData.clientProfile = const MockClientProfile(
      firstName: 'Awa',
      lastName: 'Mbemba',
      email: 'awa@example.com',
      phone: '0612345678',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ClientProfilePage(onBookings: () {}, onFavorites: () {}),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.login) {
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Connexion Client')),
            );
          }
          return null;
        },
      ),
    );
    await tester.ensureVisible(find.text('Se déconnecter'));
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(find.text('Se déconnecter ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Awa Mbemba'), findsOneWidget);

    await tester.ensureVisible(find.text('Se déconnecter'));
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se déconnecter').last);
    await tester.pumpAndSettle();
    expect(find.text('Connexion Client'), findsOneWidget);
    expect(MockData.clientProfile, isNull);
  });

  testWidgets('activity shortcuts open their Client destinations', (
    tester,
  ) async {
    var openedBookings = false;
    var openedFavorites = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ClientProfilePage(
          onBookings: () => openedBookings = true,
          onFavorites: () => openedFavorites = true,
        ),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.clientMessages) {
            return MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(),
                body: const Text('Destination Messages'),
              ),
            );
          }
          if (settings.name == AppRoutes.clientNotifications) {
            return MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(),
                body: const Text('Destination Notifications'),
              ),
            );
          }
          return null;
        },
      ),
    );

    Future<void> tapActivity(String title) async {
      await tester.ensureVisible(find.text(title));
      await tester.tap(
        find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
      );
      await tester.pumpAndSettle();
    }

    await tapActivity('Mes réservations');
    expect(openedBookings, isTrue);
    await tapActivity('Mes favoris');
    expect(openedFavorites, isTrue);
    await tapActivity('Mes messages');
    expect(find.text('Destination Messages'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tapActivity('Mes notifications');
    expect(find.text('Destination Notifications'), findsOneWidget);
  });
}
