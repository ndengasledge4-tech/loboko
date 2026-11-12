import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/helpers/app_formatters.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/buttons/app_secondary_button.dart';
import '../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/feedback/app_status_badge.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Écran de détails d'une réservation pour le Client.
class ClientBookingDetailPage extends StatefulWidget {
  const ClientBookingDetailPage({super.key, required this.bookingId});

  final String? bookingId;

  @override
  State<ClientBookingDetailPage> createState() =>
      _ClientBookingDetailPageState();
}

class _ClientBookingDetailPageState extends State<ClientBookingDetailPage> {
  MockBookingRequest? get _reservation {
    final request = widget.bookingId == null
        ? null
        : MockData.bookingRequestById(widget.bookingId!);
    return request?.clientId == 'demo_client' ? request : null;
  }

  MockProvider? get _provider {
    final res = _reservation;
    if (res == null) return null;
    for (final p in MockData.popularProviders) {
      if (p.id == res.providerId) return p;
    }
    return null;
  }

  Future<void> _cancelBooking() async {
    final res = _reservation;
    if (res == null) return;

    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: 'Annuler la réservation ?',
      message:
          'Êtes-vous sûr de vouloir annuler votre demande pour "${res.serviceName}" ?',
      confirmLabel: 'Annuler la demande',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    final cancelled = MockData.cancelBookingRequest(
      id: res.id,
      clientId: 'demo_client',
    );
    if (!cancelled) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Votre réservation a été annulée avec succès.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _contactProvider() {
    final providerId = _reservation?.providerId ?? _provider?.id ?? 'prov_1';
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.clientChat, arguments: providerId);
  }

  @override
  Widget build(BuildContext context) {
    final res = _reservation;

    if (res == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(leading: const AppBackButton()),
        body: AppEmptyState(
          title: 'Réservation introuvable',
          message: 'Cette réservation n’existe pas ou a été retirée.',
          icon: Icons.event_busy_outlined,
          actionLabel: 'Retour à l’accueil',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final canCancel =
        res.status == MockBookingStatus.pending ||
        res.status == MockBookingStatus.accepted;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Détails de la réservation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Carte principale
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
                                  res.serviceName,
                                  style: AppTextStyles.h2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppStatusBadge(status: res.status.label),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          const Divider(),
                          const SizedBox(height: AppConstants.spacing4),

                          _DetailRow(
                            icon: Icons.person_outline,
                            label: 'Prestataire',
                            value: res.providerName,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.description_outlined,
                            label: 'Description du besoin',
                            value: res.description,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date & heure',
                            value:
                                '${AppFormatters.formatDate(res.desiredDate ?? res.createdAt)} · ${res.timeSlot ?? 'Non précisé'}',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.home_work_outlined,
                            label: 'Mode d’intervention',
                            value: res.locationType,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Lieu d’intervention',
                            value: res.location,
                          ),
                          const SizedBox(height: 12),
                          if (res.estimatedPrice != null)
                            _DetailRow(
                              icon: Icons.payments_outlined,
                              label: 'Tarif indicatif',
                              value: AppFormatters.formatPrice(
                                res.estimatedPrice!,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing6),

                  // Actions
                  AppPrimaryButton(
                    label: 'Contacter le prestataire',
                    icon: Icons.chat_bubble_outline,
                    onPressed: _contactProvider,
                  ),
                  if (canCancel) ...[
                    const SizedBox(height: AppConstants.spacing3),
                    AppSecondaryButton(
                      label: 'Annuler la réservation',
                      icon: Icons.cancel_outlined,
                      onPressed: _cancelBooking,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.small),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.label),
          ],
        ),
      ],
    );
  }
}
