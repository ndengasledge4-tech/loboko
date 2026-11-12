import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/helpers/app_formatters.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/dialogs/app_info_dialog.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';
import '../../shared/widgets/navigation/app_filter_chip.dart';
import '../../shared/widgets/navigation/app_search_bar.dart';

/// Écran de liste des prestataires par catégorie ou recherche (Espace Client LOBOKO).
class ProviderListPage extends StatefulWidget {
  const ProviderListPage({
    super.key,
    this.categoryTitle = 'Plomberie',
    this.categoryId = 'plomberie',
    this.searchQuery,
  });

  final String categoryTitle;
  final String categoryId;
  final String? searchQuery;

  @override
  State<ProviderListPage> createState() => _ProviderListPageState();
}

class _ProviderListPageState extends State<ProviderListPage> {
  late TextEditingController _searchController;
  String _activeSortFilter = 'Tous'; // 'Tous', 'Mieux notés', 'Moins chers', 'Plus expérimentés'
  final Set<String> _favoriteProviderIds = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FILTRAGE ET TRI LOCAL DES PRESTATAIRES ---

  List<MockProvider> get _filteredAndSortedProviders {
    final query = _searchController.text.toLowerCase().trim();

    // 1. Filtrage par catégorie et mot-clé
    final list = MockData.popularProviders.where((p) {
      final matchesCategory = widget.categoryId.isEmpty ||
          p.categoryId == widget.categoryId ||
          p.specialty.toLowerCase().contains(widget.categoryTitle.toLowerCase());

      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.specialty.toLowerCase().contains(query) ||
          p.location.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();

    // Si la liste par catégorie exacte est vide, on renvoie les prestataires disponibles
    final resultList = list.isNotEmpty ? list : MockData.popularProviders.toList();

    // 2. Tri selon le filtre rapide actif
    switch (_activeSortFilter) {
      case 'Mieux notés':
        resultList.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Moins chers':
        resultList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Plus expérimentés':
        resultList.sort((a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience));
        break;
      case 'Tous':
      default:
        break;
    }

    return resultList;
  }

  void _toggleFavorite(String providerId) {
    setState(() {
      if (_favoriteProviderIds.contains(providerId)) {
        _favoriteProviderIds.remove(providerId);
      } else {
        _favoriteProviderIds.add(providerId);
      }
    });
  }

  void _onProviderTapped(MockProvider provider) {
    AppInfoDialog.show(
      context: context,
      title: provider.name,
      message:
          'Fiche de démonstration du prestataire :\n\n'
          '• Profession : ${provider.specialty}\n'
          '• Expérience : ${provider.yearsOfExperience} ans d’expérience\n'
          '• Zone d’intervention : ${provider.location}\n'
          '• Avis clients : ${provider.rating}★ (${provider.reviewCount} avis de démonstration)\n'
          '• Tarif moyen : ${AppFormatters.formatPrice(provider.price)}\n\n'
          '(La vue détaillée complète et la prise de rendez-vous seront reliées lors de l’étape suivante).',
      buttonLabel: 'Compris',
    );
  }

  @override
  Widget build(BuildContext context) {
    final providers = _filteredAndSortedProviders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // A. En-tête fixe avec bouton Retour
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing2,
                vertical: AppConstants.spacing2,
              ),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: AppConstants.spacing2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryTitle,
                          style: AppTextStyles.h2,
                        ),
                        Text(
                          '${providers.length} professionnels disponibles • Brazzaville',
                          style: AppTextStyles.small,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenu défilant
            Expanded(
              child: SingleChildScrollView(
                padding: AppConstants.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trouvez le professionnel qu’il vous faut',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: AppConstants.spacing4),

                    // B. Barre de recherche
                    AppSearchBar(
                      controller: _searchController,
                      hintText: 'Rechercher un prestataire...',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppConstants.spacing4),

                    // C. Filtres rapides (Chips)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Tous',
                          'Mieux notés',
                          'Moins chers',
                          'Plus expérimentés',
                        ].map((filter) {
                          final isSelected = _activeSortFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AppFilterChip(
                              label: filter,
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _activeSortFilter = filter;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing6),

                    // D. Liste des cartes prestataires
                    if (providers.isEmpty)
                      AppEmptyState(
                        title: 'Aucun prestataire trouvé',
                        message:
                            'Aucun professionnel ne correspond à vos critères de recherche.\nEssayez de modifier votre saisie.',
                        icon: Icons.person_off_outlined,
                        actionLabel: 'Réinitialiser',
                        onAction: () {
                          setState(() {
                            _searchController.clear();
                            _activeSortFilter = 'Tous';
                          });
                        },
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: providers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final provider = providers[index];
                          final isFav =
                              _favoriteProviderIds.contains(provider.id);

                          return _ProviderListItemCard(
                            provider: provider,
                            isFavorite: isFav,
                            onFavoriteToggle: () =>
                                _toggleFavorite(provider.id),
                            onTap: () => _onProviderTapped(provider),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte prestataire dédiée à la liste
class _ProviderListItemCard extends StatelessWidget {
  const _ProviderListItemCard({
    required this.provider,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  final MockProvider provider;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: AppConstants.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.lightGreen,
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          style: AppTextStyles.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.specialty,
                          style: AppTextStyles.bodySecondary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                provider.location,
                                style: AppTextStyles.small,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite ? AppColors.errorText : AppColors.textSecondary,
                    ),
                    onPressed: onFavoriteToggle,
                    tooltip: isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${provider.reviewCount} avis)',
                        style: AppTextStyles.small,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${provider.yearsOfExperience} ans d’exp.',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    AppFormatters.formatPrice(provider.price),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
