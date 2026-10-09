import 'package:flutter/material.dart';
import '../../../data/mock/mock_governance_notifications.dart';
import '../home/governance_overview_screen.dart';
import '../notification/governance_notification_screen.dart';
import '../profile/governance_profile_screen.dart';
import '../tools/governance_tools_screen.dart';
import 'governance_data_management_screen.dart';

class GovernanceMainScreen extends StatefulWidget {
  const GovernanceMainScreen({super.key});
  @override
  State<GovernanceMainScreen> createState() => _GovernanceMainScreenState();
}

class _GovernanceMainScreenState extends State<GovernanceMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages = const [
    GovernanceOverviewScreen(),
    GovernanceDataManagementScreen(),
    GovernanceToolsScreen(),
    GovernanceNotificationScreen(),
    GovernanceProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final notices = MockGovernanceNotifications.instance;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AnimatedBuilder(
        animation: notices,
        builder: (context, _) => NavigationBar(
          selectedIndex: _currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Tổng quan',
            ),
            const NavigationDestination(
              icon: Icon(Icons.dataset_outlined),
              selectedIcon: Icon(Icons.dataset),
              label: 'Dữ liệu',
            ),
            const NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune),
              label: 'Công cụ',
            ),
            NavigationDestination(
              icon: _Bell(notices.unreadCount),
              selectedIcon: _Bell(notices.unreadCount, selected: true),
              label: 'Thông báo',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}

class _Bell extends StatelessWidget {
  final int count;
  final bool selected;
  const _Bell(this.count, {this.selected = false});
  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Icon(selected ? Icons.notifications : Icons.notifications_outlined),
      if (count > 0)
        Positioned(
          top: -5,
          right: -9,
          child: Container(
            constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              count > 9 ? '9+' : '$count',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  );
}
