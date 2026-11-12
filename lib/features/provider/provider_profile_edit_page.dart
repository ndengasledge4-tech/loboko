import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/helpers/app_validators.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/inputs/app_phone_field.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Formulaire de modification du profil prestataire local.
class ProviderProfileEditPage extends StatefulWidget {
  const ProviderProfileEditPage({super.key});

  @override
  State<ProviderProfileEditPage> createState() =>
      _ProviderProfileEditPageState();
}

class _ProviderProfileEditPageState extends State<ProviderProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _professionController;
  late final TextEditingController _experienceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _areasController;
  late final TextEditingController _workshopController;
  late MockCatalogInterventionMode _interventionMode;

  MockProviderDashboardProfile get _profile =>
      MockData.providerDashboardProfile;

  @override
  void initState() {
    super.initState();
    final profile = _profile;
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _phoneController = TextEditingController(text: profile.phone ?? '');
    _emailController = TextEditingController(text: profile.email ?? '');
    _professionController = TextEditingController(text: profile.profession);
    _experienceController = TextEditingController(
      text:
          profile.yearsOfExperience?.toString() ??
          profile.experienceLabel ??
          '',
    );
    _descriptionController = TextEditingController(
      text: profile.description ?? '',
    );
    _areasController = TextEditingController(
      text: profile.serviceAreas.join(', '),
    );
    _workshopController = TextEditingController(
      text: profile.workshopAddress ?? '',
    );
    _interventionMode = profile.interventionMode;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _professionController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _areasController.dispose();
    _workshopController.dispose();
    super.dispose();
  }

  String? _validateOptionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return AppValidators.email(value.trim());
  }

  String? _validateExperience(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'L’expérience professionnelle est obligatoire.';
    final years = int.tryParse(text);
    if (years != null && years >= 0) return null;
    const ranges = [
      'Débutant',
      'Moins de 2 ans',
      '2 à 5 ans',
      '5 à 10 ans',
      'Plus de 10 ans',
    ];
    return ranges.contains(text)
        ? null
        : 'Saisissez un nombre d’années ou une fourchette valide.';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final profile = _profile;
    final experienceText = _experienceController.text.trim();
    final years = int.tryParse(experienceText);
    final workshop = _workshopController.text.trim();
    MockData.updateProviderDashboardProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      profession: _professionController.text.trim(),
      specialty: profile.specialty,
      yearsOfExperience: years,
      experienceLabel: years == null ? experienceText : null,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      serviceAreas: _areasController.text
          .split(RegExp(r'[,;\n]'))
          .map((area) => area.trim())
          .where((area) => area.isNotEmpty)
          .toList(),
      interventionMode: _interventionMode,
      workshopAddress:
          _interventionMode == MockCatalogInterventionMode.home ||
              workshop.isEmpty
          ? null
          : workshop,
      avatarIcon: profile.avatarIcon,
      isDemo: profile.isDemo,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      leading: const AppBackButton(),
      title: const Text('Modifier mon profil'),
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations professionnelles',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppConstants.spacing2),
                  Text(
                    'Les modifications sont conservées localement pendant la démonstration.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppConstants.spacing5),
                  AppTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) => AppValidators.required(
                      value,
                      'Le prénom est obligatoire.',
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  AppTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) => AppValidators.required(
                      value,
                      'Le nom est obligatoire.',
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  AppPhoneField(
                    controller: _phoneController,
                    validator: (value) => AppValidators.phone(
                      value,
                      'Veuillez saisir un numéro de téléphone valide.',
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  AppTextField(
                    controller: _emailController,
                    label: 'Adresse e-mail (facultative)',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateOptionalEmail,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  AppTextField(
                    controller: _professionController,
                    label: 'Profession',
                    prefixIcon: Icons.work_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) => AppValidators.required(
                      value,
                      'La profession est obligatoire.',
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  AppTextField(
                    controller: _experienceController,
                    label: 'Années d’expérience ou fourchette',
                    prefixIcon: Icons.workspace_premium_outlined,
                    hint: 'Ex. 5 ou 2 à 5 ans',
                    textInputAction: TextInputAction.next,
                    validator: _validateExperience,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Présentation professionnelle',
                    prefixIcon: Icons.description_outlined,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  AppTextField(
                    controller: _areasController,
                    label: 'Zones d’intervention',
                    hint: 'Séparez les quartiers par une virgule',
                    prefixIcon: Icons.location_on_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (value) => AppValidators.required(
                      value,
                      'Indiquez au moins une zone d’intervention.',
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _modeDropdown(),
                  if (_interventionMode !=
                      MockCatalogInterventionMode.home) ...[
                    const SizedBox(height: AppConstants.spacing4),
                    AppTextField(
                      controller: _workshopController,
                      label: 'Adresse de l’atelier',
                      prefixIcon: Icons.storefront_outlined,
                      textInputAction: TextInputAction.done,
                      validator: (value) => AppValidators.required(
                        value,
                        'L’adresse de l’atelier est obligatoire pour ce mode.',
                      ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacing5),
                  AppPrimaryButton(
                    label: 'Enregistrer les modifications',
                    icon: Icons.check,
                    onPressed: _save,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _modeDropdown() =>
      DropdownButtonFormField<MockCatalogInterventionMode>(
        initialValue: _interventionMode,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Mode d’intervention',
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing4,
            vertical: AppConstants.spacing4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: MockCatalogInterventionMode.home,
            child: Text('À domicile'),
          ),
          DropdownMenuItem(
            value: MockCatalogInterventionMode.workshop,
            child: Text('En atelier'),
          ),
          DropdownMenuItem(
            value: MockCatalogInterventionMode.both,
            child: Text('À domicile et en atelier'),
          ),
        ],
        onChanged: (value) => setState(() => _interventionMode = value!),
      );
}
