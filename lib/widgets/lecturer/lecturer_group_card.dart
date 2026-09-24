import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/group_model.dart';

class LecturerGroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;
  final int? minMembers;
  final int? maxMembers;

  const LecturerGroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.minMembers,
    this.maxMembers,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor(group.status, colors);
    final memberLimit = maxMembers ?? group.maxMembers;
    final memberSummary = minMembers == null
        ? group.memberCount.toString() +
              '/' +
              memberLimit.toString() +
              ' thành viên'
        : group.memberCount.toString() +
              ' thành viên • quy mô ' +
              minMembers.toString() +
              '–' +
              memberLimit.toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(Icons.groups_outlined, color: colors.onPrimaryContainer),
        ),
        title: Text(
          group.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            memberSummary + '\nTrưởng nhóm: ' + group.leader,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusBadge(status: group.status, color: statusColor),
            const SizedBox(height: 4),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

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
      constraints: const BoxConstraints(maxWidth: 116),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
