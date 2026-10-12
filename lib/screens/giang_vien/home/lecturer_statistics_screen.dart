import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/course_model.dart';
import '../../../models/group_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/course_service.dart';
import '../../../services/group_service.dart';
import '../../../services/topic_service.dart';
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
  bool _isLoading = true;
  List<CourseModel> _courses = [];
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];
  List<Map<String, dynamic>> _registrations = [];

  @override
  void initState() {
    super.initState();
    _courseId = widget.initialCourseId;
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final courses = await CourseService().getMyClasses();
      final topics = await TopicService().getLecturerTopics();
      final registrations = await TopicService().getTopicRegistrations();

      List<GroupModel> allGroups = [];
      for (final c in courses) {
        try {
          final gList = await GroupService().getGroupsByCourse(c.id);
          allGroups.addAll(gList);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _courses = courses;
          _topics = topics;
          _registrations = registrations;
          _groups = allGroups;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thống kê nâng cao')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final selectedCourses = _courseId == null
        ? _courses
        : _courses.where((c) => c.id == _courseId).toList();
    final selectedCourseIds = selectedCourses.map((c) => c.id).toSet();

    final filteredGroups = _groups
        .where((g) => _courseId == null || selectedCourseIds.contains(g.courseId))
        .toList();
    final filteredTopics = _topics
        .where((t) => _courseId == null || selectedCourseIds.contains(t.courseId))
        .toList();

    final pendingCount = _registrations
        .where((r) => (r['trangThai'] ?? '').toString().trim().toLowerCase() == 'chờ duyệt')
        .length;
    final approvedCount = _registrations
        .where((r) => (r['trangThai'] ?? '').toString().trim().toLowerCase() == 'đã duyệt')
        .length;
    final rejectedCount = _registrations
        .where((r) => (r['trangThai'] ?? '').toString().trim().toLowerCase() == 'đã từ chối')
        .length;

    final stats = <String, int>{
      'Lớp học phần': selectedCourses.length,
      'Nhóm': filteredGroups.length,
      'Đề tài': filteredTopics.length,
      'Đăng ký chờ duyệt': pendingCount,
      'Đăng ký đã duyệt': approvedCount,
      'Đăng ký bị từ chối': rejectedCount,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê nâng cao'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStats,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int?>(
            value: _courseId,
            decoration: const InputDecoration(labelText: 'Phạm vi học phần'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả học phần'),
              ),
              ..._courses.map(
                (course) => DropdownMenuItem<int?>(
                  value: course.id,
                  child: Text('${course.code} • ${course.name}'),
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
        ],
      ),
    );
  }
}

IconData _statIcon(String label) {
  if (label.contains('Lớp')) return Icons.school_outlined;
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
