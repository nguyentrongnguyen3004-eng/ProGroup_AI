import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class CommonNotificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onMarkRead;

  const CommonNotificationDetailScreen({
    super.key,
    required this.notification,
    this.onMarkRead,
  });

  @override
  State<CommonNotificationDetailScreen> createState() =>
      _CommonNotificationDetailScreenState();
}

class _CommonNotificationDetailScreenState
    extends State<CommonNotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.onMarkRead != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onMarkRead?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final item = widget.notification;
    final type = (item['type'] ?? item['loai'] ?? 'Thông báo').toString();
    final title = (item['title'] ?? item['tieuDe'] ?? '').toString();
    final content = (item['content'] ?? item['noiDung'] ?? '').toString();
    final time = (item['time'] ?? item['ngayTao'] ?? 'Gần đây').toString();

    final typeColor = _getTypeColor(type);
    final typeIcon = _getTypeIcon(type, item['icon']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết thông báo', en: 'Notification Details'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          children: [
            // Top Type & Icon Header Card (Template Chuẩn Giảng Viên)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(typeIcon, color: typeColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Divider(
                    height: 1,
                    thickness: 0.8,
                    color: colors.outlineVariant.withValues(alpha: 0.25),
                  ),

                  const SizedBox(height: 16),

                  // Notification Title
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Notification Content
                  Text(
                    content.isNotEmpty ? content : 'Không có nội dung chi tiết bổ sung.',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.88),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action / Context Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: typeColor.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: typeColor),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.text('Thông tin hệ thống', en: 'System Information'),
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thông báo này được gửi tự động từ hệ thống quản lý đồ án ProGroup AI đến tài khoản của bạn.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Back button
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                AppLocalizations.text('Quay lại', en: 'Go back'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('đề tài') || t.contains('topic')) return const Color(0xFF8B5CF6);
    if (t.contains('đăng ký') || t.contains('register')) return const Color(0xFFF59E0B);
    if (t.contains('nhóm') || t.contains('group')) return const Color(0xFF10B981);
    if (t.contains('hệ thống') || t.contains('system')) return const Color(0xFF2563EB);
    return const Color(0xFF2563EB);
  }

  IconData _getTypeIcon(String type, dynamic fallbackIcon) {
    if (fallbackIcon is IconData) return fallbackIcon;
    final t = type.toLowerCase();
    if (t.contains('đề tài') || t.contains('topic')) return Icons.lightbulb_rounded;
    if (t.contains('đăng ký') || t.contains('register')) return Icons.assignment_rounded;
    if (t.contains('nhóm') || t.contains('group')) return Icons.groups_rounded;
    if (t.contains('lớp') || t.contains('khoa')) return Icons.school_rounded;
    return Icons.notifications_rounded;
  }
}
