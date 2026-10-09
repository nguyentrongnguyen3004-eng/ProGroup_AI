import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_training_notifications.dart';
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
  TrainingDataKind _selectedKind = TrainingDataKind.students;

  void _openManagement(TrainingDataKind kind) {
    setState(() {
      _selectedKind = kind;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = MockTrainingNotifications.instance;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TrainingOverviewScreen(onOpenManagement: _openManagement),
          TrainingDataManagementScreen(
            key: ValueKey(_selectedKind),
            initialKind: _selectedKind,
          ),
          const TrainingNotificationScreen(),
          const TrainingProfileScreen(),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: notifications,
        builder: (context, _) => NavigationBar(
          selectedIndex: _currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: _text(context, 'Trang chủ', 'Home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.dataset_outlined),
              selectedIcon: const Icon(Icons.dataset),
              label: _text(context, 'Quản lý', 'Management'),
            ),
            NavigationDestination(
              icon: _NotificationIcon(notifications.unreadCount),
              selectedIcon: _NotificationIcon(
                notifications.unreadCount,
                selected: true,
              ),
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
  final int count;
  final bool selected;

  const _NotificationIcon(this.count, {this.selected = false});

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
