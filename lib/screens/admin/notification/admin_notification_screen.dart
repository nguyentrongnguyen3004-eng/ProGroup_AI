import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../../../core/localization/app_localizations.dart';
import '../../../services/admin_api_service.dart';
import '../../../widgets/common/common_notification_detail_screen.dart';
=======
import '../../../services/admin_data_service.dart';
import '../../admin/admin_helpers.dart';
>>>>>>> origin/Frontend

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
<<<<<<< HEAD
  State<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _notifications = [];
  String _filter = 'ALL'; // ALL, UNREAD, READ

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
      final list = await AdminApiService.instance.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải thông báo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(int id) async {
    await AdminApiService.instance.markNotificationAsRead(id);
    setState(() {
      for (final n in _notifications) {
        if ((n['id'] ?? n['thongBaoId']) == id) {
          n['isRead'] = true;
          n['daDoc'] = true;
        }
      }
    });
  }

  Future<void> _markAllRead() async {
    for (final n in _notifications) {
      final id = n['id'] ?? n['thongBaoId'];
      if (id != null && (n['isRead'] != true && n['daDoc'] != true)) {
        await AdminApiService.instance.markNotificationAsRead(id is int ? id : int.tryParse('$id') ?? 0);
      }
    }
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
        n['daDoc'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canPop = ModalRoute.of(context)?.canPop == true;

    final allItems = _notifications;
    final unreadCount = allItems.where((n) => n['isRead'] != true && n['daDoc'] != true).length;
    final readCount = allItems.length - unreadCount;

    final filteredItems = allItems.where((item) {
      final isRead = item['isRead'] == true || item['daDoc'] == true;
      if (_filter == 'UNREAD') return !isRead;
      if (_filter == 'READ') return isRead;
      return true;
    }).toList();

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(
                AppLocalizations.text('Thông báo hệ thống', en: 'System Notifications'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              foregroundColor: Colors.white,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              actions: [
                if (unreadCount > 0)
                  IconButton(
                    icon: const Icon(Icons.done_all_rounded),
                    tooltip: 'Đánh dấu tất cả đã đọc',
                    onPressed: _markAllRead,
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                  onPressed: _loadNotifications,
                ),
              ],
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Gradient đồng bộ chuẩn Giảng viên khi không có nút Back
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
                            AppLocalizations.text('Thông báo hệ thống', en: 'System Notifications'),
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
                        onPressed: _markAllRead,
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

            // 3 KPI Cards: Total, Unread, Read (Unified Design System)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
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
=======
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AdminDataService.instance,
    builder: (context, _) {
      final data = AdminDataService.instance;
      return Scaffold(
        appBar: AppBar(
          title: Text(adminText('Thông báo', 'Notifications')),
          actions: [
            TextButton(
              onPressed: data.unreadCount == 0
                  ? null
                  : data.markAllNotificationsRead,
              child: Text(adminText('Đọc tất cả', 'Mark all read')),
>>>>>>> origin/Frontend
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ColorScheme colors, List<Map<String, dynamic>> items) {
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
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant)),
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

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotifications,
        color: const Color(0xFF2563EB),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 48, color: colors.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      _filter == 'UNREAD' ? 'Không có thông báo chưa đọc' : 'Chưa có thông báo nào',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: const Color(0xFF2563EB),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = items[index];
          final id = n['id'] ?? n['thongBaoId'];
          final isRead = n['isRead'] == true || n['daDoc'] == true;
          final title = (n['tieuDe'] ?? n['title'] ?? 'Thông báo').toString();
          final content = (n['noiDung'] ?? n['content'] ?? '').toString();
          final time = (n['ngayTao'] ?? n['time'] ?? 'Vừa xong').toString();

          final iconColor = isRead ? const Color(0xFF6B7280) : const Color(0xFFF59E0B);

          return Card(
            elevation: isRead ? 0 : 1,
            color: isRead ? colors.surface : Color.lerp(iconColor.withValues(alpha: 0.08), colors.surface, 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isRead ? colors.outlineVariant.withValues(alpha: 0.35) : iconColor.withValues(alpha: 0.35),
                width: isRead ? 1.0 : 1.4,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (!isRead && id != null) {
                  _markRead(id is int ? id : int.tryParse('$id') ?? 0);
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommonNotificationDetailScreen(
                      notification: n,
                      onMarkRead: () {
                        if (id != null) {
                          _markRead(id is int ? id : int.tryParse('$id') ?? 0);
                        }
                      },
                    ),
                  ),
                );
              },
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
                      child: Icon(
                        isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                        color: iconColor,
                        size: 22,
                      ),
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
                                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                    fontSize: 14.5,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF59E0B),
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
                            style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            time,
                            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant.withValues(alpha: 0.7)),
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
              width: isSelected ? 1.8 : 1.0,
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
}
