import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class LecturerBottomNav extends StatelessWidget {
  /// Kept for callers using the earlier Groups callback.
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final int notificationCount;
  final VoidCallback? onGroupsTap;

  const LecturerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.notificationCount,
    this.onGroupsTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = currentIndex >= 0 && currentIndex < 5
        ? currentIndex
        : 0;
    final countLabel = notificationCount > 99 ? '99+' : '$notificationCount';

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == 2 && onGroupsTap != null) {
          onGroupsTap!.call();
          return;
        }
        onChanged(index);
      },
      height: 72,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: AppLocalizations.text('Trang chủ', en: 'Home'),
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: AppLocalizations.text('Lớp học phần', en: 'Courses'),
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: AppLocalizations.text('Nhóm', en: 'Groups'),
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: notificationCount > 0,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            label: Text(countLabel),
            child: const Icon(Icons.notifications_none),
          ),
          selectedIcon: Badge(
            isLabelVisible: notificationCount > 0,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            label: Text(countLabel),
            child: const Icon(Icons.notifications),
          ),
          label: AppLocalizations.text('Thông báo', en: 'Notifications'),
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: AppLocalizations.text('Cá nhân', en: 'Profile'),
        ),
      ],
    );
  }
}
