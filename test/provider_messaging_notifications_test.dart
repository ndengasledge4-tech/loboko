import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/routes/app_routes.dart';
import 'package:loboko/features/provider/provider_chat_page.dart';
import 'package:loboko/features/provider/provider_messages_page.dart';
import 'package:loboko/features/provider/provider_notifications_page.dart';
import 'package:loboko/features/provider/provider_workspace_page.dart';
import 'package:loboko/mock/mock_data.dart';
import 'package:loboko/shared/widgets/navigation/app_bottom_navigation.dart';

void main() {
  setUp(() {
    MockData.conversations.clear();
    MockData.providerNotifications.clear();
  });

  testWidgets(
    'client message is visible and provider reply shares conversation',
    (tester) async {
      final conversation = MockData.conversationForProvider('prov_jm');
      MockData.addMessageToConversation(
        conversation: conversation,
        text: 'Bonjour, pouvez-vous intervenir ?',
        isFromClient: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderMessagesPage(),
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.providerChat) {
              return MaterialPageRoute<void>(
                builder: (_) => ProviderChatPage(
                  conversationId: settings.arguments as String,
                ),
              );
            }
            return null;
          },
        ),
      );

      expect(find.text('Bonjour, pouvez-vous intervenir ?'), findsOneWidget);
      expect(MockData.providerUnreadMessageCount, 1);
      expect(MockData.providerUnreadNotificationCount, 1);
      await tester.tap(find.text('Bonjour, pouvez-vous intervenir ?'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Oui, je vous réponds ici.',
      );
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(conversation.messages.last.text, 'Oui, je vous réponds ici.');
      expect(conversation.messages.last.isFromClient, isFalse);
      expect(MockData.unreadMessageCount, 1);
    },
  );

  testWidgets('provider can mark notifications read and unread count follows', (
    tester,
  ) async {
    MockData.addProviderNotification(
      type: MockProviderNotificationType.newMessage,
      title: 'Nouveau message reçu',
      message: 'Un client vous a écrit.',
    );
    await tester.pumpWidget(
      const MaterialApp(home: ProviderNotificationsPage()),
    );
    expect(MockData.providerUnreadNotificationCount, 1);
    await tester.tap(find.text('Tout marquer comme lu'));
    await tester.pump();
    expect(MockData.providerUnreadNotificationCount, 0);
  });

  testWidgets('provider workspace keeps five tabs available on phone sizes', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    for (final size in const [Size(320, 568), Size(390, 844)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: ProviderWorkspacePage()));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBottomNavigation),
          matching: find.text('Messages'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull, reason: 'Navigation à $size');
      final messageTab = find.descendant(
        of: find.byType(AppBottomNavigation),
        matching: find.text('Messages'),
      );
      await tester.tap(messageTab);
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.text('Échangez avec vos clients'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Messages à $size');
    }
  });
}
