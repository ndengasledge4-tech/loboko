
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Badge réutilisable pour afficher le statut d'une réservation.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  Color get _backgroundColor {
    switch (status) {
      case 'Acceptée':
      case 'Terminée':
        return AppColors.successBackground;
      case 'En cours':
        return AppColors.infoBackground;
      case 'Annulée':
        return AppColors.errorBackground;
      case 'En attente':
        return AppColors.warningBackground;
      default:
        return AppColors.disabledBackground;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'Acceptée':
      case 'Terminée':
        return AppColors.successText;
      case 'En cours':
        return AppColors.infoText;
      case 'Annulée':
        return AppColors.errorText;
      case 'En attente':
        return AppColors.warningText;
      default:
        return AppColors.disabledText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing3,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(
          AppConstants.badgeRadius,
        ),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.small.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
