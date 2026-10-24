import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/services/student_api_service.dart';
import 'package:progroup_ai_frontend/widgets/common/common_notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _filter = 'ALL'; // ALL, UNREAD, READ
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawList = await StudentApiService.instance.fetchNotifications();
      if (!mounted) return;

      final parsed = rawList.map((item) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final isRead =
              map['isRead'] as bool? ?? !(map['unread'] as bool? ?? false);
          return <String, dynamic>{
            'id': map['id'] as int? ?? 0,
            'type': map['type'] as String? ?? 'Hệ thống',
            'title': map['title'] as String? ?? '',
            'content': map['content'] as String? ?? '',
            'time': map['time'] as String? ?? 'Gần đây',
            'unread': !isRead,
            'isRead': isRead,
            'createdAt': map['createdAt'],
          };
        }
        return <String, dynamic>{};
      }).where((m) => m.isNotEmpty).toList();

      setState(() {
        _notifications = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n['unread'] = false;
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.text(
            'Đã đánh dấu tất cả là đã đọc',
            en: 'Marked all as read',
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _markAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['unread'] = false;
        _notifications[index]['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canPop = ModalRoute.of(context)?.canPop == true;

    final unreadCount = _notifications.where((n) => n['unread'] == true).length;
    final readCount = _notifications.length - unreadCount;

    final filteredItems = _notifications.where((item) {
      final isUnread = item['unread'] as bool? ?? false;
      if (_filter == 'UNREAD') return isUnread;
      if (_filter == 'READ') return !isUnread;
      return true;
    }).toList();

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(
                AppLocalizations.text('Thông báo', en: 'Notifications'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                if (unreadCount > 0)
                  IconButton(
                    tooltip: AppLocalizations.text(
                      'Đánh dấu đã đọc',
                      en: 'Mark as read',
                    ),
                    onPressed: _markAllAsRead,
                    icon: const Icon(Icons.done_all_rounded),
                  ),
              ],
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _loadNotifications,
          color: const Color(0xFF2563EB),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner đồng bộ chuẩn Giảng viên
              if (!canPop)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.text('Thông báo', en: 'Notifications'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$unreadCount thông báo chưa đọc',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (unreadCount > 0)
                        TextButton.icon(
                          onPressed: _markAllAsRead,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.done_all_rounded, size: 16),
                          label: Text(
                            AppLocalizations.text('Đã đọc', en: 'Mark read'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),

              // 3 Thẻ thống kê KPI trên cùng: Tổng cộng, Chưa đọc, Đã đọc
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: AppLocalizations.text('Tổng cộng', en: 'Total'),
                        count: _isLoading ? 0 : _notifications.length,
                        icon: Icons.notifications_rounded,
                        color: const Color(0xFF3B82F6),
                        isSelected: _filter == 'ALL',
                        onTap: () => setState(() => _filter = 'ALL'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildKpiCard(
                        title: AppLocalizations.text('Chưa đọc', en: 'Unread'),
                        count: _isLoading ? 0 : unreadCount,
                        icon: Icons.mark_email_unread_rounded,
                        color: const Color(0xFFF59E0B),
                        isSelected: _filter == 'UNREAD',
                        onTap: () => setState(() => _filter = 'UNREAD'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildKpiCard(
                        title: AppLocalizations.text('Đã đọc', en: 'Read'),
                        count: _isLoading ? 0 : readCount,
                        icon: Icons.mark_email_read_rounded,
                        color: const Color(0xFF10B981),
                        isSelected: _filter == 'READ',
                        onTap: () => setState(() => _filter = 'READ'),
                      ),
                    ),
                  ],
                ),
              ),

              // Danh sách thông báo
              Expanded(
                child: _buildListBody(colors, filteredItems),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListBody(
      ColorScheme colors, List<Map<String, dynamic>> filteredItems) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
        ),
      );
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: colors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.text(
                  'Không thể tải thông báo',
                  en: 'Failed to load notifications',
                ),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadNotifications,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredItems.isEmpty) {
      return _NotificationEmptyState(
        filter: _filter,
        hasAny: _notifications.isNotEmpty,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 76),
      itemCount: filteredItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final id = item['id'] as int;
        final unread = item['unread'] as bool? ?? false;
        final type = item['type'] as String? ?? 'Hệ thống';
        final title = item['title'] as String? ?? '';
        final content = item['content'] as String? ?? '';
        final time = item['time'] as String? ?? '';

        return _NotificationCard(
          id: id,
          unread: unread,
          type: type,
          title: title,
          content: content,
          time: time,
          onTap: () => _showNotificationDetail(context, item),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color
                  : colors.outlineVariant.withValues(alpha: 0.35),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? color : colors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(
      BuildContext context, Map<String, dynamic> item) {
    final id = item['id'] as int;

    // Đánh dấu đã đọc
    _markAsRead(id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommonNotificationDetailScreen(
          notification: item,
          onMarkRead: () => _markAsRead(id),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final int id;
  final bool unread;
  final String type;
  final String title;
  final String content;
  final String time;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.id,
    required this.unread,
    required this.type,
    required this.title,
    required this.content,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconData = _getTypeIcon(type);
    final iconColor = _getTypeColor(type);

    return Container(
      decoration: BoxDecoration(
        color: unread ? colors.surface : colors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread
              ? iconColor.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.3),
          width: unread ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight:
                                    unread ? FontWeight.w800 : FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _NotificationEmptyState extends StatelessWidget {
  final String filter;
  final bool hasAny;

  const _NotificationEmptyState({required this.filter, required this.hasAny});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              filter == 'UNREAD'
                  ? AppLocalizations.text(
                      'Không có thông báo chưa đọc', en: 'No unread notifications')
                  : filter == 'READ'
                      ? AppLocalizations.text(
                          'Không có thông báo đã đọc', en: 'No read notifications')
                      : AppLocalizations.text(
                          'Chưa có thông báo', en: 'No notifications'),
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              filter == 'UNREAD'
                  ? AppLocalizations.text('Tất cả thông báo đã được xem.',
                      en: 'All notifications are marked as read.')
                  : AppLocalizations.text('Bạn chưa nhận thông báo nào.',
                      en: 'You have not received any notifications.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _getTypeIcon(String type) {
  switch (type.trim()) {
    case 'Nhóm':
      return Icons.groups_rounded;
    case 'Đề tài':
      return Icons.lightbulb_rounded;
    default:
      return Icons.settings_suggest_rounded;
  }
}

Color _getTypeColor(String type) {
  switch (type.trim()) {
    case 'Nhóm':
      return const Color(0xFF6366F1); // Indigo
    case 'Đề tài':
      return const Color(0xFFF59E0B); // Amber
    default:
      return const Color(0xFF0D9488); // Teal
  }
}
