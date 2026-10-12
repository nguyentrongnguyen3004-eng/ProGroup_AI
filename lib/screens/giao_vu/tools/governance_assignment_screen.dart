import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/governance_data_service.dart';
import '../../../services/notification_service.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../widgets/governance/governance_widgets.dart';

class GovernanceAssignmentScreen extends StatefulWidget {
  const GovernanceAssignmentScreen({super.key});

  @override
  State<GovernanceAssignmentScreen> createState() =>
      _GovernanceAssignmentScreenState();
}

class _GovernanceAssignmentScreenState
    extends State<GovernanceAssignmentScreen> {
  int? _courseId;
  int? _lecturerId;

  @override
  Widget build(BuildContext context) {
    final data = GovernanceDataService.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        if (data.courses.isEmpty || data.lecturers.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Phân công giảng viên')),
            body: const Center(
              child: Text('Cần có lớp học phần và giảng viên để phân công.'),
            ),
          );
        }
        final selectedCourses = data.courses
            .where((item) => item.id == _courseId)
            .toList();
        final course = selectedCourses.isEmpty
            ? data.courses.first
            : selectedCourses.first;
        final selectedLecturers = data.lecturers
            .where((item) => item.id == _lecturerId)
            .toList();
        final assignedLecturers = data.lecturers
            .where((item) => item.fullName == course.lecturer)
            .toList();
        final lecturer = selectedLecturers.isNotEmpty
            ? selectedLecturers.first
            : assignedLecturers.isNotEmpty
            ? assignedLecturers.first
            : data.lecturers.first;
        return Scaffold(
          appBar: AppBar(title: const Text('Phân công giảng viên')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Chọn lớp học phần, xem phân công hiện tại và xác nhận giảng viên mới.',
                style: TextStyle(color: AppTheme.grayColor),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                initialValue: course.id,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Lớp học phần'),
                items: data.courses
                    .map(
                      (item) => DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(
                          '${item.classCode} · ${item.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _courseId = value;
                  _lecturerId = null;
                }),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GovernanceInfoLine(
                        label: 'Mã lớp',
                        value: course.classCode,
                      ),
                      GovernanceInfoLine(label: 'Học phần', value: course.name),
                      GovernanceInfoLine(
                        label: 'Học kỳ',
                        value: course.semester,
                      ),
                      GovernanceInfoLine(
                        label: 'Giảng viên hiện tại',
                        value: course.lecturer,
                      ),
                      GovernanceInfoLine(
                        label: 'Trạng thái',
                        value: course.lecturer.trim().isEmpty
                            ? 'Chưa phân công'
                            : 'Đã phân công',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                initialValue: lecturer.id,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Giảng viên được phân công',
                ),
                items: data.lecturers
                    .map(
                      (item) => DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(
                          '${item.lecturerCode} · ${item.fullName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _lecturerId = value),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _confirm(data, course, lecturer),
                icon: const Icon(Icons.check),
                label: const Text('Xác nhận phân công'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirm(
    GovernanceDataService data,
    CourseModel course,
    LecturerModel lecturer,
  ) {
    data.assignLecturer(course.id, lecturer.fullName);
    NotificationService.instance.addNotification(
      type: 'Phân công',
      title: 'Phân công giảng viên được cập nhật',
      message: '${lecturer.fullName} phụ trách lớp ${course.classCode}.',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${lecturer.fullName} phụ trách lớp ${course.classCode}.',
        ),
      ),
    );
  }
}
