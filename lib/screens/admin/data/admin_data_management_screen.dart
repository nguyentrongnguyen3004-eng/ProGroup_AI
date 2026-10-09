import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../../data/mock/mock_groups.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../data/mock/mock_training_data.dart';
import '../../admin/admin_helpers.dart';
import 'admin_data_detail_screen.dart';

enum AdminDataType {
  students,
  lecturers,
  subjects,
  courseClasses,
  groups,
  accounts,
}

class AdminDataManagementScreen extends StatelessWidget {
  const AdminDataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      MockAdminData.instance,
      MockTrainingData.instance,
      MockGovernanceData.instance,
    ]),
    builder: (context, _) {
      final training = MockTrainingData.instance;
      final items = [
        (
          AdminDataType.students,
          adminText('Sinh viên', 'Students'),
          training.students.length,
          Icons.school_outlined,
        ),
        (
          AdminDataType.lecturers,
          adminText('Giảng viên', 'Lecturers'),
          training.lecturers.length,
          Icons.co_present_outlined,
        ),
        (
          AdminDataType.subjects,
          adminText('Học phần', 'Subjects'),
          training.subjects.length,
          Icons.menu_book_outlined,
        ),
        (
          AdminDataType.courseClasses,
          adminText('Lớp học phần', 'Course classes'),
          training.courseClasses.length,
          Icons.class_outlined,
        ),
        (
          AdminDataType.groups,
          adminText('Nhóm/đồ án', 'Groups/projects'),
          MockGroups.groups.length,
          Icons.groups_outlined,
        ),
        (
          AdminDataType.accounts,
          adminText('Tài khoản', 'Accounts'),
          MockAdminData.instance.accounts.length,
          Icons.people_outline,
        ),
      ];
      return Scaffold(
        appBar: AppBar(
          title: Text(adminText('Dữ liệu hệ thống', 'System data')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              adminText(
                'Tra cứu dữ liệu hiện có trong các module.',
                'Browse data currently owned by the existing modules.',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            for (final item in items)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(item.$4)),
                  title: Text(item.$2),
                  subtitle: Text(
                    '${item.$3} ${adminText('bản ghi', 'records')} · ${adminText('Chỉ xem', 'Read only')}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminDataDetailScreen(type: item.$1, title: item.$2),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              adminText(
                'Dữ liệu này được đọc từ collections hiện có; thao tác CRUD tiếp tục thuộc module sở hữu dữ liệu.',
                'These records are read from existing collections; CRUD remains in the owning module.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    },
  );
}
