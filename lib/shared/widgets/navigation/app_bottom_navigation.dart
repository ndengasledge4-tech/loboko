import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Destination d'une barre de navigation inférieure.
class AppNavigationDestination {
  const AppNavigationDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int badgeCount;
}

/// Barre de navigation inférieure réutilisable de LOBOKO.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
  }) : assert(destinations.length >= 2),
       assert(destinations.length <= 5),
       assert(currentIndex >= 0),
       assert(currentIndex < destinations.length);

  final List<AppNavigationDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final navigationBarTheme = Theme.of(context).navigationBarTheme;
    final labelTextStyle = navigationBarTheme.labelTextStyle;

    return SafeArea(
      top: false,
      child: Material(
        color: AppColors.white,
        child: SizedBox(
          height: navigationBarTheme.height ?? 80,
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _NavigationDestinationButton(
                    destination: destinations[index],
                    selected: index == currentIndex,
                    labelStyle:
                        labelTextStyle?.resolve(
                          index == currentIndex
                              ? const {WidgetState.selected}
                              : const {},
                        ) ??
                        Theme.of(context).textTheme.labelSmall ??
                        const TextStyle(fontSize: 11),
                    onTap: () => onDestinationSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationDestinationButton extends StatelessWidget {
  const _NavigationDestinationButton({
    required this.destination,
    required this.selected,
    required this.labelStyle,
    required this.onTap,
  });

  final AppNavigationDestination destination;
  final bool selected;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? destination.activeIcon : destination.icon;
    final iconColor = selected ? AppColors.primary : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.lightGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Badge(
                      isLabelVisible: destination.badgeCount > 0,
                      label: Text(
                        destination.badgeCount > 99
                            ? '99+'
                            : '${destination.badgeCount}',
                      ),
                      backgroundColor: AppColors.errorText,
                      textColor: AppColors.white,
                      child: Icon(icon, color: iconColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 14,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    softWrap: false,
                    style: labelStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
