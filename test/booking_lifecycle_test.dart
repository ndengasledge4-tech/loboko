import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/routes_generator.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/bookings/client_booking_page.dart';
import 'package:loboko/features/bookings/client_booking_detail_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(() {
    MockData.resetBookingRequests();
    MockData.notifications.clear();
    MockData.providerNotifications.clear();
  });

  testWidgets(
    'client booking is shared through provider lifecycle and cancellation',
    (tester) async {
      await _submitClientBooking(tester);
      final request = MockData.clientBookingRequests('demo_client').last;

      final otherProviderRequest = MockData.createBookingRequest(
        clientId: 'other_client',
        clientName: 'Autre client',
        providerId: 'prov_1',
        providerName: 'Grace Mfumu',
        serviceName: 'Demande autre prestataire',
        description: 'Cette demande doit rester privée au prestataire cible.',
        locationType: 'À domicile',
        location: 'Moungali, Brazzaville',
        desiredDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '12:00–16:00',
      );

      // 1. Client creates a booking and it appears in client list.
      expect(
        MockData.clientBookingRequests('demo_client').map((item) => item.id),
        contains(request.id),
      );

      // 2. Provider prov_jm sees this booking request.
      expect(
        MockData.providerBookingRequests('prov_jm').map((item) => item.id),
        contains(request.id),
      );
      expect(request.status, MockBookingStatus.pending);

      // Provider prov_jm does not see request for prov_1.
      expect(
        MockData.providerBookingRequests('prov_jm').map((item) => item.id),
        isNot(contains(otherProviderRequest.id)),
      );

      // Unrelated provider prov_1 cannot accept request for prov_jm.
      expect(
        MockData.acceptBookingRequest(id: request.id, providerId: 'prov_1'),
        isFalse,
      );

      // 3. Client opens booking detail page.
      await tester.pumpWidget(
        _app(ClientBookingDetailPage(key: ValueKey(request.id), bookingId: request.id)),
      );
      await tester.pumpAndSettle();
      expect(find.text(request.serviceName), findsOneWidget);
      expect(find.text('En attente'), findsOneWidget);

      // 4. Provider accepts request in shared data source.
      final accepted = MockData.acceptBookingRequest(
        id: request.id,
        providerId: 'prov_jm',
      );
      expect(accepted, isTrue);
      expect(request.status, MockBookingStatus.accepted);

      // 5. Client checks accepted status.
      await tester.pumpWidget(
        _app(ClientBookingDetailPage(key: ValueKey('${request.id}_acc'), bookingId: request.id)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Acceptée'), findsOneWidget);

      // 6. Provider starts mission in shared data source.
      final started = MockData.startBookingMission(
        id: request.id,
        providerId: 'prov_jm',
      );
      expect(started, isTrue);
      expect(request.status, MockBookingStatus.inProgress);

      // 7. Client checks inProgress status and cancellation disabled.
      await tester.pumpWidget(
        _app(ClientBookingDetailPage(key: ValueKey('${request.id}_inp'), bookingId: request.id)),
      );
      await tester.pumpAndSettle();
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('Annuler la réservation'), findsNothing);

      // 8. Provider completes mission in shared data source.
      final completed = MockData.completeBookingMission(
        id: request.id,
        providerId: 'prov_jm',
      );
      expect(completed, isTrue);
      expect(request.status, MockBookingStatus.completed);

      // 9. Client checks completed status.
      await tester.pumpWidget(
        _app(ClientBookingDetailPage(key: ValueKey('${request.id}_comp'), bookingId: request.id)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Terminée'), findsOneWidget);
      expect(find.text('Annuler la réservation'), findsNothing);

      // 10. Cancellable booking request test.
      final cancellable = MockData.createBookingRequest(
        clientId: 'demo_client',
        clientName: 'Client parcours',
        providerId: 'prov_jm',
        providerName: 'Jean-Marc Matingou',
        serviceName: 'Demande annulable',
        description: 'Une autre demande en attente.',
        locationType: 'À domicile',
        location: 'Bacongo, Brazzaville',
        desiredDate: DateTime.now().add(const Duration(days: 3)),
        timeSlot: '08:00–12:00',
      );
      await tester.pumpWidget(
        _app(ClientBookingDetailPage(key: ValueKey(cancellable.id), bookingId: cancellable.id)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Demande annulable'), findsOneWidget);

      final cancelled = MockData.cancelBookingRequest(
        id: cancellable.id,
        clientId: 'demo_client',
      );
      expect(cancelled, isTrue);

      await tester.pumpWidget(
        _app(ClientBookingDetailPage(key: ValueKey('${cancellable.id}_canc'), bookingId: cancellable.id)),
      );
      await tester.pumpAndSettle();
      expect(cancellable.status, MockBookingStatus.cancelled);
      expect(find.text('Annulée'), findsOneWidget);
    },
  );
}

Future<void> _submitClientBooking(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute: RoutesGenerator.onGenerateRoute,
      home: const ClientBookingPage(providerId: 'prov_jm'),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byType(RadioListTile<String>).first);
  await tester.tap(find.text('Continuer'));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byType(TextFormField).first,
    'Réparation demandée pour le test de bout en bout.',
  );
  await tester.tap(find.text('Continuer'));
  await tester.pumpAndSettle();

  final homeOption = find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString().startsWith('RadioListTile<'),
  );
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
  await tester.tap(find.text('Envoyer la demande'));
  await tester.pumpAndSettle();
  expect(find.text('Votre demande est enregistrée'), findsOneWidget);
}

MaterialApp _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  onGenerateRoute: RoutesGenerator.onGenerateRoute,
  home: home,
);
