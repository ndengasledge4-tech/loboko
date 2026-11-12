import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/buttons/app_secondary_button.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/feedback/app_error_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Fiche dynamique d'un prestataire à partir de son identifiant de démonstration.
class ClientProviderDetailPage extends StatefulWidget {
  const ClientProviderDetailPage({
    super.key,
    required this.providerId,
    this.onContact,
    this.onBook,
  });

  final String? providerId;
  final ValueChanged<String>? onContact;
  final ValueChanged<String>? onBook;

  @override
  State<ClientProviderDetailPage> createState() =>
      _ClientProviderDetailPageState();
}

class _ClientProviderDetailPageState extends State<ClientProviderDetailPage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = MockData.favoriteProviderIds.contains(widget.providerId);
  }

  MockProvider? get _provider {
    for (final provider in MockData.popularProviders) {
      if (provider.id == widget.providerId) return provider;
    }
    return null;
  }

  void _openBooking(MockProvider provider) {
    if (widget.onBook != null) {
      widget.onBook!(provider.id);
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.clientBooking, arguments: provider.id);
  }

  void _openContact(MockProvider provider) {
    if (widget.onContact != null) {
      widget.onContact!(provider.id);
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.clientChat, arguments: provider.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    if (provider == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: const AppBackButton(),
          backgroundColor: AppColors.background,
        ),
        body: AppErrorState(
          title: 'Prestataire introuvable',
          message:
              'Cette référence ne correspond à aucun prestataire de démonstration.',
          retryLabel: 'Retour à la liste',
          onRetry: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    final services = provider.services.isNotEmpty
        ? provider.services
        : [
            MockProviderService(
              name: provider.specialty,
              price: provider.price,
            ),
          ];
    final areas = provider.serviceAreas.isNotEmpty
        ? provider.serviceAreas
        : [provider.location.split(',').first.trim()];

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppBackButton(),
                      IconButton(
                        tooltip: _isFavorite
                            ? 'Retirer des favoris'
                            : 'Ajouter aux favoris',
                        onPressed: () => setState(() {
                          if (_isFavorite) {
                            MockData.favoriteProviderIds.remove(provider.id);
                          } else {
                            MockData.favoriteProviderIds.add(provider.id);
                          }
                          _isFavorite = !_isFavorite;
                        }),
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? Colors.redAccent
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  _ProviderHero(provider: provider),
                  const SizedBox(height: AppConstants.spacing5),
                  _SectionCard(
                    title: 'À propos',
                    child: Text(
                      provider.about.isNotEmpty
                          ? provider.about
                          : '${provider.name} propose ${provider.specialty.toLowerCase()} dans cette fiche de démonstration.',
                      style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  _SectionCard(
                    title: 'Services proposés',
                    child: Column(
                      children: [
                        for (final service in services)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.secondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    service.name,
                                    style: AppTextStyles.body,
                                  ),
                                ),
                                if (service.price != null)
                                  Text(
                                    '${service.price!.toStringAsFixed(0)} FCFA',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tarifs indicatifs de démonstration',
                            style: AppTextStyles.small,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  _SectionCard(
                    title: 'Zone d’intervention',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final area in areas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _DetailLine(
                              icon: Icons.location_on_outlined,
                              text: '$area, Brazzaville',
                            ),
                          ),
                        Text(
                          'Zones indiquées à titre fictif pour la démonstration.',
                          style: AppTextStyles.small,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  _SectionCard(
                    title: 'Disponibilité',
                    child: Text(
                      'Aucune information de disponibilité n’est renseignée.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  _SectionCard(
                    title: 'Avis clients',
                    subtitle: 'Notes et avis fictifs de démonstration',
                    child: provider.reviews.isEmpty
                        ? const AppEmptyState(
                            title: 'Aucun avis disponible',
                            message:
                                'Cette fiche ne contient pas encore d’avis de démonstration.',
                            icon: Icons.rate_review_outlined,
                          )
                        : Column(
                            children: [
                              for (final review in provider.reviews)
                                _ReviewTile(review: review),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    'Profil et informations présentés à titre fictif pour la démonstration.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  label: 'Contacter',
                  icon: Icons.chat_bubble_outline,
                  onPressed: () => _openContact(provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppPrimaryButton(
                  label: 'Réserver un service',
                  icon: Icons.calendar_month_outlined,
                  onPressed: () => _openBooking(provider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderHero extends StatelessWidget {
  const _ProviderHero({required this.provider});
  final MockProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.network(
            _portraitFor(provider.id),
            width: 112,
            height: 112,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 112,
              height: 112,
              color: AppColors.lightGreen,
              alignment: Alignment.center,
              child: const Icon(
                Icons.person,
                size: 54,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          provider.name,
          textAlign: TextAlign.center,
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 4),
        Text(
          provider.specialty,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 8),
        _DetailLine(icon: Icons.location_on_outlined, text: provider.location),
        const SizedBox(height: 4),
        _DetailLine(
          icon: Icons.work_outline,
          text: '${provider.yearsOfExperience} ans d’expérience',
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 4),
              Text(
                '${provider.rating.toStringAsFixed(1)} · ${provider.reviewCount} avis',
                style: AppTextStyles.label,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('Note fictive de démonstration', style: AppTextStyles.small),
      ],
    );
  }

  String _portraitFor(String id) {
    final index =
        int.tryParse(id.replaceAll(RegExp(r'\D'), '')) ??
        id.hashCode.abs() % 10;
    return 'https://images.unsplash.com/photo-${index.isEven ? '1500648767791-00dcc994a43e' : '1534528741775-53994a69daeb'}?auto=format&fit=crop&w=360&h=360&q=85';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: AppConstants.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, style: AppTextStyles.small),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 17, color: AppColors.textSecondary),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
      ),
    ],
  );
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final MockProviderReview review;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.lightGreen,
          child: Icon(Icons.person_outline, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(review.author, style: AppTextStyles.label),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    size: 17,
                    color: AppColors.gold,
                  ),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: AppTextStyles.small,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(review.comment, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ],
    ),
  );
}
