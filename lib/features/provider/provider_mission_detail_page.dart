import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../shared/widgets/feedback/app_error_state.dart';
import '../../shared/widgets/feedback/app_status_badge.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Fiche dynamique d'une mission de démonstration.
class ProviderMissionDetailPage extends StatefulWidget {
  const ProviderMissionDetailPage({super.key, required this.requestId});

  final String? requestId;

  @override
  State<ProviderMissionDetailPage> createState() =>
      _ProviderMissionDetailPageState();
}

class _ProviderMissionDetailPageState extends State<ProviderMissionDetailPage> {
  MockBookingRequest? get _request {
    final request = widget.requestId == null
        ? null
        : MockData.bookingRequestById(widget.requestId!);
    return request?.providerId == MockData.providerDashboardProfile.providerId
        ? request
        : null;
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _advanceMission(MockBookingRequest request) async {
    final isStarting = request.status == MockBookingStatus.accepted;
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: isStarting
          ? 'Démarrer cette mission ?'
          : 'Terminer cette mission ?',
      message: isStarting
          ? 'Le statut passera à « En cours » dans les données de démonstration.'
          : 'Le statut passera à « Terminée » dans les données de démonstration.',
      confirmLabel: isStarting ? 'Démarrer' : 'Terminer',
    );
    if (!confirmed || !mounted) return;
    final providerId = MockData.providerDashboardProfile.providerId;
    final updated = isStarting
        ? MockData.startBookingMission(id: request.id, providerId: providerId)
        : MockData.completeBookingMission(
            id: request.id,
            providerId: providerId,
          );
    if (!updated) return;
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isStarting
                ? 'Mission démarrée dans la démonstration.'
                : 'Mission terminée dans la démonstration.',
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
        title: const Text('Détail de la mission'),
      ),
      body: request == null
          ? AppErrorState(
              title: 'Mission introuvable',
              message:
                  'Cette mission ne figure pas dans les données de démonstration.',
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.spacing3),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(
                              AppConstants.cardRadius,
                            ),
                          ),
                          child: Text(
                            'Données de démonstration : informations fictives conservées localement en mémoire.',
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
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
                                    const SizedBox(width: 8),
                                    AppStatusBadge(
                                      status: request.status.label,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Client fictif',
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Divider(height: AppConstants.spacing6),
                                _detailLine(
                                  Icons.home_repair_service_outlined,
                                  'Service demandé',
                                  request.serviceName,
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  Icons.description_outlined,
                                  'Description du besoin',
                                  request.description,
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  Icons.location_on_outlined,
                                  'Lieu d’intervention',
                                  '${request.locationType} · ${request.location}',
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  Icons.event_outlined,
                                  'Date souhaitée',
                                  request.desiredDate == null
                                      ? 'Non précisée'
                                      : _formatDate(request.desiredDate!),
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  Icons.schedule_outlined,
                                  'Horaire souhaité',
                                  request.timeSlot ?? 'Non précisé',
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  Icons.calendar_today_outlined,
                                  'Demande créée le',
                                  _formatDate(request.requestedAt),
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                _detailLine(
                                  Icons.tag_outlined,
                                  'Identifiant de démonstration',
                                  request.id,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (request.status == MockBookingStatus.accepted ||
                            request.status == MockBookingStatus.inProgress) ...[
                          const SizedBox(height: AppConstants.spacing4),
                          AppPrimaryButton(
                            label: request.status == MockBookingStatus.accepted
                                ? 'Démarrer la mission'
                                : 'Marquer comme terminée',
                            icon: request.status == MockBookingStatus.accepted
                                ? Icons.play_arrow
                                : Icons.check,
                            onPressed: () => _advanceMission(request),
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

  Widget _detailLine(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: AppConstants.spacing3),
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
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.body),
          ],
        ),
      ),
    ],
  );
}
