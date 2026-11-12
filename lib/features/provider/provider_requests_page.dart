import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/feedback/app_status_badge.dart';
import '../../shared/widgets/navigation/app_back_button.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';
import '../../shared/widgets/navigation/app_filter_chip.dart';

enum _ProviderRequestFilter {
  all,
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

/// Liste filtrable des demandes de démonstration reçues par le prestataire.
class ProviderRequestsPage extends StatefulWidget {
  const ProviderRequestsPage({super.key, this.showBottomNavigation = true});
  final bool showBottomNavigation;

  @override
  State<ProviderRequestsPage> createState() => _ProviderRequestsPageState();
}

class _ProviderRequestsPageState extends State<ProviderRequestsPage> {
  _ProviderRequestFilter _filter = _ProviderRequestFilter.all;

  List<MockBookingRequest> get _allRequests => MockData.providerBookingRequests(
    MockData.providerDashboardProfile.providerId,
  )..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  MockBookingStatus? get _selectedStatus => switch (_filter) {
    _ProviderRequestFilter.all => null,
    _ProviderRequestFilter.pending => MockBookingStatus.pending,
    _ProviderRequestFilter.accepted => MockBookingStatus.accepted,
    _ProviderRequestFilter.inProgress => MockBookingStatus.inProgress,
    _ProviderRequestFilter.completed => MockBookingStatus.completed,
    _ProviderRequestFilter.cancelled => MockBookingStatus.cancelled,
  };

  List<MockBookingRequest> get _filteredRequests {
    final status = _selectedStatus;
    return _allRequests
        .where((request) => status == null || request.status == status)
        .toList();
  }

  String _formatDate(DateTime date, {bool includeTime = false}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final dateText = '$day/$month/${date.year}';
    if (!includeTime) return dateText;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$dateText à $hour:$minute';
  }

  Future<void> _openDetail(MockBookingRequest request) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.providerRequestDetail, arguments: request.id);
    if (mounted) setState(() {});
  }

  Future<void> _selectDestination(int index) async {
    if (index == 0 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (index == 2) {
      await Navigator.of(context).pushNamed(AppRoutes.providerMissions);
      if (mounted) setState(() {});
    } else if (index == 3) {
      await Navigator.of(context).pushNamed(AppRoutes.providerMessages);
      if (mounted) setState(() {});
    } else if (index == 4) {
      await Navigator.of(context).pushNamed(AppRoutes.providerProfile);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filteredRequests;
    final allRequests = _allRequests;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBackButton(),
                      const SizedBox(height: AppConstants.spacing2),
                      Text('Demandes', style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text(
                        'Consultez et traitez les demandes de service.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppConstants.spacing3),
                      _demoNotice(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: _ProviderRequestFilter.values.map((filter) {
                  final label = _filterLabel(filter);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppFilterChip(
                      label: '$label (${_countFor(filter, allRequests)})',
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Expanded(
              child: requests.isEmpty
                  ? AppEmptyState(
                      title: _filter == _ProviderRequestFilter.all
                          ? 'Aucune demande disponible'
                          : _emptyTitle,
                      message: _filter == _ProviderRequestFilter.all
                          ? 'Les demandes apparaîtront ici lorsqu’elles seront disponibles dans la démonstration.'
                          : 'Aucune demande ne correspond à ce statut dans les données de démonstration.',
                      icon: Icons.inbox_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: requests.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppConstants.spacing3),
                      itemBuilder: (context, index) => Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: _requestCard(requests[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? AppBottomNavigation(
              currentIndex: 1,
              onDestinationSelected: _selectDestination,
              destinations: _providerDestinations,
            )
          : null,
    );
  }

  int _countFor(
    _ProviderRequestFilter filter,
    List<MockBookingRequest> requests,
  ) {
    final status = switch (filter) {
      _ProviderRequestFilter.all => null,
      _ProviderRequestFilter.pending => MockBookingStatus.pending,
      _ProviderRequestFilter.accepted => MockBookingStatus.accepted,
      _ProviderRequestFilter.inProgress => MockBookingStatus.inProgress,
      _ProviderRequestFilter.completed => MockBookingStatus.completed,
      _ProviderRequestFilter.cancelled => MockBookingStatus.cancelled,
    };
    return requests
        .where((request) => status == null || request.status == status)
        .length;
  }

  String _filterLabel(_ProviderRequestFilter filter) => switch (filter) {
    _ProviderRequestFilter.all => 'Toutes',
    _ProviderRequestFilter.pending => 'En attente',
    _ProviderRequestFilter.accepted => 'Acceptées',
    _ProviderRequestFilter.inProgress => 'En cours',
    _ProviderRequestFilter.completed => 'Terminées',
    _ProviderRequestFilter.cancelled => 'Annulées',
  };

  String get _emptyTitle => switch (_filter) {
    _ProviderRequestFilter.all => 'Aucune demande disponible',
    _ProviderRequestFilter.pending => 'Aucune demande en attente',
    _ProviderRequestFilter.accepted => 'Aucune demande acceptée',
    _ProviderRequestFilter.inProgress => 'Aucune demande en cours',
    _ProviderRequestFilter.completed => 'Aucune demande terminée',
    _ProviderRequestFilter.cancelled => 'Aucune demande annulée',
  };

  Widget _demoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing3),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Text(
        'Données de démonstration : ces demandes sont fictives et n’ont pas été transmises à un prestataire réel.',
        style: AppTextStyles.small.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _requestCard(MockBookingRequest request) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _openDetail(request),
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
                    child: Text(request.clientName, style: AppTextStyles.h3),
                  ),
                  const SizedBox(width: AppConstants.spacing2),
                  AppStatusBadge(status: request.status.label),
                ],
              ),
              const SizedBox(height: AppConstants.spacing2),
              Text(request.serviceName, style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                request.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppConstants.spacing3),
              Wrap(
                spacing: AppConstants.spacing4,
                runSpacing: AppConstants.spacing2,
                children: [
                  _RequestInfo(
                    icon: Icons.location_on_outlined,
                    label: request.neighborhood,
                  ),
                  _RequestInfo(
                    icon: Icons.schedule_outlined,
                    label: request.desiredDate == null
                        ? 'Date souhaitée non précisée'
                        : _formatDate(request.desiredDate!),
                  ),
                  if (request.timeSlot != null)
                    _RequestInfo(
                      icon: Icons.access_time_outlined,
                      label: request.timeSlot!,
                    ),
                  _RequestInfo(
                    icon: Icons.edit_calendar_outlined,
                    label:
                        'Demande créée le ${_formatDate(request.requestedAt, includeTime: true)}',
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Voir le détail  ›',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _providerDestinations = [
    AppNavigationDestination(
      label: 'Accueil',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    AppNavigationDestination(
      label: 'Demandes',
      icon: Icons.inbox_outlined,
      activeIcon: Icons.inbox,
    ),
    AppNavigationDestination(
      label: 'Missions',
      icon: Icons.work_outline,
      activeIcon: Icons.work,
    ),
    AppNavigationDestination(
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
    ),
    AppNavigationDestination(
      label: 'Profil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];
}

class _RequestInfo extends StatelessWidget {
  const _RequestInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.small,
          ),
        ),
      ],
    );
  }
}
