import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/constants/app_enums.dart';
import '../../shared/helpers/app_validators.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/buttons/app_text_button.dart';
import '../../shared/widgets/inputs/app_password_field.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Écran de connexion de LOBOKO.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.selectedProfile});

  final UserProfile selectedProfile;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre numéro ou adresse e-mail';
    }
    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      return AppValidators.email(trimmed);
    } else {
      return AppValidators.phone(trimmed);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulation de traitement local
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (widget.selectedProfile == UserProfile.client) {
      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.clientHome, arguments: 'Grace');
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.providerDashboard);
    }
  }

  void _onForgotPassword() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.forgotPassword, arguments: widget.selectedProfile);
  }

  @override
  Widget build(BuildContext context) {
    final isClient = widget.selectedProfile == UserProfile.client;
    final subtitle = isClient
        ? 'Retrouvez vos prestataires et vos réservations.'
        : 'Retrouvez vos demandes et gérez votre activité.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Barre supérieure avec bouton Retour et Badge de profil
                    Row(
                      children: [
                        const AppBackButton(),
                        const SizedBox(width: AppConstants.spacing2),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.badgeRadius,
                                ),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isClient
                                        ? Icons.person_search_outlined
                                        : Icons.home_repair_service_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Profil : ${widget.selectedProfile.label}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing5),

                    // Badge LOBOKO
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.handshake_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),

                    // Titre principal
                    Text(
                      'Heureux de vous revoir !',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1,
                    ),
                    const SizedBox(height: AppConstants.spacing2),

                    // Sous-titre adapté au profil
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: AppConstants.spacing8),

                    // Champ 1 : Téléphone ou Email
                    AppTextField(
                      controller: _identifierController,
                      label: 'Numéro de téléphone ou adresse e-mail',
                      hint: 'Exemple : +242 06... ou nom@email.com',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateIdentifier,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: AppConstants.spacing4),

                    // Champ 2 : Mot de passe
                    AppPasswordField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      hint: 'Saisissez votre mot de passe',
                      validator: (val) => AppValidators.required(
                        val,
                        'Veuillez saisir votre mot de passe',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: AppConstants.spacing2),

                    // Lien Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppTextButton(
                        label: 'Mot de passe oublié ?',
                        onPressed: _isLoading ? null : _onForgotPassword,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing6),

                    // Bouton de connexion
                    AppPrimaryButton(
                      label: 'Se connecter',
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppConstants.spacing6),

                    // Lien d'inscription
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        Text(
                          "Vous n'avez pas encore de compte ?",
                          style: AppTextStyles.bodySecondary,
                        ),
                        AppTextButton(
                          label: 'Créer un compte',
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.register,
                                    arguments: widget.selectedProfile,
                                  );
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
