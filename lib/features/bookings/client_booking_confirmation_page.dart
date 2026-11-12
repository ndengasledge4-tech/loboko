import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/feedback/app_error_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

class ClientBookingConfirmationPage extends StatelessWidget {
  const ClientBookingConfirmationPage({super.key, required this.bookingId});

  final String? bookingId;

  MockBookingRequest? get _booking {
    return bookingId == null ? null : MockData.bookingRequestById(bookingId!);
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: const AppBackButton(),
          backgroundColor: AppColors.background,
        ),
        body: AppErrorState(
          title: 'Demande introuvable',
          message:
              'Aucune demande de démonstration ne correspond à cette référence.',
          retryLabel: 'Retour à l’accueil',
          onRetry: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.clientHome, (_) => false),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('Demande enregistrée', style: AppTextStyles.h3),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: AppConstants.screenPadding,
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          color: AppColors.lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        'Votre demande est enregistrée',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: AppConstants.spacing2),
                      Text(
                        'Cette demande a été ajoutée au stockage local de démonstration. Elle n’a pas été transmise au prestataire.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppConstants.spacing5),
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardRadius,
                          ),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: AppConstants.cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ConfirmationRow(
                                label: 'Référence',
                                value: booking.id,
                              ),
                              const Divider(
                                height: 20,
                                color: AppColors.divider,
                              ),
                              _ConfirmationRow(
                                label: 'Prestataire',
                                value: booking.providerName,
                              ),
                              const SizedBox(height: 10),
                              _ConfirmationRow(
                                label: 'Prestation',
                                value: booking.serviceName,
                              ),
                              const SizedBox(height: 10),
                              _ConfirmationRow(
                                label: 'Statut',
                                value: booking.status.label,
                              ),
                              if (booking.estimatedPrice != null) ...[
                                const SizedBox(height: 10),
                                _ConfirmationRow(
                                  label: 'Tarif indicatif',
                                  value:
                                      '${booking.estimatedPrice!.toStringAsFixed(0)} FCFA',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      AppPrimaryButton(
                        label: 'Retour à l’accueil',
                        icon: Icons.home_outlined,
                        onPressed: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.clientHome,
                              (_) => false,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing3),
                      Text(
                        'Le statut initial « En attente » signifie qu’aucune acceptation du prestataire n’a encore été enregistrée.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 112, child: Text(label, style: AppTextStyles.small)),
      Expanded(child: Text(value, style: AppTextStyles.label)),
    ],
  );
}
