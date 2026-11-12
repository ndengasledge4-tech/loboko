import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app.dart';
import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/constants/app_enums.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../shared/widgets/dialogs/app_info_dialog.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Page de paramètres du compte Prestataire LOBOKO.
class ProviderAccountSettingsPage extends StatefulWidget {
  const ProviderAccountSettingsPage({super.key});

  @override
  State<ProviderAccountSettingsPage> createState() =>
      _ProviderAccountSettingsPageState();
}

class _ProviderAccountSettingsPageState
    extends State<ProviderAccountSettingsPage> {
  bool _notificationsEnabled = true;

  Future<void> _setTheme(bool isDark) async {
    try {
      final saved = await LobokoApp.toggleTheme(
        isDark ? ThemeMode.dark : ThemeMode.light,
      );
      if (!mounted) return;
      if (!saved) _showThemeSaveError();
      setState(() {});
    } on PlatformException {
      if (mounted) _showThemeSaveError();
    }
  }

  void _showThemeSaveError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Le thème est appliqué, mais n’a pas pu être enregistré localement.',
        ),
      ),
    );
  }

  void _onChangePassword() {
    Navigator.of(context).pushNamed(AppRoutes.clientChangePassword);
  }

  void _onShowSecurityInfo() {
    AppInfoDialog.show(
      context: context,
      title: 'Sécurité de votre compte',
      message:
          '• Profil : Prestataire LOBOKO\n'
          '• Connexion sécurisée locale\n'
          '• Statut : ${MockData.providerDashboardProfile.verificationStatus == MockProviderVerificationStatus.verified ? "Vérifié" : "Non vérifié"}\n'
          '• Session active à Brazzaville',
    );
  }

  Future<void> _onDeleteAccount() async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: 'Supprimer mon compte ?',
      message:
          'En mode démonstration, cette action réinitialise votre session locale prestataire et supprime l’historique des données en mémoire.',
      confirmLabel: 'Supprimer mon compte',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    MockData.clearClientProfileSession();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session prestataire réinitialisée avec succès.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
      arguments: UserProfile.provider,
    );
  }

  Future<void> _logout() async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: 'Se déconnecter ?',
      message: 'Vous quitterez la session prestataire active.',
      confirmLabel: 'Se déconnecter',
    );

    if (!confirmed || !mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
      arguments: UserProfile.provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = LobokoApp.themeModeNotifier.value;
    final isDark = currentThemeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Paramètres du compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sécurité du compte', style: AppTextStyles.h3),
                  const SizedBox(height: AppConstants.spacing2),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_outline,
                              color: AppColors.primary),
                          title: Text('Modifier le mot de passe',
                              style: AppTextStyles.label),
                          subtitle: Text('Changer votre mot de passe de connexion',
                              style: AppTextStyles.small),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _onChangePassword,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.shield_outlined,
                              color: AppColors.primary),
                          title: Text('Informations de sécurité',
                              style: AppTextStyles.label),
                          subtitle: Text('Consulter les détails du compte',
                              style: AppTextStyles.small),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _onShowSecurityInfo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing6),

                  Text('Préférences', style: AppTextStyles.h3),
                  const SizedBox(height: AppConstants.spacing2),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: isDark,
                          activeThumbColor: AppColors.primary,
                          secondary: const Icon(Icons.dark_mode_outlined,
                              color: AppColors.primary),
                          title: Text('Thème sombre', style: AppTextStyles.label),
                          subtitle: Text(
                              isDark ? 'Mode sombre actif' : 'Mode clair actif',
                              style: AppTextStyles.small),
                          onChanged: _setTheme,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: _notificationsEnabled,
                          activeThumbColor: AppColors.primary,
                          secondary: const Icon(Icons.notifications_outlined,
                              color: AppColors.primary),
                          title:
                              Text('Notifications Push', style: AppTextStyles.label),
                          subtitle: Text('Alertes pour les nouvelles demandes et messages',
                              style: AppTextStyles.small),
                          onChanged: (val) {
                            setState(() {
                              _notificationsEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing6),

                  Text('Gestion du compte', style: AppTextStyles.h3),
                  const SizedBox(height: AppConstants.spacing2),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout,
                              color: AppColors.errorText),
                          title: Text('Se déconnecter',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.errorText)),
                          onTap: _logout,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.delete_forever_outlined,
                              color: AppColors.errorText),
                          title: Text('Supprimer mon compte (Simulé)',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.errorText)),
                          subtitle: Text('Réinitialiser la session prestataire',
                              style: AppTextStyles.small),
                          onTap: _onDeleteAccount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
