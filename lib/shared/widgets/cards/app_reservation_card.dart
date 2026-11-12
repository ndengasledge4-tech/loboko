import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../helpers/app_formatters.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../feedback/app_status_badge.dart';

/// Carte de réservation réutilisable de LOBOKO.
class AppReservationCard extends StatelessWidget {
  const AppReservationCard({
    super.key,
    required this.serviceName,
    required this.personName,
    required this.date,
    required this.status,
    required this.onTap,
    this.location,
    this.price,
  });

  final String serviceName;
  final String personName;
  final DateTime date;
  final String status;
  final VoidCallback onTap;
  final String? location;
  final double? price;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: AppConstants.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      serviceName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppStatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AppConstants.spacing3),
              _InfoRow(
                icon: Icons.person_outline,
                text: personName,
              ),
              const SizedBox(height: AppConstants.spacing2),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: AppFormatters.formatDate(date),
              ),
              if (location != null && location!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing2),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: location!,
                ),
              ],
              if (price != null) ...[
                const SizedBox(height: AppConstants.spacing3),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppFormatters.formatPrice(price!),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AppConstants.smallIconSize,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppConstants.spacing2),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySecondary,
          ),
        ),
      ],
    );
  }
}
