
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Indicateur de chargement réutilisable de LOBOKO.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 32,
    this.color = AppColors.primary,
    this.centered = true,
  });

  final String? message;
  final double size;
  final Color color;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: color,
          ),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacing3),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ],
    );

    if (!centered) {
      return content;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing4),
        child: content,
      ),
    );
  }
}
