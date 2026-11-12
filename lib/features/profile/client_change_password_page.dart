import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/helpers/app_validators.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/feedback/app_message_banner.dart';
import '../../shared/widgets/inputs/app_password_field.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Page de modification du mot de passe de l'utilisateur (Client ou Prestataire).
class ClientChangePasswordPage extends StatefulWidget {
  const ClientChangePasswordPage({super.key});

  @override
  State<ClientChangePasswordPage> createState() =>
      _ClientChangePasswordPageState();
}

class _ClientChangePasswordPageState extends State<ClientChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSaving = false;
  String? _successMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    setState(() {
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les nouveaux mots de passe ne correspondent pas.'),
          backgroundColor: AppColors.errorText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _successMessage =
          'Votre mot de passe a été modifié avec succès (mise à jour en démonstration locale).';
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mot de passe mis à jour avec succès !'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Changer de mot de passe'),
      ),
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
                    Text(
                      'Modifier votre mot de passe',
                      style: AppTextStyles.h1.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Renseignez votre mot de passe actuel puis choisissez un nouveau mot de passe sécurisé.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: AppConstants.spacing6),

                    if (_successMessage != null) ...[
                      AppMessageBanner(
                        message: _successMessage!,
                        type: AppMessageType.success,
                      ),
                      const SizedBox(height: AppConstants.spacing6),
                    ],

                    // Champ Mot de passe actuel
                    AppPasswordField(
                      controller: _currentPasswordController,
                      label: 'Mot de passe actuel',
                      hint: 'Saisissez votre mot de passe actuel',
                      textInputAction: TextInputAction.next,
                      validator: (val) => AppValidators.required(
                        val,
                        'Veuillez saisir votre mot de passe actuel',
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),

                    // Champ Nouveau mot de passe
                    AppPasswordField(
                      controller: _newPasswordController,
                      label: 'Nouveau mot de passe',
                      hint: 'Au moins 6 caractères',
                      textInputAction: TextInputAction.next,
                      validator: (val) => AppValidators.password(val),
                    ),
                    const SizedBox(height: AppConstants.spacing4),

                    // Champ Confirmation nouveau mot de passe
                    AppPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirmer le nouveau mot de passe',
                      hint: 'Répétez le nouveau mot de passe',
                      textInputAction: TextInputAction.done,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Veuillez confirmer le nouveau mot de passe';
                        }
                        if (val != _newPasswordController.text) {
                          return 'Les nouveaux mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                      onSubmitted: (_) => _savePassword(),
                    ),
                    const SizedBox(height: AppConstants.spacing8),

                    AppPrimaryButton(
                      label: 'Enregistrer les modifications',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _savePassword,
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
