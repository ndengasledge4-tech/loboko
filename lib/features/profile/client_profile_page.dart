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
import '../../shared/widgets/navigation/app_page_header.dart';

/// Profil et paramètres Client, intégrés à l'onglet Profil de l'accueil.
class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({
    super.key,
    required this.onBookings,
    required this.onFavorites,
  });

  final VoidCallback onBookings;
  final VoidCallback onFavorites;

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
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

  Future<void> _editProfile() async {
    await Navigator.of(context).pushNamed(AppRoutes.clientProfileEdit);
    if (mounted) setState(() {});
  }

  Future<void> _openMessages() async {
    await Navigator.of(context).pushNamed(AppRoutes.clientMessages);
    if (mounted) setState(() {});
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).pushNamed(AppRoutes.clientNotifications);
    if (mounted) setState(() {});
  }

  Future<void> _showInformation(String title, String message) {
    return AppInfoDialog.show(context: context, title: title, message: message);
  }

  Future<void> _openPasswordChange() async {
    await Navigator.of(context).pushNamed(AppRoutes.clientChangePassword);
  }

  Future<void> _logout() async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: 'Se déconnecter ?',
      message:
          'Votre profil saisi dans cette session de démonstration sera effacé.',
      confirmLabel: 'Se déconnecter',
      cancelLabel: 'Annuler',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    MockData.clearClientProfileSession();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
      arguments: UserProfile.client,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = MockData.clientProfile;
    final fullName = profile?.fullName ?? '';
    final unread = MockData.unreadNotificationCount;
    final isDark = LobokoApp.themeModeNotifier.value == ThemeMode.dark;

    return SingleChildScrollView(
      padding: AppConstants.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spacing4),
          const AppPageHeader(
            title: 'Mon profil',
            subtitle: 'Vos informations et préférences Client',
          ),
          const SizedBox(height: AppConstants.spacing4),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: AppConstants.cardPadding,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(
                      profile?.avatarIcon ?? Icons.person_outline,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing3),
                  Text(
                    profile == null ? 'Profil Client' : fullName,
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile == null
                        ? 'Aucune information personnelle renseignée dans cette démonstration.'
                        : 'Client LOBOKO · Coordonnées de démonstration',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: AppConstants.spacing3),
                    _ProfileLine(
                      icon: Icons.email_outlined,
                      text: profile.email,
                    ),
                    const SizedBox(height: AppConstants.spacing2),
                    _ProfileLine(
                      icon: Icons.phone_outlined,
                      text: profile.phone,
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacing4),
                  OutlinedButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(
                      profile == null
                          ? 'Compléter mon profil'
                          : 'Modifier mon profil',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing5),
          Text('Mes activités', style: AppTextStyles.h3),
          const SizedBox(height: AppConstants.spacing2),
          _ActivityTile(
            icon: Icons.calendar_month_outlined,
            title: 'Mes réservations',
            count: MockData.bookingRequests.length,
            onTap: widget.onBookings,
          ),
          _ActivityTile(
            icon: Icons.chat_bubble_outline,
            title: 'Mes messages',
            count: MockData.conversations.length,
            onTap: _openMessages,
          ),
          _ActivityTile(
            icon: Icons.favorite_border,
            title: 'Mes favoris',
            onTap: widget.onFavorites,
          ),
          _ActivityTile(
            icon: Icons.notifications_none_outlined,
            title: 'Mes notifications',
            count: unread,
            onTap: _openNotifications,
          ),
          const SizedBox(height: AppConstants.spacing4),
          _SettingsGroup(
            title: 'Préférences',
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: MockData.clientPreferences.notificationsEnabled,
                onChanged: (value) => setState(
                  () => MockData.clientPreferences.notificationsEnabled = value,
                ),
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Préférence notifications',
                  style: AppTextStyles.label,
                ),
                subtitle: Text(
                  'Réglage local uniquement, sans envoi externe.',
                  style: AppTextStyles.small,
                ),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: isDark,
                onChanged: _setTheme,
                activeThumbColor: AppColors.primary,
                title: Text('Thème sombre', style: AppTextStyles.label),
                subtitle: Text(
                  isDark ? 'Mode sombre actif' : 'Mode clair actif',
                  style: AppTextStyles.small,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing3),
          _SettingsGroup(
            title: 'Sécurité',
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Modifier le mot de passe',
                onTap: _openPasswordChange,
              ),
              _SettingsTile(
                icon: Icons.security_outlined,
                title: 'Sécurité du compte',
                onTap: () => _showInformation(
                  'Sécurité du compte',
                  'Cette démonstration ne crée pas de compte authentifié et ne transmet aucune donnée à un serveur.',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing3),
          _SettingsGroup(
            title: 'Assistance',
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Aide et support',
                onTap: () => _showInformation(
                  'Aide et support',
                  'Le support Client n’est pas encore connecté dans cette démonstration.',
                ),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Conditions d’utilisation',
                onTap: () => _showInformation(
                  'Conditions d’utilisation',
                  'Aucun document de conditions d’utilisation n’est disponible dans cette démonstration.',
                ),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Politique de confidentialité',
                onTap: () => _showInformation(
                  'Politique de confidentialité',
                  'Aucun document de politique de confidentialité n’est disponible dans cette démonstration.',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing3),
          _SettingsGroup(
            title: 'Compte',
            children: [
              _SettingsTile(
                icon: Icons.logout,
                title: 'Se déconnecter',
                color: AppColors.errorText,
                onTap: _logout,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing6),
          Center(
            child: Text(
              'Profil et réglages conservés uniquement dans cette session de démonstration.',
              textAlign: TextAlign.center,
              style: AppTextStyles.small,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
        ],
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Flexible(child: Text(text, style: AppTextStyles.bodySecondary)),
    ],
  );
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.count,
  });

  final IconData icon;
  final String title;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 6),
    elevation: 0,
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count != null && count! > 0) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.lightGreen,
              child: Text(
                '$count',
                style: AppTextStyles.small.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    ),
  );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(title, style: AppTextStyles.h3),
          ),
          ...children,
        ],
      ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: color),
    title: Text(title, style: AppTextStyles.label.copyWith(color: color)),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
