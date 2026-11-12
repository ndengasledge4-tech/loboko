import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../shared/constants/app_enums.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';

/// Page de choix du profil (Client ou Prestataire) de LOBOKO.
class ProfileSelectionPage extends StatefulWidget {
  const ProfileSelectionPage({super.key});

  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  UserProfile? _selectedProfile;

  void _continue() {
    if (_selectedProfile == null) return;

    Navigator.of(context).pushNamed(
      AppRoutes.login,
      arguments: _selectedProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_pin_circle_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Comment souhaitez-vous utiliser LOBOKO ?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choisissez votre profil pour continuer et profiter d’une expérience adaptée à vos besoins.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 32),

                  // Carte Client
                  _ProfileCard(
                    icon: Icons.person_search_outlined,
                    title: 'Je cherche un prestataire',
                    description: UserProfile.client.description,
                    isSelected: _selectedProfile == UserProfile.client,
                    onTap: () {
                      setState(() {
                        _selectedProfile = UserProfile.client;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Carte Prestataire
                  _ProfileCard(
                    icon: Icons.home_repair_service_outlined,
                    title: 'Je propose mes services',
                    description: UserProfile.provider.description,
                    isSelected: _selectedProfile == UserProfile.provider,
                    onTap: () {
                      setState(() {
                        _selectedProfile = UserProfile.provider;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Bouton Continuer
                  AppPrimaryButton(
                    label: 'Continuer',
                    onPressed: _selectedProfile == null ? null : _continue,
                    expand: true,
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.lightGreen : AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.white : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
