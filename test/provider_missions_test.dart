import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/routes_generator.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/provider/provider_dashboard_page.dart';
import 'package:loboko/features/provider/provider_mission_detail_page.dart';
import 'package:loboko/features/provider/provider_missions_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(() {
    const statuses = {
      'demo_request_001': MockBookingStatus.pending,
      'demo_request_002': MockBookingStatus.accepted,
      'demo_request_003': MockBookingStatus.inProgress,
      'demo_request_004': MockBookingStatus.completed,
      'demo_request_005': MockBookingStatus.completed,
    };
    MockData.resetBookingRequests();
    for (final entry in statuses.entries) {
      MockData.bookingRequestById(entry.key)!.status = entry.value;
    }
  });

  testWidgets('shows only accepted and later requests and filters them', (
    tester,
  ) async {
    MockData.refuseBookingRequest(
      id: 'demo_request_001',
      providerId: 'prov_jm',
    );
    await tester.pumpWidget(_app(const ProviderMissionsPage()));
    expect(
      find.text(
        'Données de démonstration : ces missions sont fictives et conservées localement en mémoire.',
      ),
      findsOneWidget,
    );
    expect(find.text('Aline Mpassi'), findsOneWidget);
    expect(find.text('Boris Nsimba'), findsOneWidget);
    await _scrollToText(tester, 'Clarisse Okemba');
    expect(find.text('Clarisse Okemba'), findsOneWidget);
    await _scrollToText(tester, 'David Makaya');
    expect(find.text('David Makaya'), findsOneWidget);
    await _tapFilter(tester, 'À démarrer (1)');
    expect(find.text('Boris Nsimba'), findsOneWidget);
    expect(find.text('Clarisse Okemba'), findsNothing);
    await _tapFilter(tester, 'En cours (1)');
    await _scrollToText(tester, 'Clarisse Okemba');
    expect(find.text('Clarisse Okemba'), findsOneWidget);
    await _tapFilter(tester, 'Terminées (2)');
    await _scrollToText(tester, 'David Makaya');
    expect(find.text('David Makaya'), findsOneWidget);
    await _scrollToText(tester, 'Estelle Bemba');
    expect(find.text('Estelle Bemba'), findsOneWidget);
    await _tapFilter(tester, 'Annulées (1)');
    await _scrollToText(tester, 'Aline Mpassi');
    expect(find.text('Aline Mpassi'), findsOneWidget);
  });

  testWidgets('opens a dynamic mission detail with available information', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const ProviderMissionsPage()));
    await tester.tap(find.text('Boris Nsimba'));
    await tester.pumpAndSettle();
    expect(find.text('Détail de la mission'), findsOneWidget);
    expect(find.text('Installation de robinet'), findsOneWidget);
    expect(find.text('Client fictif'), findsOneWidget);
    expect(find.text('Démarrer la mission'), findsOneWidget);
  });

  testWidgets(
    'starting and completing update shared data and dashboard statistics',
    (tester) async {
      await tester.pumpWidget(_app(const ProviderDashboardPage()));
      await tester.tap(find.text('Missions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Boris Nsimba'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Démarrer la mission'));
      await tester.tap(find.text('Démarrer la mission'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Démarrer'));
      await tester.pumpAndSettle();
      expect(
        MockData.bookingRequestById('demo_request_002')?.status,
        MockBookingStatus.inProgress,
      );
      expect(find.text('Marquer comme terminée'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await _goBack(tester);
      await tester.pumpAndSettle();
      await _goBack(tester);
      await tester.pumpAndSettle();
      expect(find.text('Missions en cours'), findsOneWidget);
      final inProgressCard = find
          .ancestor(
            of: find.text('Missions en cours'),
            matching: find.byType(Card),
          )
          .first;
      expect(
        find.descendant(of: inProgressCard, matching: find.text('2')),
        findsOneWidget,
      );

      await tester.tap(find.text('Missions'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Clarisse Okemba'));
      await tester.tap(find.text('Clarisse Okemba'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Marquer comme terminée'));
      await tester.tap(find.text('Marquer comme terminée'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Terminer'));
      await tester.pumpAndSettle();
      expect(
        MockData.bookingRequestById('demo_request_003')?.status,
        MockBookingStatus.completed,
      );
      expect(find.text('Terminée'), findsOneWidget);
      expect(find.text('Marquer comme terminée'), findsNothing);
      await _goBack(tester);
      await tester.pumpAndSettle();
      await _goBack(tester);
      await tester.pumpAndSettle();
      final completedCard = find
          .ancestor(
            of: find.text('Missions terminées'),
            matching: find.byType(Card),
          )
          .first;
      expect(
        find.descendant(of: completedCard, matching: find.text('3')),
        findsOneWidget,
      );
    },
  );

  test('rejects forbidden lifecycle transitions', () {
    expect(
      MockData.startBookingMission(
        id: 'demo_request_001',
        providerId: 'prov_jm',
      ),
      isFalse,
    );
    expect(
      MockData.completeBookingMission(
        id: 'demo_request_002',
        providerId: 'prov_jm',
      ),
      isFalse,
    );
    expect(
      MockData.startBookingMission(
        id: 'demo_request_004',
        providerId: 'prov_jm',
      ),
      isFalse,
    );
    MockData.refuseBookingRequest(
      id: 'demo_request_001',
      providerId: 'prov_jm',
    );
    expect(
      MockData.startBookingMission(
        id: 'demo_request_001',
        providerId: 'prov_jm',
      ),
      isFalse,
    );
    expect(
      MockData.completeBookingMission(
        id: 'demo_request_003',
        providerId: 'prov_jm',
      ),
      isTrue,
    );
    expect(
      MockData.completeBookingMission(
        id: 'demo_request_003',
        providerId: 'prov_jm',
      ),
      isFalse,
    );
  });

  testWidgets('mission list and detail fit 320x568 and 390x844', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    for (final size in const [Size(320, 568), Size(390, 844)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(_app(const ProviderMissionsPage()));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'Liste à $size');
      await tester.pumpWidget(
        _app(const ProviderMissionDetailPage(requestId: 'demo_request_002')),
      );
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'Détail à $size');
    }
  });
}

MaterialApp _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  onGenerateRoute: RoutesGenerator.onGenerateRoute,
  home: home,
);

Future<void> _tapFilter(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _scrollToText(WidgetTester tester, String label) async {
  final target = find.text(label);
  final scrollable = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
  await tester.scrollUntilVisible(target, 140, scrollable: scrollable.first);
  await tester.pumpAndSettle();
}

Future<void> _goBack(WidgetTester tester) async {
  final back = find.byTooltip('Retour');
  await tester.ensureVisible(back.first);
  await tester.tap(back.first);
  await tester.pumpAndSettle();
}
