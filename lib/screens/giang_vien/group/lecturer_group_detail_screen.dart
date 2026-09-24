import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_topic_registrations.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';

class LecturerGroupDetailScreen extends StatelessWidget {
  final LecturerCourseModel course;
  final GroupModel group;

  const LecturerGroupDetailScreen({
    super.key,
    required this.course,
    required this.group,
  });

  TopicRegistrationModel? _registeredTopicRegistration(
    LecturerCourseModel groupCourse,
  ) {
    final topicIds = MockLecturerTopics.getByCourse(
      groupCourse.courseId,
    ).map((topic) => topic.id).toSet();
    final registrations =
        MockLecturerTopicRegistrations.getAll()
            .where(
              (item) =>
                  item.groupId == group.id && topicIds.contains(item.topicId),
            )
            .toList()
          ..sort((a, b) => b.registeredAt.compareTo(a.registeredAt));

    return registrations.isEmpty ? null : registrations.first;
  }

  Color _groupStatusColor(BuildContext context) {
    final status = group.status.trim().toLowerCase();
    if (status.contains('hoạt động') || status.contains('đủ thành viên')) {
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
    final groupCourse =
        MockLecturerCourses.getByCourseId(group.courseId) ??
        (course.courseId == group.courseId ? course : null);
    if (groupCourse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết nhóm')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: colors.onSurfaceVariant),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.text(
                    'Không tìm thấy cấu hình học phần của nhóm.',
                    en: 'The course configuration for this group was not found.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.text(
                    'Số thành viên hiện tại: ${group.memberCount}. Giới hạn lưu trong nhóm: 1 - ${group.maxMembers}.',
                    en: 'Current members: ${group.memberCount}. Stored group limit: 1 - ${group.maxMembers}.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final registration = _registeredTopicRegistration(groupCourse);
    final TopicModel? topic = registration == null
        ? null
        : MockLecturerTopics.getById(registration.topicId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết nhóm', en: 'Group details'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GroupHeader(
            group: group,
            course: groupCourse,
            statusColor: _groupStatusColor(context),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: AppLocalizations.text(
              'Thông tin nhóm',
              en: 'Group information',
            ),
            children: [
              _InfoRow(
                icon: Icons.school_outlined,
                label: AppLocalizations.text('Học phần', en: 'Course'),
                value: '${groupCourse.name} • ${groupCourse.classCode}',
              ),
              _InfoRow(
                icon: Icons.person_outline,
                label: AppLocalizations.text('Trưởng nhóm', en: 'Leader'),
                value: group.leader,
              ),
              _InfoRow(
                icon: Icons.people_outline,
                label: AppLocalizations.text('Số thành viên', en: 'Members'),
                value: AppLocalizations.memberCount(
                  group.memberCount,
                  groupCourse.maxMembers,
                ),
              ),
              _InfoRow(
                icon: Icons.groups_outlined,
                label: AppLocalizations.text(
                  'Giới hạn thành viên',
                  en: 'Member limits',
                ),
                value: '${groupCourse.minMembers} - ${groupCourse.maxMembers}',
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
          const SizedBox(height: 16),
          _TopicCard(topic: topic, registration: registration),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final GroupModel group;
  final LecturerCourseModel course;
  final Color statusColor;

  const _GroupHeader({
    required this.group,
    required this.course,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  '${course.classCode} • ${AppLocalizations.memberCount(group.memberCount, course.maxMembers)} • ${course.minMembers}-${course.maxMembers}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    group.status,
                    style: TextStyle(
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primaryContainer,
            child: Icon(Icons.person_outline, color: colors.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isLeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Color.lerp(AppTheme.warningColor, colors.surface, 0.82),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.text('Trưởng nhóm', en: 'Leader'),
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicModel? topic;
  final TopicRegistrationModel? registration;

  const _TopicCard({required this.topic, required this.registration});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (topic == null || registration == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 40,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.text(
                  'Chưa đăng ký đề tài',
                  en: 'No registered topic',
                ),
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.text(
                'Đề tài đã đăng ký',
                en: 'Registered topic',
              ),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              topic!.title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              topic!.description,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(label: 'Đăng ký: ${registration!.status}'),
                _Tag(label: 'Trạng thái đề tài: ${topic!.status}'),
                if (topic!.technology.trim().isNotEmpty)
                  _Tag(label: topic!.technology),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
