import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_admin_data.dart';
import '../../../models/user_model.dart';
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

  @override
  void initState() {
    super.initState();
    MockAdminData.instance.recordActivity(
      action: 'Đăng nhập',
      target: widget.user.username,
      description: 'Tài khoản Admin đăng nhập thành công.',
    );
  }

  void _openSection(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final data = MockAdminData.instance;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AdminOverviewScreen(
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
          ),
          AdminUserScreen(currentAdminId: widget.user.id),
          const AdminDataManagementScreen(),
          const AdminNotificationScreen(),
          AdminProfileScreen(user: widget.user),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: data,
        builder: (context, _) => NavigationBar(
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: _openSection,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: _text(context, 'Tổng quan', 'Overview'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: _text(context, 'Người dùng', 'Users'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.storage_outlined),
              selectedIcon: const Icon(Icons.storage),
              label: _text(context, 'Dữ liệu', 'Data'),
            ),
            NavigationDestination(
              icon: _NotificationIcon(data.unreadCount),
              selectedIcon: _NotificationIcon(data.unreadCount, selected: true),
              label: _text(context, 'Thông báo', 'Notifications'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: _text(context, 'Cá nhân', 'Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

String _text(BuildContext context, String vi, String en) =>
    AppLocalizations.text(vi, en: en);

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon(this.count, {this.selected = false});

  final int count;
  final bool selected;

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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
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
