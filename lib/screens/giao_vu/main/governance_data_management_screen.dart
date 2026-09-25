import 'package:flutter/material.dart';
import '../course/governance_course_screen.dart';
import '../lecturer/governance_lecturer_screen.dart';
import '../student/governance_student_screen.dart';

enum GovernanceDataKind { students, lecturers, courses }

extension GovernanceDataKindLabel on GovernanceDataKind {
  String get label => switch (this) {
    GovernanceDataKind.students => 'Sinh viên',
    GovernanceDataKind.lecturers => 'Giảng viên',
    GovernanceDataKind.courses => 'Lớp học phần',
  };
}

class GovernanceDataManagementScreen extends StatefulWidget {
  const GovernanceDataManagementScreen({super.key});
  @override
  State<GovernanceDataManagementScreen> createState() =>
      _GovernanceDataManagementScreenState();
}

class _GovernanceDataManagementScreenState
    extends State<GovernanceDataManagementScreen> {
  GovernanceDataKind _kind = GovernanceDataKind.students;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quản lý dữ liệu')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: DropdownButtonFormField<GovernanceDataKind>(
            initialValue: _kind,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Chọn loại dữ liệu',
              prefixIcon: Icon(Icons.dataset_outlined),
            ),
            items: GovernanceDataKind.values
                .map(
                  (kind) =>
                      DropdownMenuItem(value: kind, child: Text(kind.label)),
                )
                .toList(),
            onChanged: (kind) {
              if (kind != null) setState(() => _kind = kind);
            },
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _kind.index,
            children: const [
              GovernanceStudentScreen(showAppBar: false),
              GovernanceLecturerScreen(showAppBar: false),
              GovernanceCourseScreen(showAppBar: false),
            ],
          ),
        ),
      ],
    ),
  );
}
