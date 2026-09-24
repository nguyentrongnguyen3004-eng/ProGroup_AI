import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/data/mock/mock_notifications.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockNotifications.instance,
      builder: (context, _) {
        final unreadCount = MockNotifications.instance.unreadCount;

        return NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: AppLocalizations.text('Trang chủ', en: 'Home'),
            ),

            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: AppLocalizations.text('Nhóm', en: 'Groups'),
            ),

            NavigationDestination(
              icon: _NotificationIcon(
                unreadCount: unreadCount,
                selected: false,
              ),
              selectedIcon: _NotificationIcon(
                unreadCount: unreadCount,
                selected: true,
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
      },
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final int unreadCount;
  final bool selected;

  const _NotificationIcon({required this.unreadCount, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(
              selected ? Icons.notifications : Icons.notifications_outlined,
            ),
          ),

          if (unreadCount > 0)
            Positioned(
              right: -7,
              top: -7,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
