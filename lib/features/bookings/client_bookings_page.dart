import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_filter_chip.dart';

enum _BookingFilter { all, pending, accepted, inProgress, completed, cancelled }

/// Onglet Réservations, alimenté par le stockage local de démonstration.
class ClientBookingsPage extends StatefulWidget {
  const ClientBookingsPage({super.key, this.onRequestSelected});

  /// Fournit l'identifiant pour un futur écran de détail.
  final ValueChanged<String>? onRequestSelected;

  @override
  State<ClientBookingsPage> createState() => _ClientBookingsPageState();
}

class _ClientBookingsPageState extends State<ClientBookingsPage> {
  _BookingFilter _filter = _BookingFilter.all;

  List<MockBookingRequest> get _allRequests {
    final requests = MockData.clientBookingRequests('demo_client');
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return requests;
  }

  List<MockBookingRequest> get _filteredRequests =>
      _allRequests.where((request) => _matchesFilter(request.status)).toList();

  bool _matchesFilter(MockBookingStatus status, [_BookingFilter? filter]) {
    switch (filter ?? _filter) {
      case _BookingFilter.all:
        return true;
      case _BookingFilter.pending:
        return status == MockBookingStatus.pending;
      case _BookingFilter.accepted:
        return status == MockBookingStatus.accepted;
      case _BookingFilter.inProgress:
        return status == MockBookingStatus.inProgress;
      case _BookingFilter.completed:
        return status == MockBookingStatus.completed;
      case _BookingFilter.cancelled:
        return status == MockBookingStatus.cancelled;
    }
  }

  String _filterLabel(_BookingFilter filter) => switch (filter) {
    _BookingFilter.all => 'Toutes',
    _BookingFilter.pending => 'En attente',
    _BookingFilter.accepted => 'Acceptées',
    _BookingFilter.inProgress => 'En cours',
    _BookingFilter.completed => 'Terminées',
    _BookingFilter.cancelled => 'Annulées',
  };

  String get _emptyTitle => switch (_filter) {
    _BookingFilter.all => 'Aucune demande pour le moment',
    _BookingFilter.pending => 'Aucune demande en attente',
    _BookingFilter.accepted => 'Aucune demande acceptée',
    _BookingFilter.inProgress => 'Aucune demande en cours',
    _BookingFilter.completed => 'Aucune demande terminée',
    _BookingFilter.cancelled => 'Aucune demande annulée',
  };

  int _countFor(_BookingFilter filter) {
    return _allRequests
        .where((request) => _matchesFilter(request.status, filter))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final allRequests = _allRequests;
    final requests = _filteredRequests;
    final hasRequests = allRequests.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mes réservations', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'Retrouvez et suivez vos demandes de services',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppConstants.spacing3),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonRadius,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demandes de démonstration conservées uniquement pendant cette session.',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasRequests) ...[
                const SizedBox(height: AppConstants.spacing3),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _BookingFilter.values.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _BookingFilter.values[index];
                      return AppFilterChip(
                        label: '${_filterLabel(filter)} (${_countFor(filter)})',
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.spacing2),
              ],
            ],
          ),
        ),
        Expanded(
          child: !hasRequests
              ? const AppEmptyState(
                  title: 'Aucune demande pour le moment',
                  message:
                      'Vos demandes de service envoyées pendant cette session apparaîtront ici.',
                  icon: Icons.event_note_outlined,
                )
              : requests.isEmpty
              ? AppEmptyState(
                  title: _emptyTitle,
                  message:
                      'Aucune demande ne correspond à ce filtre. Essayez un autre statut.',
                  icon: Icons.filter_alt_off_outlined,
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => setState(() {}),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: requests.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) => _BookingRequestCard(
                      request: requests[index],
                      onTap: () =>
                          widget.onRequestSelected?.call(requests[index].id),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  const _BookingRequestCard({required this.request, required this.onTap});

  final MockBookingRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == MockBookingStatus.pending;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppConstants.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProviderAvatar(providerId: request.providerId),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.providerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.serviceName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RequestStatusBadge(status: request.status.label),
                ],
              ),
              if (isPending) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningBackground,
                    borderRadius: BorderRadius.circular(
                      AppConstants.buttonRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.hourglass_top,
                        size: 16,
                        color: AppColors.warningText,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'En attente de la réponse du prestataire',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.warningText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _CardInfo(
                icon: Icons.event_available_outlined,
                label: 'Date souhaitée',
                value: request.desiredDate == null
                    ? 'Non précisée'
                    : '${_formatDate(request.desiredDate!)} · ${request.timeSlot ?? 'Horaire non précisé'}',
              ),
              const SizedBox(height: 7),
              _CardInfo(
                icon: Icons.schedule_outlined,
                label: 'Demande créée',
                value: _formatDateTime(request.createdAt),
              ),
              const SizedBox(height: 7),
              _CardInfo(
                icon: Icons.location_on_outlined,
                label: request.locationType,
                value: request.location,
              ),
              if (request.estimatedPrice != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Tarif indicatif · ${request.estimatedPrice!.toStringAsFixed(0)} FCFA',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Réf. ${_shortId(request.id)}',
                      style: AppTextStyles.small,
                    ),
                  ),
                  Text(
                    'Voir la demande',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _shortId(String id) =>
      id.length <= 17 ? id : '${id.substring(0, 13)}…';

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _formatDateTime(DateTime date) =>
      '${_formatDate(date)} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.network(
      _portraitFor(providerId),
      width: 52,
      height: 52,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 52,
        height: 52,
        color: AppColors.lightGreen,
        child: const Icon(Icons.person, color: AppColors.primary),
      ),
    ),
  );

  String _portraitFor(String id) {
    final index =
        int.tryParse(id.replaceAll(RegExp(r'\D'), '')) ??
        id.hashCode.abs() % 10;
    return 'https://images.unsplash.com/photo-${index.isEven ? '1500648767791-00dcc994a43e' : '1534528741775-53994a69daeb'}?auto=format&fit=crop&w=120&h=120&q=80';
  }
}

class _RequestStatusBadge extends StatelessWidget {
  const _RequestStatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final background = normalized.contains('attente')
        ? AppColors.warningBackground
        : normalized.contains('accept') || normalized.contains('termin')
        ? AppColors.successBackground
        : normalized.contains('cours')
        ? AppColors.infoBackground
        : normalized.contains('annul')
        ? AppColors.errorBackground
        : AppColors.disabledBackground;
    final foreground = normalized.contains('attente')
        ? AppColors.warningText
        : normalized.contains('accept') || normalized.contains('termin')
        ? AppColors.successText
        : normalized.contains('cours')
        ? AppColors.infoText
        : normalized.contains('annul')
        ? AppColors.errorText
        : AppColors.disabledText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppConstants.badgeRadius),
      ),
      child: Text(
        status,
        style: AppTextStyles.small.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 17, color: AppColors.textSecondary),
      const SizedBox(width: 7),
      SizedBox(width: 110, child: Text(label, style: AppTextStyles.small)),
      Expanded(
        child: Text(
          value,
          style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
        ),
      ),
    ],
  );
}
