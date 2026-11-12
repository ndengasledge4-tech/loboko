
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Filtre sélectionnable réutilisable de LOBOKO.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null
          ? null
          : Icon(
        icon,
        size: AppConstants.smallIconSize,
        color: selected
            ? AppColors.primary
            : AppColors.textSecondary,
      ),
      showCheckmark: false,
      backgroundColor: AppColors.white,
      selectedColor: AppColors.lightGreen,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppConstants.badgeRadius,
        ),
      ),
      labelStyle: AppTextStyles.label.copyWith(
        color: selected ? AppColors.primary : AppColors.textPrimary,
      ),
    );
  }
}
