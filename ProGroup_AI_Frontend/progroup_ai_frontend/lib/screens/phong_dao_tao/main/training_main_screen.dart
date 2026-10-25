import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/settings/app_settings.dart';
import '../../../services/admin_api_service.dart';
import '../../../services/app_update_service.dart';
import '../../../widgets/common/unified_role_bottom_nav.dart';
import '../home/training_overview_screen.dart';
import '../management/training_data_management_screen.dart';
import '../notification/training_notification_screen.dart';
import '../profile/training_profile_screen.dart';

class TrainingMainScreen extends StatefulWidget {
  const TrainingMainScreen({super.key});

  @override
  State<TrainingMainScreen> createState() => _TrainingMainScreenState();
}

class _TrainingMainScreenState extends State<TrainingMainScreen> {
  int _currentIndex = 0;
  int _unreadCount = 0;
  TrainingDataKind _selectedKind = TrainingDataKind.courseClasses;

  @override
  void initState() {
    super.initState();
    _loadUnread();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.instance.autoCheckAndPrompt(context);
      }
    });
  }

  Future<void> _loadUnread() async {
    try {
      final list = await AdminApiService.instance.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _unreadCount = list.where((n) => n['isRead'] != true && n['daDoc'] != true).length;
      });
    } catch (_) {}
  }

  void _selectTab(int index) {
    if (index < 0 || index >= 4 || index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 2) _loadUnread();
  }

  void _openManagement(TrainingDataKind kind) {
    setState(() {
      _selectedKind = kind;
      _currentIndex = 1;
    });
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
            color: const Color(0xFF2563EB), // Blue
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('QL Đào tạo', en: 'Training'),
            activeIcon: Icons.school_rounded,
            inactiveIcon: Icons.school_rounded,
            color: const Color(0xFF6366F1), // Indigo
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Thông báo', en: 'Notifications'),
            activeIcon: Icons.notifications_rounded,
            inactiveIcon: Icons.notifications_rounded,
            color: const Color(0xFFF59E0B), // Amber
            badgeCount: _unreadCount,
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Cá nhân', en: 'Profile'),
            activeIcon: Icons.person_rounded,
            inactiveIcon: Icons.person_rounded,
            color: const Color(0xFF8B5CF6), // Purple
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            key: ValueKey('train_stack_$lang'),
            index: _currentIndex,
            children: [
              TrainingOverviewScreen(
                key: ValueKey('train_overview_$lang'),
                onOpenManagement: _openManagement,
                onOpenNotifications: () => _selectTab(2),
                onOpenProfile: () => _selectTab(3),
              ),
              TrainingDataManagementScreen(
                key: ValueKey('train_data_${_selectedKind}_$lang'),
                initialKind: _selectedKind,
              ),
              TrainingNotificationScreen(key: ValueKey('train_notif_$lang')),
              TrainingProfileScreen(key: ValueKey('train_prof_$lang')),
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
