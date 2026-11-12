import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/feedback/app_message_banner.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Page de gestion des disponibilités hebdomadaires du Prestataire.
class ProviderAvailabilityPage extends StatefulWidget {
  const ProviderAvailabilityPage({super.key});

  @override
  State<ProviderAvailabilityPage> createState() =>
      _ProviderAvailabilityPageState();
}

class _ProviderAvailabilityPageState extends State<ProviderAvailabilityPage> {
  late List<MockDayAvailability> _days;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _days = MockData.providerAvailability;
  }

  Future<void> _pickTime(
    BuildContext context,
    MockDayAvailability day,
    bool isStart,
  ) async {
    final initial = isStart
        ? TimeOfDay(hour: day.startHour, minute: day.startMinute)
        : TimeOfDay(hour: day.endHour, minute: day.endMinute);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          day.startHour = picked.hour;
          day.startMinute = picked.minute;
        } else {
          day.endHour = picked.hour;
          day.endMinute = picked.minute;
        }
      });
    }
  }

  void _saveAvailability() {
    // Validation que l'heure de fin est après l'heure de début pour les jours actifs
    for (final day in _days) {
      if (day.isOpen) {
        final startMins = day.startHour * 60 + day.startMinute;
        final endMins = day.endHour * 60 + day.endMinute;
        if (endMins <= startMins) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'L’heure de fin pour ${day.dayName} doit être supérieure à l’heure de début.',
              ),
              backgroundColor: AppColors.errorText,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    setState(() {
      _successMessage =
          'Vos disponibilités hebdomadaires ont été enregistrées avec succès.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disponibilités enregistrées avec succès !'),
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
        title: const Text('Mes disponibilités'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Jours et horaires d’intervention',
                    style: AppTextStyles.h1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Définissez vos plages horaires pour recevoir des demandes adaptées à votre emploi du temps.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppConstants.spacing5),

                  if (_successMessage != null) ...[
                    AppMessageBanner(
                      message: _successMessage!,
                      type: AppMessageType.success,
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                  ],

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _days.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Switch(
                                    value: day.isOpen,
                                    activeThumbColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        day.isOpen = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    day.dayName,
                                    style: AppTextStyles.h3,
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: day.isOpen
                                          ? AppColors.lightGreen
                                          : AppColors.disabledBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      day.isOpen ? 'Disponible' : 'Repos / Indisponible',
                                      style: AppTextStyles.small.copyWith(
                                        color: day.isOpen
                                            ? AppColors.primary
                                            : AppColors.disabledText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (day.isOpen) ...[
                                const Divider(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _TimeSelectorTile(
                                        label: 'Début',
                                        timeString: day.startTimeFormatted,
                                        onTap: () => _pickTime(context, day, true),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('à', style: AppTextStyles.bodySecondary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _TimeSelectorTile(
                                        label: 'Fin',
                                        timeString: day.endTimeFormatted,
                                        onTap: () => _pickTime(context, day, false),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing8),

                  AppPrimaryButton(
                    label: 'Enregistrer mes disponibilités',
                    icon: Icons.save_outlined,
                    onPressed: _saveAvailability,
                  ),
                  const SizedBox(height: AppConstants.spacing6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeSelectorTile extends StatelessWidget {
  const _TimeSelectorTile({
    required this.label,
    required this.timeString,
    required this.onTap,
  });

  final String label;
  final String timeString;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightGreen.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.small),
                const SizedBox(height: 2),
                Text(timeString, style: AppTextStyles.label),
              ],
            ),
            const Icon(Icons.access_time, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
