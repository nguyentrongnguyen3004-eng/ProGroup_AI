import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/topic_model.dart';

class LecturerTopicCard extends StatelessWidget {
  final TopicModel topic;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LecturerTopicCard({
    super.key,
    required this.topic,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor(topic.status, colors);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFD97706),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.topicText(topic.title),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _StatusBadge(status: topic.status, color: statusColor),
                        ],
                      ),
                    ),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<_TopicCardAction>(
                        tooltip: AppLocalizations.text('Tùy chọn đề tài', en: 'Topic options'),
                        icon: Icon(
                          Icons.more_vert,
                          color: colors.onSurfaceVariant,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _TopicCardAction.edit:
                              onEdit?.call();
                              break;
                            case _TopicCardAction.delete:
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            PopupMenuItem(
                              value: _TopicCardAction.edit,
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 18),
                                  const SizedBox(width: 10),
                                  Text(AppLocalizations.text('Chỉnh sửa', en: 'Edit')),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            PopupMenuItem(
                              value: _TopicCardAction.delete,
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: colors.error, size: 18),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppLocalizations.text('Xóa', en: 'Delete'),
                                    style: TextStyle(color: colors.error),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    else if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                  ],
                ),
                if (topic.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.topicText(topic.description),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                if (topic.source.trim().isNotEmpty ||
                    topic.technology.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (topic.source.trim().isNotEmpty)
                        _MetadataTag(
                          icon: Icons.source_rounded,
                          label: AppLocalizations.source(topic.source),
                          color: const Color(0xFF6366F1),
                        ),
                      if (topic.technology.trim().isNotEmpty)
                        _MetadataTag(
                          icon: Icons.code_rounded,
                          label: topic.technology,
                          color: const Color(0xFF2563EB),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _TopicCardAction { edit, delete }

Color _statusColor(String status, ColorScheme colors) {
  final value = status.trim().toLowerCase();
  if (value.contains('chờ') || value.contains('pending')) {
    return AppTheme.warningColor;
  }
  if (value.contains('từ chối') ||
      value.contains('khóa') ||
      value.contains('rejected') ||
      value.contains('locked')) {
    return AppTheme.dangerColor;
  }
  if (value.contains('hoạt động') ||
      value.contains('đang') ||
      value.contains('đã duyệt') ||
      value.contains('active') ||
      value.contains('approved')) {
    return AppTheme.successColor;
  }
  return colors.onSurfaceVariant;
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 136),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Color.lerp(
          color,
          theme.colorScheme.surface,
          theme.brightness == Brightness.light ? 0.88 : 0.76,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        AppLocalizations.status(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetadataTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetadataTag({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tagColor = color ?? colors.primary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: tagColor.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tagColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tagColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
