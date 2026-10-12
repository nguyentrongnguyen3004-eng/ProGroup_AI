import 'package:flutter/material.dart';

import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/group_service.dart';
import '../../../services/topic_service.dart';
import '../../../widgets/lecturer/lecturer_group_card.dart';
import '../group/lecturer_group_detail_screen.dart';
import '../group/lecturer_group_screen.dart';
import '../topic/lecturer_topic_screen.dart';
import 'lecturer_course_settings_screen.dart';

class LecturerCourseDetailScreen extends StatefulWidget {
  final LecturerCourseModel course;

  const LecturerCourseDetailScreen({super.key, required this.course});

  @override
  State<LecturerCourseDetailScreen> createState() =>
      _LecturerCourseDetailScreenState();
}

class _LecturerCourseDetailScreenState
    extends State<LecturerCourseDetailScreen> {
  late LecturerCourseModel course;
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    course = widget.course;
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    setState(() => _isLoading = true);
    try {
      final groups = await GroupService().getGroupsByCourse(course.courseId);
      final topics = await TopicService().getLecturerTopics(dotDangKyId: course.courseId);
      if (mounted) {
        setState(() {
          _groups = groups;
          _topics = topics;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lớp học phần')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lớp học phần'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourseData,
          ),
        ],
      ),
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
                  _Info(label: 'Sinh viên tối đa', value: '${course.studentCount}'),
                  _Info(label: 'Nhóm', value: '${_groups.length}'),
                  _Info(label: 'Đề tài', value: '${_topics.length}'),
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
                        '${course.groupRegistrationStart} – ${course.groupRegistrationEnd}',
                  ),
                  _Info(
                    label: 'Đăng ký đề tài',
                    value:
                        '${course.topicRegistrationStart} – ${course.topicRegistrationEnd}',
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
                      if (updated != null && mounted) {
                        setState(() => course = updated);
                      }
                    },
                    icon: const Icon(Icons.tune_outlined),
                    label: const Text('Cấu hình thời gian và quy mô nhóm'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeading(
            title: 'Nhóm của học phần',
            trailing: Text('${_groups.length}'),
          ),
          const SizedBox(height: 8),
          if (_groups.isEmpty)
            const _EmptyCard(message: 'Học phần chưa có nhóm.')
          else
            ..._groups
                .take(3)
                .map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LecturerGroupCard(
                      group: group,
                      onTap: () => _openGroup(context, group),
                    ),
                  ),
                ),
          if (_groups.isNotEmpty)
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
            trailing: Text('${_topics.length}'),
          ),
          const SizedBox(height: 8),
          if (_topics.isEmpty)
            const _EmptyCard(message: 'Học phần chưa có đề tài.')
          else
            ..._topics.map(
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
                    builder: (_) => const LecturerTopicScreen(),
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
        builder: (_) => LecturerGroupDetailScreen(group: group),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing!,
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
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.grey),
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
    return Card(
      child: ListTile(
        title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          topic.description.isNotEmpty ? topic.description : 'Chưa có mô tả',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            topic.status,
            style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
