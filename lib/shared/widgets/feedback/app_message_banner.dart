
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Bannière réutilisable pour informer l'utilisateur.
class AppMessageBanner extends StatelessWidget {
  const AppMessageBanner({
    super.key,
    required this.message,
    this.type = AppMessageType.info,
    this.icon,
  });

  final String message;
  final AppMessageType type;
  final IconData? icon;

  Color get _backgroundColor {
    switch (type) {
      case AppMessageType.success:
        return AppColors.successBackground;
      case AppMessageType.error:
        return AppColors.errorBackground;
      case AppMessageType.warning:
        return AppColors.warningBackground;
      case AppMessageType.info:
        return AppColors.infoBackground;
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case AppMessageType.success:
        return AppColors.successText;
      case AppMessageType.error:
        return AppColors.errorText;
      case AppMessageType.warning:
        return AppColors.warningText;
      case AppMessageType.info:
        return AppColors.infoText;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case AppMessageType.success:
        return Icons.check_circle_outline;
      case AppMessageType.error:
        return Icons.error_outline;
      case AppMessageType.warning:
        return Icons.warning_amber_rounded;
      case AppMessageType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(
          AppConstants.inputRadius,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? _defaultIcon,
            color: _foregroundColor,
            size: AppConstants.iconSize,
          ),
          const SizedBox(width: AppConstants.spacing2),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.message.copyWith(
                color: _foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Types de messages disponibles.
enum AppMessageType {
  success,
  error,
  warning,
  info,
}
