import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/app_routes.dart';
import 'package:loboko/features/messaging/client_chat_page.dart';
import 'package:loboko/features/messaging/client_messages_page.dart';
import 'package:loboko/mock/mock_data.dart';

void main() {
  setUp(() {
    MockData.conversations.clear();
    MockData.notifications.clear();
  });

  testWidgets('sends a local message and finds its conversation in the list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const ClientMessagesPage(),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.clientChat, arguments: 'prov_jm'),
              child: const Icon(Icons.chat),
            ),
          ),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.clientChat) {
            return MaterialPageRoute<void>(
              builder: (_) =>
                  ClientChatPage(providerId: settings.arguments as String?),
            );
          }
          return null;
        },
      ),
    );
    expect(find.text('Aucune conversation'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Jean-Marc Matingou'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'Bonjour, avez-vous un créneau ?',
    );
    await tester.tap(find.byTooltip('Envoyer'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour, avez-vous un créneau ?'), findsOneWidget);
    expect(MockData.conversations.single.messages, hasLength(1));

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();
    Navigator.of(
      tester.element(find.byType(ClientMessagesPage)),
    ).push(MaterialPageRoute<void>(builder: (_) => const ClientMessagesPage()));
    await tester.pumpAndSettle();
    expect(find.text('Jean-Marc Matingou'), findsOneWidget);
    expect(find.text('Bonjour, avez-vous un créneau ?'), findsOneWidget);
  });
}
