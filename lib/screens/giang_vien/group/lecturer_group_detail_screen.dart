import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/group_model.dart';
<<<<<<< HEAD
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';
import '../../../services/lecturer_api_service.dart';

class LecturerGroupDetailScreen extends StatefulWidget {
  final LecturerCourseModel course;
=======

class LecturerGroupDetailScreen extends StatelessWidget {
>>>>>>> origin/Frontend
  final GroupModel group;

  const LecturerGroupDetailScreen({
    super.key,
    required this.group,
  });

<<<<<<< HEAD
  @override
  State<LecturerGroupDetailScreen> createState() =>
      _LecturerGroupDetailScreenState();
}

class _LecturerGroupDetailScreenState extends State<LecturerGroupDetailScreen> {
  bool _isLoading = true;
  TopicRegistrationModel? _registration;
  TopicModel? _topic;

  @override
  void initState() {
    super.initState();
    _loadTopicAndRegistration();
  }

  Future<void> _loadTopicAndRegistration() async {
    try {
      final results = await Future.wait([
        LecturerApiService.instance.fetchTopics(widget.course.courseId),
        LecturerApiService.instance.fetchTopicRegistrations(widget.course.courseId),
      ]);

      final topics = results[0] as List<TopicModel>;
      final rawRegs = results[1] as List<Map<String, dynamic>>;

      TopicRegistrationModel? matchedReg;
      for (final raw in rawRegs) {
        final reg = TopicRegistrationModel.fromJson(raw);
        if (reg.groupId == widget.group.id) {
          matchedReg = reg;
          break;
        }
      }

      TopicModel? matchedTopic;
      if (matchedReg != null) {
        for (final t in topics) {
          if (t.id == matchedReg.topicId) {
            matchedTopic = t;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _registration = matchedReg;
          _topic = matchedTopic;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _groupStatusColor(BuildContext context) {
    final status = widget.group.status.trim().toLowerCase();
    if (status.contains('hoạt động') || status.contains('đủ thành viên')) {
=======
  Color _groupStatusColor(BuildContext context) {
    final status = group.status.trim().toLowerCase();
    if (status.contains('hoạt động') || status.contains('đủ thành viên') || status.contains('đang mở')) {
>>>>>>> origin/Frontend
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
<<<<<<< HEAD
    final groupCourse = widget.course;
=======
>>>>>>> origin/Frontend

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Chi tiết nhóm', en: 'Group details')),
      ),
<<<<<<< HEAD
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                children: [
                  _GroupHeader(
                    group: widget.group,
                    course: groupCourse,
                    statusColor: _groupStatusColor(context),
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: AppLocalizations.text(
                      'Thông tin nhóm',
                      en: 'Group information',
=======
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
>>>>>>> origin/Frontend
                    ),
                    children: [
                      _InfoRow(
                        icon: Icons.school_rounded,
                        iconColor: const Color(0xFF6366F1),
                        label: AppLocalizations.text('Học phần', en: 'Course'),
                        value:
                            '${AppLocalizations.courseName(groupCourse.name)} • ${groupCourse.classCode}',
                      ),
<<<<<<< HEAD
                      _InfoRow(
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        label: AppLocalizations.text('Trưởng nhóm', en: 'Leader'),
                        value: widget.group.leader,
                      ),
                      _InfoRow(
                        icon: Icons.people_alt_rounded,
                        iconColor: const Color(0xFF2563EB),
                        label: AppLocalizations.text('Số thành viên', en: 'Members'),
                        value: AppLocalizations.memberCount(
                          widget.group.memberCount,
                          groupCourse.maxMembers,
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.groups_rounded,
                        iconColor: const Color(0xFF10B981),
                        label: AppLocalizations.text(
                          'Giới hạn thành viên',
                          en: 'Member limits',
                        ),
                        value: '${groupCourse.minMembers} - ${groupCourse.maxMembers}',
                      ),
                      _InfoRow(
                        icon: Icons.info_rounded,
                        iconColor: _groupStatusColor(context),
                        label: AppLocalizations.text('Trạng thái', en: 'Status'),
                        value: AppLocalizations.status(widget.group.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: AppLocalizations.text('Thành viên', en: 'Members'),
                    children: widget.group.members.isEmpty
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
                            for (final member in widget.group.members)
                              _MemberRow(
                                name: member,
                                isLeader: member == widget.group.leader,
                              ),
                          ],
                  ),
                  const SizedBox(height: 16),
                  _TopicCard(topic: _topic, registration: _registration),
                ],
              ),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  AppLocalizations.groupName(group.name),
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
                    AppLocalizations.status(group.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
=======
                  ],
>>>>>>> origin/Frontend
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
<<<<<<< HEAD
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
=======
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
>>>>>>> origin/Frontend
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = iconColor ?? colors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
<<<<<<< HEAD
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
=======
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
>>>>>>> origin/Frontend
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
<<<<<<< HEAD
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isLeader
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                  : const Color(0xFF6366F1).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLeader ? Icons.star_rounded : Icons.person_rounded,
              size: 20,
              color: isLeader ? const Color(0xFFD97706) : const Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: isLeader ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          if (isLeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.text('Trưởng nhóm', en: 'Leader'),
                style: const TextStyle(
                  color: Color(0xFFD97706),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                size: 32,
                color: colors.onSurfaceVariant,
              ),
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
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  size: 18,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.text(
                  'Đề tài đã đăng ký',
                  en: 'Registered topic',
                ),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.topicText(topic!.title),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.topicText(topic!.description),
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(
                label:
                    '${AppLocalizations.text('Đăng ký', en: 'Registration')}: ${AppLocalizations.status(registration!.status)}',
              ),
              _Tag(
                label:
                    '${AppLocalizations.text('Trạng thái đề tài', en: 'Topic status')}: ${AppLocalizations.status(topic!.status)}',
              ),
              if (topic!.technology.trim().isNotEmpty)
                _Tag(label: topic!.technology),
            ],
          ),
        ],
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
=======
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
>>>>>>> origin/Frontend
    );
  }
}
