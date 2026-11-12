import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Barre de recherche réutilisable de LOBOKO.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterPressed,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Row(
          children: [
            Expanded(
              child: SearchBar(
                controller: controller,
                hintText: hintText,
                enabled: enabled,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: const WidgetStatePropertyAll(
                  AppColors.white,
                ),
                side: const WidgetStatePropertyAll(
                  BorderSide(color: AppColors.border),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.inputRadius,
                    ),
                  ),
                ),
                textStyle: WidgetStatePropertyAll(
                  AppTextStyles.body,
                ),
                hintStyle: WidgetStatePropertyAll(
                  AppTextStyles.bodySecondary,
                ),
                leading: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                trailing: value.text.isEmpty
                    ? null
                    : [
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: AppColors.textSecondary,
                          onPressed: () {
                            controller.clear();
                            onChanged?.call('');
                          },
                        ),
                      ],
              ),
            ),
            if (onFilterPressed != null) ...[
              const SizedBox(width: AppConstants.spacing2),
              IconButton.filledTonal(
                onPressed: onFilterPressed,
                tooltip: 'Filtrer',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.inputRadius,
                    ),
                  ),
                ),
                icon: const Icon(Icons.tune),
              ),
            ],
          ],
        );
      },
    );
  }
}
