import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/feedback/app_error_state.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Formulaire d'ajout ou de modification d'une prestation de démonstration.
class ProviderServiceFormPage extends StatefulWidget {
  const ProviderServiceFormPage({super.key, this.serviceId});

  final String? serviceId;

  @override
  State<ProviderServiceFormPage> createState() =>
      _ProviderServiceFormPageState();
}

class _ProviderServiceFormPageState extends State<ProviderServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  MockCatalogPricingType _pricingType = MockCatalogPricingType.fixed;
  MockCatalogInterventionMode _interventionMode =
      MockCatalogInterventionMode.home;

  MockProviderCatalogService? get _service => widget.serviceId == null
      ? null
      : MockData.providerCatalogServiceById(widget.serviceId!);

  @override
  void initState() {
    super.initState();
    final service = _service;
    if (service != null) {
      _nameController.text = service.name;
      _descriptionController.text = service.description;
      _priceController.text = service.price?.toStringAsFixed(0) ?? '';
      _durationController.text =
          service.estimatedDurationMinutes?.toString() ?? '';
      _pricingType = service.pricingType;
      _interventionMode = service.interventionMode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'Saisissez un montant supérieur à zéro.';
    }
    return null;
  }

  String? _validateDuration(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return 'Saisissez une durée entière supérieure à zéro.';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final priceText = _priceController.text.trim();
    final price = priceText.isEmpty
        ? null
        : double.parse(priceText.replaceAll(',', '.'));
    final durationText = _durationController.text.trim();
    final duration = durationText.isEmpty ? null : int.parse(durationText);
    final serviceId = widget.serviceId;
    if (serviceId == null) {
      MockData.addProviderCatalogService(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        pricingType: _pricingType,
        interventionMode: _interventionMode,
        estimatedDurationMinutes: duration,
      );
    } else {
      final updated = MockData.updateProviderCatalogService(
        id: serviceId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        pricingType: _pricingType,
        interventionMode: _interventionMode,
        estimatedDurationMinutes: duration,
      );
      if (!updated) return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.serviceId != null;
    final serviceIsValid = !isEditing || _service != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(isEditing ? 'Modifier le service' : 'Ajouter un service'),
      ),
      body: !serviceIsValid
          ? AppErrorState(
              title: 'Service introuvable',
              message:
                  'Ce service n’est plus disponible dans le catalogue de démonstration.',
              retryLabel: 'Retour',
              onRetry: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            )
          : SafeArea(
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
                            'Informations de la prestation',
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: AppConstants.spacing2),
                          Text(
                            'Ces informations seront conservées dans le catalogue local de démonstration.',
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: AppConstants.spacing5),
                          AppTextField(
                            controller: _nameController,
                            label: 'Nom du service',
                            hint: 'Ex. Dépannage plomberie',
                            prefixIcon: Icons.home_repair_service_outlined,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Le nom du service est obligatoire.'
                                : null,
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          AppTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            hint: 'Décrivez brièvement la prestation',
                            prefixIcon: Icons.description_outlined,
                            textInputAction: TextInputAction.newline,
                            maxLines: 4,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'La description est obligatoire.'
                                : null,
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          AppTextField(
                            controller: _priceController,
                            label: 'Prix indicatif en FCFA (facultatif)',
                            hint: 'Ex. 15000',
                            prefixIcon: Icons.payments_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: _validatePrice,
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          _dropdown<MockCatalogPricingType>(
                            label: 'Type de tarification',
                            value: _pricingType,
                            items: const {
                              MockCatalogPricingType.fixed: 'Prix fixe',
                              MockCatalogPricingType.quote: 'Sur devis',
                            },
                            onChanged: (value) =>
                                setState(() => _pricingType = value!),
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          _dropdown<MockCatalogInterventionMode>(
                            label: 'Mode d’intervention',
                            value: _interventionMode,
                            items: const {
                              MockCatalogInterventionMode.home: 'À domicile',
                              MockCatalogInterventionMode.workshop:
                                  'En atelier',
                              MockCatalogInterventionMode.both:
                                  'À domicile et en atelier',
                            },
                            onChanged: (value) =>
                                setState(() => _interventionMode = value!),
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          AppTextField(
                            controller: _durationController,
                            label: 'Durée estimée en minutes (facultatif)',
                            hint: 'Ex. 60',
                            prefixIcon: Icons.schedule_outlined,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            validator: _validateDuration,
                          ),
                          const SizedBox(height: AppConstants.spacing5),
                          AppPrimaryButton(
                            label: isEditing
                                ? 'Enregistrer les modifications'
                                : 'Ajouter au catalogue',
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
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) => DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
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
    style: AppTextStyles.body,
    items: items.entries
        .map(
          (entry) => DropdownMenuItem<T>(
            value: entry.key,
            child: Text(entry.value, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );
}
