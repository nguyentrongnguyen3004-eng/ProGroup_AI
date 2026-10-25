import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/settings/app_settings.dart';
import '../../../services/governance_api_service.dart';
import '../../../widgets/common/unified_role_bottom_nav.dart';
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
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    try {
      final list = await GovernanceApiService.instance.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _unreadCount = list.where((n) => n['isRead'] != true && n['daDoc'] != true).length;
      });
    } catch (_) {}
  }

  void _selectTab(int index) {
    if (index < 0 || index >= 5 || index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 3) _loadUnread();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final lang = AppSettings.instance.language;

        final navItems = [
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Tổng quan', en: 'Overview'),
            activeIcon: Icons.dashboard_rounded,
            inactiveIcon: Icons.dashboard_rounded,
            color: const Color(0xFF2563EB), // Vibrant Blue
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Dữ liệu khoa', en: 'Faculty Data'),
            activeIcon: Icons.school_rounded,
            inactiveIcon: Icons.school_rounded,
            color: const Color(0xFF6366F1), // Indigo
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Phân công', en: 'Assignments'),
            activeIcon: Icons.assignment_ind_rounded,
            inactiveIcon: Icons.assignment_ind_rounded,
            color: const Color(0xFF10B981), // Emerald Green
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Thông báo', en: 'Notifications'),
            activeIcon: Icons.notifications_rounded,
            inactiveIcon: Icons.notifications_rounded,
            color: const Color(0xFFF59E0B), // Warm Amber
            badgeCount: _unreadCount,
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Cá nhân', en: 'Profile'),
            activeIcon: Icons.person_rounded,
            inactiveIcon: Icons.person_rounded,
            color: const Color(0xFF8B5CF6), // Royal Purple
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            key: ValueKey('gov_stack_$lang'),
            index: _currentIndex,
            children: [
              GovernanceOverviewScreen(
                key: ValueKey('gov_overview_$lang'),
                onOpenData: () => _selectTab(1),
                onOpenAssignments: () => _selectTab(2),
                onOpenNotifications: () => _selectTab(3),
                onOpenProfile: () => _selectTab(4),
              ),
              GovernanceDataManagementScreen(key: ValueKey('gov_data_$lang')),
              GovernanceToolsScreen(key: ValueKey('gov_tools_$lang')),
              GovernanceNotificationScreen(key: ValueKey('gov_notif_$lang')),
              GovernanceProfileScreen(key: ValueKey('gov_prof_$lang')),
            ],
          ),
          bottomNavigationBar: UnifiedRoleBottomNav(
            currentIndex: _currentIndex,
            onChanged: _selectTab,
            items: navItems,
          ),
        );
      },
    );
  }
}
