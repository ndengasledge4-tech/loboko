import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../shared/widgets/feedback/app_empty_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Catalogue local du prestataire de démonstration.
class ProviderServicesPage extends StatefulWidget {
  const ProviderServicesPage({super.key});

  @override
  State<ProviderServicesPage> createState() => _ProviderServicesPageState();
}

class _ProviderServicesPageState extends State<ProviderServicesPage> {
  List<MockProviderCatalogService> get _services =>
      List<MockProviderCatalogService>.of(MockData.providerCatalogServices);

  Future<void> _openForm([String? serviceId]) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.providerServiceForm, arguments: serviceId);
    if (mounted) setState(() {});
  }

  Future<void> _delete(MockProviderCatalogService service) async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: 'Supprimer ce service ?',
      message:
          '« ${service.name} » sera retiré du catalogue local de démonstration.',
      confirmLabel: 'Supprimer',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    if (MockData.removeProviderCatalogService(service.id)) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service supprimé de la démonstration.')),
      );
    }
  }

  Future<void> _toggle(MockProviderCatalogService service, bool value) async {
    if (!MockData.setProviderCatalogServiceActive(
      id: service.id,
      isActive: value,
    )) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Mes services'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gérez les prestations proposées à vos clients.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppConstants.spacing3),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.spacing3),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardRadius,
                          ),
                        ),
                        child: Text(
                          'Catalogue de démonstration : les modifications restent locales en mémoire et ne publient pas vos services sur une plateforme.',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: services.isEmpty
                  ? AppEmptyState(
                      title: 'Aucun service pour le moment',
                      message:
                          'Ajoutez une prestation pour la retrouver dans votre catalogue de démonstration.',
                      icon: Icons.home_repair_service_outlined,
                      actionLabel: 'Ajouter un service',
                      onAction: _openForm,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: services.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppConstants.spacing3),
                      itemBuilder: (context, index) => Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: _serviceCard(services[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: services.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _openForm,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un service'),
            ),
    );
  }

  Widget _serviceCard(MockProviderCatalogService service) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: AppConstants.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home_repair_service_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name, style: AppTextStyles.h3),
                    const SizedBox(height: AppConstants.spacing2),
                    Text(
                      service.description,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Actions sur le service',
                onSelected: (action) {
                  if (action == 'edit') _openForm(service.id);
                  if (action == 'delete') _delete(service);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing3),
          Wrap(
            spacing: AppConstants.spacing2,
            runSpacing: AppConstants.spacing2,
            children: [
              _ServiceTag(text: _priceLabel(service)),
              _ServiceTag(text: _interventionLabel(service.interventionMode)),
              if (service.estimatedDurationMinutes != null)
                _ServiceTag(text: '${service.estimatedDurationMinutes} min'),
            ],
          ),
          const Divider(height: AppConstants.spacing6),
          Row(
            children: [
              Expanded(
                child: Text(
                  service.isActive ? 'Service actif' : 'Service inactif',
                  style: AppTextStyles.label.copyWith(
                    color: service.isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: service.isActive,
                onChanged: (value) => _toggle(service, value),
                activeTrackColor: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  String _priceLabel(MockProviderCatalogService service) {
    if (service.pricingType == MockCatalogPricingType.quote) return 'Sur devis';
    final price = service.price;
    return price == null
        ? 'Prix fixe non renseigné'
        : '${price.toStringAsFixed(0)} FCFA';
  }

  String _interventionLabel(MockCatalogInterventionMode mode) => switch (mode) {
    MockCatalogInterventionMode.home => 'À domicile',
    MockCatalogInterventionMode.workshop => 'En atelier',
    MockCatalogInterventionMode.both => 'Domicile et atelier',
  };
}

class _ServiceTag extends StatelessWidget {
  const _ServiceTag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.lightGreen,
      borderRadius: BorderRadius.circular(AppConstants.badgeRadius),
    ),
    child: Text(
      text,
      style: AppTextStyles.small.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
