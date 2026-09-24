import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/data/mock/mock_notifications.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedFilter = 0;

  static const List<String> _filterTypes = ['', 'Nhóm', 'Đề tài', 'Hệ thống'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockNotifications.instance,
      builder: (context, _) {
        final notifications = MockNotifications.instance.notifications;
        final filters = [
          AppLocalizations.text('Tất cả', en: 'All'),
          AppLocalizations.text('Nhóm', en: 'Groups'),
          AppLocalizations.text('Đề tài', en: 'Topics'),
          AppLocalizations.text('Hệ thống', en: 'System'),
        ];
        final currentType = _filterTypes[selectedFilter];

        final filtered = notifications.where((item) {
          if (currentType.isEmpty) {
            return true;
          }

          return item['type'] == currentType;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.text('Thông báo', en: 'Notifications'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: AppLocalizations.text(
                  'Đánh dấu đã đọc',
                  en: 'Mark as read',
                ),
                onPressed: MockNotifications.instance.unreadCount > 0
                    ? () {
                        MockNotifications.instance.markAllAsRead();
                      }
                    : null,
                icon: const Icon(Icons.done_all),
              ),
            ],
          ),

          body: Column(
            children: [
              // ==================================================
              // FILTER
              // ==================================================
              SizedBox(
                height: 55,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selected = selectedFilter == index;

                    return ChoiceChip(
                      label: Text(filters[index]),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = index;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 4),

              // ==================================================
              // LIST
              // ==================================================
              Expanded(
                child: filtered.isEmpty
                    ? _NotificationEmptyState(
                        hasAnyNotifications: notifications.isNotEmpty,
                        filterLabel: filters[selectedFilter],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filtered[index];

                          final unread = item['unread'] as bool;

                          final id = item['id'] as int;

                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),

                              // ==================================
                              // ICON
                              // ==================================
                              leading: CircleAvatar(
                                backgroundColor: unread
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: unread
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                              ),

                              // ==================================
                              // TITLE
                              // ==================================
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _localizedMessage(
                                        item['title'] as String,
                                      ),
                                      style: TextStyle(
                                        fontWeight: unread
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  if (unread)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),

                              // ==================================
                              // CONTENT
                              // ==================================
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _localizedMessage(
                                        item['content'] as String,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _localizedMessage(item['time'] as String),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ==================================
                              // READ
                              // ==================================
                              onTap: () {
                                MockNotifications.instance.markAsRead(id);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _localizedMessage(String value) {
  if (!AppLocalizations.isEnglish) return value;

  const translations = <String, String>{
    'Bạn được mời vào nhóm': 'You were invited to a group',
    'Đăng ký đề tài đã được mở': 'Topic registration is open',
    'Đề tài đã được duyệt': 'Topic approved',
    'Đăng nhập thành công': 'Successful sign-in',
    'Nhóm ProGroup đã gửi lời mời tham gia nhóm.':
        'ProGroup invited you to join the team.',
    'Giảng viên đã mở thời gian đăng ký đề tài cho lớp LTDD-01.':
        'The lecturer opened topic registration for class LTDD-01.',
    'Đề tài "Hệ thống gợi ý đề tài bằng AI" đã được duyệt.':
        'The topic "AI-powered topic recommendation system" was approved.',
    'Tài khoản của bạn vừa đăng nhập trên thiết bị hiện tại.':
        'Your account was signed in on this device.',
    '10 phút trước': '10 minutes ago',
    '1 giờ trước': '1 hour ago',
    'Hôm qua': 'Yesterday',
  };

  return translations[value] ?? value;
}

class _NotificationEmptyState extends StatelessWidget {
  final bool hasAnyNotifications;
  final String filterLabel;

  const _NotificationEmptyState({
    required this.hasAnyNotifications,
    required this.filterLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 56,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasAnyNotifications
                  ? AppLocalizations.text(
                      'Không có thông báo phù hợp',
                      en: 'No matching notifications',
                    )
                  : AppLocalizations.text(
                      'Chưa có thông báo',
                      en: 'No notifications yet',
                    ),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              hasAnyNotifications
                  ? AppLocalizations.text(
                      'Không có thông báo trong mục $filterLabel.',
                      en: 'There are no notifications in $filterLabel.',
                    )
                  : AppLocalizations.text(
                      'Thông báo mới sẽ xuất hiện tại đây.',
                      en: 'New notifications will appear here.',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
