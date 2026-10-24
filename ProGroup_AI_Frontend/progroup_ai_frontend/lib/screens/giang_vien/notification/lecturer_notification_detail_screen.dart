import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/lecturer_api_service.dart';
import '../group/lecturer_group_screen.dart';
import '../topic_proposal/lecturer_topic_proposal_screen.dart';
import '../topic_registration/topic_registration_screen.dart';

class LecturerNotificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notification;

  const LecturerNotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  State<LecturerNotificationDetailScreen> createState() =>
      _LecturerNotificationDetailScreenState();
}

class _LecturerNotificationDetailScreenState
    extends State<LecturerNotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    final id = widget.notification['id'];
    if (id is int) {
      LecturerApiService.instance.markNotificationRead(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final item = widget.notification;
    final type = item['type'] as String? ?? 'Thông báo';
    final title = item['title'] as String? ?? '';
    final content = item['content'] as String? ?? '';
    final time = item['time'] as String? ?? '';

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
            // Top Type & Icon Header Card
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
                    content,
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

            // Context Action Card
            _buildActionCard(context, type, colors, typeColor),

            const SizedBox(height: 16),

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

  Widget _buildActionCard(
    BuildContext context,
    String type,
    ColorScheme colors,
    Color typeColor,
  ) {
    String actionLabel = 'Xem chi tiết liên quan';
    String description = 'Nhấn vào nút bên dưới để chuyển tiếp đến trang quản lý tương ứng.';
    IconData actionIcon = Icons.arrow_forward_rounded;
    VoidCallback? onAction;

    if (type.toLowerCase().contains('đề tài') ||
        widget.notification['title'].toString().toLowerCase().contains('đề xuất')) {
      actionLabel = 'Xem danh sách đề xuất đề tài';
      description = 'Xem và phê duyệt các đề xuất đề tài mới từ nhóm sinh viên.';
      actionIcon = Icons.lightbulb_rounded;
      onAction = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LecturerTopicProposalScreen(),
          ),
        );
      };
    } else if (type.toLowerCase().contains('đăng ký')) {
      actionLabel = 'Xem danh sách đăng ký đề tài';
      description = 'Kiểm tra và xét duyệt các nhóm sinh viên đăng ký đề tài môn học.';
      actionIcon = Icons.assignment_turned_in_rounded;
      onAction = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TopicRegistrationScreen(),
          ),
        );
      };
    } else if (type.toLowerCase().contains('nhóm')) {
      actionLabel = 'Xem danh sách nhóm học phần';
      description = 'Theo dõi các nhóm sinh viên trong lớp học phần LTDD-01.';
      actionIcon = Icons.groups_rounded;
      onAction = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LecturerGroupScreen(),
          ),
        );
      };
    }

    return Container(
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
              Expanded(
                child: Text(
                  AppLocalizations.text('Tác vụ đề xuất', en: 'Suggested Action'),
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: Icon(actionIcon, size: 18),
              label: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('đề tài')) return const Color(0xFF8B5CF6);
    if (t.contains('đăng ký')) return const Color(0xFFF59E0B);
    if (t.contains('nhóm')) return const Color(0xFF10B981);
    return const Color(0xFF2563EB);
  }

  IconData _getTypeIcon(String type, dynamic fallbackIcon) {
    if (fallbackIcon is IconData) return fallbackIcon;
    final t = type.toLowerCase();
    if (t.contains('đề tài')) return Icons.lightbulb_rounded;
    if (t.contains('đăng ký')) return Icons.assignment_rounded;
    if (t.contains('nhóm')) return Icons.groups_rounded;
    return Icons.notifications_rounded;
  }
}
