import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/app_routes.dart';
import 'package:loboko/features/bookings/client_booking_confirmation_page.dart';
import 'package:loboko/features/bookings/client_booking_page.dart';
import 'package:loboko/features/bookings/client_bookings_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(() {
    MockData.bookingRequests.clear();
    MockData.notifications.clear();
    MockData.providerNotifications.clear();
  });

  testWidgets('submits a pending request to local demo storage', (
    tester,
  ) async {
    String? selectedRequestId;
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/booking-test',
        onGenerateRoute: (settings) {
          if (settings.name == '/booking-test') {
            return MaterialPageRoute<void>(
              builder: (_) => const ClientBookingPage(providerId: 'prov_jm'),
            );
          }
          if (settings.name == AppRoutes.clientBookingConfirmation) {
            return MaterialPageRoute<void>(
              builder: (_) => ClientBookingConfirmationPage(
                bookingId: settings.arguments as String?,
              ),
            );
          }
          if (settings.name == AppRoutes.clientHome) {
            return MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                body: ClientBookingsPage(
                  onRequestSelected: (id) => selectedRequestId = id,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();

    final serviceOption = find.byType(RadioListTile<String>).first;
    await tester.ensureVisible(serviceOption);
    await tester.tap(serviceOption);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Étape 2 sur 5'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Réparer une fuite sous l’évier.',
    );
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Étape 3 sur 5'), findsOneWidget);

    final homeOption = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString().startsWith('RadioListTile<'),
    );
    expect(homeOption, findsOneWidget);
    await tester.tap(homeOption);
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, 'Bacongo');
    await tester.enterText(find.byType(TextFormField).at(1), 'Près du marché');
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choisir une date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choisir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('08:00 – 12:00'));
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Récapitulatif'), findsOneWidget);
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();

    final clientRequests = MockData.clientBookingRequests('demo_client');
    expect(clientRequests, hasLength(1));
    final request = clientRequests.single;
    expect(MockData.notifications, hasLength(1));
    expect(
      MockData.notifications.single.type,
      MockNotificationType.bookingCreated,
    );
    expect(MockData.notifications.single.bookingId, request.id);
    expect(MockData.unreadNotificationCount, 1);
    expect(request.providerId, 'prov_jm');
    expect(request.status, MockBookingStatus.pending);
    expect(request.serviceName, 'Dépannage plomberie sanitaire');
    expect(request.location, contains('Bacongo'));
    expect(find.text('Votre demande est enregistrée'), findsOneWidget);

    await tester.tap(find.text('Retour à l’accueil'));
    await tester.pumpAndSettle();
    expect(find.text('Jean-Marc Matingou'), findsOneWidget);
    expect(
      find.text('En attente de la réponse du prestataire'),
      findsOneWidget,
    );

    await tester.tap(find.text('Acceptées (0)'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune demande acceptée'), findsOneWidget);

    await tester.tap(find.text('En attente (1)'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Voir la demande'));
    await tester.tap(find.text('Voir la demande'));
    await tester.pumpAndSettle();
    expect(selectedRequestId, request.id);
  });
}
