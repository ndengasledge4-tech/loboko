import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';
import 'provider_dashboard_page.dart';
import 'provider_missions_page.dart';
import 'provider_messages_page.dart';
import 'provider_profile_page.dart';
import 'provider_requests_page.dart';

/// Navigation persistante de l'espace prestataire.
class ProviderWorkspacePage extends StatefulWidget {
  const ProviderWorkspacePage({super.key});
  @override
  State<ProviderWorkspacePage> createState() => _ProviderWorkspacePageState();
}

class _ProviderWorkspacePageState extends State<ProviderWorkspacePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      const AppNavigationDestination(
        label: 'Accueil',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      const AppNavigationDestination(
        label: 'Demandes',
        icon: Icons.inbox_outlined,
        activeIcon: Icons.inbox,
      ),
      const AppNavigationDestination(
        label: 'Missions',
        icon: Icons.work_outline,
        activeIcon: Icons.work,
      ),
      AppNavigationDestination(
        label: 'Messages',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        badgeCount: MockData.providerUnreadMessageCount,
      ),
      const AppNavigationDestination(
        label: 'Profil',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: const [
          ProviderDashboardPage(showBottomNavigation: false),
          ProviderRequestsPage(showBottomNavigation: false),
          ProviderMissionsPage(showBottomNavigation: false),
          ProviderMessagesPage(showBottomNavigation: false),
          ProviderProfilePage(showBottomNavigation: false),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _index,
        destinations: destinations,
        onDestinationSelected: (index) => setState(() => _index = index),
      ),
    );
  }
}
