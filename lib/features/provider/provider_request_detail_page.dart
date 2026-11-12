import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/buttons/app_secondary_button.dart';
import '../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../shared/widgets/feedback/app_error_state.dart';
import '../../shared/widgets/feedback/app_status_badge.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Détail dynamique d’une demande issue du jeu de démonstration partagé.
class ProviderRequestDetailPage extends StatefulWidget {
  const ProviderRequestDetailPage({super.key, required this.requestId});

  final String? requestId;

  @override
  State<ProviderRequestDetailPage> createState() =>
      _ProviderRequestDetailPageState();
}

class _ProviderRequestDetailPageState extends State<ProviderRequestDetailPage> {
  MockBookingRequest? get _request {
    final request = widget.requestId == null
        ? null
        : MockData.bookingRequestById(widget.requestId!);
    return request?.providerId == MockData.providerDashboardProfile.providerId
        ? request
        : null;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} à $hour:$minute';
  }

  Future<void> _changeStatus({required bool accept}) async {
    final request = _request;
    if (request == null || request.status != MockBookingStatus.pending) {
      return;
    }

    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: accept ? 'Accepter cette demande ?' : 'Refuser cette demande ?',
      message: accept
          ? 'La demande passera au statut « Acceptée » dans les données de démonstration.'
          : 'La demande passera au statut « Annulée » dans les données de démonstration.',
      confirmLabel: accept ? 'Accepter' : 'Refuser',
      isDestructive: !accept,
    );
    if (!confirmed || !mounted) return;

    final providerId = MockData.providerDashboardProfile.providerId;
    final updated = accept
        ? MockData.acceptBookingRequest(id: request.id, providerId: providerId)
        : MockData.refuseBookingRequest(id: request.id, providerId: providerId);
    if (!updated) return;

    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Demande acceptée dans la démonstration.'
                : 'Demande annulée dans la démonstration.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Détail de la demande'),
      ),
      body: request == null
          ? AppErrorState(
              title: 'Demande introuvable',
              message:
                  'Cette demande n’est pas disponible dans la démonstration.',
              retryLabel: 'Retour',
              onRetry: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            )
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: AppConstants.screenPadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _demoNotice(),
                        const SizedBox(height: AppConstants.spacing4),
                        Card(
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
                                        request.clientName,
                                        style: AppTextStyles.h2,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppConstants.spacing2,
                                    ),
                                    AppStatusBadge(
                                      status: request.status.label,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.spacing2),
                                Text(
                                  'Client fictif',
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Divider(height: AppConstants.spacing6),
                                _detailLine(
                                  icon: Icons.home_repair_service_outlined,
                                  label: 'Service demandé',
                                  value: request.serviceName,
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  icon: Icons.description_outlined,
                                  label: 'Description du besoin',
                                  value: request.description,
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  icon: Icons.location_on_outlined,
                                  label: 'Lieu d’intervention',
                                  value:
                                      '${request.locationType} · ${request.location}',
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  icon: Icons.event_outlined,
                                  label: 'Date souhaitée',
                                  value: request.desiredDate == null
                                      ? 'Non précisée'
                                      : _formatDate(request.desiredDate!),
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  icon: Icons.schedule_outlined,
                                  label: 'Horaire souhaité',
                                  value: request.timeSlot ?? 'Non précisé',
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Demande créée le',
                                  value: _formatDate(request.requestedAt),
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  icon: Icons.tag_outlined,
                                  label: 'Identifiant de démonstration',
                                  value: request.id,
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  icon: Icons.info_outline,
                                  label: 'Informations complémentaires',
                                  value:
                                      'Aucune autre information n’a été fournie.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (request.status == MockBookingStatus.pending) ...[
                          const SizedBox(height: AppConstants.spacing4),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 360) {
                                return Column(
                                  children: [
                                    AppPrimaryButton(
                                      label: 'Accepter la demande',
                                      icon: Icons.check,
                                      onPressed: () =>
                                          _changeStatus(accept: true),
                                    ),
                                    const SizedBox(
                                      height: AppConstants.spacing2,
                                    ),
                                    AppSecondaryButton(
                                      label: 'Refuser la demande',
                                      icon: Icons.close,
                                      onPressed: () =>
                                          _changeStatus(accept: false),
                                    ),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(
                                    child: AppPrimaryButton(
                                      label: 'Accepter',
                                      icon: Icons.check,
                                      onPressed: () =>
                                          _changeStatus(accept: true),
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacing3),
                                  Expanded(
                                    child: AppSecondaryButton(
                                      label: 'Refuser',
                                      icon: Icons.close,
                                      onPressed: () =>
                                          _changeStatus(accept: false),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: AppConstants.spacing5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _demoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing3),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Text(
        'Données de démonstration : cette demande est fictive et sa mise à jour reste locale.',
        style: AppTextStyles.small.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _detailLine({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppConstants.spacing2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.label),
            ],
          ),
        ),
      ],
    );
  }
}
