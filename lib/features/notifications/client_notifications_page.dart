import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Centre des notifications locales du Client.
class ClientNotificationsPage extends StatefulWidget {
  const ClientNotificationsPage({super.key});

  @override
  State<ClientNotificationsPage> createState() =>
      _ClientNotificationsPageState();
}

class _ClientNotificationsPageState extends State<ClientNotificationsPage> {
  List<MockNotification> get _notifications =>
      List<MockNotification>.of(MockData.notifications)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void _markAllRead() {
    setState(MockData.markAllNotificationsAsRead);
  }

  Future<void> _openNotification(MockNotification notification) async {
    setState(() => notification.isRead = true);

    if (notification.bookingId != null &&
        MockData.bookingRequestById(notification.bookingId!)?.clientId ==
            'demo_client') {
      await Navigator.of(context).pushNamed(
        AppRoutes.clientHome,
        arguments: const {'initialBottomNavIndex': 3},
      );
      return;
    }

    if (notification.providerId != null &&
        MockData.conversations.any(
          (conversation) => conversation.providerId == notification.providerId,
        )) {
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.clientChat, arguments: notification.providerId);
    }
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      return "Aujourd'hui · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notifications;
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
                  Row(
                    children: [
                      const AppBackButton(),
                      const Spacer(),
                      Flexible(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          onPressed: MockData.unreadNotificationCount == 0
                              ? null
                              : _markAllRead,
                          child: const Text(
                            'Tout marquer comme lu',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing2),
                  Text('Notifications', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Suivez les activités de vos services',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(
                        AppConstants.buttonRadius,
                      ),
                    ),
                    child: Text(
                      'Notifications de démonstration, conservées en mémoire pendant cette session. Aucun SMS, email ou push réel n’est envoyé.',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? const AppEmptyState(
                      title: 'Aucune notification',
                      message:
                          'Les informations liées à vos demandes apparaîtront ici pendant la démonstration.',
                      icon: Icons.notifications_none_outlined,
                    )
                  : ListView.separated(
                      padding: AppConstants.screenPadding,
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final style = _NotificationStyle.forType(
                          notification.type,
                        );
                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: notification.isRead
                              ? AppColors.white
                              : AppColors.lightGreen.withValues(alpha: .55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.cardRadius,
                            ),
                            side: BorderSide(
                              color: notification.isRead
                                  ? AppColors.border
                                  : AppColors.secondary.withValues(alpha: .6),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _openNotification(notification),
                            borderRadius: BorderRadius.circular(
                              AppConstants.cardRadius,
                            ),
                            child: Padding(
                              padding: AppConstants.cardPadding,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: style.background,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      style.icon,
                                      color: style.foreground,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: AppTextStyles.label,
                                              ),
                                            ),
                                            if (!notification.isRead)
                                              Container(
                                                width: 9,
                                                height: 9,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.secondary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          notification.message,
                                          style: AppTextStyles.bodySecondary,
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          _dateLabel(notification.createdAt),
                                          style: AppTextStyles.small,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationStyle {
  const _NotificationStyle(this.icon, this.background, this.foreground);

  final IconData icon;
  final Color background;
  final Color foreground;

  factory _NotificationStyle.forType(MockNotificationType type) {
    return switch (type) {
      MockNotificationType.bookingCreated => const _NotificationStyle(
        Icons.event_available_outlined,
        AppColors.lightGreen,
        AppColors.primary,
      ),
      MockNotificationType.bookingAccepted => const _NotificationStyle(
        Icons.check_circle_outline,
        AppColors.successBackground,
        AppColors.successText,
      ),
      MockNotificationType.bookingDeclined => const _NotificationStyle(
        Icons.event_busy_outlined,
        AppColors.errorBackground,
        AppColors.errorText,
      ),
      MockNotificationType.interventionInProgress => const _NotificationStyle(
        Icons.handyman_outlined,
        AppColors.infoBackground,
        AppColors.infoText,
      ),
      MockNotificationType.interventionCompleted => const _NotificationStyle(
        Icons.task_alt_outlined,
        AppColors.successBackground,
        AppColors.successText,
      ),
      MockNotificationType.newMessage => const _NotificationStyle(
        Icons.chat_bubble_outline,
        AppColors.lightGreen,
        AppColors.primary,
      ),
      MockNotificationType.general => const _NotificationStyle(
        Icons.info_outline,
        AppColors.warningBackground,
        AppColors.warningText,
      ),
    };
  }
}
