import 'package:flutter/material.dart';

import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/bookings/client_booking_confirmation_page.dart';
import '../../features/bookings/client_booking_detail_page.dart';
import '../../features/bookings/client_booking_page.dart';
import '../../features/explore/client_explore_page.dart';
import '../../features/favorites/client_favorites_page.dart';
import '../../features/home/client_home_page.dart';
import '../../features/messaging/client_chat_page.dart';
import '../../features/messaging/client_messages_page.dart';
import '../../features/notifications/client_notifications_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/profile/client_change_password_page.dart';
import '../../features/profile/client_profile_edit_page.dart';
import '../../features/profile_selection/profile_selection_page.dart';
import '../../features/provider/provider_account_settings_page.dart';
import '../../features/provider/provider_availability_page.dart';
import '../../features/provider/provider_chat_page.dart';
import '../../features/provider/provider_messages_page.dart';
import '../../features/provider/provider_mission_detail_page.dart';
import '../../features/provider/provider_missions_page.dart';
import '../../features/provider/provider_notifications_page.dart';
import '../../features/provider/provider_profile_edit_page.dart';
import '../../features/provider/provider_profile_page.dart';
import '../../features/provider/provider_request_detail_page.dart';
import '../../features/provider/provider_requests_page.dart';
import '../../features/provider/provider_service_form_page.dart';
import '../../features/provider/provider_services_page.dart';
import '../../features/provider/provider_workspace_page.dart';
import '../../features/providers/client_provider_detail_page.dart';
import '../../features/providers/client_providers_page.dart';
import '../../features/splash/splash_page.dart';
import '../../shared/constants/app_enums.dart';
import 'app_routes.dart';

/// Générateur de routes dynamique de l'application LOBOKO.
abstract final class RoutesGenerator {
  RoutesGenerator._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (!AppRoutes.contains(settings.name)) {
      return null;
    }

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashPage(),
        );
      case AppRoutes.onboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OnboardingPage(),
        );
      case AppRoutes.profileSelection:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfileSelectionPage(),
        );
      case AppRoutes.login:
        final profile =
            settings.arguments as UserProfile? ?? UserProfile.client;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => LoginPage(selectedProfile: profile),
        );
      case AppRoutes.register:
        final profile =
            settings.arguments as UserProfile? ?? UserProfile.client;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => RegisterPage(selectedProfile: profile),
        );
      case AppRoutes.forgotPassword:
        final profile =
            settings.arguments as UserProfile? ?? UserProfile.client;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ForgotPasswordPage(selectedProfile: profile),
        );
      case AppRoutes.clientHome:
        final arguments = settings.arguments;
        final userName = arguments is String
            ? arguments
            : arguments is Map && arguments['userName'] is String
                ? arguments['userName'] as String
                : 'Grace';
        final initialBottomNavIndex =
            arguments is Map && arguments['initialBottomNavIndex'] is int
                ? arguments['initialBottomNavIndex'] as int
                : 0;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClientHomePage(
            userName: userName,
            initialBottomNavIndex: initialBottomNavIndex,
          ),
        );
      case AppRoutes.clientExplore:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClientExplorePage(),
        );
      case AppRoutes.clientProviders:
        final arguments = settings.arguments;
        final params = arguments is Map<String, String>
            ? arguments
            : const <String, String>{};
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClientProvidersPage(
            categoryId: params['categoryId'],
            initialSearchTerm: params['searchTerm'],
          ),
        );
      case AppRoutes.clientProviderDetail:
        final providerId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClientProviderDetailPage(providerId: providerId),
        );
      case AppRoutes.clientBooking:
        final providerId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClientBookingPage(providerId: providerId),
        );
      case AppRoutes.clientBookingConfirmation:
        final bookingId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClientBookingConfirmationPage(bookingId: bookingId),
        );
      case AppRoutes.clientBookingDetail:
        final bookingId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClientBookingDetailPage(bookingId: bookingId),
        );
      case AppRoutes.clientMessages:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClientMessagesPage(),
        );
      case AppRoutes.clientChat:
        final providerId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClientChatPage(providerId: providerId),
        );
      case AppRoutes.clientNotifications:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClientNotificationsPage(),
        );
      case AppRoutes.clientProfileEdit:
        return MaterialPageRoute<bool>(
          settings: settings,
          builder: (_) => const ClientProfileEditPage(),
        );
      case AppRoutes.clientChangePassword:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClientChangePasswordPage(),
        );
      case AppRoutes.clientFavorites:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClientFavoritesPage(),
        );
      case AppRoutes.providerDashboard:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderWorkspacePage(),
        );
      case AppRoutes.providerMessages:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderMessagesPage(),
        );
      case AppRoutes.providerChat:
        final conversationId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProviderChatPage(conversationId: conversationId),
        );
      case AppRoutes.providerNotifications:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderNotificationsPage(),
        );
      case AppRoutes.providerRequests:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderRequestsPage(),
        );
      case AppRoutes.providerRequestDetail:
        final requestId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProviderRequestDetailPage(requestId: requestId),
        );
      case AppRoutes.providerMissions:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderMissionsPage(),
        );
      case AppRoutes.providerMissionDetail:
        final requestId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProviderMissionDetailPage(requestId: requestId),
        );
      case AppRoutes.providerServices:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderServicesPage(),
        );
      case AppRoutes.providerServiceForm:
        final serviceId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute<bool>(
          settings: settings,
          builder: (_) => ProviderServiceFormPage(serviceId: serviceId),
        );
      case AppRoutes.providerProfile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderProfilePage(),
        );
      case AppRoutes.providerProfileEdit:
        return MaterialPageRoute<bool>(
          settings: settings,
          builder: (_) => const ProviderProfileEditPage(),
        );
      case AppRoutes.providerAvailability:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderAvailabilityPage(),
        );
      case AppRoutes.providerAccountSettings:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProviderAccountSettingsPage(),
        );
      default:
        return null;
    }
  }
}
