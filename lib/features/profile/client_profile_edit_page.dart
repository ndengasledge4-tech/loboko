import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/helpers/app_validators.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Saisie locale des coordonnées Client pour la session de démonstration.
class ClientProfileEditPage extends StatefulWidget {
  const ClientProfileEditPage({super.key});

  @override
  State<ClientProfileEditPage> createState() => _ClientProfileEditPageState();
}

class _ClientProfileEditPageState extends State<ClientProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  IconData? _avatarIcon;

  @override
  void initState() {
    super.initState();
    final profile = MockData.clientProfile;
    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _avatarIcon = profile?.avatarIcon;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _chooseAvatar() async {
    final selected = await showModalBottomSheet<IconData?>(
      context: context,
      backgroundColor: AppColors.white,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing4),
              child: Text(
                'Choisir un avatar illustratif',
                style: AppTextStyles.h3,
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.person_pin_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Avatar classique'),
              onTap: () => Navigator.pop(context, Icons.person_pin_outlined),
            ),
            ListTile(
              leading: const Icon(
                Icons.face_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Avatar visage'),
              onTap: () => Navigator.pop(context, Icons.face_outlined),
            ),
            ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
              ),
              title: const Text('Avatar par défaut'),
              onTap: () => Navigator.pop(context, null),
            ),
            const SizedBox(height: AppConstants.spacing3),
          ],
        ),
      ),
    );
    if (mounted) setState(() => _avatarIcon = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    MockData.clientProfile = MockClientProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarIcon: _avatarIcon,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('Modifier mon profil', style: AppTextStyles.h3),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppConstants.screenPadding,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.lightGreen,
                      child: Icon(
                        _avatarIcon ?? Icons.person_outline,
                        size: 42,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: _chooseAvatar,
                      icon: const Icon(Icons.face_retouching_natural_outlined),
                      label: const Text('Choisir un avatar illustratif'),
                    ),
                    Text(
                      'Aucune photo personnelle n’est importée dans cette démonstration.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing4),
              AppTextField(
                controller: _firstNameController,
                label: 'Prénom',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidators.required(
                  value,
                  'Veuillez saisir votre prénom.',
                ),
              ),
              const SizedBox(height: AppConstants.spacing3),
              AppTextField(
                controller: _lastNameController,
                label: 'Nom',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    AppValidators.required(value, 'Veuillez saisir votre nom.'),
              ),
              const SizedBox(height: AppConstants.spacing3),
              AppTextField(
                controller: _emailController,
                label: 'Adresse e-mail',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: AppValidators.email,
              ),
              const SizedBox(height: AppConstants.spacing3),
              AppTextField(
                controller: _phoneController,
                label: 'Numéro de téléphone',
                hint: 'Ex. +242 06 123 45 67',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: AppValidators.phone,
              ),
              const SizedBox(height: AppConstants.spacing5),
              const Text(
                'Ces informations sont conservées uniquement en mémoire pendant la session.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing3),
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
    );
  }
}
