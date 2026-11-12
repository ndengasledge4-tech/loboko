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

enum _MissionFilter { all, toStart, inProgress, completed, cancelled }

/// Missions issues de la source partagée de démonstration.
class ProviderMissionsPage extends StatefulWidget {
  const ProviderMissionsPage({super.key, this.showBottomNavigation = true});
  final bool showBottomNavigation;

  @override
  State<ProviderMissionsPage> createState() => _ProviderMissionsPageState();
}

class _ProviderMissionsPageState extends State<ProviderMissionsPage> {
  _MissionFilter _filter = _MissionFilter.all;

  List<MockBookingRequest> get _missions =>
      MockData.providerBookingRequests(
            MockData.providerDashboardProfile.providerId,
          )
          .where((request) => request.status != MockBookingStatus.pending)
          .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  List<MockBookingRequest> get _visibleMissions => _missions
      .where(
        (request) => switch (_filter) {
          _MissionFilter.all => true,
          _MissionFilter.toStart =>
            request.status == MockBookingStatus.accepted,
          _MissionFilter.inProgress =>
            request.status == MockBookingStatus.inProgress,
          _MissionFilter.completed =>
            request.status == MockBookingStatus.completed,
          _MissionFilter.cancelled =>
            request.status == MockBookingStatus.cancelled,
        },
      )
      .toList();

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  Future<void> _openDetail(MockBookingRequest request) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.providerMissionDetail, arguments: request.id);
    if (mounted) setState(() {});
  }

  void _selectDestination(int index) {
    if (index == 0 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (index == 1) {
      Navigator.of(context).pushNamed(AppRoutes.providerRequests);
    } else if (index == 3) {
      Navigator.of(context).pushNamed(AppRoutes.providerMessages);
    } else if (index == 4) {
      Navigator.of(context).pushNamed(AppRoutes.providerProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final missions = _visibleMissions;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBackButton(),
                      const SizedBox(height: AppConstants.spacing2),
                      Text('Missions', style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text(
                        'Suivez les interventions acceptées et leur progression.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppConstants.spacing3),
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
                          'Données de démonstration : ces missions sont fictives et conservées localement en mémoire.',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _MissionFilter.values
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppFilterChip(
                          label: '${_label(filter)} (${_count(filter)})',
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Expanded(
              child: missions.isEmpty
                  ? AppEmptyState(
                      title: _emptyTitle,
                      message:
                          'Aucune mission ne correspond à ce filtre dans les données de démonstration.',
                      icon: Icons.work_outline,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: missions.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppConstants.spacing3),
                      itemBuilder: (context, index) => Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: _missionCard(missions[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? AppBottomNavigation(
              currentIndex: 2,
              onDestinationSelected: _selectDestination,
              destinations: _providerDestinations,
            )
          : null,
    );
  }

  int _count(_MissionFilter filter) => _missions
      .where(
        (request) => switch (filter) {
          _MissionFilter.all => true,
          _MissionFilter.toStart =>
            request.status == MockBookingStatus.accepted,
          _MissionFilter.inProgress =>
            request.status == MockBookingStatus.inProgress,
          _MissionFilter.completed =>
            request.status == MockBookingStatus.completed,
          _MissionFilter.cancelled =>
            request.status == MockBookingStatus.cancelled,
        },
      )
      .length;

  String _label(_MissionFilter filter) => switch (filter) {
    _MissionFilter.all => 'Toutes',
    _MissionFilter.toStart => 'À démarrer',
    _MissionFilter.inProgress => 'En cours',
    _MissionFilter.completed => 'Terminées',
    _MissionFilter.cancelled => 'Annulées',
  };

  String get _emptyTitle => switch (_filter) {
    _MissionFilter.all => 'Aucune mission disponible',
    _MissionFilter.toStart => 'Aucune mission à démarrer',
    _MissionFilter.inProgress => 'Aucune mission en cours',
    _MissionFilter.completed => 'Aucune mission terminée',
    _MissionFilter.cancelled => 'Aucune mission annulée',
  };

  Widget _missionCard(MockBookingRequest request) => Card(
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
                const SizedBox(width: 8),
                AppStatusBadge(status: request.status.label),
              ],
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(request.serviceName, style: AppTextStyles.label),
            const SizedBox(height: AppConstants.spacing3),
            Wrap(
              spacing: AppConstants.spacing4,
              runSpacing: AppConstants.spacing2,
              children: [
                _MissionInfo(
                  icon: Icons.location_on_outlined,
                  label: request.neighborhood,
                ),
                _MissionInfo(
                  icon: Icons.event_outlined,
                  label: request.desiredDate == null
                      ? 'Date souhaitée non précisée'
                      : _date(request.desiredDate!),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing3),
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

const _providerDestinations = [
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

class _MissionInfo extends StatelessWidget {
  const _MissionInfo({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Flexible(child: Text(label, style: AppTextStyles.small)),
    ],
  );
}
