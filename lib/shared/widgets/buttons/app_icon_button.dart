import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

/// Bouton d'icône réutilisable de LOBOKO.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color = AppColors.textPrimary,
    this.backgroundColor,
    this.iconSize = AppConstants.iconSize,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color color;
  final Color? backgroundColor;
  final double iconSize;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: onPressed == null ? AppColors.disabledText : color,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(badgeCount > 99 ? '99+' : '$badgeCount'),
        backgroundColor: AppColors.errorText,
        textColor: AppColors.white,
        child: iconWidget,
      );
    }

    if (backgroundColor != null) {
      return IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
        ),
        icon: iconWidget,
      );
    }

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: iconWidget,
    );
  }
}
