import 'dart:async';
import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/constants/app_enums.dart';
import '../../shared/helpers/app_validators.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/buttons/app_secondary_button.dart';
import '../../shared/widgets/buttons/app_text_button.dart';
import '../../shared/widgets/feedback/app_message_banner.dart';
import '../../shared/widgets/inputs/app_otp_field.dart';
import '../../shared/widgets/inputs/app_password_field.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Écran de récupération et réinitialisation de mot de passe de LOBOKO.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, required this.selectedProfile});

  final UserProfile selectedProfile;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 0;

  // Keys pour la validation des étapes
  final _step1Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Étape 1 : Identification
  final _identifierController = TextEditingController();
  String _maskedIdentifier = '';

  // Étape 2 : OTP
  String _otpCode = '';
  Timer? _countdownTimer;
  int _timerSeconds = 60;

  // Étape 3 : Nouveau mot de passe
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _timerSeconds = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) {
          setState(() {
            _timerSeconds--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _resendCode() {
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Un nouveau code de vérification à 6 chiffres a été généré.',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _maskIdentifier(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains('@')) {
      final parts = trimmed.split('@');
      final name = parts[0];
      final domain = parts[1];
      if (name.length <= 2) {
        return '${name[0]}***@$domain';
      }
      return '${name[0]}***${name[name.length - 1]}@$domain';
    } else {
      final clean = trimmed.replaceAll(RegExp(r'\s+'), '');
      if (clean.length > 6) {
        final start = clean.substring(0, 4);
        final end = clean.substring(clean.length - 2);
        return '$start *** $end';
      }
      return clean;
    }
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

  void _submitStep1() {
    if (!_step1Key.currentState!.validate()) return;

    setState(() {
      _maskedIdentifier = _maskIdentifier(_identifierController.text);
      _currentStep = 1;
    });
    _startTimer();
  }

  void _submitStep2() {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le code complet à 6 chiffres.'),
          backgroundColor: AppColors.errorText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  void _submitStep3() {
    if (!_step3Key.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas.'),
          backgroundColor: AppColors.errorText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 3;
    });
  }

  void _previousStep() {
    if (_currentStep > 0 && _currentStep < 3) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushReplacementNamed(AppRoutes.login, arguments: widget.selectedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barre supérieure
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing2,
                vertical: AppConstants.spacing2,
              ),
              child: Row(
                children: [
                  AppBackButton(onPressed: _previousStep),
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
                        child: Text(
                          'Mot de passe oublié (${widget.selectedProfile.label})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stepper progress indicator
            _buildStepperHeader(),

            // Contenu de l'étape
            Expanded(
              child: SingleChildScrollView(
                padding: AppConstants.screenPadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _buildCurrentStepContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    final stepTitles = [
      'Identification',
      'Vérification OTP',
      'Nouveau mot de passe',
      'Confirmation',
    ];

    final progress = (_currentStep + 1) / 4;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing4,
            vertical: AppConstants.spacing2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Étape ${_currentStep + 1} sur 4',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Flexible(
                child: Text(
                  stepTitles[_currentStep],
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.disabledBackground,
          color: AppColors.primary,
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Identification();
      case 1:
        return _buildStep2Otp();
      case 2:
        return _buildStep3NewPassword();
      case 3:
      default:
        return _buildStep4Confirmation();
    }
  }

  // --- ÉTAPE 1 : IDENTIFICATION ---
  Widget _buildStep1Identification() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mot de passe oublié ?', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Renseignez votre numéro de téléphone ou votre adresse e-mail pour récupérer l\'accès à votre compte.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),

          const AppMessageBanner(
            message:
                'Mode démonstration locale : la réinitialisation s’exécute localement sans passer par un serveur SMS/Email distant.',
            type: AppMessageType.info,
          ),
          const SizedBox(height: AppConstants.spacing6),

          AppTextField(
            controller: _identifierController,
            label: 'Numéro de téléphone ou adresse e-mail',
            hint: 'Exemple : +242 06... ou nom@email.com',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: _validateIdentifier,
            onSubmitted: (_) => _submitStep1(),
          ),
          const SizedBox(height: AppConstants.spacing8),

          AppPrimaryButton(label: 'Continuer', onPressed: _submitStep1),
          const SizedBox(height: AppConstants.spacing3),
          AppSecondaryButton(
            label: 'Retour à la connexion',
            onPressed: _goToLogin,
          ),
        ],
      ),
    );
  }

  // --- ÉTAPE 2 : VÉRIFICATION OTP ---
  Widget _buildStep2Otp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Vérifiez votre identité', style: AppTextStyles.h1),
        const SizedBox(height: AppConstants.spacing2),
        Text(
          'Saisissez le code de vérification à 6 chiffres envoyé à vos coordonnées.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppConstants.spacing4),

        // Encart identifiant masqué
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing4,
            vertical: AppConstants.spacing3,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing2),
              Expanded(
                child: Text(
                  'Code envoyé à : $_maskedIdentifier',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing6),

        // Saisie du code OTP 6 chiffres
        AppOtpField(
          length: 6,
          onCompleted: (code) {
            setState(() {
              _otpCode = code;
            });
          },
          onChanged: (code) {
            setState(() {
              _otpCode = code;
            });
          },
        ),
        const SizedBox(height: AppConstants.spacing6),

        // Compte à rebours / Renvoi
        Center(
          child: _timerSeconds > 0
              ? Text(
                  'Renvoyer le code dans 00:${_timerSeconds.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodySecondary,
                )
              : AppTextButton(
                  label: 'Renvoyer un nouveau code',
                  icon: Icons.refresh,
                  onPressed: _resendCode,
                ),
        ),
        const SizedBox(height: AppConstants.spacing8),

        AppPrimaryButton(label: 'Vérifier le code', onPressed: _submitStep2),
        const SizedBox(height: AppConstants.spacing3),
        AppSecondaryButton(label: 'Retour', onPressed: _previousStep),
      ],
    );
  }

  // --- ÉTAPE 3 : NOUVEAU MOT DE PASSE ---
  Widget _buildStep3NewPassword() {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Créez un nouveau mot de passe', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Choisissez un nouveau mot de passe pour sécuriser votre compte.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),

          AppPasswordField(
            controller: _newPasswordController,
            label: 'Nouveau mot de passe',
            hint: 'Au moins 6 caractères',
            textInputAction: TextInputAction.next,
            validator: (val) => AppValidators.password(val),
          ),
          const SizedBox(height: AppConstants.spacing4),

          AppPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmer le nouveau mot de passe',
            hint: 'Répétez le mot de passe',
            textInputAction: TextInputAction.done,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Veuillez confirmer le mot de passe';
              }
              if (val != _newPasswordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
            onSubmitted: (_) => _submitStep3(),
          ),
          const SizedBox(height: AppConstants.spacing8),

          AppPrimaryButton(
            label: 'Réinitialiser le mot de passe',
            onPressed: _submitStep3,
          ),
          const SizedBox(height: AppConstants.spacing3),
          AppSecondaryButton(label: 'Retour', onPressed: _previousStep),
        ],
      ),
    );
  }

  // --- ÉTAPE 4 : CONFIRMATION ---
  Widget _buildStep4Confirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppConstants.spacing4),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.successBackground,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: AppColors.successText,
            size: 48,
          ),
        ),
        const SizedBox(height: AppConstants.spacing6),

        Text(
          'Mot de passe modifié !',
          textAlign: TextAlign.center,
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: AppConstants.spacing3),

        Text(
          'Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter à votre compte LOBOKO.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),

        AppPrimaryButton(label: 'Se connecter', onPressed: _goToLogin),
      ],
    );
  }
}
