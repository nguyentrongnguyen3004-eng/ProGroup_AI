import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_governance_notifications.dart';

class GovernanceNotificationScreen extends StatelessWidget {
  const GovernanceNotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final mock = MockGovernanceNotifications.instance;
    return AnimatedBuilder(
      animation: mock,
      builder: (context, _) {
        final items = mock.notifications;
        final colors = Theme.of(context).colorScheme;
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
                onPressed: mock.unreadCount == 0 ? null : mock.markAllAsRead,
                icon: const Icon(Icons.done_all),
              ),
            ],
          ),
          body: items.isEmpty
              ? Center(
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
                          _text(
                            context,
                            'Chưa có thông báo',
                            'No notifications',
                          ),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _text(
                            context,
                            'Thông báo mới sẽ xuất hiện tại đây.',
                            'New notifications will appear here.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final read = item['isRead'] == true;
                    final title = item['title'] as String;
                    final content = item['content'] as String;
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      color: read
                          ? colors.surface
                          : Color.lerp(
                              colors.primaryContainer,
                              colors.surface,
                              Theme.of(context).brightness == Brightness.light
                                  ? 0.58
                                  : 0.78,
                            ),
                      child: InkWell(
                        onTap: () {
                          mock.markAsRead(item['id'] as int);
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              icon: const Icon(
                                Icons.notifications_active_outlined,
                              ),
                              title: Text(title),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['type'] as String),
                                  const SizedBox(height: 8),
                                  Text(content),
                                  const SizedBox(height: 12),
                                  Text(item['time'] as String),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(_text(context, 'Đóng', 'Close')),
                                ),
                              ],
                            ),
                          );
                        },
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
                                  backgroundColor: read
                                      ? colors.surfaceContainerHighest
                                      : colors.primaryContainer,
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: read
                                        ? colors.onSurfaceVariant
                                        : colors.onPrimaryContainer,
                                  ),
                                ),
                                if (!read)
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
                                fontWeight: read
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item['time'] as String,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  read
                                      ? _text(context, 'Đã đọc', 'Read')
                                      : _text(context, 'Chưa đọc', 'Unread'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: read
                                        ? colors.onSurfaceVariant
                                        : colors.error,
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

String _text(BuildContext context, String vi, String en) =>
    AppLocalizations.text(vi, en: en);
