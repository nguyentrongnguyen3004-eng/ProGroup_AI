import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/settings/app_settings.dart';
import '../../../models/user_model.dart';
import '../../../services/admin_api_service.dart';
import '../../../widgets/common/unified_role_bottom_nav.dart';
import '../activity/admin_activity_log_screen.dart';
import '../data/admin_data_management_screen.dart';
import '../home/admin_overview_screen.dart';
import '../notification/admin_notification_screen.dart';
import '../profile/admin_profile_screen.dart';
import '../role/admin_role_screen.dart';
import '../user/admin_user_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
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

  void _openSection(int index) {
    if (index < 0 || index >= 5 || index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
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
            color: const Color(0xFF2563EB), // Blue
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Người dùng', en: 'Users'),
            activeIcon: Icons.people_rounded,
            inactiveIcon: Icons.people_rounded,
            color: const Color(0xFF6366F1), // Indigo
          ),
          UnifiedRoleNavItem(
            label: AppLocalizations.text('Dữ liệu', en: 'Data'),
            activeIcon: Icons.dataset_rounded,
            inactiveIcon: Icons.dataset_rounded,
            color: const Color(0xFF10B981), // Emerald
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
            key: ValueKey('admin_stack_$lang'),
            index: _selectedIndex,
            children: [
              AdminOverviewScreen(
                key: ValueKey('admin_overview_$lang'),
                onOpenUsers: () => _openSection(1),
                onOpenData: () => _openSection(2),
                onOpenRoles: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminRoleScreen()),
                ),
                onOpenActivity: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminActivityLogScreen()),
                ),
                onOpenNotifications: () => _openSection(3),
                onOpenProfile: () => _openSection(4),
              ),
              AdminUserScreen(
                key: ValueKey('admin_user_$lang'),
                currentAdminId: widget.user.id,
              ),
              AdminDataManagementScreen(key: ValueKey('admin_data_$lang')),
              AdminNotificationScreen(key: ValueKey('admin_notif_$lang')),
              AdminProfileScreen(
                key: ValueKey('admin_prof_$lang'),
                user: widget.user,
              ),
            ],
          ),
          bottomNavigationBar: UnifiedRoleBottomNav(
            currentIndex: _selectedIndex,
            onChanged: _openSection,
            items: navItems,
          ),
        );
      },
    );
  }
}
