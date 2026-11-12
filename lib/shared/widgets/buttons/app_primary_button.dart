
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Bouton principal réutilisable de LOBOKO.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  /// Texte affiché sur le bouton.
  final String label;

  /// Action exécutée au clic.
  /// Utiliser null pour désactiver le bouton.
  final VoidCallback? onPressed;

  /// Icône facultative affichée avant le texte.
  final IconData? icon;

  /// Affiche un indicateur de chargement.
  final bool isLoading;

  /// Occupe toute la largeur disponible si true.
  final bool expand;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: isLoading
              ? AppColors.primary
              : AppColors.disabledBackground,
          disabledForegroundColor: isLoading
              ? AppColors.white
              : AppColors.disabledText,
          elevation: 0,
          padding: AppConstants.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.button,
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.white,
            ),
          ),
        )
            : Row(
          mainAxisSize:
          expand ? MainAxisSize.max : MainAxisSize.min,
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
      ),
    );
  }
}
