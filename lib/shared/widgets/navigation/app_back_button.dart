
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

/// Bouton de retour réutilisable de LOBOKO.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.tooltip = 'Retour',
  });

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      tooltip: tooltip,
      icon: const Icon(Icons.arrow_back),
      color: AppColors.textPrimary,
      iconSize: AppConstants.iconSize,
      splashRadius: 24,
    );
  }
}
