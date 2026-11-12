
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Bouton texte réutilisable de LOBOKO.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// Texte affiché sur le bouton.
  final String label;

  /// Action exécutée au clic.
  /// Utiliser null pour désactiver le bouton.
  final VoidCallback? onPressed;

  /// Icône facultative affichée avant le texte.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.disabledText,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing2,
          vertical: AppConstants.spacing2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.buttonRadius,
          ),
        ),
        textStyle: AppTextStyles.button,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppConstants.smallIconSize),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
