import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../models/course_model.dart';
import '../../../widgets/governance/governance_widgets.dart';

class GovernanceCourseScreen extends StatefulWidget {
  final bool showAppBar;
  const GovernanceCourseScreen({super.key, this.showAppBar = true});

  @override
  State<GovernanceCourseScreen> createState() => _GovernanceCourseScreenState();
}

class _GovernanceCourseScreenState extends State<GovernanceCourseScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final data = MockGovernanceData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final query = _query.trim().toLowerCase();
        final courses = data.courses.where((course) {
          return query.isEmpty ||
              course.code.toLowerCase().contains(query) ||
              course.name.toLowerCase().contains(query) ||
              course.classCode.toLowerCase().contains(query) ||
              course.lecturer.toLowerCase().contains(query);
        }).toList();
        return Scaffold(
          appBar: widget.showAppBar
              ? AppBar(title: const Text('Lớp học phần'))
              : null,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: GovernanceSearchField(
                  hint: 'Tìm mã lớp, học phần hoặc giảng viên',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: courses.isEmpty
                    ? const Center(child: Text('Không tìm thấy lớp học phần.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: courses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _courseCard(context, courses[index], data),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _courseCard(
    BuildContext context,
    CourseModel course,
    MockGovernanceData data,
  ) {
    final studentCount = data.students
        .where((student) => student.classCode == course.classCode)
        .length;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          foregroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.school_outlined),
        ),
        title: Text(
          course.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${course.classCode} · ${course.semester}\n${course.lecturer} · $studentCount sinh viên',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GovernanceCourseDetailScreen(courseId: course.id),
          ),
        ),
      ),
    );
  }
}

class GovernanceCourseDetailScreen extends StatelessWidget {
  final int courseId;

  const GovernanceCourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final data = MockGovernanceData.instance;
    final course = data.courses.firstWhere((item) => item.id == courseId);
    final students = data.students
        .where((student) => student.classCode == course.classCode)
        .toList();
    final matchingLecturers = data.lecturers
        .where((item) => item.fullName == course.lecturer)
        .toList();
    final lecturerCode = matchingLecturers.isEmpty
        ? 'Chưa có dữ liệu'
        : matchingLecturers.first.lecturerCode;
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lớp học phần')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GovernanceInfoLine(label: 'Mã học phần', value: course.code),
                  GovernanceInfoLine(label: 'Tên học phần', value: course.name),
                  GovernanceInfoLine(
                    label: 'Mã lớp học phần',
                    value: course.classCode,
                  ),
                  GovernanceInfoLine(label: 'Học kỳ', value: course.semester),
                  GovernanceInfoLine(
                    label: 'Giảng viên',
                    value: course.lecturer,
                  ),
                  GovernanceInfoLine(
                    label: 'Mã giảng viên',
                    value: lecturerCode,
                  ),
                  GovernanceInfoLine(
                    label: 'Số sinh viên',
                    value: '${students.length}',
                  ),
                  GovernanceInfoLine(label: 'Trạng thái', value: course.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Sinh viên thuộc lớp',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (students.isEmpty)
            const Text('Chưa có sinh viên trong mock roster của lớp này.')
          else
            ...students.map(
              (student) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(
                    student.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${student.studentCode} · ${student.email}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
