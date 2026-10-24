import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
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
        ? AppLocalizations.text(
            '${group.memberCount}/$memberLimit thành viên',
            en: '${group.memberCount}/$memberLimit members',
          )
        : AppLocalizations.text(
            '${group.memberCount} thành viên • quy mô $minMembers–$memberLimit',
            en: '${group.memberCount} members • size $minMembers–$memberLimit',
          );

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colorful Squircle Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _statusIcon(group.status),
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.groupName(group.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: group.status, color: statusColor),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Subtitle with colorful mini icons
                      Row(
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            size: 13,
                            color: Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              memberSummary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 13,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${AppLocalizations.text('Trưởng nhóm', en: 'Leader')}: ${group.leader}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (onTap != null)
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                        ],
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

IconData _statusIcon(String status) {
  final value = status.trim().toLowerCase();
  if (value.contains('chờ') || value.contains('pending')) {
    return Icons.group_add_rounded;
  }
  if (value.contains('từ chối') ||
      value.contains('khóa') ||
      value.contains('rejected') ||
      value.contains('locked')) {
    return Icons.lock_person_rounded;
  }
  return Icons.groups_rounded;
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
