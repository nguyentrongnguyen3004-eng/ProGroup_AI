import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/group_model.dart';

class LecturerGroupDetailScreen extends StatelessWidget {
  final GroupModel group;

  const LecturerGroupDetailScreen({
    super.key,
    required this.group,
  });

  Color _groupStatusColor(BuildContext context) {
    final status = group.status.trim().toLowerCase();
    if (status.contains('hoạt động') || status.contains('đủ thành viên') || status.contains('đang mở')) {
      return AppTheme.successColor;
    }
    if (status.contains('khóa') || status.contains('inactive')) {
      return AppTheme.dangerColor;
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Chi tiết nhóm', en: 'Group details')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.groups, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Số thành viên: ${group.memberCount}/${group.maxMembers}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _groupStatusColor(context).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          group.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: AppLocalizations.text('Thông tin nhóm', en: 'Group information'),
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                label: AppLocalizations.text('Trưởng nhóm', en: 'Leader'),
                value: group.leader.isNotEmpty ? group.leader : 'Chưa có',
              ),
              _InfoRow(
                icon: Icons.people_outline,
                label: AppLocalizations.text('Số thành viên', en: 'Members'),
                value: '${group.memberCount} / ${group.maxMembers}',
              ),
              _InfoRow(
                icon: Icons.info_outline,
                label: AppLocalizations.text('Trạng thái', en: 'Status'),
                value: group.status,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: AppLocalizations.text('Thành viên', en: 'Members'),
            children: group.members.isEmpty
                ? [
                    Text(
                      AppLocalizations.text(
                        'Chưa có thông tin thành viên.',
                        en: 'Member information is not available.',
                      ),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ]
                : [
                    for (final member in group.members)
                      _MemberRow(
                        name: member,
                        isLeader: member == group.leader,
                      ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final String name;
  final bool isLeader;

  const _MemberRow({required this.name, required this.isLeader});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
      ),
      title: Text(name),
      trailing: isLeader
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Trưởng nhóm',
                style: TextStyle(color: colors.onPrimaryContainer, fontSize: 11),
              ),
            )
          : null,
    );
  }
}
