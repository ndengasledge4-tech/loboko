import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Boîte de dialogue réutilisable pour afficher une information.
abstract final class AppInfoDialog {
  AppInfoDialog._();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'Compris',
    IconData icon = Icons.info_outline,
    Color iconColor = AppColors.infoText,
    Color iconBackgroundColor = AppColors.infoBackground,
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
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
