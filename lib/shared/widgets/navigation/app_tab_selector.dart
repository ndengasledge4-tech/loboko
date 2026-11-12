import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Sélecteur d'onglets réutilisable de LOBOKO.
class AppTabSelector extends StatelessWidget {
  const AppTabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.isScrollable = false,
  })  : assert(tabs.length >= 2),
        assert(selectedIndex >= 0),
        assert(selectedIndex < tabs.length);

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool isScrollable;

  Widget _buildTabItem(int index, String title) {
    final isSelected = index == selectedIndex;
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing4,
          vertical: AppConstants.spacing3,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: isSelected
              ? AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                )
              : AppTextStyles.bodySecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isScrollable) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              tabs.length,
              (index) => _buildTabItem(index, tabs[index]),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: _buildTabItem(index, tabs[index]),
          ),
        ),
      ),
    );
  }
}
