import 'package:flutter/material.dart';

import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_groups.dart';
import '../../../data/mock/mock_lecturer_topic_registrations.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../widgets/lecturer/lecturer_group_card.dart';
import '../home/lecturer_statistics_screen.dart';
import 'lecturer_course_settings_screen.dart';
import '../group/lecturer_group_detail_screen.dart';
import '../group/lecturer_group_screen.dart';
import '../topic/lecturer_topic_screen.dart';

class LecturerCourseDetailScreen extends StatefulWidget {
  final LecturerCourseModel course;

  const LecturerCourseDetailScreen({super.key, required this.course});

  @override
  State<LecturerCourseDetailScreen> createState() =>
      _LecturerCourseDetailScreenState();
}

class _LecturerCourseDetailScreenState
    extends State<LecturerCourseDetailScreen> {
  LecturerCourseModel get course =>
      MockLecturerCourses.getByCourseId(widget.course.courseId) ??
      widget.course;

  @override
  Widget build(BuildContext context) {
    final groups = MockLecturerGroups.getByCourse(course.courseId);
    final topics = MockLecturerTopics.getByCourse(course.courseId);
    final groupIds = groups.map((group) => group.id).toSet();
    final topicIds = topics.map((topic) => topic.id).toSet();
    final registrations = MockLecturerTopicRegistrations.getAll()
        .where(
          (item) =>
              groupIds.contains(item.groupId) &&
              topicIds.contains(item.topicId),
        )
        .toList();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lớp học phần')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.school_outlined,
                      size: 30,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${course.code} • ${course.classCode}',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _Info(label: 'Học kỳ', value: course.semester),
                  _Info(label: 'Sinh viên', value: '${course.studentCount}'),
                  _Info(label: 'Nhóm', value: '${groups.length}'),
                  _Info(label: 'Đề tài', value: '${topics.length}'),
                  _Info(
                    label: 'Đăng ký đề tài',
                    value: '${registrations.length}',
                  ),
                  _Info(
                    label: 'Số thành viên mỗi nhóm',
                    value: '${course.minMembers} - ${course.maxMembers}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời gian đăng ký',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _Info(
                    label: 'Lập nhóm',
                    value:
                        course.groupRegistrationStart +
                        ' – ' +
                        course.groupRegistrationEnd,
                  ),
                  _Info(
                    label: 'Đăng ký đề tài',
                    value:
                        course.topicRegistrationStart +
                        ' – ' +
                        course.topicRegistrationEnd,
                  ),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push<LecturerCourseModel>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LecturerCourseSettingsScreen(course: course),
                        ),
                      );
                      if (updated != null && mounted) setState(() {});
                    },
                    icon: const Icon(Icons.tune_outlined),
                    label: const Text('Cấu hình thời gian và quy mô nhóm'),
                  ),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LecturerStatisticsScreen(
                          initialCourseId: course.courseId,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('Thống kê học phần'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeading(
            title: 'Nhóm của học phần',
            trailing: Text('${groups.length}'),
          ),
          const SizedBox(height: 8),
          if (groups.isEmpty)
            const _EmptyCard(message: 'Học phần chưa có nhóm.')
          else
            ...groups
                .take(3)
                .map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LecturerGroupCard(
                      group: group,
                      minMembers: course.minMembers,
                      maxMembers: course.maxMembers,
                      onTap: () => _openGroup(context, group),
                    ),
                  ),
                ),
          if (groups.isNotEmpty)
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LecturerGroupScreen(course: course),
                    ),
                  );
                },
                icon: const Icon(Icons.groups_outlined),
                label: const Text('Xem tất cả nhóm'),
              ),
            ),
          const SizedBox(height: 20),
          _SectionHeading(
            title: 'Đề tài của học phần',
            trailing: Text('${topics.length}'),
          ),
          const SizedBox(height: 8),
          if (topics.isEmpty)
            const _EmptyCard(message: 'Học phần chưa có đề tài.')
          else
            ...topics.map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TopicPreview(topic: topic),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LecturerTopicScreen(lecturerCourseId: course.courseId),
                  ),
                );
              },
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Quản lý đề tài của học phần'),
            ),
          ),
        ],
      ),
    );
  }

  void _openGroup(BuildContext context, GroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LecturerGroupDetailScreen(course: course, group: group),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeading({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null)
          DefaultTextStyle(
            style: TextStyle(color: colors.onSurfaceVariant),
            child: trailing!,
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TopicPreview extends StatelessWidget {
  final TopicModel topic;

  const _TopicPreview({required this.topic});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(
            Icons.lightbulb_outline,
            color: colors.onPrimaryContainer,
          ),
        ),
        title: Text(topic.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${topic.technology} • ${topic.status}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
