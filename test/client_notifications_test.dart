import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/app_routes.dart';
import 'package:loboko/features/notifications/client_notifications_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(() {
    MockData.notifications.clear();
    MockData.resetBookingRequests();
  });

  testWidgets('lists newest first and marks all notifications as read', (
    tester,
  ) async {
    final now = DateTime.now();
    MockData.addNotification(
      type: MockNotificationType.general,
      title: 'Information précédente',
      message: 'Message de démonstration plus ancien.',
      createdAt: now.subtract(const Duration(hours: 2)),
    );
    MockData.addNotification(
      type: MockNotificationType.bookingCreated,
      title: 'Demande enregistrée',
      message: 'Demande de démonstration créée.',
      createdAt: now,
    );

    await tester.pumpWidget(const MaterialApp(home: ClientNotificationsPage()));
    expect(MockData.unreadNotificationCount, 2);
    expect(
      tester.getTopLeft(find.text('Demande enregistrée')).dy,
      lessThan(tester.getTopLeft(find.text('Information précédente')).dy),
    );

    await tester.tap(find.text('Tout marquer comme lu'));
    await tester.pumpAndSettle();
    expect(MockData.unreadNotificationCount, 0);
    expect(find.text('Demande enregistrée'), findsOneWidget);
  });

  testWidgets('opens the reservations list for an existing booking', (
    tester,
  ) async {
    final request = MockData.createBookingRequest(
      clientId: 'demo_client',
      clientName: 'Grace',
      providerId: 'prov_jm',
      providerName: 'Jean-Marc Matingou',
      serviceName: 'Dépannage plomberie sanitaire',
      description: 'Exemple de test.',
      locationType: 'À domicile',
      location: 'Bacongo, Brazzaville',
      desiredDate: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '08:00–12:00',
    );
    MockData.addNotification(
      type: MockNotificationType.bookingCreated,
      title: 'Demande enregistrée',
      message: 'Ouvrir la demande de démonstration.',
      bookingId: request.id,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const ClientNotificationsPage(),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.clientHome) {
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Mes réservations')),
            );
          }
          return null;
        },
      ),
    );

    await tester.tap(find.text('Demande enregistrée'));
    await tester.pumpAndSettle();
    expect(find.text('Mes réservations'), findsOneWidget);
    expect(MockData.unreadNotificationCount, 0);
  });
}
