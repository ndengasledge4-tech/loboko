
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Bouton réutilisable pour déclencher le tri des résultats.
class AppSortButton extends StatelessWidget {
  const AppSortButton({
    super.key,
    this.label = 'Trier',
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.sort,
        size: AppConstants.smallIconSize,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing3,
          vertical: AppConstants.spacing2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.inputRadius,
          ),
        ),
        textStyle: AppTextStyles.label,
      ),
    );
  }
}
