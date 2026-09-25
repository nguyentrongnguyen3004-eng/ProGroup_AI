import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../admin/admin_helpers.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: MockAdminData.instance,
    builder: (context, _) {
      final data = MockAdminData.instance;
      return Scaffold(
        appBar: AppBar(
          title: Text(adminText('Thông báo', 'Notifications')),
          actions: [
            TextButton(
              onPressed: data.unreadCount == 0
                  ? null
                  : data.markAllNotificationsRead,
              child: Text(adminText('Đọc tất cả', 'Mark all read')),
            ),
          ],
        ),
        body: data.notifications.isEmpty
            ? adminEmptyState(
                context,
                'Chưa có thông báo.',
                'No notifications yet.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: data.notifications.length,
                itemBuilder: (context, index) {
                  final item = data.notifications[index];
                  return Card(
                    color: item.isRead
                        ? null
                        : Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: .28),
                    child: ListTile(
                      leading: Icon(
                        item.isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active_outlined,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: item.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${item.message}\n${adminDateTime(item.createdAt)}',
                      ),
                      isThreeLine: true,
                      trailing: item.isRead
                          ? null
                          : Icon(
                              Icons.circle,
                              size: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      onTap: () => data.markNotificationRead(item.id),
                    ),
                  );
                },
              ),
      );
    },
  );
}
