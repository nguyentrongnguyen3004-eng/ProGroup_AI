import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/lecturer_api_service.dart';
import 'lecturer_notification_detail_screen.dart';

class LecturerNotificationScreen extends StatefulWidget {
  const LecturerNotificationScreen({super.key});

  @override
  State<LecturerNotificationScreen> createState() => _LecturerNotificationScreenState();
}

class _LecturerNotificationScreenState extends State<LecturerNotificationScreen> {
  // 'ALL' | 'UNREAD' | 'READ'
  String _filter = 'ALL';
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
      final notifs = await LecturerApiService.instance.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    await LecturerApiService.instance.markAllNotificationsRead();
    if (mounted) {
      setState(() {
        for (var n in _notifications) {
          n['isRead'] = true;
        }
      });
    }
  }

  Future<void> _markAsRead(int id) async {
    await LecturerApiService.instance.markNotificationRead(id);
    if (mounted) {
      setState(() {
        for (var n in _notifications) {
          if (n['id'] == id) {
            n['isRead'] = true;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canPop = ModalRoute.of(context)?.canPop == true;

    final allItems = _notifications;
    final unreadCount = allItems.where((item) => item['isRead'] != true).length;
    final readCount = allItems.length - unreadCount;

    final filteredItems = allItems.where((item) {
      final isRead = item['isRead'] == true;
      if (_filter == 'UNREAD') return !isRead;
      if (_filter == 'READ') return isRead;
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
                IconButton(
                  tooltip: AppLocalizations.text(
                    'Đánh dấu tất cả đã đọc',
                    en: 'Mark all as read',
                  ),
                  onPressed: unreadCount == 0 ? null : _markAllAsRead,
                  icon: const Icon(Icons.done_all),
                ),
              ],
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header khi không có nút Back
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
                        icon: const Icon(Icons.done_all_rounded, size: 16, color: Colors.white),
                        label: Text(
                          AppLocalizations.text('Đã đọc tất cả', en: 'Mark all read'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),

            // 3 KPI Cards: Total, Unread, Read
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: AppLocalizations.text('Tổng cộng', en: 'Total'),
                      count: allItems.length,
                      icon: Icons.notifications_rounded,
                      color: const Color(0xFF2563EB),
                      isSelected: _filter == 'ALL',
                      onTap: () => setState(() => _filter = 'ALL'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      title: AppLocalizations.text('Chưa đọc', en: 'Unread'),
                      count: unreadCount,
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
                      count: readCount,
                      icon: Icons.mark_email_read_rounded,
                      color: const Color(0xFF10B981),
                      isSelected: _filter == 'READ',
                      onTap: () => setState(() => _filter = 'READ'),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _buildList(colors, filteredItems),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ColorScheme colors, List<Map<String, dynamic>> filteredItems) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.text('Thử lại', en: 'Retry')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: _EmptyNotifications(
                title: _filter == 'UNREAD'
                    ? AppLocalizations.text('Không có thông báo chưa đọc', en: 'No unread notifications')
                    : _filter == 'READ'
                        ? AppLocalizations.text('Không có thông báo đã đọc', en: 'No read notifications')
                        : AppLocalizations.text('Chưa có thông báo', en: 'No notifications'),
                message: _filter == 'UNREAD'
                    ? AppLocalizations.text('Tất cả thông báo đã được xem.', en: 'All notifications are marked as read.')
                    : AppLocalizations.text('Danh sách thông báo trống.', en: 'The notification list is currently empty.'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
        itemCount: filteredItems.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          final id = item['id'];
          final title = item['title'] as String? ?? '';
          final content = item['content'] as String? ?? '';
          final time = item['time'] as String? ?? '';
          final isRead = item['isRead'] == true;
          final type = item['type'] as String? ?? '';

          final iconColor = _getNotificationColor(type);
          final iconData = _getNotificationIcon(type, item['icon']);

          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isRead
                    ? colors.outlineVariant.withValues(alpha: 0.4)
                    : iconColor.withValues(alpha: 0.35),
                width: isRead ? 1 : 1.5,
              ),
            ),
            elevation: isRead ? 0 : 1,
            color: isRead
                ? colors.surface
                : Color.lerp(
                    iconColor.withValues(alpha: 0.08),
                    colors.surface,
                    0.6,
                  ),
            child: InkWell(
              onTap: () {
                if (id is int && !isRead) {
                  _markAsRead(id);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LecturerNotificationDetailScreen(
                      notification: item,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(
                              alpha: isRead ? 0.12 : 0.22,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            iconData,
                            color: iconColor,
                            size: 22,
                          ),
                        ),
                        if (!isRead)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colors.onSurfaceVariant,
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
                              fontSize: 13,
                              height: 1.35,
                              color: isRead
                                  ? colors.onSurfaceVariant
                                  : colors.onSurface.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : colors.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
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

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'Đề tài':
      case 'Đề xuất':
        return const Color(0xFFF59E0B);
      case 'Đăng ký':
        return const Color(0xFF2563EB);
      case 'Nhóm':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getNotificationIcon(String type, dynamic icon) {
    if (icon is IconData) return icon;
    switch (type) {
      case 'Đề tài':
      case 'Đề xuất':
        return Icons.lightbulb_outline_rounded;
      case 'Đăng ký':
        return Icons.assignment_outlined;
      case 'Nhóm':
        return Icons.groups_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: colors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
