import 'package:flutter/material.dart';

import '../../shared/constants/app_enums.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Page d'inscription (Cible de navigation après la connexion).
class RegisterPlaceholderPage extends StatelessWidget {
  const RegisterPlaceholderPage({
    super.key,
    required this.selectedProfile,
  });

  final UserProfile selectedProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Création de compte',
                      style: AppTextStyles.h1,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Profil sélectionné : ${selectedProfile.label}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'L’étape suivante d’inscription sera développée lors de l’étape dédiée.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
