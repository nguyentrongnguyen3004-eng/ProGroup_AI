import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_groups.dart';
import '../../../data/mock/mock_lecturer_topic_proposals.dart';
import '../../../data/mock/mock_lecturer_topic_registrations.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../widgets/lecturer/lecturer_stat_card.dart';

class LecturerStatisticsScreen extends StatefulWidget {
  final int? initialCourseId;
  const LecturerStatisticsScreen({super.key, this.initialCourseId});

  @override
  State<LecturerStatisticsScreen> createState() =>
      _LecturerStatisticsScreenState();
}

class _LecturerStatisticsScreenState extends State<LecturerStatisticsScreen> {
  int? _courseId;

  @override
  void initState() {
    super.initState();
    _courseId = widget.initialCourseId;
  }

  @override
  Widget build(BuildContext context) {
    final courses = MockLecturerCourses.courses;
    final selected = _courseId == null
        ? courses
        : courses.where((course) => course.courseId == _courseId).toList();
    final ids = selected.map((course) => course.courseId).toSet();
    final groups = MockLecturerGroups.groups
        .where((group) => ids.contains(group.courseId))
        .toList();
    final topics = MockLecturerTopics.topics
        .where((topic) => ids.contains(topic.courseId))
        .toList();
    final groupIds = groups.map((group) => group.id).toSet();
    final topicIds = topics.map((topic) => topic.id).toSet();
    final registrations = MockLecturerTopicRegistrations.getAll()
        .where(
          (item) =>
              groupIds.contains(item.groupId) &&
              topicIds.contains(item.topicId),
        )
        .toList();
    final groupsRegistered = registrations
        .map((item) => item.groupId)
        .toSet()
        .length;
    final openTopics = topics
        .where(
          (topic) =>
              topic.status.contains('Đang hoạt động') ||
              topic.status.contains('Đang mở'),
        )
        .length;
    final stats = <String, int>{
      'Sinh viên': selected.fold<int>(
        0,
        (sum, course) => sum + course.studentCount,
      ),
      'Nhóm': groups.length,
      'Nhóm có đăng ký đề tài': groupsRegistered,
      'Nhóm chưa đăng ký': groups.length - groupsRegistered,
      'Đề tài đang mở': openTopics,
      'Đề tài đã đăng ký': registrations.length,
      'Đăng ký chờ duyệt': registrations
          .where((item) => item.status == 'Chờ duyệt')
          .length,
      'Đăng ký đã duyệt': registrations
          .where((item) => item.status == 'Đã duyệt')
          .length,
      'Đăng ký bị từ chối': registrations
          .where((item) => item.status == 'Từ chối')
          .length,
      'Đề xuất sinh viên': MockLecturerTopicProposals.instance.proposals
          .where((item) => ids.contains(item.courseId))
          .length,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê nâng cao')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int?>(
            initialValue: _courseId,
            decoration: const InputDecoration(labelText: 'Phạm vi học phần'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả học phần'),
              ),
              ...courses.map(
                (course) => DropdownMenuItem<int?>(
                  value: course.courseId,
                  child: Text(course.name + ' • ' + course.classCode),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _courseId = value),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.48,
            children: [
              for (final entry in stats.entries)
                LecturerStatCard(
                  title: entry.key,
                  value: entry.value.toString(),
                  icon: _statIcon(entry.key),
                  color: _statColor(entry.key),
                ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tỷ lệ nhóm gửi đăng ký đề tài'),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: groups.isEmpty
                        ? 0
                        : groupsRegistered / groups.length,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    groupsRegistered.toString() +
                        ' / ' +
                        groups.length.toString() +
                        ' nhóm',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _statIcon(String label) {
  if (label.contains('Sinh viên')) return Icons.people_outline;
  if (label.contains('Nhóm')) return Icons.groups_outlined;
  if (label.contains('Đề tài')) return Icons.lightbulb_outline;
  if (label.contains('chờ')) return Icons.pending_actions_outlined;
  if (label.contains('đã duyệt')) return Icons.check_circle_outline;
  if (label.contains('từ chối')) return Icons.cancel_outlined;
  return Icons.assignment_outlined;
}

Color _statColor(String label) {
  if (label.contains('chờ')) return AppTheme.warningColor;
  if (label.contains('từ chối')) return AppTheme.dangerColor;
  if (label.contains('đã duyệt')) return AppTheme.successColor;
  return AppTheme.primaryColor;
}
