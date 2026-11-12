import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';
import '../../shared/widgets/navigation/app_search_bar.dart';

/// Liste des conversations locales de démonstration du client.
class ClientMessagesPage extends StatefulWidget {
  const ClientMessagesPage({super.key, this.embedded = false});

  /// Quand true, la page est affichée dans l'onglet Messagerie de la navigation.
  final bool embedded;

  @override
  State<ClientMessagesPage> createState() => _ClientMessagesPageState();
}

class _ClientMessagesPageState extends State<ClientMessagesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  MockProvider? _providerFor(String id) {
    for (final provider in MockData.popularProviders) {
      if (provider.id == id) return provider;
    }
    return null;
  }

  String _timeLabel(DateTime date) {
    final now = DateTime.now();
    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final conversations = MockData.conversations.where((conversation) {
      final provider = _providerFor(conversation.providerId);
      return provider != null &&
          (query.isEmpty || provider.name.toLowerCase().contains(query));
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

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
                  if (!widget.embedded)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackButton(),
                    ),
                  const SizedBox(height: AppConstants.spacing3),
                  Text('Messages', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Échangez avec les professionnels',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  AppSearchBar(
                    controller: _searchController,
                    hintText: 'Rechercher un prestataire',
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            Expanded(
              child: conversations.isEmpty
                  ? AppEmptyState(
                      title: query.isEmpty
                          ? 'Aucune conversation'
                          : 'Aucun résultat',
                      message: query.isEmpty
                          ? 'Les conversations démarrent lorsque vous contactez un prestataire. Vos messages restent dans cette démonstration.'
                          : 'Aucun prestataire ne correspond à votre recherche.',
                      icon: Icons.chat_bubble_outline,
                    )
                  : ListView.separated(
                      padding: AppConstants.screenPadding,
                      itemCount: conversations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final provider = _providerFor(conversation.providerId)!;
                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.cardRadius,
                            ),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: _ProviderAvatar(
                              provider: provider,
                              radius: 27,
                            ),
                            title: Text(
                              provider.name,
                              style: AppTextStyles.label,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.specialty,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.small,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    conversation.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                ],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _timeLabel(conversation.updatedAt),
                                  style: AppTextStyles.small,
                                ),
                                if (conversation.unreadCount > 0) ...[
                                  const SizedBox(height: 6),
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      '${conversation.unreadCount}',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () async {
                              conversation.unreadCount = 0;
                              await Navigator.of(context).pushNamed(
                                AppRoutes.clientChat,
                                arguments: provider.id,
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text(
                'Messages conservés uniquement pendant la session de démonstration.',
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

class ProviderAvatar extends StatelessWidget {
  const ProviderAvatar({super.key, required this.provider, this.radius = 28});
  final MockProvider provider;
  final double radius;

  @override
  Widget build(BuildContext context) =>
      _ProviderAvatar(provider: provider, radius: radius);
}

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.provider, required this.radius});
  final MockProvider provider;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final index =
        int.tryParse(provider.id.replaceAll(RegExp(r'\D'), '')) ??
        provider.id.hashCode.abs();
    final imageId = index.isEven
        ? '1500648767791-00dcc994a43e'
        : '1534528741775-53994a69daeb';
    return ClipOval(
      child: Image.network(
        'https://images.unsplash.com/photo-$imageId?auto=format&fit=crop&w=180&h=180&q=80',
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.lightGreen,
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
      ),
    );
  }
}
