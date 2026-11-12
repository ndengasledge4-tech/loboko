import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_category_card.dart';
import '../../shared/widgets/cards/app_service_card.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';
import '../../shared/widgets/navigation/app_notification_button.dart';
import '../../shared/widgets/navigation/app_search_bar.dart';
import '../../shared/widgets/navigation/app_section_header.dart';

/// Écran d'exploration des services LOBOKO (Espace Client).
class ClientExplorePage extends StatefulWidget {
  const ClientExplorePage({super.key});

  @override
  State<ClientExplorePage> createState() => _ClientExplorePageState();
}

class _ClientExplorePageState extends State<ClientExplorePage> {
  final int _currentBottomNavIndex = 1; // Onglet "Explorer" sélectionné
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FILTRAGE LOCAL RECHERCHE ---

  List<MockCategory> get _filteredCategories {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return MockData.categories;

    return MockData.categories.where((cat) {
      return cat.title.toLowerCase().contains(query);
    }).toList();
  }

  List<MockServiceItem> get _filteredServices {
    final query = _searchController.text.toLowerCase().trim();

    return MockData.popularServices.where((service) {
      final matchesQuery =
          query.isEmpty ||
          service.title.toLowerCase().contains(query) ||
          service.description.toLowerCase().contains(query) ||
          service.categoryName.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategoryId == null ||
          service.categoryId == _selectedCategoryId;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  // --- ACTIONS & DIALOGUES ---

  Future<void> _showNotificationsModal() async {
    await Navigator.of(context).pushNamed(AppRoutes.clientNotifications);
    if (mounted) setState(() {});
  }

  void _onCategoryTapped(MockCategory category) {
    Navigator.of(context).pushNamed(
      AppRoutes.clientProviders,
      arguments: <String, String>{
        'categoryId': category.id,
        'searchTerm': _searchController.text.trim(),
      },
    );
  }

  void _onServiceTapped(MockServiceItem service) {
    Navigator.of(context).pushNamed(
      AppRoutes.clientProviders,
      arguments: <String, String>{
        'categoryId': service.categoryId,
        'searchTerm': service.title,
      },
    );
  }

  void _onBottomNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.clientHome);
    } else if (index != 1) {
      // Les autres onglets sont affichés dans la navigation Client partagée.
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.clientHome,
        arguments: <String, Object>{
          'userName': 'Grace',
          'initialBottomNavIndex': index,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;
    final isResultsEmpty =
        _filteredCategories.isEmpty && _filteredServices.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A. En-tête
              _buildHeader(),
              const SizedBox(height: AppConstants.spacing5),

              // B. Barre de recherche
              AppSearchBar(
                controller: _searchController,
                hintText: 'Quel service recherchez-vous ?',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppConstants.spacing6),

              // En-tête statut de recherche le cas échéant
              if (hasSearchQuery) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Résultats pour "${_searchController.text}"',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _selectedCategoryId = null;
                        });
                      },
                      child: Text(
                        'Effacer',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.errorText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing3),
              ],

              // E. État vide si aucun résultat
              if (hasSearchQuery && isResultsEmpty)
                AppEmptyState(
                  title: 'Aucun résultat trouvé',
                  message:
                      'Aucune catégorie ou prestation ne correspond à "${_searchController.text}".\nEssayez avec d’autres mots-clés comme "Plomberie" ou "Climatisation".',
                  icon: Icons.search_off_outlined,
                  actionLabel: 'Réinitialiser la recherche',
                  onAction: () {
                    setState(() {
                      _searchController.clear();
                      _selectedCategoryId = null;
                    });
                  },
                )
              else ...[
                // C. Catégories de services (Grille de 11 catégories)
                if (_filteredCategories.isNotEmpty) ...[
                  const AppSectionHeader(
                    title: 'Toutes les catégories',
                    subtitle:
                        'Choisissez un domaine d’intervention à Brazzaville',
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      final isSelected = _selectedCategoryId == category.id;
                      return AppCategoryCard(
                        title: category.title,
                        icon: category.icon,
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : AppColors.lightGreen,
                        iconColor: isSelected
                            ? AppColors.white
                            : AppColors.primary,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = isSelected
                                ? null
                                : category.id;
                          });
                          _onCategoryTapped(category);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                ],

                // D. Services populaires
                if (_filteredServices.isNotEmpty) ...[
                  const AppSectionHeader(
                    title: 'Services populaires',
                    subtitle: 'Prestations les plus demandées par les clients',
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredServices.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return AppServiceCard(
                        title: service.title,
                        category: service.categoryName,
                        price: service.startingPrice,
                        description: service.description,
                        onTap: () => _onServiceTapped(service),
                      );
                    },
                  ),
                ],
              ],
              const SizedBox(height: AppConstants.spacing8),
            ],
          ),
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

  // --- EN-TÊTE ---
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explorer', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'Trouvez le service dont vous avez besoin',
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
}
