
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_text_styles.dart';

/// En-tête réutilisable pour les pages de LOBOKO.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h1,
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing2),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppConstants.spacing2),
          trailing!,
        ],
      ],
    );
  }
}
