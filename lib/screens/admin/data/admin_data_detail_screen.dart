import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../../data/mock/mock_groups.dart';
import '../../../data/mock/mock_training_data.dart';
import '../../../models/admin_account_model.dart';
import '../../../models/course_model.dart';
import '../../../models/group_model.dart';
import '../../../models/training_subject_model.dart';
import '../../admin/admin_helpers.dart';
import 'admin_data_management_screen.dart';

class AdminDataDetailScreen extends StatefulWidget {
  const AdminDataDetailScreen({
    super.key,
    required this.type,
    required this.title,
  });
  final AdminDataType type;
  final String title;

  @override
  State<AdminDataDetailScreen> createState() => _AdminDataDetailScreenState();
}

class _AdminDataDetailScreenState extends State<AdminDataDetailScreen> {
  String _query = '';

  List<_Record> _records() {
    final training = MockTrainingData.instance;
    return switch (widget.type) {
      AdminDataType.students =>
        training.students
            .map(
              (item) => _Record(
                item.fullName,
                '${item.studentCode} · ${item.email}',
                '${item.classCode} · ${adminStatusText(item.status)}',
              ),
            )
            .toList(),
      AdminDataType.lecturers =>
        training.lecturers
            .map(
              (item) => _Record(
                item.fullName,
                '${item.lecturerCode} · ${item.email}',
                '${item.faculty} · ${item.department}',
              ),
            )
            .toList(),
      AdminDataType.subjects =>
        training.subjects.map((item) => _subject(item)).toList(),
      AdminDataType.courseClasses =>
        training.courseClasses.map((item) => _course(item)).toList(),
      AdminDataType.groups =>
        MockGroups.groups.map((item) => _group(item)).toList(),
      AdminDataType.accounts =>
        MockAdminData.instance.accounts.map((item) => _account(item)).toList(),
    };
  }

  _Record _subject(TrainingSubjectModel item) => _Record(
    item.name,
    item.code,
    '${item.credits} ${adminText('tín chỉ', 'credits')} · ${item.department} · ${adminStatusText(item.status)}',
  );
  _Record _course(CourseModel item) => _Record(
    item.classCode,
    '${item.code} · ${item.name}',
    '${item.semester} · ${item.lecturer.isEmpty ? adminText('Chưa phân công', 'Unassigned') : item.lecturer} · ${adminStatusText(item.status)}',
  );
  _Record _group(GroupModel item) => _Record(
    item.name,
    '${item.memberCount}/${item.maxMembers} · ${item.leader}',
    adminStatusText(item.status),
  );
  _Record _account(AdminAccountModel item) => _Record(
    item.fullName,
    '${item.userCode} · ${item.username} · ${item.email}',
    '${adminRoleText(item.role)} · ${adminStatusText(item.status)}',
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      MockTrainingData.instance,
      MockAdminData.instance,
    ]),
    builder: (context, _) {
      final records = _records()
          .where(
            (item) => '${item.title} ${item.subtitle} ${item.extra}'
                .toLowerCase()
                .contains(_query.toLowerCase()),
          )
          .toList();
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: adminText(
                    'Tìm trong dữ liệu...',
                    'Search these records...',
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: records.isEmpty
                  ? adminEmptyState(
                      context,
                      'Không có dữ liệu phù hợp.',
                      'No matching records found.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final item = records[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.description_outlined),
                            title: Text(item.title),
                            subtitle: Text('${item.subtitle}\n${item.extra}'),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

class _Record {
  const _Record(this.title, this.subtitle, this.extra);
  final String title;
  final String subtitle;
  final String extra;
}
