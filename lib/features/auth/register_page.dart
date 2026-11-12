import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/app_enums.dart';
import '../../shared/helpers/app_validators.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/buttons/app_secondary_button.dart';
import '../../shared/widgets/buttons/app_text_button.dart';
import '../../shared/widgets/feedback/app_message_banner.dart';
import '../../shared/widgets/inputs/app_multiline_field.dart';
import '../../shared/widgets/inputs/app_password_field.dart';
import '../../shared/widgets/inputs/app_phone_field.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/navigation/app_back_button.dart';
import '../../mock/mock_data.dart';

/// Écran d'inscription multi-étapes de LOBOKO (Client & Prestataire).
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key, required this.selectedProfile});

  final UserProfile selectedProfile;

  @override
  Widget build(BuildContext context) {
    if (selectedProfile == UserProfile.provider) {
      return const _ProviderRegisterForm();
    }
    return const _ClientRegisterForm();
  }
}

// =============================================================================
// PARCOURS 1 : INSCRIPTION CLIENT (4 ÉTAPES)
// =============================================================================

class _ClientRegisterForm extends StatefulWidget {
  const _ClientRegisterForm();

  @override
  State<_ClientRegisterForm> createState() => _ClientRegisterFormState();
}

class _ClientRegisterFormState extends State<_ClientRegisterForm> {
  int _currentStep = 0;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Étape 1
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  IconData? _selectedAvatarIcon;
  String? _avatarLabel;

  // Étape 2
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Étape 3
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Étape 4
  bool _acceptedTerms = false;
  bool _isSubmitted = false;
  String? _successMessage;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_validateStep1()) return;
    } else if (_currentStep == 1) {
      if (!_validateStep2()) return;
    } else if (_currentStep == 2) {
      if (!_validateStep3()) return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToStep(int stepIndex) {
    setState(() => _currentStep = stepIndex);
  }

  bool _validateStep1() {
    if (!_step1Key.currentState!.validate()) return false;
    if (_nomController.text.trim().isEmpty ||
        _prenomController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    return _step2Key.currentState!.validate();
  }

  bool _validateStep3() {
    if (!_step3Key.currentState!.validate()) return false;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas.'),
          backgroundColor: AppColors.errorText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  void _finishRegistration() {
    if (!_acceptedTerms) return;
    setState(() {
      _isSubmitted = true;
      _successMessage =
          'Inscription Client validée localement avec succès ! '
          'Bienvenue sur LOBOKO. L’interface de démonstration est terminée.';
    });
  }

  void _showPhotoPickerModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Photo de profil', style: AppTextStyles.h3),
                const SizedBox(height: AppConstants.spacing2),
                Text(
                  'Choisissez une illustration ou simulez la sélection',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppConstants.spacing5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AvatarOption(
                      icon: Icons.person_pin_outlined,
                      label: 'Avatar 1',
                      onTap: () {
                        setState(() {
                          _selectedAvatarIcon = Icons.person_pin_outlined;
                          _avatarLabel = 'Avatar Client LOBOKO 1';
                        });
                        Navigator.of(modalContext).pop();
                      },
                    ),
                    _AvatarOption(
                      icon: Icons.face_outlined,
                      label: 'Avatar 2',
                      onTap: () {
                        setState(() {
                          _selectedAvatarIcon = Icons.face_outlined;
                          _avatarLabel = 'Avatar Client LOBOKO 2';
                        });
                        Navigator.of(modalContext).pop();
                      },
                    ),
                    _AvatarOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Galerie (Simulée)',
                      onTap: () {
                        setState(() {
                          _selectedAvatarIcon = Icons.image_outlined;
                          _avatarLabel = 'Photo choisie depuis la galerie';
                        });
                        Navigator.of(modalContext).pop();
                      },
                    ),
                  ],
                ),
                if (_selectedAvatarIcon != null) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  AppTextButton(
                    label: 'Retirer la photo',
                    icon: Icons.delete_outline,
                    onPressed: () {
                      setState(() {
                        _selectedAvatarIcon = null;
                        _avatarLabel = null;
                      });
                      Navigator.of(modalContext).pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing2,
                vertical: AppConstants.spacing2,
              ),
              child: Row(
                children: [
                  AppBackButton(onPressed: _previousStep),
                  const SizedBox(width: AppConstants.spacing2),
                  const Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _ProfileTag(label: 'Création de compte Client'),
                    ),
                  ),
                ],
              ),
            ),
            _buildStepperHeader(),
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
      'Informations personnelles',
      'Coordonnées',
      'Sécurisation du compte',
      'Récapitulatif & Finalisation',
    ];

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
          value: (_currentStep + 1) / 4,
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
        return _buildStep1InformationsPersonnelles();
      case 1:
        return _buildStep2Coordonnees();
      case 2:
        return _buildStep3Securisation();
      case 3:
      default:
        return _buildStep4Recapitulatif();
    }
  }

  Widget _buildStep1InformationsPersonnelles() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Faisons connaissance', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Commençons par quelques informations personnelles.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.lightGreen,
                      child: Icon(
                        _selectedAvatarIcon ?? Icons.person_outline,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                    InkWell(
                      onTap: _showPhotoPickerModal,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing2),
                AppTextButton(
                  label: _selectedAvatarIcon != null
                      ? 'Remplacer la photo'
                      : 'Ajouter une photo (facultatif)',
                  onPressed: _showPhotoPickerModal,
                ),
                if (_avatarLabel != null) ...[
                  Text(
                    _avatarLabel!,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing6),
          AppTextField(
            controller: _nomController,
            label: 'Nom',
            hint: 'Ex. Mfumu',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (val) =>
                AppValidators.required(val, 'Le nom est obligatoire'),
          ),
          const SizedBox(height: AppConstants.spacing4),
          AppTextField(
            controller: _prenomController,
            label: 'Prénom',
            hint: 'Ex. Grace',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.done,
            validator: (val) =>
                AppValidators.required(val, 'Le prénom est obligatoire'),
            onSubmitted: (_) => _nextStep(),
          ),
          const SizedBox(height: AppConstants.spacing8),
          AppPrimaryButton(label: 'Continuer', onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep2Coordonnees() {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Comment pouvons-nous vous joindre ?', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Renseignez vos coordonnées pour utiliser LOBOKO.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),
          AppPhoneField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            hint: '06 123 45 67',
            countryCode: '+242',
            validator: (val) => AppValidators.phone(
              val,
              'Veuillez saisir un numéro congolais valide (+242)',
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          AppTextField(
            controller: _emailController,
            label: 'Adresse e-mail',
            hint: 'exemple@domaine.cg',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (val) => AppValidators.email(
              val,
              'Veuillez saisir une adresse e-mail valide',
            ),
            onSubmitted: (_) => _nextStep(),
          ),
          const SizedBox(height: AppConstants.spacing8),
          AppPrimaryButton(label: 'Continuer', onPressed: _nextStep),
          const SizedBox(height: AppConstants.spacing3),
          AppSecondaryButton(label: 'Retour', onPressed: _previousStep),
        ],
      ),
    );
  }

  Widget _buildStep3Securisation() {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sécurisez votre compte', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Choisissez un mot de passe pour protéger votre compte LOBOKO.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),
          AppPasswordField(
            controller: _passwordController,
            label: 'Mot de passe',
            hint: 'Au moins 6 caractères',
            textInputAction: TextInputAction.next,
            validator: (val) => AppValidators.password(val),
          ),
          const SizedBox(height: AppConstants.spacing4),
          AppPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmer le mot de passe',
            hint: 'Répétez le mot de passe',
            textInputAction: TextInputAction.done,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Veuillez confirmer le mot de passe';
              }
              if (val != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
            onSubmitted: (_) => _nextStep(),
          ),
          const SizedBox(height: AppConstants.spacing3),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing3),
            decoration: BoxDecoration(
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.infoText,
                ),
                const SizedBox(width: AppConstants.spacing2),
                Expanded(
                  child: Text(
                    'Votre mot de passe doit contenir au moins 6 caractères.',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.infoText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          AppPrimaryButton(label: 'Continuer', onPressed: _nextStep),
          const SizedBox(height: AppConstants.spacing3),
          AppSecondaryButton(label: 'Retour', onPressed: _previousStep),
        ],
      ),
    );
  }

  Widget _buildStep4Recapitulatif() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Vérifiez vos informations', style: AppTextStyles.h1),
        const SizedBox(height: AppConstants.spacing2),
        Text(
          'Assurez-vous que vos informations sont correctes avant de terminer.',
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
        _RecapCategoryCard(
          title: 'Informations personnelles',
          icon: Icons.person_outline,
          onEdit: () => _goToStep(0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.lightGreen,
                child: Icon(
                  _selectedAvatarIcon ?? Icons.person_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_prenomController.text} ${_nomController.text}',
                      style: AppTextStyles.label,
                    ),
                    Text(
                      _avatarLabel ?? 'Aucune photo ajoutée',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing4),
        _RecapCategoryCard(
          title: 'Coordonnées',
          icon: Icons.contact_phone_outlined,
          onEdit: () => _goToStep(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecapItemRow(
                label: 'Téléphone',
                value: '+242 ${_phoneController.text}',
              ),
              const SizedBox(height: 6),
              _RecapItemRow(label: 'E-mail', value: _emailController.text),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing4),
        _RecapCategoryCard(
          title: 'Sécurité',
          icon: Icons.lock_outline,
          onEdit: () => _goToStep(2),
          child: const _RecapItemRow(
            label: 'Mot de passe',
            value: '•••••••• (Sécurisé)',
          ),
        ),
        const SizedBox(height: AppConstants.spacing6),
        CheckboxListTile(
          value: _acceptedTerms,
          onChanged: _isSubmitted
              ? null
              : (val) => setState(() => _acceptedTerms = val ?? false),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            "J'accepte les conditions générales d'utilisation et la politique de confidentialité de LOBOKO.",
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          ),
        ),
        const SizedBox(height: AppConstants.spacing6),
        AppPrimaryButton(
          label: 'Terminer l\'inscription',
          onPressed: (_acceptedTerms && !_isSubmitted)
              ? _finishRegistration
              : null,
        ),
        const SizedBox(height: AppConstants.spacing3),
        AppSecondaryButton(
          label: 'Retour',
          onPressed: _isSubmitted ? null : _previousStep,
        ),
      ],
    );
  }
}

// =============================================================================
// PARCOURS 2 : INSCRIPTION PRESTATAIRE (5 ÉTAPES)
// =============================================================================

class _ProviderRegisterForm extends StatefulWidget {
  const _ProviderRegisterForm();

  @override
  State<_ProviderRegisterForm> createState() => _ProviderRegisterFormState();
}

class _ProviderRegisterFormState extends State<_ProviderRegisterForm> {
  int _currentStep = 0;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();

  // Étape 1 : Informations personnelles
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  IconData? _selectedAvatarIcon;
  String? _avatarLabel;

  // Étape 2 : Coordonnées
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Étape 3 : Informations professionnelles
  String? _selectedMetier;
  final _specialiteController = TextEditingController();
  String? _selectedExperience;
  final _descriptionController = TextEditingController();

  // Étape 4 : Conditions d'intervention
  String _modeIntervention = 'domicile'; // 'domicile', 'atelier', 'les_deux'
  final _zoneInterventionController = TextEditingController(
    text: 'Toute la ville de Brazzaville',
  );
  final _adresseAtelierController = TextEditingController();

  // Étape 5 : Sécurité & Finalisation
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _isSubmitted = false;
  String? _successMessage;

  static const List<String> _metiersList = [
    'Plomberie',
    'Électricité',
    'Menuiserie',
    'Maçonnerie',
    'Peinture',
    'Mécanique',
    'Coiffure et beauté',
    'Nettoyage et entretien',
    'Jardinage',
    'Réparation et maintenance',
    'Autres services',
  ];

  static const List<String> _experiencesList = [
    'Débutant',
    'Moins de 2 ans',
    '2 à 5 ans',
    '5 à 10 ans',
    'Plus de 10 ans',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specialiteController.dispose();
    _descriptionController.dispose();
    _zoneInterventionController.dispose();
    _adresseAtelierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_validateStep1()) return;
    } else if (_currentStep == 1) {
      if (!_validateStep2()) return;
    } else if (_currentStep == 2) {
      if (!_validateStep3()) return;
    } else if (_currentStep == 3) {
      if (!_validateStep4()) return;
    } else if (_currentStep == 4) {
      if (!_validateStep5()) return;
    }

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToStep(int stepIndex) {
    setState(() => _currentStep = stepIndex);
  }

  bool _validateStep1() {
    if (!_step1Key.currentState!.validate()) return false;
    if (_nomController.text.trim().isEmpty ||
        _prenomController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    return _step2Key.currentState!.validate();
  }

  bool _validateStep3() {
    if (!_step3Key.currentState!.validate()) return false;
    if (_selectedMetier == null || _selectedExperience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre métier et expérience.'),
          backgroundColor: AppColors.errorText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    if (!_step4Key.currentState!.validate()) return false;
    if ((_modeIntervention == 'atelier' || _modeIntervention == 'les_deux') &&
        _adresseAtelierController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("L'adresse de l'atelier est obligatoire pour ce mode."),
          backgroundColor: AppColors.errorText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateStep5() {
    if (!_step5Key.currentState!.validate()) return false;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas.'),
          backgroundColor: AppColors.errorText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  void _finishRegistration() {
    if (!_acceptedTerms) return;

    MockData.updateProviderDashboardProfile(
      firstName: _prenomController.text.trim(),
      lastName: _nomController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      profession: _selectedMetier ?? '',
      specialty: _specialiteController.text.trim().isEmpty
          ? null
          : _specialiteController.text.trim(),
      yearsOfExperience: null,
      experienceLabel: _selectedExperience,
      description: _descriptionController.text.trim(),
      serviceAreas: _zoneInterventionController.text
          .split(RegExp(r'[,;\n]'))
          .map((area) => area.trim())
          .where((area) => area.isNotEmpty)
          .toList(),
      interventionMode: switch (_modeIntervention) {
        'atelier' => MockCatalogInterventionMode.workshop,
        'les_deux' => MockCatalogInterventionMode.both,
        _ => MockCatalogInterventionMode.home,
      },
      workshopAddress: _adresseAtelierController.text.trim().isEmpty
          ? null
          : _adresseAtelierController.text.trim(),
      avatarIcon: _selectedAvatarIcon,
      isDemo: true,
    );

    setState(() {
      _isSubmitted = true;
      _successMessage =
          'Inscription Prestataire validée localement avec succès ! '
          'Bienvenue sur LOBOKO. Votre dossier sera étudié par l’administration.';
    });
  }

  void _showPhotoPickerModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Photo du Prestataire', style: AppTextStyles.h3),
                const SizedBox(height: AppConstants.spacing2),
                Text(
                  'Choisissez une illustration ou simulez la sélection',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppConstants.spacing5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AvatarOption(
                      icon: Icons.business_center_outlined,
                      label: 'Pro 1',
                      onTap: () {
                        setState(() {
                          _selectedAvatarIcon = Icons.business_center_outlined;
                          _avatarLabel = 'Photo Pro LOBOKO 1';
                        });
                        Navigator.of(modalContext).pop();
                      },
                    ),
                    _AvatarOption(
                      icon: Icons.handyman_outlined,
                      label: 'Pro 2',
                      onTap: () {
                        setState(() {
                          _selectedAvatarIcon = Icons.handyman_outlined;
                          _avatarLabel = 'Photo Pro LOBOKO 2';
                        });
                        Navigator.of(modalContext).pop();
                      },
                    ),
                    _AvatarOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Galerie (Simulée)',
                      onTap: () {
                        setState(() {
                          _selectedAvatarIcon = Icons.image_outlined;
                          _avatarLabel = 'Photo choisie depuis la galerie';
                        });
                        Navigator.of(modalContext).pop();
                      },
                    ),
                  ],
                ),
                if (_selectedAvatarIcon != null) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  AppTextButton(
                    label: 'Retirer la photo',
                    icon: Icons.delete_outline,
                    onPressed: () {
                      setState(() {
                        _selectedAvatarIcon = null;
                        _avatarLabel = null;
                      });
                      Navigator.of(modalContext).pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing2,
                vertical: AppConstants.spacing2,
              ),
              child: Row(
                children: [
                  AppBackButton(onPressed: _previousStep),
                  const SizedBox(width: AppConstants.spacing2),
                  const Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _ProfileTag(
                        label: 'Création de compte Prestataire',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildStepperHeader(),
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
      'Informations personnelles',
      'Coordonnées',
      'Informations professionnelles',
      "Conditions d'intervention",
      'Sécurité & Finalisation',
    ];

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
                'Étape ${_currentStep + 1} sur 5',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
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
          value: (_currentStep + 1) / 5,
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
        return _buildStep1InformationsPersonnelles();
      case 1:
        return _buildStep2Coordonnees();
      case 2:
        return _buildStep3InformationsProfessionnelles();
      case 3:
        return _buildStep4ConditionsIntervention();
      case 4:
      default:
        return _buildStep5SecuriteEtFinalisation();
    }
  }

  // --- ÉTAPE 1 : INFORMATIONS PERSONNELLES ---
  Widget _buildStep1InformationsPersonnelles() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Faisons connaissance', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Présentez-vous pour commencer votre inscription.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.lightGreen,
                      child: Icon(
                        _selectedAvatarIcon ??
                            Icons.home_repair_service_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    InkWell(
                      onTap: _showPhotoPickerModal,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing2),
                AppTextButton(
                  label: _selectedAvatarIcon != null
                      ? 'Remplacer la photo'
                      : 'Ajouter une photo (facultatif)',
                  onPressed: _showPhotoPickerModal,
                ),
                if (_avatarLabel != null) ...[
                  Text(
                    _avatarLabel!,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing6),
          AppTextField(
            controller: _nomController,
            label: 'Nom',
            hint: 'Ex. Nkoulou',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (val) =>
                AppValidators.required(val, 'Le nom est obligatoire'),
          ),
          const SizedBox(height: AppConstants.spacing4),
          AppTextField(
            controller: _prenomController,
            label: 'Prénom',
            hint: 'Ex. Martial',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.done,
            validator: (val) =>
                AppValidators.required(val, 'Le prénom est obligatoire'),
            onSubmitted: (_) => _nextStep(),
          ),
          const SizedBox(height: AppConstants.spacing8),
          AppPrimaryButton(label: 'Continuer', onPressed: _nextStep),
        ],
      ),
    );
  }

  // --- ÉTAPE 2 : COORDONNÉES ---
  Widget _buildStep2Coordonnees() {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Vos coordonnées', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Comment les clients pourront-ils vous contacter ?',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),
          AppPhoneField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            hint: '06 123 45 67',
            countryCode: '+242',
            validator: (val) => AppValidators.phone(
              val,
              'Veuillez saisir un numéro congolais valide (+242)',
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          AppTextField(
            controller: _emailController,
            label: 'Adresse e-mail',
            hint: 'exemple@domaine.cg',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (val) => AppValidators.email(
              val,
              'Veuillez saisir une adresse e-mail valide',
            ),
            onSubmitted: (_) => _nextStep(),
          ),
          const SizedBox(height: AppConstants.spacing8),
          AppPrimaryButton(label: 'Continuer', onPressed: _nextStep),
          const SizedBox(height: AppConstants.spacing3),
          AppSecondaryButton(label: 'Retour', onPressed: _previousStep),
        ],
      ),
    );
  }

  // --- ÉTAPE 3 : INFORMATIONS PROFESSIONNELLES ---
  Widget _buildStep3InformationsProfessionnelles() {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Parlez-nous de votre activité', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Présentez les services que vous proposez sur LOBOKO.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),

          // 1. Métier / Profession
          DropdownButtonFormField<String>(
            initialValue: _selectedMetier,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Métier / Catégorie',
              prefixIcon: const Icon(
                Icons.work_outline,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              ),
            ),
            hint: const Text('Sélectionnez votre métier'),
            items: _metiersList.map((metier) {
              return DropdownMenuItem(
                value: metier,
                child: Text(metier, style: AppTextStyles.body),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedMetier = value),
            validator: (val) =>
                val == null ? 'Le métier est obligatoire' : null,
          ),
          const SizedBox(height: AppConstants.spacing4),

          // 2. Spécialité (Facultative)
          AppTextField(
            controller: _specialiteController,
            label: 'Spécialité (facultatif)',
            hint: 'Ex. Installation sanitaire, dépannage express',
            prefixIcon: Icons.handyman_outlined,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppConstants.spacing4),

          // 3. Expérience professionnelle
          DropdownButtonFormField<String>(
            initialValue: _selectedExperience,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Expérience professionnelle',
              prefixIcon: const Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              ),
            ),
            hint: const Text("Années d'expérience"),
            items: _experiencesList.map((exp) {
              return DropdownMenuItem(
                value: exp,
                child: Text(exp, style: AppTextStyles.body),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedExperience = value),
            validator: (val) =>
                val == null ? "L'expérience est obligatoire" : null,
          ),
          const SizedBox(height: AppConstants.spacing4),

          // 4. Description de l'activité
          AppMultilineField(
            controller: _descriptionController,
            label: "Description de l'activité",
            hint: 'Présentez vos compétences et prestations...',
            minLines: 3,
            maxLines: 5,
            maxLength: 300,
            validator: (val) =>
                AppValidators.required(val, 'La description est obligatoire'),
          ),
          const SizedBox(height: AppConstants.spacing6),

          AppPrimaryButton(label: 'Continuer', onPressed: _nextStep),
          const SizedBox(height: AppConstants.spacing3),
          AppSecondaryButton(label: 'Retour', onPressed: _previousStep),
        ],
      ),
    );
  }

  // --- ÉTAPE 4 : CONDITIONS D'INTERVENTION ---
  Widget _buildStep4ConditionsIntervention() {
    final requiresAtelier =
        _modeIntervention == 'atelier' || _modeIntervention == 'les_deux';

    return Form(
      key: _step4Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Où intervenez-vous ?', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Indiquez aux clients comment vous réalisez vos prestations.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),

          Text("Mode d'intervention", style: AppTextStyles.label),
          const SizedBox(height: AppConstants.spacing3),

          // Cartes de mode d'intervention
          _ModeCard(
            title: 'À domicile',
            description: 'Vous vous déplacez chez le client',
            icon: Icons.directions_run_outlined,
            isSelected: _modeIntervention == 'domicile',
            onTap: () => setState(() => _modeIntervention = 'domicile'),
          ),
          const SizedBox(height: 10),
          _ModeCard(
            title: 'En atelier / Local',
            description: 'Le client se rend à votre adresse',
            icon: Icons.storefront_outlined,
            isSelected: _modeIntervention == 'atelier',
            onTap: () => setState(() => _modeIntervention = 'atelier'),
          ),
          const SizedBox(height: 10),
          _ModeCard(
            title: 'Les deux',
            description: 'À domicile ou en atelier selon le besoin',
            icon: Icons.swap_horizontal_circle_outlined,
            isSelected: _modeIntervention == 'les_deux',
            onTap: () => setState(() => _modeIntervention = 'les_deux'),
          ),
          const SizedBox(height: AppConstants.spacing5),

          // Zone d'intervention
          AppTextField(
            controller: _zoneInterventionController,
            label: "Zone d'intervention",
            hint: 'Ex. Bacongo, Poto-Poto, Tout Brazzaville',
            prefixIcon: Icons.map_outlined,
            textInputAction: TextInputAction.next,
            validator: (val) => AppValidators.required(
              val,
              "La zone d'intervention est obligatoire",
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),

          // Adresse de l'atelier (Conditionnel)
          if (requiresAtelier) ...[
            AppTextField(
              controller: _adresseAtelierController,
              label: "Adresse de l'atelier / local",
              hint: 'Ex. Rue Mbochi, Poto-Poto, Brazzaville',
              prefixIcon: Icons.location_city_outlined,
              textInputAction: TextInputAction.done,
              validator: (val) => AppValidators.required(
                val,
                "L'adresse de l'atelier est obligatoire pour ce mode",
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
          ],

          const SizedBox(height: AppConstants.spacing6),
          AppPrimaryButton(label: 'Continuer', onPressed: _nextStep),
          const SizedBox(height: AppConstants.spacing3),
          AppSecondaryButton(label: 'Retour', onPressed: _previousStep),
        ],
      ),
    );
  }

  // --- ÉTAPE 5 : SÉCURITÉ ET FINALISATION ---
  Widget _buildStep5SecuriteEtFinalisation() {
    final modeLabel = _modeIntervention == 'domicile'
        ? 'À domicile'
        : _modeIntervention == 'atelier'
        ? 'En atelier'
        : 'À domicile & En atelier';

    return Form(
      key: _step5Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sécurisez votre compte', style: AppTextStyles.h1),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            'Choisissez un mot de passe pour protéger votre compte LOBOKO.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppConstants.spacing6),

          AppPasswordField(
            controller: _passwordController,
            label: 'Mot de passe',
            hint: 'Au moins 6 caractères',
            textInputAction: TextInputAction.next,
            validator: (val) => AppValidators.password(val),
          ),
          const SizedBox(height: AppConstants.spacing4),
          AppPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmer le mot de passe',
            hint: 'Répétez le mot de passe',
            textInputAction: TextInputAction.done,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Veuillez confirmer le mot de passe';
              }
              if (val != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.spacing6),

          if (_successMessage != null) ...[
            AppMessageBanner(
              message: _successMessage!,
              type: AppMessageType.success,
            ),
            const SizedBox(height: AppConstants.spacing6),
          ],

          Text('Récapitulatif de votre profil', style: AppTextStyles.h3),
          const SizedBox(height: AppConstants.spacing3),

          // 1. Informations Personnelles
          _RecapCategoryCard(
            title: 'Informations personnelles',
            icon: Icons.person_outline,
            onEdit: () => _goToStep(0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(
                    _selectedAvatarIcon ?? Icons.home_repair_service_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_prenomController.text} ${_nomController.text}',
                        style: AppTextStyles.label,
                      ),
                      Text(
                        _avatarLabel ?? 'Aucune photo ajoutée',
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),

          // 2. Coordonnées
          _RecapCategoryCard(
            title: 'Coordonnées',
            icon: Icons.contact_phone_outlined,
            onEdit: () => _goToStep(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RecapItemRow(
                  label: 'Téléphone',
                  value: '+242 ${_phoneController.text}',
                ),
                const SizedBox(height: 6),
                _RecapItemRow(label: 'E-mail', value: _emailController.text),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),

          // 3. Activité professionnelle
          _RecapCategoryCard(
            title: 'Activité professionnelle',
            icon: Icons.business_center_outlined,
            onEdit: () => _goToStep(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RecapItemRow(
                  label: 'Métier',
                  value: _selectedMetier ?? 'Non renseigné',
                ),
                if (_specialiteController.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _RecapItemRow(
                    label: 'Spécialité',
                    value: _specialiteController.text,
                  ),
                ],
                const SizedBox(height: 6),
                _RecapItemRow(
                  label: 'Expérience',
                  value: _selectedExperience ?? 'Non renseignée',
                ),
                const SizedBox(height: 6),
                Text(
                  'Description :',
                  style: AppTextStyles.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _descriptionController.text,
                  style: AppTextStyles.bodySecondary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),

          // 4. Conditions d'intervention
          _RecapCategoryCard(
            title: "Conditions d'intervention",
            icon: Icons.map_outlined,
            onEdit: () => _goToStep(3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RecapItemRow(label: 'Mode', value: modeLabel),
                const SizedBox(height: 6),
                _RecapItemRow(
                  label: 'Zone',
                  value: _zoneInterventionController.text,
                ),
                if (_adresseAtelierController.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _RecapItemRow(
                    label: 'Atelier',
                    value: _adresseAtelierController.text,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged: _isSubmitted
                    ? null
                    : (value) =>
                          setState(() => _acceptedTerms = value ?? false),
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: InkWell(
                  onTap: _isSubmitted
                      ? null
                      : () => setState(() => _acceptedTerms = !_acceptedTerms),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Text(
                      "J'accepte les conditions générales d'utilisation et la politique de confidentialité de LOBOKO.",
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing6),

          AppPrimaryButton(
            label: 'Terminer mon inscription',
            onPressed: (_acceptedTerms && !_isSubmitted)
                ? _finishRegistration
                : null,
          ),
          const SizedBox(height: AppConstants.spacing3),
          AppSecondaryButton(
            label: 'Retour',
            onPressed: _isSubmitted ? null : _previousStep,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPOSANTS LOCAUX DE SUPPORT (PRIVÉS & RÉUTILISABLES)
// =============================================================================

class _ProfileTag extends StatelessWidget {
  const _ProfileTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppConstants.badgeRadius),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.small.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.small),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.lightGreen : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.label),
                    Text(description, style: AppTextStyles.small),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecapCategoryCard extends StatelessWidget {
  const _RecapCategoryCard({
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: AppTextStyles.label)),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.primary,
                  tooltip: 'Modifier',
                  onPressed: onEdit,
                ),
              ],
            ),
            const Divider(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _RecapItemRow extends StatelessWidget {
  const _RecapItemRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
        const SizedBox(width: AppConstants.spacing2),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.label,
          ),
        ),
      ],
    );
  }
}
