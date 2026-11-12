import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_category_card.dart';
import '../../shared/widgets/cards/app_provider_card.dart';
import '../../shared/widgets/cards/app_reservation_card.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';
import '../../shared/widgets/navigation/app_filter_chip.dart';
import '../../shared/widgets/navigation/app_notification_button.dart';
import '../../shared/widgets/navigation/app_search_bar.dart';
import '../../shared/widgets/navigation/app_section_header.dart';
import '../bookings/client_bookings_page.dart';
import '../messaging/client_messages_page.dart';
import '../profile/client_profile_page.dart';

/// Écran d'accueil principal de l'espace Client LOBOKO.
class ClientHomePage extends StatefulWidget {
  const ClientHomePage({
    super.key,
    this.userName = 'Grace',
    this.initialBottomNavIndex = 0,
  });

  final String userName;
  final int initialBottomNavIndex;

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  late int _currentBottomNavIndex;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedZoneFilter;

  @override
  void initState() {
    super.initState();
    _currentBottomNavIndex =
        widget.initialBottomNavIndex < 0 || widget.initialBottomNavIndex > 4
        ? 0
        : widget.initialBottomNavIndex;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE FILTRAGE LOCAL SUR DONNÉES FONTES MOCKÉES ---

  List<MockProvider> get _filteredProviders {
    return MockData.popularProviders.where((p) {
      final query = _searchController.text.toLowerCase().trim();
      final matchesQuery =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.specialty.toLowerCase().contains(query) ||
          p.location.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategoryId == null || p.categoryId == _selectedCategoryId;

      final matchesZone =
          _selectedZoneFilter == null ||
          p.location.toLowerCase().contains(_selectedZoneFilter!.toLowerCase());

      return matchesQuery && matchesCategory && matchesZone;
    }).toList();
  }

  // --- ACTIONS & DIALOGUES ---

  Future<void> _showNotificationsModal() async {
    await Navigator.of(context).pushNamed(AppRoutes.clientNotifications);
    if (mounted) setState(() {});
  }

  void _showFiltersModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtrer les prestataires', style: AppTextStyles.h3),
                    const SizedBox(height: AppConstants.spacing3),
                    Text(
                      "Zone d'intervention à Brazzaville",
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppConstants.spacing2),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            'Toutes',
                            'Bacongo',
                            'Poto-Poto',
                            'Moungali',
                            'Talangaï',
                            'Centre-ville',
                          ].map((zone) {
                            final isSelected =
                                (zone == 'Toutes' &&
                                    _selectedZoneFilter == null) ||
                                _selectedZoneFilter == zone;
                            return AppFilterChip(
                              label: zone,
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  setState(() {
                                    _selectedZoneFilter =
                                        (zone == 'Toutes' || !selected)
                                        ? null
                                        : zone;
                                  });
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: AppConstants.spacing6),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _goToExplore() {
    Navigator.of(context).pushNamed(AppRoutes.clientExplore);
  }

  Future<void> _goToFavorites() async {
    await Navigator.of(context).pushNamed(AppRoutes.clientFavorites);
    if (mounted) setState(() {});
  }

  void _onProviderTapped(MockProvider provider) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.clientProviderDetail, arguments: provider.id);
  }

  void _onReservationTapped(MockBookingRequest reservation) =>
      _openBookingDetail(reservation.id);

  Future<void> _openBookingDetail(String bookingId) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.clientBookingDetail, arguments: bookingId);
    if (mounted) setState(() {});
  }

  void _onBottomNavSelected(int index) {
    if (index == 1) {
      _goToExplore();
    } else {
      setState(() {
        _currentBottomNavIndex = index;
      });
    }
  }

  // --- CONSTRUCTION DES VUES PAR ONGLET ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentBottomNavIndex,
          children: [
            _buildHomeFeed(),
            const SizedBox.shrink(), // Le clic ouvre /client-explore
            ClientMessagesPage(embedded: true),
            _buildReservationsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentBottomNavIndex,
        onDestinationSelected: _onBottomNavSelected,
        destinations: [
          AppNavigationDestination(
            label: 'Accueil',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          AppNavigationDestination(
            label: 'Explorer',
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
          ),
          AppNavigationDestination(
            label: 'Messages',
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            badgeCount: MockData.unreadMessageCount,
          ),
          AppNavigationDestination(
            label: 'Réservations',
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
          ),
          AppNavigationDestination(
            label: 'Profil',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  /// Flux principal de l'accueil Client (Onglet 0)
  Widget _buildHomeFeed() {
    final clientReservations = MockData.clientBookingRequests('demo_client');
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. En-tête
            _buildHeader(),
            const SizedBox(height: AppConstants.spacing5),

            // B. Recherche
            AppSearchBar(
              controller: _searchController,
              hintText: 'Quel service recherchez-vous ?',
              onChanged: (_) => setState(() {}),
              onFilterPressed: _showFiltersModal,
            ),
            const SizedBox(height: AppConstants.spacing6),

            // Filtres actifs de zone / catégorie si sélectionnés
            if (_selectedCategoryId != null || _selectedZoneFilter != null) ...[
              Row(
                children: [
                  Text('Filtres actifs : ', style: AppTextStyles.small),
                  if (_selectedCategoryId != null) ...[
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(
                        MockData.categories
                            .firstWhere((c) => c.id == _selectedCategoryId)
                            .title,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: AppColors.lightGreen,
                      onDeleted: () =>
                          setState(() => _selectedCategoryId = null),
                      deleteIconColor: AppColors.primary,
                    ),
                  ],
                  if (_selectedZoneFilter != null) ...[
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(
                        _selectedZoneFilter!,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: AppColors.lightGreen,
                      onDeleted: () =>
                          setState(() => _selectedZoneFilter = null),
                      deleteIconColor: AppColors.primary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppConstants.spacing4),
            ],

            // C. Catégories de services
            AppSectionHeader(
              title: 'Catégories de services',
              actionLabel: 'Voir tout',
              onAction: _goToExplore,
            ),
            const SizedBox(height: AppConstants.spacing3),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: MockData.categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = MockData.categories[index];
                  final isSelected = _selectedCategoryId == cat.id;
                  return SizedBox(
                    width: 92,
                    child: AppCategoryCard(
                      title: cat.title,
                      icon: cat.icon,
                      backgroundColor: isSelected
                          ? AppColors.primary
                          : AppColors.lightGreen,
                      iconColor: isSelected
                          ? AppColors.white
                          : AppColors.primary,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = isSelected ? null : cat.id;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacing6),

            // D. Prestataires populaires
            AppSectionHeader(
              title: 'Prestataires populaires',
              subtitle: 'Avis vérifiés de démonstration à Brazzaville',
            ),
            const SizedBox(height: AppConstants.spacing3),
            if (_filteredProviders.isEmpty)
              const AppEmptyState(
                title: 'Aucun prestataire trouvé',
                message:
                    'Essayez de modifier votre recherche ou de réinitialiser les filtres.',
                icon: Icons.search_off_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredProviders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 12, height: 12),
                itemBuilder: (context, index) {
                  final provider = _filteredProviders[index];
                  return AppProviderCard(
                    name: provider.name,
                    specialty: provider.specialty,
                    rating: provider.rating,
                    reviewCount: provider.reviewCount,
                    location: provider.location,
                    isVerified: provider.isVerified,
                    onTap: () => _onProviderTapped(provider),
                  );
                },
              ),
            const SizedBox(height: AppConstants.spacing6),

            // E. Mes réservations
            AppSectionHeader(
              title: 'Mes réservations',
              actionLabel: 'Voir tout',
              onAction: () {
                setState(() {
                  _currentBottomNavIndex = 3;
                });
              },
            ),
            const SizedBox(height: AppConstants.spacing3),
            if (clientReservations.isEmpty)
              const AppEmptyState(
                title: 'Aucune réservation',
                message:
                    'Découvrez nos prestataires et réservez votre premier service.',
                icon: Icons.event_note_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: clientReservations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final res = clientReservations[index];
                  return AppReservationCard(
                    serviceName: res.serviceName,
                    personName: res.personName,
                    date: res.date,
                    status: res.status.label,
                    location: res.location,
                    price: res.price,
                    onTap: () => _onReservationTapped(res),
                  );
                },
              ),
            const SizedBox(height: AppConstants.spacing6),
          ],
        ),
      ),
    );
  }

  // --- EN-TÊTE D'ACCUEIL ---
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.handshake_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LOBOKO',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing3),
              Text(
                'Bonjour, ${widget.userName} 👋',
                style: AppTextStyles.h1.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                'Quel service recherchez-vous aujourd’hui ?',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
        AppNotificationButton(
          unreadCount: MockData.unreadNotificationCount,
          onPressed: _showNotificationsModal,
        ),
      ],
    );
  }

  // --- ONGLET 2 : FAVORIS ---
  // --- ONGLET 3 : RÉSERVATIONS ---
  Widget _buildReservationsTab() {
    return ClientBookingsPage(onRequestSelected: _onBookingRequestSelected);
  }

  void _onBookingRequestSelected(String requestId) {
    final request = MockData.bookingRequestById(requestId);
    if (request == null || request.clientId != 'demo_client') return;
    _openBookingDetail(request.id);
  }

  // --- ONGLET 4 : PROFIL ---
  Widget _buildProfileTab() => ClientProfilePage(
    onBookings: () => setState(() => _currentBottomNavIndex = 3),
    onFavorites: _goToFavorites,
  );
}
