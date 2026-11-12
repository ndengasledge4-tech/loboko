
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

/// Bouton de notification réutilisable avec compteur optionnel.
class AppNotificationButton extends StatelessWidget {
  const AppNotificationButton({
    super.key,
    required this.onPressed,
    this.unreadCount = 0,
    this.tooltip = 'Notifications',
  }) : assert(unreadCount >= 0);

  final VoidCallback onPressed;
  final int unreadCount;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(
          unreadCount > 99 ? '99+' : '$unreadCount',
        ),
        backgroundColor: AppColors.errorText,
        textColor: AppColors.white,
        child: const Icon(
          Icons.notifications_outlined,
          size: AppConstants.iconSize,
        ),
      ),
      color: AppColors.textPrimary,
    );
  }
}
