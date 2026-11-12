import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';

/// Boîte de réception des conversations partagées avec l'espace Client.
class ProviderMessagesPage extends StatefulWidget {
  const ProviderMessagesPage({super.key, this.showBottomNavigation = true});
  final bool showBottomNavigation;

  @override
  State<ProviderMessagesPage> createState() => _ProviderMessagesPageState();
}

class _ProviderMessagesPageState extends State<ProviderMessagesPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = MockData.providerDashboardProfile;
    final query = _search.text.trim().toLowerCase();
    final conversations = MockData.conversations.where((conversation) {
      final provider = MockData.popularProviders.where(
        (item) => item.id == conversation.providerId,
      );
      return conversation.providerId == profile.providerId &&
          (query.isEmpty ||
              (provider.isNotEmpty && provider.first.name.toLowerCase().contains(query)));
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: widget.showBottomNavigation ? const AppBackButton() : null,
        automaticallyImplyLeading: widget.showBottomNavigation,
        title: const Text('Messages'),
      ),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Échangez avec vos clients', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Rechercher un client',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              Text('Messagerie locale de démonstration', style: AppTextStyles.small),
            ]),
          ),
          Expanded(
            child: conversations.isEmpty
                ? const AppEmptyState(
                    title: 'Aucune conversation',
                    message: 'Les messages envoyés par les clients apparaîtront ici dans cette démonstration.',
                    icon: Icons.chat_bubble_outline,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.lightGreen,
                            child: Icon(profile.avatarIcon ?? Icons.person_outline, color: AppColors.primary),
                          ),
                          title: Text('Client de démonstration', style: AppTextStyles.label),
                          subtitle: Text(conversation.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: conversation.providerUnreadCount == 0
                              ? const Icon(Icons.chevron_right)
                              : CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.primary,
                                  child: Text('${conversation.providerUnreadCount}', style: const TextStyle(color: AppColors.white, fontSize: 11)),
                                ),
                          onTap: () async {
                            conversation.providerUnreadCount = 0;
                            await Navigator.of(context).pushNamed(
                              AppRoutes.providerChat,
                              arguments: conversation.id,
                            );
                            if (mounted) setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? AppBottomNavigation(
              currentIndex: 3,
              onDestinationSelected: (index) {
                if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
              },
              destinations: const [
                AppNavigationDestination(label: 'Accueil', icon: Icons.home_outlined, activeIcon: Icons.home),
                AppNavigationDestination(label: 'Demandes', icon: Icons.inbox_outlined, activeIcon: Icons.inbox),
                AppNavigationDestination(label: 'Missions', icon: Icons.work_outline, activeIcon: Icons.work),
                AppNavigationDestination(label: 'Messages', icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble),
                AppNavigationDestination(label: 'Profil', icon: Icons.person_outline, activeIcon: Icons.person),
              ],
            )
          : null,
    );
  }
}
