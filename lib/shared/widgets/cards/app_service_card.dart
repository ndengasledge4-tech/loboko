import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../helpers/app_formatters.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Carte de présentation d'une prestation de LOBOKO.
class AppServiceCard extends StatelessWidget {
  const AppServiceCard({
    super.key,
    required this.title,
    required this.category,
    required this.price,
    required this.onTap,
    this.description,
    this.priceUnit = 'FCFA',
    this.image,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final String title;
  final String category;
  final double price;
  final VoidCallback onTap;
  final String? description;
  final String priceUnit;
  final ImageProvider? image;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              Stack(
                children: [
                  Image(
                    image: image!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  if (onFavoriteTap != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'Retirer des favoris'
                            : 'Ajouter aux favoris',
                        onPressed: onFavoriteTap,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white,
                        ),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.errorText
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: AppConstants.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3,
                  ),
                  if (description != null &&
                      description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacing3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'À partir de',
                        style: AppTextStyles.small,
                      ),
                      Flexible(
                        child: Text(
                          AppFormatters.formatPrice(price, unit: priceUnit),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
