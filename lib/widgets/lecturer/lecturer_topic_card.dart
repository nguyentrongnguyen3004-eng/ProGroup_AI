import 'package:flutter/material.dart';

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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _StatusBadge(status: topic.status, color: statusColor),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<_TopicCardAction>(
                      tooltip: 'Tùy chọn đề tài',
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
                          const PopupMenuItem(
                            value: _TopicCardAction.edit,
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined),
                                SizedBox(width: 10),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: _TopicCardAction.delete,
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: colors.error),
                                const SizedBox(width: 10),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: colors.error),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  else if (onTap != null)
                    Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                ],
              ),
              if (topic.description.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  topic.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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
                        icon: Icons.link_outlined,
                        label: topic.source,
                      ),
                    if (topic.technology.trim().isNotEmpty)
                      _MetadataTag(
                        icon: Icons.memory_outlined,
                        label: topic.technology,
                      ),
                  ],
                ),
              ],
            ],
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
        status,
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

  const _MetadataTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
