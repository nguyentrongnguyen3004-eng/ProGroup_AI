import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_training_notifications.dart';
import '../../../models/training_notification_model.dart';

class TrainingNotificationScreen extends StatelessWidget {
  const TrainingNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = MockTrainingNotifications.instance;
    return AnimatedBuilder(
      animation: notifications,
      builder: (context, _) {
        final items = notifications.notifications;
        return Scaffold(
          appBar: AppBar(
            title: Text(_text(context, 'Thông báo', 'Notifications')),
            actions: [
              IconButton(
                tooltip: _text(
                  context,
                  'Đánh dấu tất cả đã đọc',
                  'Mark all as read',
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
                  title: _text(
                    context,
                    'Chưa có thông báo',
                    'No notifications',
                  ),
                  message: _text(
                    context,
                    'Thông báo mới sẽ xuất hiện tại đây.',
                    'New notifications will appear here.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _NotificationCard(
                    item: items[index],
                    onTap: () {
                      notifications.markAsRead(items[index].id);
                      _showDetails(context, items[index]);
                    },
                  ),
                ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, TrainingNotificationModel item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(item.icon),
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.type,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(item.content),
            const SizedBox(height: 14),
            Text(
              item.time,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_text(context, 'Đóng', 'Close')),
          ),
        ],
      ),
    );
  }
}

String _text(BuildContext context, String vi, String en) =>
    AppLocalizations.text(vi, en: en);

class _NotificationCard extends StatelessWidget {
  final TrainingNotificationModel item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unreadColor = Color.lerp(
      colors.primaryContainer,
      colors.surface,
      Theme.of(context).brightness == Brightness.light ? 0.58 : 0.78,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      color: item.isRead ? colors.surface : unreadColor,
      child: InkWell(
        onTap: onTap,
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
                  backgroundColor: item.isRead
                      ? colors.surfaceContainerHighest
                      : colors.primaryContainer,
                  child: Icon(
                    item.icon,
                    color: item.isRead
                        ? colors.onSurfaceVariant
                        : colors.onPrimaryContainer,
                  ),
                ),
                if (!item.isRead)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: colors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                item.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.isRead
                      ? _text(context, 'Đã đọc', 'Read')
                      : _text(context, 'Chưa đọc', 'Unread'),
                  style: TextStyle(
                    color: item.isRead ? colors.onSurfaceVariant : colors.error,
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
