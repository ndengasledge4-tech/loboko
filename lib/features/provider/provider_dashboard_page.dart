import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_statistic_card.dart';
import '../../shared/widgets/feedback/app_status_badge.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';
import '../../shared/widgets/navigation/app_notification_button.dart';

/// Tableau de bord d’accueil du profil prestataire de démonstration.
class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key, this.showBottomNavigation = true});
  final bool showBottomNavigation;

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  static const _statusPending = MockBookingStatus.pending;
  static const _statusAccepted = MockBookingStatus.accepted;
  static const _statusInProgress = MockBookingStatus.inProgress;
  static const _statusCompleted = MockBookingStatus.completed;

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature sera disponible dans une prochaine étape.'),
        ),
      );
  }

  Future<void> _openRequests() async {
    await Navigator.of(context).pushNamed(AppRoutes.providerRequests);
    if (mounted) setState(() {});
  }

  Future<void> _openMissions() async {
    await Navigator.of(context).pushNamed(AppRoutes.providerMissions);
    if (mounted) setState(() {});
  }

  Future<void> _openServices() async {
    await Navigator.of(context).pushNamed(AppRoutes.providerServices);
    if (mounted) setState(() {});
  }

  Future<void> _openProviderProfile() async {
    await Navigator.of(context).pushNamed(AppRoutes.providerProfile);
    if (mounted) setState(() {});
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).pushNamed(AppRoutes.providerNotifications);
    if (mounted) setState(() {});
  }

  Future<void> _openRequest(String requestId) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.providerRequestDetail, arguments: requestId);
    if (mounted) setState(() {});
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final requests = MockData.providerBookingRequests(
      MockData.providerDashboardProfile.providerId,
    )..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    final recentRequests = requests.take(3).toList();
    int countFor(MockBookingStatus status) =>
        requests.where((request) => request.status == status).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppConstants.screenPadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: AppConstants.spacing4),
                        _buildDemoNotice(),
                        const SizedBox(height: AppConstants.spacing6),
                        Text('Résumé de l’activité', style: AppTextStyles.h2),
                        const SizedBox(height: AppConstants.spacing3),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 640 ? 4 : 2;
                            return GridView.count(
                              crossAxisCount: columns,
                              crossAxisSpacing: AppConstants.spacing3,
                              mainAxisSpacing: AppConstants.spacing3,
                              childAspectRatio: columns == 2 ? 0.8 : 0.9,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                AppStatisticCard(
                                  title: 'Demandes en attente',
                                  value: '${countFor(_statusPending)}',
                                  icon: Icons.hourglass_top_rounded,
                                  iconBackgroundColor:
                                      AppColors.warningBackground,
                                  iconColor: AppColors.warningText,
                                ),
                                AppStatisticCard(
                                  title: 'Réservations acceptées',
                                  value: '${countFor(_statusAccepted)}',
                                  icon: Icons.event_available_outlined,
                                  iconBackgroundColor: AppColors.lightGreen,
                                  iconColor: AppColors.primary,
                                ),
                                AppStatisticCard(
                                  title: 'Missions en cours',
                                  value: '${countFor(_statusInProgress)}',
                                  icon: Icons.handyman_outlined,
                                  iconBackgroundColor: AppColors.infoBackground,
                                  iconColor: AppColors.infoText,
                                ),
                                AppStatisticCard(
                                  title: 'Missions terminées',
                                  value: '${countFor(_statusCompleted)}',
                                  icon: Icons.task_alt_rounded,
                                  iconBackgroundColor:
                                      AppColors.successBackground,
                                  iconColor: AppColors.successText,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppConstants.spacing6),
                        _buildSectionHeading(
                          title: 'Demandes récentes',
                          action: 'Voir tout',
                          onPressed: _openRequests,
                        ),
                        const SizedBox(height: AppConstants.spacing3),
                        if (recentRequests.isEmpty)
                          _buildNoRequests()
                        else
                          ...recentRequests.map(
                            (request) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildRequestCard(context, request),
                            ),
                          ),
                        const SizedBox(height: AppConstants.spacing4),
                        Text('Actions rapides', style: AppTextStyles.h2),
                        const SizedBox(height: AppConstants.spacing3),
                        _buildQuickActions(context),
                        const SizedBox(height: AppConstants.spacing5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? AppBottomNavigation(
              currentIndex: 0,
              onDestinationSelected: (index) {
                if (index == 1) {
                  _openRequests();
                } else if (index == 2) {
                  _openMissions();
                } else if (index == 3) {
                  Navigator.of(context).pushNamed(AppRoutes.providerMessages);
                } else if (index == 4) {
                  _openProviderProfile();
                }
              },
              destinations: [
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
                  badgeCount: MockData.providerUnreadMessageCount,
                ),
                AppNavigationDestination(
                  label: 'Profil',
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final profile = MockData.providerDashboardProfile;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour, ${profile.firstName}', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'Voici un aperçu de votre activité',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spacing2),
        CircleAvatar(
          radius: 23,
          backgroundColor: AppColors.lightGreen,
          child: Icon(
            Icons.handyman_outlined,
            color: AppColors.primary,
            semanticLabel: '${profile.profession}, profil de démonstration',
          ),
        ),
        AppNotificationButton(
          unreadCount: MockData.providerUnreadNotificationCount,
          onPressed: _openNotifications,
        ),
      ],
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing3),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: AppConstants.spacing2),
          Expanded(
            child: Text(
              'Profil et demandes fictifs de démonstration. Aucune demande réelle n’a été transmise.',
              style: AppTextStyles.small.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String action,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.h2)),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, MockBookingRequest request) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _openRequest(request.id),
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
              Text(request.description, style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppConstants.spacing3),
              Wrap(
                spacing: AppConstants.spacing4,
                runSpacing: AppConstants.spacing2,
                children: [
                  _RequestMeta(
                    icon: Icons.location_on_outlined,
                    label: request.neighborhood,
                  ),
                  _RequestMeta(
                    icon: Icons.calendar_today_outlined,
                    label: _formatDate(request.requestedAt),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Consulter la demande  ›',
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

  Widget _buildNoRequests() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Aucune demande à afficher pour le moment.',
        style: AppTextStyles.bodySecondary,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const actions = [
      _DashboardAction('Mes demandes', Icons.inbox_outlined),
      _DashboardAction('Mes missions', Icons.work_outline),
      _DashboardAction(
        'Catalogue de services',
        Icons.home_repair_service_outlined,
      ),
      _DashboardAction('Mes disponibilités', Icons.calendar_month_outlined),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppConstants.spacing3,
            mainAxisSpacing: AppConstants.spacing3,
            mainAxisExtent: 82,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              child: InkWell(
                onTap: () {
                  if (index == 0) {
                    _openRequests();
                  } else if (index == 1) {
                    _openMissions();
                  } else if (index == 2) {
                    _openServices();
                  } else {
                    _showComingSoon(context, action.label);
                  }
                },
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppConstants.cardRadius,
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(action.icon, color: AppColors.primary),
                      const SizedBox(width: AppConstants.spacing2),
                      Expanded(
                        child: Text(
                          action.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardAction {
  const _DashboardAction(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _RequestMeta extends StatelessWidget {
  const _RequestMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.small),
      ],
    );
  }
}
