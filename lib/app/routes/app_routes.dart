import 'route_names.dart';

/// Définition et registre des routes de l'application LOBOKO.
abstract final class AppRoutes {
  AppRoutes._();

  static const String initial = RouteNames.splash;
  static const String splash = RouteNames.splash;
  static const String onboarding = RouteNames.onboarding;
  static const String profileSelection = RouteNames.profileSelection;
  static const String login = RouteNames.login;
  static const String register = RouteNames.register;
  static const String forgotPassword = RouteNames.forgotPassword;
  static const String clientHome = RouteNames.clientHome;
  static const String clientExplore = RouteNames.clientExplore;
  static const String clientProviders = RouteNames.clientProviders;
  static const String clientProviderDetail = RouteNames.clientProviderDetail;
  static const String clientBooking = RouteNames.clientBooking;
  static const String clientBookingConfirmation =
      RouteNames.clientBookingConfirmation;
  static const String clientBookingDetail = RouteNames.clientBookingDetail;
  static const String clientMessages = RouteNames.clientMessages;
  static const String clientChat = RouteNames.clientChat;
  static const String clientNotifications = RouteNames.clientNotifications;
  static const String clientProfileEdit = RouteNames.clientProfileEdit;
  static const String clientChangePassword = RouteNames.clientChangePassword;
  static const String clientFavorites = RouteNames.clientFavorites;
  static const String providerDashboard = RouteNames.providerDashboard;
  static const String providerMessages = RouteNames.providerMessages;
  static const String providerChat = RouteNames.providerChat;
  static const String providerNotifications = RouteNames.providerNotifications;
  static const String providerRequests = RouteNames.providerRequests;
  static const String providerRequestDetail = RouteNames.providerRequestDetail;
  static const String providerMissions = RouteNames.providerMissions;
  static const String providerMissionDetail = RouteNames.providerMissionDetail;
  static const String providerServices = RouteNames.providerServices;
  static const String providerServiceForm = RouteNames.providerServiceForm;
  static const String providerProfile = RouteNames.providerProfile;
  static const String providerProfileEdit = RouteNames.providerProfileEdit;
  static const String providerAvailability = RouteNames.providerAvailability;
  static const String providerAccountSettings =
      RouteNames.providerAccountSettings;

  static const Set<String> registeredRoutes = {
    splash,
    onboarding,
    profileSelection,
    login,
    register,
    forgotPassword,
    clientHome,
    clientExplore,
    clientProviders,
    clientProviderDetail,
    clientBooking,
    clientBookingConfirmation,
    clientBookingDetail,
    clientMessages,
    clientChat,
    clientNotifications,
    clientProfileEdit,
    clientChangePassword,
    clientFavorites,
    providerDashboard,
    providerMessages,
    providerChat,
    providerNotifications,
    providerRequests,
    providerRequestDetail,
    providerMissions,
    providerMissionDetail,
    providerServices,
    providerServiceForm,
    providerProfile,
    providerProfileEdit,
    providerAvailability,
    providerAccountSettings,
  };

  static bool contains(String? routeName) {
    return registeredRoutes.contains(routeName);
  }
}
