import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_provider_card.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Favoris Client locaux pour conserver l'accès depuis le profil.
class ClientFavoritesPage extends StatefulWidget {
  const ClientFavoritesPage({super.key});

  @override
  State<ClientFavoritesPage> createState() => _ClientFavoritesPageState();
}

class _ClientFavoritesPageState extends State<ClientFavoritesPage> {
  Future<void> _openProvider(MockProvider provider) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.clientProviderDetail, arguments: provider.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final providers = MockData.popularProviders
        .where((provider) => MockData.favoriteProviderIds.contains(provider.id))
        .toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppConstants.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(),
                  ),
                  const SizedBox(height: AppConstants.spacing2),
                  Text('Mes favoris', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Retrouvez les professionnels enregistrés',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: providers.isEmpty
                  ? AppEmptyState(
                      title: 'Aucun favori pour le moment',
                      message:
                          'Ajoutez des prestataires à vos favoris depuis leur fiche ou depuis la liste.',
                      icon: Icons.favorite_border_outlined,
                      actionLabel: 'Explorer les prestataires',
                      onAction: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.clientExplore),
                    )
                  : ListView.separated(
                      padding: AppConstants.screenPadding,
                      itemCount: providers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        return AppProviderCard(
                          name: provider.name,
                          specialty: provider.specialty,
                          rating: provider.rating,
                          reviewCount: provider.reviewCount,
                          location: provider.location,
                          isVerified: provider.isVerified,
                          onTap: () => _openProvider(provider),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text(
                'Favoris conservés uniquement pendant cette session de démonstration.',
                textAlign: TextAlign.center,
                style: AppTextStyles.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
