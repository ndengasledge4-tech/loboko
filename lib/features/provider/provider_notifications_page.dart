import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

class ProviderNotificationsPage extends StatefulWidget {
  const ProviderNotificationsPage({super.key});
  @override
  State<ProviderNotificationsPage> createState() =>
      _ProviderNotificationsPageState();
}

class _ProviderNotificationsPageState extends State<ProviderNotificationsPage> {
  Future<void> _open(MockProviderNotification item) async {
    setState(() => item.isRead = true);
    final conversationId = item.conversationId;
    if (conversationId != null) {
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.providerChat, arguments: conversationId);
    } else if (item.bookingId != null &&
        MockData.bookingRequestById(item.bookingId!)?.providerId ==
            MockData.providerDashboardProfile.providerId) {
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.providerRequestDetail, arguments: item.bookingId);
    } else if (item.type == MockProviderNotificationType.newRequest) {
      await Navigator.of(context).pushNamed(AppRoutes.providerRequests);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = MockData.providerNotifications.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Notifications'),
      ),
      body: items.isEmpty
          ? const AppEmptyState(
              title: 'Aucune notification',
              message:
                  'Les nouveaux événements de la démonstration apparaîtront ici.',
              icon: Icons.notifications_none,
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Activité de votre espace prestataire'),
                      ),
                      TextButton(
                        onPressed: MockData.providerUnreadNotificationCount == 0
                            ? null
                            : () => setState(() {
                                for (final item
                                    in MockData.providerNotifications) {
                                  item.isRead = true;
                                }
                              }),
                        child: const Text('Tout marquer comme lu'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Données locales de démonstration',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final icon = switch (item.type) {
                        MockProviderNotificationType.newRequest =>
                          Icons.inbox_outlined,
                        MockProviderNotificationType.requestAccepted =>
                          Icons.event_available_outlined,
                        MockProviderNotificationType.requestDeclined =>
                          Icons.event_busy_outlined,
                        MockProviderNotificationType.newMission =>
                          Icons.work_outline,
                        MockProviderNotificationType.newMessage =>
                          Icons.chat_bubble_outline,
                        MockProviderNotificationType.missionCompleted =>
                          Icons.task_alt_outlined,
                      };
                      return Card(
                        color: item.isRead
                            ? AppColors.white
                            : AppColors.lightGreen,
                        child: ListTile(
                          onTap: () => _open(item),
                          leading: Icon(icon, color: AppColors.primary),
                          title: Text(item.title, style: AppTextStyles.label),
                          subtitle: Text(
                            '${item.message}\n${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')} · ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                          ),
                          isThreeLine: true,
                          trailing: item.isRead
                              ? const Icon(Icons.chevron_right)
                              : const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: AppColors.secondary,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
