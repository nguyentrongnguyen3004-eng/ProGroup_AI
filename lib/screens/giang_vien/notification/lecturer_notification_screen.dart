import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_lecturer_notifications.dart';

class LecturerNotificationScreen extends StatelessWidget {
  const LecturerNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = MockLecturerNotifications.instance;

    return AnimatedBuilder(
      animation: notifications,
      builder: (context, _) {
        final items = notifications.notifications;
        final colors = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.text('Thông báo', en: 'Notifications'),
            ),
            actions: [
              IconButton(
                tooltip: AppLocalizations.text(
                  'Đánh dấu tất cả đã đọc',
                  en: 'Mark all as read',
                ),
                onPressed: notifications.unreadCount == 0
                    ? null
                    : notifications.markAllAsRead,
                icon: const Icon(Icons.done_all),
              ),
            ],
          ),
          body: items.isEmpty
              ? _EmptyNotifications(
                  title: AppLocalizations.text(
                    'Chưa có thông báo',
                    en: 'No notifications',
                  ),
                  message: AppLocalizations.text(
                    'Không có thông báo mới.',
                    en: 'There are no new notifications.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final icon = item['icon'];
                    final id = item['id'];
                    final title = item['title'] as String? ?? '';
                    final content = item['content'] as String? ?? '';
                    final time = item['time'] as String? ?? '';
                    final isRead = item['isRead'] == true;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      color: isRead
                          ? colors.surface
                          : Color.lerp(
                              colors.primaryContainer,
                              colors.surface,
                              Theme.of(context).brightness == Brightness.light
                                  ? 0.58
                                  : 0.78,
                            ),
                      child: InkWell(
                        onTap: id is int
                            ? () => notifications.markAsRead(id)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            leading: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  backgroundColor: isRead
                                      ? colors.surfaceContainerHighest
                                      : colors.primaryContainer,
                                  child: Icon(
                                    icon is IconData
                                        ? icon
                                        : Icons.notifications_outlined,
                                    color: isRead
                                        ? colors.onSurfaceVariant
                                        : colors.onPrimaryContainer,
                                  ),
                                ),
                                if (!isRead)
                                  Positioned(
                                    right: -1,
                                    top: -1,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: colors.error,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colors.surface,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  isRead
                                      ? AppLocalizations.text(
                                          'Đã đọc',
                                          en: 'Read',
                                        )
                                      : AppLocalizations.text(
                                          'Chưa đọc',
                                          en: 'Unread',
                                        ),
                                  style: TextStyle(
                                    color: isRead
                                        ? colors.onSurfaceVariant
                                        : colors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyNotifications({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 56,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
