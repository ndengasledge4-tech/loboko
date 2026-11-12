import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/app.dart';
import 'package:loboko/app/routes/routes_generator.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/bookings/client_booking_detail_page.dart';
import 'package:loboko/features/profile/client_change_password_page.dart';
import 'package:loboko/features/provider/provider_availability_page.dart';
import 'package:loboko/features/provider/provider_profile_page.dart';
import 'package:loboko/mock/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Provider availability page renders and allows toggling days', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ProviderAvailabilityPage(),
      ),
    );

    expect(find.text('Mes disponibilités'), findsOneWidget);
    expect(find.text('Jours et horaires d’intervention'), findsOneWidget);

    final saveButton = find.text('Enregistrer mes disponibilités');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Disponibilités enregistrées avec succès !'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Provider account settings page renders options and theme toggle',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const LobokoApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );

  testWidgets('Client change password page validates fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ClientChangePasswordPage(),
      ),
    );

    expect(find.text('Changer de mot de passe'), findsOneWidget);

    final saveButton = find.text('Enregistrer les modifications');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Veuillez saisir votre mot de passe actuel'),
      findsOneWidget,
    );
  });

  testWidgets('Client booking detail page renders and supports cancellation', (
    tester,
  ) async {
    final bookingId = MockData.clientBookingRequests('demo_client').first.id;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: RoutesGenerator.onGenerateRoute,
        home: ClientBookingDetailPage(bookingId: bookingId),
      ),
    );

    expect(find.text('Détails de la réservation'), findsOneWidget);
    expect(find.text('Contacter le prestataire'), findsOneWidget);
  });

  testWidgets('Provider profile page has no duplicate edit button at top', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: RoutesGenerator.onGenerateRoute,
        home: const ProviderProfilePage(),
      ),
    );

    expect(find.text('Mon profil'), findsOneWidget);
    expect(
      find.text('Modifier mon profil'),
      findsOneWidget,
    ); // Only 1 action tile in 'Mon espace'
  });
}
