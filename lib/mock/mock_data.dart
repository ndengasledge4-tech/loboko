import 'package:flutter/material.dart';

/// Modèle de catégorie pour la démonstration localisée à Brazzaville.
class MockCategory {
  const MockCategory({
    required this.id,
    required this.title,
    required this.icon,
  });

  final String id;
  final String title;
  final IconData icon;
}

/// Modèle de prestataire pour la démonstration localisée à Brazzaville.
class MockProvider {
  const MockProvider({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.categoryId,
    this.yearsOfExperience = 5,
    this.isVerified = false,
    this.about = '',
    this.serviceAreas = const [],
    this.services = const [],
    this.reviews = const [],
    this.offersHomeVisit = true,
    this.workshopAddress,
  });

  final String id;
  final String name;
  final String specialty;
  final String location;
  final double rating;
  final int reviewCount;
  final double price;
  final String categoryId;
  final int yearsOfExperience;
  final bool isVerified;
  final String about;
  final List<String> serviceAreas;
  final List<MockProviderService> services;
  final List<MockProviderReview> reviews;
  final bool offersHomeVisit;
  final String? workshopAddress;
}

/// Service proposé dans la fiche de démonstration d'un prestataire.
class MockProviderService {
  const MockProviderService({required this.name, this.price});

  final String name;
  final double? price;
}

/// Avis fictif utilisé uniquement pour présenter l'interface de démonstration.
class MockProviderReview {
  const MockProviderReview({
    required this.author,
    required this.comment,
    required this.rating,
  });

  final String author;
  final String comment;
  final double rating;
}

/// Modèle de prestation/service de démonstration.
class MockServiceItem {
  const MockServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryName,
    required this.categoryId,
    required this.startingPrice,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final String categoryName;
  final String categoryId;
  final double startingPrice;
  final IconData icon;
}

enum MockCatalogPricingType { fixed, quote }

enum MockCatalogInterventionMode { home, workshop, both }

/// Prestation du catalogue prestataire de démonstration, conservée en mémoire.
class MockProviderCatalogService {
  MockProviderCatalogService({
    required this.id,
    required this.name,
    required this.description,
    required this.pricingType,
    required this.interventionMode,
    this.price,
    this.estimatedDurationMinutes,
    this.isActive = true,
  });

  final String id;
  String name;
  String description;
  double? price;
  MockCatalogPricingType pricingType;
  MockCatalogInterventionMode interventionMode;
  int? estimatedDurationMinutes;
  bool isActive;
}

class MockDayAvailability {
  MockDayAvailability({
    required this.dayName,
    this.isOpen = true,
    this.startHour = 8,
    this.startMinute = 0,
    this.endHour = 18,
    this.endMinute = 0,
  });

  final String dayName;
  bool isOpen;
  int startHour;
  int startMinute;
  int endHour;
  int endMinute;

  String get startTimeFormatted =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endTimeFormatted =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
}

enum MockBookingStatus { pending, accepted, inProgress, completed, cancelled }

extension MockBookingStatusLabel on MockBookingStatus {
  String get label => switch (this) {
    MockBookingStatus.pending => 'En attente',
    MockBookingStatus.accepted => 'Acceptée',
    MockBookingStatus.inProgress => 'En cours',
    MockBookingStatus.completed => 'Terminée',
    MockBookingStatus.cancelled => 'Annulée',
  };
}

/// Réservation/demande canonique, partagée par les espaces Client et Prestataire.
class MockBookingRequest {
  MockBookingRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.providerId,
    required this.providerName,
    required this.serviceName,
    required this.description,
    required this.locationType,
    required this.location,
    this.desiredDate,
    this.timeSlot,
    required this.status,
    required this.createdAt,
    this.estimatedPrice,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String providerId;
  final String providerName;
  final String serviceName;
  final String description;
  final String locationType;
  final String location;
  final DateTime? desiredDate;
  final String? timeSlot;
  MockBookingStatus status;
  final DateTime createdAt;
  final double? estimatedPrice;

  String get statusLabel => status.label;
  String get personName => providerName;
  DateTime get date => desiredDate ?? createdAt;
  String get neighborhood => location.split(',').first.trim();
  DateTime get requestedAt => createdAt;
  double? get price => estimatedPrice;
}

/// Profil de prestataire fictif affiché sur le tableau de bord de démonstration.
class MockProviderDashboardProfile {
  MockProviderDashboardProfile({
    required this.providerId,
    required this.firstName,
    this.lastName = '',
    required this.profession,
    this.phone,
    this.email,
    this.specialty,
    this.yearsOfExperience,
    this.experienceLabel,
    this.description,
    List<String> serviceAreas = const [],
    this.interventionMode = MockCatalogInterventionMode.home,
    this.workshopAddress,
    this.avatarIcon,
    this.verificationStatus = MockProviderVerificationStatus.unverified,
    this.isDemo = true,
  }) : serviceAreas = List<String>.of(serviceAreas);

  final String providerId;
  String firstName;
  String lastName;
  String? phone;
  String? email;
  String profession;
  String? specialty;
  int? yearsOfExperience;
  String? experienceLabel;
  String? description;
  List<String> serviceAreas;
  MockCatalogInterventionMode interventionMode;
  String? workshopAddress;
  IconData? avatarIcon;
  MockProviderVerificationStatus verificationStatus;
  bool isDemo;

  String get fullName => '$firstName $lastName'.trim();
}

enum MockProviderVerificationStatus { unverified, pending, verified }

/// Message local de démonstration (aucune transmission à un prestataire).
class MockChatMessage {
  MockChatMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.isFromClient,
  });

  final String id;
  final String text;
  final DateTime sentAt;
  final bool isFromClient;
}

/// Conversation créée par le client dans le stockage en mémoire.
class MockConversation {
  MockConversation({
    required this.id,
    required this.providerId,
    required this.createdAt,
    this.clientId = 'demo_client',
  });

  final String id;
  final String providerId;
  final String clientId;
  final DateTime createdAt;
  final List<MockChatMessage> messages = [];
  int unreadCount = 0;
  int providerUnreadCount = 0;

  DateTime get updatedAt => messages.isEmpty ? createdAt : messages.last.sentAt;
  String get lastMessage =>
      messages.isEmpty ? 'Aucun message pour le moment' : messages.last.text;
}

enum MockProviderNotificationType {
  newRequest,
  requestAccepted,
  requestDeclined,
  newMission,
  newMessage,
  missionCompleted,
}

/// Notification dédiée à l'espace prestataire, conservée en mémoire.
class MockProviderNotification {
  MockProviderNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.bookingId,
    this.conversationId,
    this.isRead = false,
  });

  final String id;
  final MockProviderNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final String? bookingId;
  final String? conversationId;
  bool isRead;
}

enum MockNotificationType {
  bookingCreated,
  bookingAccepted,
  bookingDeclined,
  interventionInProgress,
  interventionCompleted,
  newMessage,
  general,
}

/// Notification de démonstration conservée en mémoire pendant la session.
class MockNotification {
  MockNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.bookingId,
    this.providerId,
    this.isRead = false,
  });

  final String id;
  final MockNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final String? bookingId;
  final String? providerId;
  bool isRead;
}

/// Profil Client saisi dans la démonstration, sans compte authentifié.
class MockClientProfile {
  const MockClientProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.avatarIcon,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final IconData? avatarIcon;

  String get fullName => '$firstName $lastName'.trim();
}

/// Préférences Client locales et temporaires.
class MockClientPreferences {
  bool notificationsEnabled = true;
}

/// Source centralisée de données fictives locales de démonstration.
abstract final class MockData {
  MockData._();

  /// Source unique en mémoire des demandes et réservations de démonstration.
  static final List<MockBookingRequest> bookingRequests =
      _createInitialBookingRequests();
  static int _bookingSequence = 0;

  /// Compte et demandes fictifs du tableau de bord prestataire.
  static final MockProviderDashboardProfile
  providerDashboardProfile = MockProviderDashboardProfile(
    providerId: 'prov_jm',
    firstName: 'Jean-Marc',
    lastName: 'Matingou',
    profession: 'Plombier',
    specialty: 'Plomberie sanitaire & tuyauterie',
    yearsOfExperience: 5,
    description:
        'Jean-Marc propose des interventions de plomberie sanitaire et de tuyauterie dans le cadre de cette démonstration.',
    serviceAreas: ['Bacongo'],
    interventionMode: MockCatalogInterventionMode.home,
    avatarIcon: Icons.handyman_outlined,
  );

  /// Met à jour le profil prestataire partagé sans modifier son statut administratif.
  static void updateProviderDashboardProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String? email,
    required String profession,
    required String? specialty,
    required int? yearsOfExperience,
    required String? experienceLabel,
    required String? description,
    required List<String> serviceAreas,
    required MockCatalogInterventionMode interventionMode,
    required String? workshopAddress,
    IconData? avatarIcon,
    bool? isDemo,
  }) {
    providerDashboardProfile
      ..firstName = firstName
      ..lastName = lastName
      ..phone = phone
      ..email = email
      ..profession = profession
      ..specialty = specialty
      ..yearsOfExperience = yearsOfExperience
      ..experienceLabel = experienceLabel
      ..description = description
      ..serviceAreas = List<String>.of(serviceAreas)
      ..interventionMode = interventionMode
      ..workshopAddress = workshopAddress
      ..avatarIcon = avatarIcon
      ..isDemo = isDemo ?? providerDashboardProfile.isDemo;
  }

  /// Catalogue du prestataire fictif, partagé pendant la session de démonstration.
  static final List<MockProviderCatalogService> providerCatalogServices = [
    MockProviderCatalogService(
      id: 'provider_service_demo_001',
      name: 'Dépannage plomberie sanitaire',
      description:
          'Recherche et réparation de fuites, robinetterie et sanitaires.',
      price: 15000,
      pricingType: MockCatalogPricingType.fixed,
      interventionMode: MockCatalogInterventionMode.home,
      estimatedDurationMinutes: 60,
    ),
    MockProviderCatalogService(
      id: 'provider_service_demo_002',
      name: 'Diagnostic de tuyauterie',
      description:
          'Évaluation de l’installation avant proposition d’intervention.',
      pricingType: MockCatalogPricingType.quote,
      interventionMode: MockCatalogInterventionMode.both,
    ),
  ];

  static int _providerCatalogServiceSequence = 0;

  static MockProviderCatalogService? providerCatalogServiceById(String id) {
    for (final service in providerCatalogServices) {
      if (service.id == id) return service;
    }
    return null;
  }

  static MockProviderCatalogService addProviderCatalogService({
    required String name,
    required String description,
    required MockCatalogPricingType pricingType,
    required MockCatalogInterventionMode interventionMode,
    double? price,
    int? estimatedDurationMinutes,
  }) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final service = MockProviderCatalogService(
      id: 'provider_service_${now}_${_providerCatalogServiceSequence++}',
      name: name,
      description: description,
      price: price,
      pricingType: pricingType,
      interventionMode: interventionMode,
      estimatedDurationMinutes: estimatedDurationMinutes,
    );
    providerCatalogServices.add(service);
    return service;
  }

  static bool updateProviderCatalogService({
    required String id,
    required String name,
    required String description,
    required MockCatalogPricingType pricingType,
    required MockCatalogInterventionMode interventionMode,
    double? price,
    int? estimatedDurationMinutes,
  }) {
    final service = providerCatalogServiceById(id);
    if (service == null) return false;
    service
      ..name = name
      ..description = description
      ..price = price
      ..pricingType = pricingType
      ..interventionMode = interventionMode
      ..estimatedDurationMinutes = estimatedDurationMinutes;
    return true;
  }

  static bool setProviderCatalogServiceActive({
    required String id,
    required bool isActive,
  }) {
    final service = providerCatalogServiceById(id);
    if (service == null) return false;
    service.isActive = isActive;
    return true;
  }

  static bool removeProviderCatalogService(String id) {
    final service = providerCatalogServiceById(id);
    return service != null && providerCatalogServices.remove(service);
  }

  static List<MockBookingRequest> _createInitialBookingRequests() {
    final now = DateTime.now();
    MockBookingRequest request({
      required String id,
      required String clientName,
      String? clientId,
      required String providerId,
      required String providerName,
      required String serviceName,
      required String description,
      required String neighborhood,
      required DateTime createdAt,
      required MockBookingStatus status,
      DateTime? desiredDate,
      String? timeSlot,
      double? estimatedPrice,
    }) => MockBookingRequest(
      id: id,
      clientId: clientId ?? 'demo_$id',
      clientName: clientName,
      providerId: providerId,
      providerName: providerName,
      serviceName: serviceName,
      description: description,
      locationType: 'À domicile',
      location: '$neighborhood, Brazzaville',
      desiredDate: desiredDate,
      timeSlot: timeSlot,
      status: status,
      createdAt: createdAt,
      estimatedPrice: estimatedPrice,
    );

    return [
      request(
        id: 'demo_request_001',
        clientName: 'Aline Mpassi',
        providerId: 'prov_jm',
        providerName: providerDashboardProfile.fullName,
        serviceName: 'Réparation de fuite',
        description: 'Fuite sous l’évier de la cuisine.',
        neighborhood: 'Bacongo',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: MockBookingStatus.pending,
      ),
      request(
        id: 'demo_request_002',
        clientName: 'Boris Nsimba',
        providerId: 'prov_jm',
        providerName: providerDashboardProfile.fullName,
        serviceName: 'Installation de robinet',
        description: 'Remplacement d’un robinet de salle de bain.',
        neighborhood: 'Moungali',
        createdAt: now.subtract(const Duration(days: 1)),
        status: MockBookingStatus.accepted,
      ),
      request(
        id: 'demo_request_003',
        clientName: 'Clarisse Okemba',
        providerId: 'prov_jm',
        providerName: providerDashboardProfile.fullName,
        serviceName: 'Débouchage de canalisation',
        description: 'Évacuation lente dans la cuisine.',
        neighborhood: 'Poto-Poto',
        createdAt: now.subtract(const Duration(days: 2)),
        status: MockBookingStatus.inProgress,
      ),
      request(
        id: 'demo_request_004',
        clientName: 'David Makaya',
        providerId: 'prov_jm',
        providerName: providerDashboardProfile.fullName,
        serviceName: 'Contrôle de plomberie',
        description: 'Vérification générale de la tuyauterie.',
        neighborhood: 'Ouenzé',
        createdAt: now.subtract(const Duration(days: 4)),
        status: MockBookingStatus.completed,
      ),
      request(
        id: 'demo_request_005',
        clientName: 'Estelle Bemba',
        providerId: 'prov_jm',
        providerName: providerDashboardProfile.fullName,
        serviceName: 'Réparation de chasse d’eau',
        description: 'La chasse d’eau du logement ne se remplit plus.',
        neighborhood: 'Bacongo',
        createdAt: now.subtract(const Duration(days: 6)),
        status: MockBookingStatus.completed,
      ),
      request(
        id: 'res_1',
        clientId: 'demo_client',
        clientName: 'Grace',
        providerId: 'prov_1',
        providerName: 'Grace Mfumu',
        serviceName: 'Dépannage plomberie sanitaire',
        description: 'Demande de démonstration existante.',
        neighborhood: 'Bacongo',
        createdAt: now.subtract(const Duration(days: 1)),
        desiredDate: now.add(const Duration(days: 2, hours: 3)),
        timeSlot: '08:00–12:00',
        status: MockBookingStatus.accepted,
        estimatedPrice: 15000,
      ),
      request(
        id: 'res_2',
        clientId: 'demo_client',
        clientName: 'Grace',
        providerId: 'prov_2',
        providerName: 'Martial Nkoulou',
        serviceName: 'Installation climatiseur split',
        description: 'Demande de démonstration existante.',
        neighborhood: 'Poto-Poto',
        createdAt: now.subtract(const Duration(days: 1)),
        desiredDate: now.add(const Duration(days: 5, hours: 1)),
        timeSlot: '08:00–12:00',
        status: MockBookingStatus.pending,
        estimatedPrice: 25000,
      ),
      request(
        id: 'res_3',
        clientId: 'demo_client',
        clientName: 'Grace',
        providerId: 'prov_3',
        providerName: 'Archange Bantsimba',
        serviceName: 'Entretien jardin & espace vert',
        description: 'Demande de démonstration existante.',
        neighborhood: 'Moungali',
        createdAt: now.subtract(const Duration(days: 3)),
        desiredDate: now.subtract(const Duration(days: 3)),
        timeSlot: '08:00–12:00',
        status: MockBookingStatus.completed,
        estimatedPrice: 12000,
      ),
    ];
  }

  static void resetBookingRequests() {
    bookingRequests
      ..clear()
      ..addAll(_createInitialBookingRequests());
    _bookingSequence = 0;
  }

  static MockBookingRequest? bookingRequestById(String id) {
    for (final request in bookingRequests) {
      if (request.id == id) return request;
    }
    return null;
  }

  static List<MockBookingRequest> clientBookingRequests(String clientId) =>
      bookingRequests.where((request) => request.clientId == clientId).toList();

  static List<MockBookingRequest> providerBookingRequests(String providerId) =>
      bookingRequests
          .where((request) => request.providerId == providerId)
          .toList();

  static MockBookingRequest createBookingRequest({
    required String clientId,
    required String clientName,
    required String providerId,
    required String providerName,
    required String serviceName,
    required String description,
    required String locationType,
    required String location,
    required DateTime desiredDate,
    required String timeSlot,
    double? estimatedPrice,
  }) {
    final timestamp = DateTime.now();
    final request = MockBookingRequest(
      id: 'booking_${timestamp.microsecondsSinceEpoch}_${_bookingSequence++}',
      clientId: clientId,
      clientName: clientName,
      providerId: providerId,
      providerName: providerName,
      serviceName: serviceName,
      description: description,
      locationType: locationType,
      location: location,
      desiredDate: desiredDate,
      timeSlot: timeSlot,
      status: MockBookingStatus.pending,
      createdAt: timestamp,
      estimatedPrice: estimatedPrice,
    );
    bookingRequests.add(request);
    return request;
  }

  static bool acceptBookingRequest({
    required String id,
    required String providerId,
  }) => _transitionBookingRequest(
    id: id,
    target: MockBookingStatus.accepted,
    providerId: providerId,
  );

  static bool refuseBookingRequest({
    required String id,
    required String providerId,
  }) => _transitionBookingRequest(
    id: id,
    target: MockBookingStatus.cancelled,
    providerId: providerId,
  );

  static bool cancelBookingRequest({
    required String id,
    required String clientId,
  }) => _transitionBookingRequest(
    id: id,
    target: MockBookingStatus.cancelled,
    clientId: clientId,
  );

  static bool startBookingMission({
    required String id,
    required String providerId,
  }) => _transitionBookingRequest(
    id: id,
    target: MockBookingStatus.inProgress,
    providerId: providerId,
  );

  static bool completeBookingMission({
    required String id,
    required String providerId,
  }) => _transitionBookingRequest(
    id: id,
    target: MockBookingStatus.completed,
    providerId: providerId,
  );

  static bool _transitionBookingRequest({
    required String id,
    required MockBookingStatus target,
    String? providerId,
    String? clientId,
  }) {
    final request = bookingRequestById(id);
    if (request == null ||
        (providerId != null && request.providerId != providerId) ||
        (clientId != null && request.clientId != clientId) ||
        !_canTransitionBookingStatus(request.status, target)) {
      return false;
    }
    request.status = target;
    final providerNotification = switch (target) {
      MockBookingStatus.accepted =>
        MockProviderNotificationType.requestAccepted,
      MockBookingStatus.cancelled =>
        MockProviderNotificationType.requestDeclined,
      MockBookingStatus.inProgress => MockProviderNotificationType.newMission,
      MockBookingStatus.completed =>
        MockProviderNotificationType.missionCompleted,
      MockBookingStatus.pending => null,
    };
    if (providerNotification != null) {
      addProviderNotification(
        type: providerNotification,
        title: switch (target) {
          MockBookingStatus.accepted => 'Demande acceptée',
          MockBookingStatus.cancelled => 'Demande annulée',
          MockBookingStatus.inProgress => 'Mission démarrée',
          MockBookingStatus.completed => 'Mission terminée',
          MockBookingStatus.pending => 'Mise à jour',
        },
        message: 'La demande est maintenant « ${target.label} ».',
        bookingId: request.id,
      );
    }
    final clientNotification = switch (target) {
      MockBookingStatus.accepted => MockNotificationType.bookingAccepted,
      MockBookingStatus.cancelled => MockNotificationType.bookingDeclined,
      MockBookingStatus.inProgress =>
        MockNotificationType.interventionInProgress,
      MockBookingStatus.completed => MockNotificationType.interventionCompleted,
      MockBookingStatus.pending => null,
    };
    if (clientNotification != null) {
      addNotification(
        type: clientNotification,
        title: 'Mise à jour de votre réservation',
        message: '${request.serviceName} : ${target.label}.',
        bookingId: request.id,
        providerId: request.providerId,
      );
    }
    return true;
  }

  static bool _canTransitionBookingStatus(
    MockBookingStatus current,
    MockBookingStatus target,
  ) => switch (current) {
    MockBookingStatus.pending =>
      target == MockBookingStatus.accepted ||
          target == MockBookingStatus.cancelled,
    MockBookingStatus.accepted =>
      target == MockBookingStatus.inProgress ||
          target == MockBookingStatus.cancelled,
    MockBookingStatus.inProgress => target == MockBookingStatus.completed,
    MockBookingStatus.completed || MockBookingStatus.cancelled => false,
  };

  /// ThemeMode courant de la session
  /// Disponibilités hebdomadaires du prestataire de démonstration
  static final List<MockDayAvailability> providerAvailability = [
    MockDayAvailability(
      dayName: 'Lundi',
      isOpen: true,
      startHour: 8,
      startMinute: 0,
      endHour: 18,
      endMinute: 0,
    ),
    MockDayAvailability(
      dayName: 'Mardi',
      isOpen: true,
      startHour: 8,
      startMinute: 0,
      endHour: 18,
      endMinute: 0,
    ),
    MockDayAvailability(
      dayName: 'Mercredi',
      isOpen: true,
      startHour: 8,
      startMinute: 0,
      endHour: 18,
      endMinute: 0,
    ),
    MockDayAvailability(
      dayName: 'Jeudi',
      isOpen: true,
      startHour: 8,
      startMinute: 0,
      endHour: 18,
      endMinute: 0,
    ),
    MockDayAvailability(
      dayName: 'Vendredi',
      isOpen: true,
      startHour: 8,
      startMinute: 0,
      endHour: 18,
      endMinute: 0,
    ),
    MockDayAvailability(
      dayName: 'Samedi',
      isOpen: true,
      startHour: 8,
      startMinute: 0,
      endHour: 14,
      endMinute: 0,
    ),
    MockDayAvailability(
      dayName: 'Dimanche',
      isOpen: false,
      startHour: 9,
      startMinute: 0,
      endHour: 13,
      endMinute: 0,
    ),
  ];

  /// Conversations et messages de démonstration, conservés en mémoire.
  static final List<MockConversation> conversations = [];

  /// Notifications réservées au profil prestataire courant.
  static final List<MockProviderNotification> providerNotifications = [];

  static int get providerUnreadNotificationCount => providerNotifications
      .where((notification) => !notification.isRead)
      .length;

  static MockProviderNotification addProviderNotification({
    required MockProviderNotificationType type,
    required String title,
    required String message,
    String? bookingId,
    String? conversationId,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    final notification = MockProviderNotification(
      id: 'provider_notif_${timestamp.microsecondsSinceEpoch}_${providerNotifications.length}',
      type: type,
      title: title,
      message: message,
      createdAt: timestamp,
      bookingId: bookingId,
      conversationId: conversationId,
    );
    providerNotifications.add(notification);
    return notification;
  }

  /// Identifiants des prestataires ajoutés aux favoris pendant la session.
  static final Set<String> favoriteProviderIds = <String>{};

  static int get unreadMessageCount => conversations.fold<int>(
    0,
    (total, conversation) => total + conversation.unreadCount,
  );

  static int get providerUnreadMessageCount => conversations.fold<int>(
    0,
    (total, conversation) =>
        total +
        (conversation.providerId == providerDashboardProfile.providerId
            ? conversation.providerUnreadCount
            : 0),
  );

  /// Notifications liées aux événements de démonstration de cette session.
  static final List<MockNotification> notifications = [];

  /// Reste null tant que le Client n'a pas renseigné ses propres informations.
  static MockClientProfile? clientProfile;

  static final MockClientPreferences clientPreferences =
      MockClientPreferences();

  static void clearClientProfileSession() {
    clientProfile = null;
    clientPreferences.notificationsEnabled = true;
  }

  static int get unreadNotificationCount =>
      notifications.where((notification) => !notification.isRead).length;

  static MockNotification addNotification({
    required MockNotificationType type,
    required String title,
    required String message,
    String? bookingId,
    String? providerId,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    final notification = MockNotification(
      id: 'notif_${timestamp.microsecondsSinceEpoch}_${notifications.length}',
      type: type,
      title: title,
      message: message,
      createdAt: timestamp,
      bookingId: bookingId,
      providerId: providerId,
    );
    notifications.add(notification);
    return notification;
  }

  static MockChatMessage addMessageToConversation({
    required MockConversation conversation,
    required String text,
    required bool isFromClient,
  }) {
    final sentAt = DateTime.now();
    final message = MockChatMessage(
      id: 'msg_${sentAt.microsecondsSinceEpoch}',
      text: text,
      sentAt: sentAt,
      isFromClient: isFromClient,
    );
    conversation.messages.add(message);
    if (isFromClient) {
      conversation.providerUnreadCount++;
      if (conversation.providerId == providerDashboardProfile.providerId) {
        addProviderNotification(
          type: MockProviderNotificationType.newMessage,
          title: 'Nouveau message reçu',
          message: 'Un client vous a envoyé un message.',
          conversationId: conversation.id,
          createdAt: sentAt,
        );
      }
    } else {
      conversation.unreadCount++;
      final provider = popularProviders.where(
        (item) => item.id == conversation.providerId,
      );
      final providerName = provider.isEmpty
          ? 'votre prestataire'
          : provider.first.name;
      addNotification(
        type: MockNotificationType.newMessage,
        title: 'Nouveau message',
        message: 'Vous avez reçu un message de $providerName.',
        providerId: conversation.providerId,
        createdAt: sentAt,
      );
    }
    return message;
  }

  static void markAllNotificationsAsRead() {
    for (final notification in notifications) {
      notification.isRead = true;
    }
  }

  static MockConversation conversationForProvider(String providerId) {
    for (final conversation in conversations) {
      if (conversation.providerId == providerId) return conversation;
    }
    final conversation = MockConversation(
      id: 'conv_${DateTime.now().microsecondsSinceEpoch}',
      providerId: providerId,
      createdAt: DateTime.now(),
    );
    conversations.add(conversation);
    return conversation;
  }

  static const List<MockCategory> categories = [
    MockCategory(
      id: 'plomberie',
      title: 'Plomberie',
      icon: Icons.plumbing_outlined,
    ),
    MockCategory(
      id: 'electricite',
      title: 'Électricité',
      icon: Icons.electrical_services_outlined,
    ),
    MockCategory(
      id: 'menuiserie',
      title: 'Menuiserie',
      icon: Icons.carpenter_outlined,
    ),
    MockCategory(
      id: 'maconnerie',
      title: 'Maçonnerie',
      icon: Icons.foundation_outlined,
    ),
    MockCategory(
      id: 'peinture',
      title: 'Peinture',
      icon: Icons.format_paint_outlined,
    ),
    MockCategory(
      id: 'mecanique',
      title: 'Mécanique',
      icon: Icons.build_outlined,
    ),
    MockCategory(
      id: 'coiffure',
      title: 'Beauté et coiffure',
      icon: Icons.content_cut_outlined,
    ),
    MockCategory(
      id: 'nettoyage',
      title: 'Nettoyage',
      icon: Icons.cleaning_services_outlined,
    ),
    MockCategory(
      id: 'jardinage',
      title: 'Jardinage',
      icon: Icons.grass_outlined,
    ),
    MockCategory(
      id: 'reparation',
      title: 'Réparation et entretien',
      icon: Icons.handyman_outlined,
    ),
    MockCategory(
      id: 'autres',
      title: 'Autres services',
      icon: Icons.more_horiz_outlined,
    ),
  ];

  static const List<MockServiceItem> popularServices = [
    MockServiceItem(
      id: 'serv_1',
      title: 'Dépannage plomberie express',
      description:
          'Réparation de fuites, tuyauterie et robinetterie sanitaire à domicile.',
      categoryName: 'Plomberie',
      categoryId: 'plomberie',
      startingPrice: 15000,
      icon: Icons.plumbing_outlined,
    ),
    MockServiceItem(
      id: 'serv_2',
      title: 'Installation & entretien climatisation',
      description:
          'Pose de climatiseurs split, recharge de gaz R22/R410 et entretien.',
      categoryName: 'Électricité',
      categoryId: 'electricite',
      startingPrice: 20000,
      icon: Icons.ac_unit_outlined,
    ),
    MockServiceItem(
      id: 'serv_3',
      title: 'Menuiserie & agencement bois',
      description:
          'Fabrication et rénovation de meubles, portes, placards et fenêtres.',
      categoryName: 'Menuiserie',
      categoryId: 'menuiserie',
      startingPrice: 25000,
      icon: Icons.carpenter_outlined,
    ),
    MockServiceItem(
      id: 'serv_4',
      title: 'Pose de carrelage & maçonnerie',
      description:
          'Travaux de maçonnerie générale, dalles, cloisons et pose de carrelage.',
      categoryName: 'Maçonnerie',
      categoryId: 'maconnerie',
      startingPrice: 30000,
      icon: Icons.foundation_outlined,
    ),
    MockServiceItem(
      id: 'serv_5',
      title: 'Peinture bâtiment & finitions',
      description:
          'Peinture intérieure/extérieure, enduit de lissage et étanchéité.',
      categoryName: 'Peinture',
      categoryId: 'peinture',
      startingPrice: 22000,
      icon: Icons.format_paint_outlined,
    ),
    MockServiceItem(
      id: 'serv_6',
      title: 'Coiffure & tresses à domicile',
      description:
          'Coiffures événementielles, tresses africaines et soins du visage.',
      categoryName: 'Beauté et coiffure',
      categoryId: 'coiffure',
      startingPrice: 10000,
      icon: Icons.content_cut_outlined,
    ),
    MockServiceItem(
      id: 'serv_7',
      title: 'Nettoyage & désinfection locaux',
      description:
          'Entretien complet de résidences, bureaux et locaux commerciaux.',
      categoryName: 'Nettoyage',
      categoryId: 'nettoyage',
      startingPrice: 12000,
      icon: Icons.cleaning_services_outlined,
    ),
  ];

  static const List<MockProvider> popularProviders = [
    MockProvider(
      id: 'prov_jm',
      name: 'Jean-Marc Matingou',
      specialty: 'Plombier sanitaire & tuyauterie',
      location: 'Bacongo, Brazzaville',
      rating: 4.8,
      reviewCount: 42,
      price: 15000,
      categoryId: 'plomberie',
      yearsOfExperience: 5,
      isVerified: false,
      about:
          'Jean-Marc propose des interventions de plomberie sanitaire et de tuyauterie dans le cadre de cette démonstration.',
      serviceAreas: ['Bacongo'],
      services: [
        MockProviderService(
          name: 'Dépannage plomberie sanitaire',
          price: 15000,
        ),
        MockProviderService(name: 'Réparation de tuyauterie'),
      ],
      offersHomeVisit: true,
      reviews: [
        MockProviderReview(
          author: 'Aline M.',
          comment: 'Intervention soignée, présentation de démonstration.',
          rating: 4.8,
        ),
        MockProviderReview(
          author: 'David K.',
          comment: 'Explications claires dans cet exemple fictif.',
          rating: 4.7,
        ),
      ],
    ),
    MockProvider(
      id: 'prov_pat',
      name: 'Patrick Ondaye',
      specialty: 'Électricien bâtiment & Climatisation',
      location: 'Moungali, Brazzaville',
      rating: 4.9,
      reviewCount: 58,
      price: 20000,
      categoryId: 'electricite',
      yearsOfExperience: 7,
      isVerified: false,
      about:
          'Patrick présente des services d’électricité et de climatisation dans cette fiche fictive.',
      serviceAreas: ['Moungali'],
      services: [
        MockProviderService(name: 'Dépannage électrique', price: 20000),
        MockProviderService(name: 'Installation de climatisation'),
      ],
      offersHomeVisit: true,
      reviews: [
        MockProviderReview(
          author: 'Sonia B.',
          comment: 'Avis fictif pour illustrer cette section.',
          rating: 4.9,
        ),
      ],
    ),
    MockProvider(
      id: 'prov_chr',
      name: 'Christian Banzouzi',
      specialty: 'Menuisier qualifié & Agencement',
      location: 'Poto-Poto, Brazzaville',
      rating: 4.7,
      reviewCount: 31,
      price: 25000,
      categoryId: 'menuiserie',
      yearsOfExperience: 4,
      isVerified: false,
      about:
          'Christian réalise des travaux de menuiserie et d’agencement dans cet exemple de démonstration.',
      serviceAreas: ['Poto-Poto'],
      services: [
        MockProviderService(
          name: 'Fabrication et réparation de meubles',
          price: 25000,
        ),
        MockProviderService(name: 'Agencement bois'),
      ],
      offersHomeVisit: true,
      workshopAddress:
          'Atelier fictif de démonstration, Poto-Poto, Brazzaville',
    ),
    MockProvider(
      id: 'prov_gra',
      name: 'Grâce Kouka',
      specialty: 'Coiffeuse & Soins esthétiques',
      location: 'Ouenzé, Brazzaville',
      rating: 4.9,
      reviewCount: 65,
      price: 10000,
      categoryId: 'coiffure',
      yearsOfExperience: 6,
      isVerified: false,
      about:
          'Grâce propose des prestations de coiffure et de soins esthétiques à titre de démonstration.',
      serviceAreas: ['Ouenzé'],
      services: [
        MockProviderService(name: 'Coiffure à domicile', price: 10000),
        MockProviderService(name: 'Soins esthétiques'),
      ],
      offersHomeVisit: true,
      reviews: [
        MockProviderReview(
          author: 'Mireille L.',
          comment: 'Commentaire fictif de démonstration.',
          rating: 4.9,
        ),
      ],
    ),
    MockProvider(
      id: 'prov_1',
      name: 'Grace Mfumu',
      specialty: 'Plomberie sanitaire & urgences',
      location: 'Bacongo, Brazzaville',
      rating: 4.8,
      reviewCount: 34,
      price: 15000,
      categoryId: 'plomberie',
      yearsOfExperience: 5,
      isVerified: false,
    ),
    MockProvider(
      id: 'prov_2',
      name: 'Martial Nkoulou',
      specialty: 'Électricité générale & Climatisation',
      location: 'Poto-Poto, Brazzaville',
      rating: 4.9,
      reviewCount: 52,
      price: 20000,
      categoryId: 'electricite',
      yearsOfExperience: 8,
      isVerified: false,
    ),
    MockProvider(
      id: 'prov_3',
      name: 'Gabin Mabiala',
      specialty: 'Menuiserie & Agencement bois',
      location: 'Moungali, Brazzaville',
      rating: 4.7,
      reviewCount: 28,
      price: 25000,
      categoryId: 'menuiserie',
      yearsOfExperience: 3,
      isVerified: false,
    ),
    MockProvider(
      id: 'prov_4',
      name: 'Clarisse Loubaki',
      specialty: 'Coiffure & Soins esthétiques à domicile',
      location: 'Centre-ville, Brazzaville',
      rating: 4.9,
      reviewCount: 61,
      price: 10000,
      categoryId: 'coiffure',
      yearsOfExperience: 9,
      isVerified: false,
    ),
    MockProvider(
      id: 'prov_5',
      name: 'Rodrigue Youlou',
      specialty: 'Mécanique auto & dépannage rapide',
      location: 'Talangaï, Brazzaville',
      rating: 4.6,
      reviewCount: 19,
      price: 18000,
      categoryId: 'mecanique',
      yearsOfExperience: 10,
      isVerified: false,
    ),
  ];
}
