import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';
import '../../shared/widgets/navigation/app_filter_chip.dart';
import '../../shared/widgets/navigation/app_search_bar.dart';

enum _ProviderSort { all, bestRated, lowestPrice, mostExperienced }

class ClientProvidersPage extends StatefulWidget {
  const ClientProvidersPage({
    super.key,
    this.categoryId,
    this.initialSearchTerm,
  });

  final String? categoryId;
  final String? initialSearchTerm;

  @override
  State<ClientProvidersPage> createState() => _ClientProvidersPageState();
}

class _ClientProvidersPageState extends State<ClientProvidersPage> {
  late final TextEditingController _searchController;
  _ProviderSort _sort = _ProviderSort.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.initialSearchTerm ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  MockCategory? get _category {
    for (final category in MockData.categories) {
      if (category.id == widget.categoryId) return category;
    }
    return null;
  }

  String get _title {
    switch (widget.categoryId) {
      case 'plomberie':
        return 'Plombiers';
      case 'electricite':
        return 'Électriciens';
      case 'menuiserie':
        return 'Menuisiers';
      case 'coiffure':
        return 'Coiffeurs et coiffeuses';
      default:
        return _category?.title ?? 'Prestataires';
    }
  }

  List<MockProvider> get _providers {
    final query = _searchController.text.trim().toLowerCase();
    final result = MockData.popularProviders.where((provider) {
      final categoryMatches =
          widget.categoryId == null || provider.categoryId == widget.categoryId;
      final queryMatches =
          query.isEmpty ||
          provider.name.toLowerCase().contains(query) ||
          provider.specialty.toLowerCase().contains(query) ||
          provider.location.toLowerCase().contains(query);
      return categoryMatches && queryMatches;
    }).toList();
    switch (_sort) {
      case _ProviderSort.bestRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _ProviderSort.lowestPrice:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _ProviderSort.mostExperienced:
        result.sort(
          (a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience),
        );
        break;
      case _ProviderSort.all:
        break;
    }
    return result;
  }

  Future<void> _showFilters() async {
    final selected = await showModalBottomSheet<_ProviderSort>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trier les prestataires', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              for (final option in _ProviderSort.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_sortLabel(option), style: AppTextStyles.body),
                  trailing: _sort == option
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, option),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) setState(() => _sort = selected);
  }

  String _sortLabel(_ProviderSort sort) => switch (sort) {
    _ProviderSort.all => 'Tous',
    _ProviderSort.bestRated => 'Mieux notés',
    _ProviderSort.lowestPrice => 'Moins chers',
    _ProviderSort.mostExperienced => 'Plus expérimentés',
  };

  void _onProviderTapped(MockProvider provider) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.clientProviderDetail, arguments: provider.id);
  }

  @override
  Widget build(BuildContext context) {
    final providers = _providers;
    final initialQuery = widget.initialSearchTerm?.trim() ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: AppConstants.screenPadding,
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _title,
                          style: AppTextStyles.h1.copyWith(fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trouvez le professionnel qu’il vous faut',
                    style: AppTextStyles.bodySecondary,
                  ),
                  if (initialQuery.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Recherche : « $initialQuery »',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    '${providers.length} prestataire${providers.length == 1 ? '' : 's'} disponible${providers.length == 1 ? '' : 's'}',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  AppSearchBar(
                    controller: _searchController,
                    hintText: 'Nom, métier ou spécialité',
                    onChanged: (_) => setState(() {}),
                    onFilterPressed: _showFilters,
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final option in _ProviderSort.values) ...[
                          AppFilterChip(
                            label: _sortLabel(option),
                            selected: _sort == option,
                            onSelected: (_) => setState(() => _sort = option),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  if (providers.isEmpty)
                    const AppEmptyState(
                      title: 'Aucun prestataire trouvé',
                      message:
                          'Modifiez votre recherche ou choisissez un autre filtre.',
                      icon: Icons.search_off_outlined,
                    )
                  else
                    for (final provider in providers) ...[
                      _ProviderListCard(
                        provider: provider,
                        isFavorite: MockData.favoriteProviderIds.contains(
                          provider.id,
                        ),
                        onFavoritePressed: () => setState(() {
                          if (!MockData.favoriteProviderIds.add(provider.id)) {
                            MockData.favoriteProviderIds.remove(provider.id);
                          }
                        }),
                        onTap: () => _onProviderTapped(provider),
                      ),
                      const SizedBox(height: AppConstants.spacing3),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderListCard extends StatelessWidget {
  const _ProviderListCard({
    required this.provider,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onTap,
  });

  final MockProvider provider;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Image.network(
                  _portraitFor(provider.id),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.lightGreen,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      provider.specialty,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: provider.location,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.work_outline,
                      text: '${provider.yearsOfExperience} ans d’expérience',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          provider.rating.toStringAsFixed(1),
                          style: AppTextStyles.label,
                        ),
                        Text(
                          '  (${provider.reviewCount} avis)',
                          style: AppTextStyles.small,
                        ),
                        Text(
                          '${provider.price.toStringAsFixed(0)} FCFA',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavoritePressed,
                tooltip: isFavorite
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.redAccent
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _portraitFor(String id) {
    final index =
        int.tryParse(id.replaceAll(RegExp(r'\D'), '')) ??
        id.hashCode.abs() % 10;
    return 'https://images.unsplash.com/photo-${index.isEven ? '1500648767791-00dcc994a43e' : '1534528741775-53994a69daeb'}?auto=format&fit=crop&w=120&h=120&q=80';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.small,
        ),
      ),
    ],
  );
}
