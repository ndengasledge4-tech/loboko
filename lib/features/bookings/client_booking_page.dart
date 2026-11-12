import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/buttons/app_secondary_button.dart';
import '../../shared/widgets/feedback/app_error_state.dart';
import '../../shared/widgets/inputs/app_multiline_field.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

enum _BookingLocation { home, workshop }

class ClientBookingPage extends StatefulWidget {
  const ClientBookingPage({super.key, required this.providerId});

  final String? providerId;

  @override
  State<ClientBookingPage> createState() => _ClientBookingPageState();
}

class _ClientBookingPageState extends State<ClientBookingPage> {
  static const _timeSlots = ['08:00 – 12:00', '12:00 – 15:00', '15:00 – 18:00'];
  final _pageController = PageController();
  final _descriptionController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _addressController = TextEditingController();
  int _step = 0;
  String? _selectedServiceName;
  _BookingLocation? _location;
  DateTime? _desiredDate;
  String? _timeSlot;
  String? _stepError;

  MockProvider? get _provider {
    for (final provider in MockData.popularProviders) {
      if (provider.id == widget.providerId) return provider;
    }
    return null;
  }

  List<MockProviderService> _servicesFor(MockProvider provider) =>
      provider.services.isNotEmpty
      ? provider.services
      : [MockProviderService(name: provider.specialty, price: provider.price)];

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    _neighborhoodController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep(MockProvider provider) {
    String? error;
    switch (_step) {
      case 0:
        if (_selectedServiceName == null) {
          error = 'Sélectionnez une prestation pour continuer.';
        }
        break;
      case 1:
        if (_descriptionController.text.trim().isEmpty) {
          error = 'Décrivez le besoin pour continuer.';
        }
        break;
      case 2:
        if (_location == null) {
          error = 'Choisissez le lieu d’intervention souhaité.';
        } else if (_location == _BookingLocation.home &&
            _neighborhoodController.text.trim().isEmpty) {
          error = 'Indiquez votre quartier à Brazzaville.';
        } else if (_location == _BookingLocation.home &&
            _addressController.text.trim().isEmpty) {
          error = 'Ajoutez une adresse ou des indications.';
        } else if (_location == _BookingLocation.workshop &&
            provider.workshopAddress == null) {
          error = 'Aucune adresse d’atelier n’est renseignée.';
        }
        break;
      case 3:
        if (_desiredDate == null) {
          error = 'Choisissez une date souhaitée.';
        } else if (_timeSlot == null) {
          error = 'Choisissez une plage horaire souhaitée.';
        }
        break;
      default:
        break;
    }
    setState(() => _stepError = error);
    return error == null;
  }

  Future<void> _advance(MockProvider provider) async {
    if (!_validateCurrentStep(provider)) return;
    if (_step < 4) {
      setState(() {
        _step++;
        _stepError = null;
      });
      await _pageController.animateToPage(
        _step,
        duration: AppConstants.animationNormal,
        curve: Curves.easeOut,
      );
    } else {
      _submit(provider);
    }
  }

  Future<void> _goToStep(int step) async {
    setState(() {
      _step = step;
      _stepError = null;
    });
    await _pageController.animateToPage(
      step,
      duration: AppConstants.animationNormal,
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _desiredDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Choisissez une date souhaitée',
      cancelText: 'Annuler',
      confirmText: 'Choisir',
    );
    if (picked != null) setState(() => _desiredDate = picked);
  }

  void _submit(MockProvider provider) {
    final service = _servicesFor(
      provider,
    ).firstWhere((item) => item.name == _selectedServiceName);
    final isHome = _location == _BookingLocation.home;
    final location = isHome
        ? '${_neighborhoodController.text.trim()}, Brazzaville — ${_addressController.text.trim()}'
        : provider.workshopAddress!;
    final request = MockData.createBookingRequest(
      clientId: 'demo_client',
      clientName: MockData.clientProfile?.fullName ?? 'Grace',
      providerId: provider.id,
      providerName: provider.name,
      serviceName: service.name,
      description: _descriptionController.text.trim(),
      locationType: isHome ? 'À domicile' : 'À l’atelier',
      location: location,
      desiredDate: _desiredDate!,
      timeSlot: _timeSlot!,
      estimatedPrice: service.price,
    );
    final createdAt = request.createdAt;
    final bookingId = request.id;
    MockData.addNotification(
      type: MockNotificationType.bookingCreated,
      title: 'Demande de réservation enregistrée',
      message:
          'Votre demande pour ${service.name} auprès de ${provider.name} est enregistrée dans cette démonstration.',
      bookingId: bookingId,
      providerId: provider.id,
      createdAt: createdAt,
    );
    if (provider.id == MockData.providerDashboardProfile.providerId) {
      MockData.addProviderNotification(
        type: MockProviderNotificationType.newRequest,
        title: 'Nouvelle demande de prestation',
        message: 'Une demande de démonstration concerne ${service.name}.',
        bookingId: bookingId,
        createdAt: createdAt,
      );
    }
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.clientBookingConfirmation,
      arguments: bookingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    if (provider == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: const AppBackButton(),
          backgroundColor: AppColors.background,
        ),
        body: AppErrorState(
          title: 'Prestataire introuvable',
          message:
              'La réservation ne peut pas être préparée sans prestataire valide.',
          retryLabel: 'Retour',
          onRetry: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('Demande de réservation', style: AppTextStyles.h3),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Étape ${_step + 1} sur 5',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_step + 1) / 5,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.secondary,
                    backgroundColor: AppColors.lightGreen,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _stepPage(_serviceStep(provider)),
                  _stepPage(_descriptionStep()),
                  _stepPage(_locationStep(provider)),
                  _stepPage(_scheduleStep()),
                  _stepPage(_summaryStep(provider)),
                ],
              ),
            ),
            if (_stepError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  _stepError!,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.errorText,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing4),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Précédent',
                        onPressed: () => _goToStep(_step - 1),
                      ),
                    )
                  else
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Annuler',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppPrimaryButton(
                      label: _step == 4 ? 'Envoyer la demande' : 'Continuer',
                      onPressed: () => _advance(provider),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepPage(Widget child) =>
      SingleChildScrollView(padding: AppConstants.screenPadding, child: child);

  Widget _serviceStep(MockProvider provider) {
    final services = _servicesFor(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProviderSummary(provider: provider),
        const SizedBox(height: AppConstants.spacing5),
        Text('Choisissez une prestation', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Sélectionnez le service que vous souhaitez demander.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppConstants.spacing3),
        RadioGroup<String>(
          groupValue: _selectedServiceName,
          onChanged: (value) => setState(() {
            _selectedServiceName = value;
            _stepError = null;
          }),
          child: Column(
            children: [
              for (final service in services)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.cardRadius,
                    ),
                    side: BorderSide(
                      color: _selectedServiceName == service.name
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: service.name,
                    activeColor: AppColors.primary,
                    title: Text(service.name, style: AppTextStyles.label),
                    subtitle: Text(
                      service.price == null
                          ? 'Tarif à confirmer'
                          : 'À partir de ${service.price!.toStringAsFixed(0)} FCFA · indicatif',
                      style: AppTextStyles.small,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _descriptionStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Décrivez votre besoin', style: AppTextStyles.h2),
      const SizedBox(height: 8),
      Text(
        'Quelques détails aideront le prestataire à comprendre votre demande.',
        style: AppTextStyles.bodySecondary,
      ),
      const SizedBox(height: AppConstants.spacing4),
      AppMultilineField(
        controller: _descriptionController,
        label: 'Description du besoin',
        hint: 'Décrivez votre problème ou votre besoin…',
        minLines: 5,
        maxLines: 8,
        maxLength: 800,
        errorText: _step == 1 ? _stepError : null,
        onChanged: (_) => setState(() => _stepError = null),
      ),
    ],
  );

  Widget _locationStep(MockProvider provider) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Lieu d’intervention', style: AppTextStyles.h2),
      const SizedBox(height: 6),
      Text(
        'Choisissez où vous souhaitez recevoir la prestation.',
        style: AppTextStyles.bodySecondary,
      ),
      const SizedBox(height: AppConstants.spacing3),
      RadioGroup<_BookingLocation>(
        groupValue: _location,
        onChanged: (selected) => setState(() {
          _location = selected;
          _stepError = null;
        }),
        child: Column(
          children: [
            if (provider.offersHomeVisit)
              _locationOption(
                title: 'À domicile',
                subtitle: 'Intervention dans un quartier de Brazzaville',
                value: _BookingLocation.home,
              ),
            if (provider.workshopAddress != null)
              _locationOption(
                title: 'À l’atelier du prestataire',
                subtitle: provider.workshopAddress!,
                value: _BookingLocation.workshop,
              ),
          ],
        ),
      ),
      if (_location == _BookingLocation.home) ...[
        const SizedBox(height: AppConstants.spacing3),
        AppTextField(
          controller: _neighborhoodController,
          label: 'Quartier à Brazzaville',
          hint: 'Ex. Bacongo, Moungali…',
          prefixIcon: Icons.location_city_outlined,
          errorText: _step == 2 && _stepError?.contains('quartier') == true
              ? _stepError
              : null,
          onChanged: (_) => setState(() => _stepError = null),
        ),
        const SizedBox(height: AppConstants.spacing3),
        AppTextField(
          controller: _addressController,
          label: 'Adresse ou indications',
          hint: 'Rue, repère ou instructions pour vous trouver',
          prefixIcon: Icons.place_outlined,
          maxLines: 2,
          errorText: _step == 2 && _stepError?.contains('adresse') == true
              ? _stepError
              : null,
          onChanged: (_) => setState(() => _stepError = null),
        ),
      ],
      if (_location == _BookingLocation.workshop &&
          provider.workshopAddress != null) ...[
        const SizedBox(height: AppConstants.spacing3),
        _InfoPanel(text: 'Adresse de l’atelier : ${provider.workshopAddress}'),
      ],
    ],
  );

  Widget _locationOption({
    required String title,
    required String subtitle,
    required _BookingLocation value,
  }) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 0,
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      side: BorderSide(
        color: _location == value ? AppColors.primary : AppColors.border,
      ),
    ),
    child: RadioListTile<_BookingLocation>(
      value: value,
      activeColor: AppColors.primary,
      title: Text(title, style: AppTextStyles.label),
      subtitle: Text(subtitle, style: AppTextStyles.small),
    ),
  );

  Widget _scheduleStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Date et horaire souhaités', style: AppTextStyles.h2),
      const SizedBox(height: 6),
      Text(
        'Il s’agit de vos préférences, pas d’une confirmation de disponibilité.',
        style: AppTextStyles.bodySecondary,
      ),
      const SizedBox(height: AppConstants.spacing4),
      OutlinedButton.icon(
        onPressed: _pickDate,
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text(
          _desiredDate == null
              ? 'Choisir une date'
              : _formatDate(_desiredDate!),
        ),
      ),
      if (_step == 3 && _desiredDate == null && _stepError != null) ...[
        const SizedBox(height: 4),
        Text(
          _stepError!,
          style: AppTextStyles.small.copyWith(color: AppColors.errorText),
        ),
      ],
      const SizedBox(height: AppConstants.spacing5),
      Text('Plage horaire souhaitée', style: AppTextStyles.label),
      const SizedBox(height: AppConstants.spacing2),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final slot in _timeSlots)
            ChoiceChip(
              label: Text(slot),
              selected: _timeSlot == slot,
              selectedColor: AppColors.lightGreen,
              side: BorderSide(
                color: _timeSlot == slot ? AppColors.primary : AppColors.border,
              ),
              onSelected: (_) => setState(() {
                _timeSlot = slot;
                _stepError = null;
              }),
            ),
        ],
      ),
      if (_step == 3 &&
          _timeSlot == null &&
          _stepError?.contains('plage') == true) ...[
        const SizedBox(height: 4),
        Text(
          _stepError!,
          style: AppTextStyles.small.copyWith(color: AppColors.errorText),
        ),
      ],
      const SizedBox(height: AppConstants.spacing3),
      const _InfoPanel(
        text:
            'Les plages proposées sont des préférences de demande. Le prestataire devra confirmer ou refuser la demande.',
      ),
    ],
  );

  Widget _summaryStep(MockProvider provider) {
    final service = _servicesFor(provider).firstWhere(
      (item) => item.name == _selectedServiceName,
      orElse: () => _servicesFor(provider).first,
    );
    final location = _location == _BookingLocation.home
        ? '${_neighborhoodController.text.trim()}, Brazzaville — ${_addressController.text.trim()}'
        : provider.workshopAddress ?? 'Non renseigné';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Récapitulatif', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Vérifiez votre demande avant de l’envoyer.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppConstants.spacing4),
        _SummaryCard(
          title: 'Prestataire et prestation',
          value: '${provider.name}\n${service.name}',
          onEdit: () => _goToStep(0),
        ),
        _SummaryCard(
          title: 'Votre besoin',
          value: _descriptionController.text.trim(),
          onEdit: () => _goToStep(1),
        ),
        _SummaryCard(
          title: 'Lieu',
          value:
              '${_location == _BookingLocation.home ? 'À domicile' : 'À l’atelier'}\n$location',
          onEdit: () => _goToStep(2),
        ),
        _SummaryCard(
          title: 'Date et horaire souhaités',
          value:
              '${_desiredDate == null ? '—' : _formatDate(_desiredDate!)} · ${_timeSlot ?? '—'}',
          onEdit: () => _goToStep(3),
        ),
        if (service.price != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _InfoPanel(
              text:
                  'Tarif indicatif : à partir de ${service.price!.toStringAsFixed(0)} FCFA. Le montant définitif reste à confirmer.',
            ),
          ),
        const SizedBox(height: AppConstants.spacing3),
        Text(
          'La demande sera enregistrée en démonstration avec le statut « En attente ». Aucun paiement ne sera demandé.',
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _ProviderSummary extends StatelessWidget {
  const _ProviderSummary({required this.provider});
  final MockProvider provider;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipOval(
        child: Image.network(
          _portraitFor(provider.id),
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 64,
            height: 64,
            color: AppColors.lightGreen,
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.name, style: AppTextStyles.h3.copyWith(fontSize: 17)),
            const SizedBox(height: 4),
            Text(provider.specialty, style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    ],
  );

  String _portraitFor(String id) {
    final index =
        int.tryParse(id.replaceAll(RegExp(r'\D'), '')) ??
        id.hashCode.abs() % 10;
    return 'https://images.unsplash.com/photo-${index.isEven ? '1500648767791-00dcc994a43e' : '1534528741775-53994a69daeb'}?auto=format&fit=crop&w=160&h=160&q=80';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.onEdit,
  });
  final String title;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 0,
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 5),
                Text(value, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Modifier')),
        ],
      ),
    ),
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.lightGreen,
      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
    ),
    child: Text(
      text,
      style: AppTextStyles.small.copyWith(color: AppColors.primary),
    ),
  );
}
