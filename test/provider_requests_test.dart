import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/routes_generator.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/provider/provider_dashboard_page.dart';
import 'package:loboko/features/provider/provider_request_detail_page.dart';
import 'package:loboko/features/provider/provider_requests_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(() {
    final initialStatuses = {
      'demo_request_001': MockBookingStatus.pending,
      'demo_request_002': MockBookingStatus.accepted,
      'demo_request_003': MockBookingStatus.inProgress,
      'demo_request_004': MockBookingStatus.completed,
      'demo_request_005': MockBookingStatus.completed,
    };
    MockData.resetBookingRequests();
    for (final entry in initialStatuses.entries) {
      MockData.bookingRequestById(entry.key)!.status = entry.value;
    }
  });

  testWidgets('lists shared demonstration requests and filters by status', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(_app(const ProviderRequestsPage()));

    expect(find.textContaining('Données de démonstration'), findsOneWidget);
    expect(find.text('Aline Mpassi'), findsOneWidget);
    expect(find.text('Boris Nsimba'), findsOneWidget);
    expect(find.text('Date souhaitée non précisée'), findsWidgets);

    await _selectFilter(tester, 'En attente (1)');
    expect(find.text('Aline Mpassi'), findsOneWidget);
    expect(find.text('Boris Nsimba'), findsNothing);

    await _selectFilter(tester, 'Acceptées (1)');
    expect(find.text('Boris Nsimba'), findsOneWidget);
    expect(find.text('Aline Mpassi'), findsNothing);

    await _selectFilter(tester, 'En cours (1)');
    expect(find.text('Clarisse Okemba'), findsOneWidget);

    await _selectFilter(tester, 'Terminées (2)');
    expect(find.text('David Makaya'), findsOneWidget);
    expect(find.text('Estelle Bemba'), findsOneWidget);

    await _selectFilter(tester, 'Annulées (0)');
    expect(find.text('Aucune demande annulée'), findsOneWidget);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('opens a request detail with available information', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const ProviderRequestsPage()));
    await tester.tap(find.text('Aline Mpassi'));
    await tester.pumpAndSettle();

    expect(find.text('Détail de la demande'), findsOneWidget);
    expect(find.text('Réparation de fuite'), findsOneWidget);
    expect(find.text('Fuite sous l’évier de la cuisine.'), findsOneWidget);
    expect(find.text('À domicile · Bacongo, Brazzaville'), findsOneWidget);
    expect(find.text('Non précisée'), findsOneWidget);
    expect(find.text('Client fictif'), findsOneWidget);
  });

  testWidgets('acceptance updates shared status and dashboard statistics', (
    tester,
  ) async {
    await _openFirstPendingRequest(tester);
    final acceptButton = find.byType(ElevatedButton);
    await tester.ensureVisible(acceptButton);
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Accepter'));
    await tester.pumpAndSettle();

    final request = MockData.bookingRequestById('demo_request_001');
    expect(request?.status, MockBookingStatus.accepted);
    expect(
      MockData.acceptBookingRequest(
        id: 'demo_request_001',
        providerId: 'prov_jm',
      ),
      isFalse,
    );
    expect(find.text('Acceptée'), findsOneWidget);
    expect(find.text('Accepter'), findsNothing);
    expect(find.text('Refuser'), findsNothing);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();

    final pendingCard = find
        .ancestor(
          of: find.text('Demandes en attente'),
          matching: find.byType(Card),
        )
        .first;
    expect(
      find.descendant(of: pendingCard, matching: find.text('0')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: pendingCard, matching: find.text('1')),
      findsNothing,
    );
  });

  testWidgets('refusal cancels the pending request and cannot repeat', (
    tester,
  ) async {
    await _openFirstPendingRequest(tester);
    final refuseButton = find.byType(OutlinedButton);
    await tester.ensureVisible(refuseButton);
    await tester.tap(refuseButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Refuser'));
    await tester.pumpAndSettle();

    final request = MockData.bookingRequestById('demo_request_001');
    expect(request?.status, MockBookingStatus.cancelled);
    expect(find.text('Annulée'), findsOneWidget);
    expect(find.text('Accepter'), findsNothing);
    expect(find.text('Refuser'), findsNothing);
    expect(
      MockData.refuseBookingRequest(
        id: 'demo_request_001',
        providerId: 'prov_jm',
      ),
      isFalse,
    );
    expect(request?.status, MockBookingStatus.cancelled);
  });

  testWidgets('requests list and detail fit small and standard phones', (
    tester,
  ) async {
    const sizes = [Size(320, 568), Size(390, 844)];
    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(_app(const ProviderRequestsPage()));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: 'Liste sur $size');

      await tester.pumpWidget(
        _app(const ProviderRequestDetailPage(requestId: 'demo_request_001')),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: 'Détail sur $size');
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

MaterialApp _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  onGenerateRoute: RoutesGenerator.onGenerateRoute,
  home: home,
);

Future<void> _openFirstPendingRequest(WidgetTester tester) async {
  await tester.pumpWidget(_app(const ProviderDashboardPage()));
  await tester.tap(find.text('Demandes'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Aline Mpassi'));
  await tester.pumpAndSettle();
}

Future<void> _selectFilter(WidgetTester tester, String label) async {
  final filter = find.text(label);
  final horizontalScrollable = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.right,
  );
  await tester.scrollUntilVisible(
    filter,
    120,
    scrollable: horizontalScrollable.first,
  );
  await tester.ensureVisible(filter);
  await tester.pumpAndSettle();
  await tester.tap(filter);
  await tester.pumpAndSettle();
}
