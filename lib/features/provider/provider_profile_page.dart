import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/constants/app_enums.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../shared/widgets/navigation/app_back_button.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';

/// Profil professionnel du prestataire courant de démonstration.
class ProviderProfilePage extends StatefulWidget {
  const ProviderProfilePage({super.key, this.showBottomNavigation = true});
  final bool showBottomNavigation;

  @override
  State<ProviderProfilePage> createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  MockProviderDashboardProfile get _profile =>
      MockData.providerDashboardProfile;

  Future<void> _editProfile() async {
    final saved = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.providerProfileEdit);
    if (!mounted) return;
    if (saved == true) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour dans la démonstration.'),
        ),
      );
    }
  }

  Future<void> _openServices() async {
    await Navigator.of(context).pushNamed(AppRoutes.providerServices);
  }

  Future<void> _openAvailability() async {
    await Navigator.of(context).pushNamed(AppRoutes.providerAvailability);
  }

  Future<void> _openAccountSettings() async {
    await Navigator.of(context).pushNamed(AppRoutes.providerAccountSettings);
  }

  Future<void> _logout() async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: 'Quitter l’espace prestataire ?',
      message: 'Vous reviendrez à l’écran de connexion de démonstration.',
      confirmLabel: 'Se déconnecter',
    );
    if (!confirmed || !mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
      arguments: UserProfile.provider,
    );
  }

  Future<void> _selectDestination(int index) async {
    if (index == 0 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (index == 1) {
      await Navigator.of(context).pushNamed(AppRoutes.providerRequests);
    } else if (index == 2) {
      await Navigator.of(context).pushNamed(AppRoutes.providerMissions);
    } else if (index == 3) {
      await Navigator.of(context).pushNamed(AppRoutes.providerMessages);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Mon profil'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile.isDemo) ...[
                    _demoNotice(),
                    const SizedBox(height: AppConstants.spacing4),
                  ],
                  Card(
                    child: Padding(
                      padding: AppConstants.cardPadding,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.lightGreen,
                            child: Icon(
                              profile.avatarIcon ?? Icons.person_outline,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacing3),
                          Text(
                            profile.fullName.isEmpty
                                ? 'Nom non renseigné'
                                : profile.fullName,
                            style: AppTextStyles.h2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.profession.trim().isEmpty
                                ? 'Profession non renseignée'
                                : profile.profession,
                            style: AppTextStyles.bodySecondary,
                            textAlign: TextAlign.center,
                          ),
                          if (profile.specialty?.trim().isNotEmpty ??
                              false) ...[
                            const SizedBox(height: 4),
                            Text(
                              profile.specialty!,
                              style: AppTextStyles.small,
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: AppConstants.spacing3),
                          _verificationBadge(profile.verificationStatus),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _sectionCard(
                    title: 'Coordonnées et expérience',
                    children: [
                      _ProfileInfo(
                        icon: Icons.phone_outlined,
                        label: 'Téléphone',
                        value: _optional(profile.phone),
                      ),
                      _ProfileInfo(
                        icon: Icons.email_outlined,
                        label: 'Adresse e-mail',
                        value: _optional(profile.email),
                      ),
                      _ProfileInfo(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Expérience professionnelle',
                        value: _experience(profile),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _sectionCard(
                    title: 'Présentation professionnelle',
                    children: [
                      Text(
                        _optional(profile.description),
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _sectionCard(
                    title: 'Intervention',
                    children: [
                      _ProfileInfo(
                        icon: Icons.location_on_outlined,
                        label: 'Quartiers desservis',
                        value: profile.serviceAreas.isEmpty
                            ? 'Non renseigné'
                            : profile.serviceAreas.join(', '),
                      ),
                      _ProfileInfo(
                        icon: Icons.home_work_outlined,
                        label: 'Mode d’intervention',
                        value: _mode(profile.interventionMode),
                      ),
                      if (profile.interventionMode !=
                          MockCatalogInterventionMode.home)
                        _ProfileInfo(
                          icon: Icons.storefront_outlined,
                          label: 'Adresse de l’atelier',
                          value: _optional(profile.workshopAddress),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing5),
                  Text('Mon espace', style: AppTextStyles.h2),
                  const SizedBox(height: AppConstants.spacing2),
                  _actionTile(
                    icon: Icons.edit_outlined,
                    title: 'Modifier mon profil',
                    subtitle: 'Mettre à jour mes informations professionnelles',
                    onTap: _editProfile,
                  ),
                  _actionTile(
                    icon: Icons.event_available_outlined,
                    title: 'Mes disponibilités',
                    subtitle: 'Gérer vos jours et horaires d’intervention',
                    onTap: _openAvailability,
                  ),
                  _actionTile(
                    icon: Icons.home_repair_service_outlined,
                    title: 'Mes services',
                    subtitle:
                        '${MockData.providerCatalogServices.length} prestation(s) dans le catalogue de démonstration',
                    onTap: _openServices,
                  ),
                  _actionTile(
                    icon: Icons.settings_outlined,
                    title: 'Paramètres du compte',
                    subtitle: 'Sécurité, thème et préférences du compte',
                    onTap: _openAccountSettings,
                  ),
                  _actionTile(
                    icon: Icons.logout,
                    title: 'Se déconnecter',
                    subtitle: 'Quitter cette session de démonstration',
                    onTap: _logout,
                    destructive: true,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? AppBottomNavigation(
              currentIndex: 4,
              onDestinationSelected: _selectDestination,
              destinations: _providerDestinations,
            )
          : null,
    );
  }

  Widget _demoNotice() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppConstants.spacing3),
    decoration: BoxDecoration(
      color: AppColors.lightGreen,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
    ),
    child: Text(
      'Profil de démonstration : ces informations sont conservées localement pendant la session.',
      style: AppTextStyles.small.copyWith(color: AppColors.primary),
    ),
  );

  Widget _verificationBadge(MockProviderVerificationStatus status) {
    final (label, color, background, icon) = switch (status) {
      MockProviderVerificationStatus.unverified => (
        'Non vérifié',
        AppColors.warningText,
        AppColors.warningBackground,
        Icons.info_outline,
      ),
      MockProviderVerificationStatus.pending => (
        'En attente de vérification',
        AppColors.infoText,
        AppColors.infoBackground,
        Icons.hourglass_top_outlined,
      ),
      MockProviderVerificationStatus.verified => (
        'Vérifié par l’administration',
        AppColors.successText,
        AppColors.successBackground,
        Icons.verified_outlined,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing3,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppConstants.badgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppConstants.spacing2),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) => Card(
    child: Padding(
      padding: AppConstants.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppConstants.spacing3),
          ...children,
        ],
      ),
    ),
  );

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) => Card(
    margin: const EdgeInsets.only(bottom: AppConstants.spacing2),
    child: ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: destructive ? AppColors.errorText : AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: destructive ? AppColors.errorText : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.small),
      trailing: const Icon(Icons.chevron_right),
    ),
  );

  String _optional(String? value) =>
      value == null || value.trim().isEmpty ? 'Non renseigné' : value.trim();

  String _experience(MockProviderDashboardProfile profile) {
    if (profile.yearsOfExperience != null) {
      final years = profile.yearsOfExperience!;
      return '$years ${years == 1 ? 'an' : 'ans'}';
    }
    return _optional(profile.experienceLabel);
  }

  String _mode(MockCatalogInterventionMode mode) => switch (mode) {
    MockCatalogInterventionMode.home => 'À domicile',
    MockCatalogInterventionMode.workshop => 'En atelier',
    MockCatalogInterventionMode.both => 'À domicile et en atelier',
  };
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

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppConstants.spacing3),
    child: Row(
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
    ),
  );
}
