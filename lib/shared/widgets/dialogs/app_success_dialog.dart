import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Boîte de dialogue réutilisable pour signaler une réussite.
abstract final class AppSuccessDialog {
  AppSuccessDialog._();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'Continuer',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.dialogRadius,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.successBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successText,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppConstants.spacing2),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(
                  double.infinity,
                  AppConstants.buttonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonRadius,
                  ),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                buttonLabel,
                style: AppTextStyles.button,
              ),
            ),
          ],
        );
      },
    );
  }
}
