import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/theme/app_theme.dart';
import 'package:loboko/features/auth/forgot_password_page.dart';
import 'package:loboko/features/auth/login_page.dart';
import 'package:loboko/features/auth/register_page.dart';
import 'package:loboko/features/bookings/client_booking_page.dart';
import 'package:loboko/features/explore/client_explore_page.dart';
import 'package:loboko/features/favorites/client_favorites_page.dart';
import 'package:loboko/features/home/client_home_page.dart';
import 'package:loboko/features/messaging/client_chat_page.dart';
import 'package:loboko/features/messaging/client_messages_page.dart';
import 'package:loboko/features/notifications/client_notifications_page.dart';
import 'package:loboko/features/profile/client_profile_page.dart';
import 'package:loboko/features/providers/client_provider_detail_page.dart';
import 'package:loboko/features/providers/client_providers_page.dart';
import 'package:loboko/shared/constants/app_enums.dart';
import 'package:loboko/shared/widgets/navigation/app_bottom_navigation.dart';

void main() {
  testWidgets('Client navigation labels and icons align on phone sizes', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const sizes = <Size>[Size(320, 568), Size(390, 844)];
    const labels = [
      'Accueil',
      'Explorer',
      'Messages',
      'Réservations',
      'Profil',
    ];
    const icons = [
      Icons.home,
      Icons.explore_outlined,
      Icons.chat_bubble_outline,
      Icons.calendar_today_outlined,
      Icons.person_outline,
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const ClientHomePage()),
      );
      await tester.pumpAndSettle();

      final navigation = find.byType(AppBottomNavigation);
      expect(navigation, findsOneWidget);
      final navigationRect = tester.getRect(navigation);
      final iconCenters = <double>[];

      for (var index = 0; index < labels.length; index++) {
        final label = find.descendant(
          of: navigation,
          matching: find.text(labels[index]),
        );
        final icon = find.descendant(
          of: navigation,
          matching: find.byIcon(icons[index]),
        );
        expect(label, findsOneWidget, reason: 'Libellé à $size');
        expect(icon, findsOneWidget, reason: 'Icône à $size');
        expect(
          tester.getRect(label).left,
          greaterThanOrEqualTo(navigationRect.left),
          reason: 'Libellé hors navigation à $size',
        );
        expect(
          tester.getRect(label).right,
          lessThanOrEqualTo(navigationRect.right),
          reason: 'Libellé hors navigation à $size',
        );
        iconCenters.add(tester.getCenter(icon).dy);
      }

      expect(
        iconCenters.every((center) => (center - iconCenters.first).abs() < 1),
        isTrue,
        reason: 'Les cinq icônes doivent être alignées à $size',
      );
      expect(tester.takeException(), isNull, reason: 'Navigation à $size');
    }
  });

  testWidgets('Client screens fit small and standard phone sizes', (
    tester,
  ) async {
    final screens = <String, Widget Function()>{
      'inscription Client': () =>
          const RegisterPage(selectedProfile: UserProfile.client),
      'inscription Prestataire': () =>
          const RegisterPage(selectedProfile: UserProfile.provider),
      'connexion': () => const LoginPage(selectedProfile: UserProfile.client),
      'récupération du mot de passe': () =>
          const ForgotPasswordPage(selectedProfile: UserProfile.client),
      'accueil': () => const ClientHomePage(),
      'exploration et catégories': () => const ClientExplorePage(),
      'liste de prestataires': () => const ClientProvidersPage(),
      'fiche prestataire': () =>
          const ClientProviderDetailPage(providerId: 'prov_jm'),
      'réservation': () => const ClientBookingPage(providerId: 'prov_jm'),
      'profil': () => ClientProfilePage(onBookings: () {}, onFavorites: () {}),
      'favoris': () => const ClientFavoritesPage(),
      'messages': () => const ClientMessagesPage(),
      'discussion': () => const ClientChatPage(providerId: 'prov_jm'),
      'notifications': () => const ClientNotificationsPage(),
    };
    const sizes = <Size>[Size(320, 568), Size(390, 844)];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final entry in screens.entries) {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: entry.value()),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.key} sur ${size.width}×${size.height}',
        );
      }
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
