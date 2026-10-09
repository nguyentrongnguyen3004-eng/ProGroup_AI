import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../models/lecturer_model.dart';
import '../../../widgets/governance/governance_widgets.dart';
import '../main/governance_add_form_screen.dart';
import '../tools/governance_import_screen.dart';

class GovernanceLecturerScreen extends StatefulWidget {
  final bool showAppBar;
  const GovernanceLecturerScreen({super.key, this.showAppBar = true});

  @override
  State<GovernanceLecturerScreen> createState() =>
      _GovernanceLecturerScreenState();
}

class _GovernanceLecturerScreenState extends State<GovernanceLecturerScreen> {
  String _query = '';
  String _statusFilter = 'Tất cả';
  String _facultyFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final data = MockGovernanceData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final query = _query.trim().toLowerCase();
        final statuses =
            data.lecturers.map(data.lecturerStatus).toSet().toList()..sort();
        final faculties =
            data.lecturers.map((item) => item.faculty).toSet().toList()..sort();
        final lecturers = data.lecturers.where((lecturer) {
          final matchesQuery =
              query.isEmpty ||
              lecturer.lecturerCode.toLowerCase().contains(query) ||
              lecturer.fullName.toLowerCase().contains(query) ||
              lecturer.email.toLowerCase().contains(query) ||
              lecturer.faculty.toLowerCase().contains(query) ||
              lecturer.department.toLowerCase().contains(query);
          final status = data.lecturerStatus(lecturer);
          return matchesQuery &&
              (_statusFilter == 'Tất cả' || status == _statusFilter) &&
              (_facultyFilter == 'Tất cả' ||
                  lecturer.faculty == _facultyFilter);
        }).toList();
        return Scaffold(
          appBar: widget.showAppBar
              ? AppBar(title: const Text('Quản lý giảng viên'))
              : null,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GovernanceAddFormScreen(
                            kind: GovernanceAddKind.lecturer,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Thêm giảng viên'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GovernanceImportScreen(
                            initialKind: GovernanceImportKind.lecturers,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Nhập dữ liệu'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: GovernanceSearchField(
                  hint: 'Tìm theo mã, họ tên, email hoặc bộ môn',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openFilters(statuses, faculties),
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Bộ lọc'),
                    ),
                    const SizedBox(width: 8),
                    if (_statusFilter != 'Tất cả' || _facultyFilter != 'Tất cả')
                      TextButton(
                        onPressed: () => setState(() {
                          _statusFilter = 'Tất cả';
                          _facultyFilter = 'Tất cả';
                        }),
                        child: const Text('Xóa bộ lọc'),
                      ),
                    const Spacer(),
                    Text('${lecturers.length} / ${data.lecturers.length}'),
                  ],
                ),
              ),
              Expanded(
                child: lecturers.isEmpty
                    ? const Center(child: Text('Không tìm thấy giảng viên.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: lecturers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _lecturerCard(context, lecturers[index], data),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openFilters(
    List<String> statuses,
    List<String> faculties,
  ) async {
    var selectedStatus = statuses.contains(_statusFilter)
        ? _statusFilter
        : 'Tất cả';
    var selectedFaculty = faculties.contains(_facultyFilter)
        ? _facultyFilter
        : 'Tất cả';
    final filters = await showModalBottomSheet<Map<String, String>>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lọc giảng viên',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                items: [
                  const DropdownMenuItem(
                    value: 'Tất cả',
                    child: Text('Tất cả'),
                  ),
                  ...statuses.map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setSheetState(() => selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedFaculty,
                decoration: const InputDecoration(labelText: 'Khoa'),
                items: [
                  const DropdownMenuItem(
                    value: 'Tất cả',
                    child: Text('Tất cả'),
                  ),
                  ...faculties.map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setSheetState(() => selectedFaculty = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext, {
                      'status': 'Tất cả',
                      'faculty': 'Tất cả',
                    }),
                    child: const Text('Xóa bộ lọc'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, {
                      'status': selectedStatus,
                      'faculty': selectedFaculty,
                    }),
                    child: const Text('Áp dụng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (filters == null || !mounted) return;
    setState(() {
      _statusFilter = filters['status'] ?? 'Tất cả';
      _facultyFilter = filters['faculty'] ?? 'Tất cả';
    });
  }

  Widget _lecturerCard(
    BuildContext context,
    LecturerModel lecturer,
    MockGovernanceData data,
  ) {
    final courseCount = data.courses
        .where((course) => course.lecturer == lecturer.fullName)
        .length;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          foregroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.badge_outlined),
        ),
        title: Text(
          lecturer.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${lecturer.lecturerCode} · ${lecturer.department}\n${data.lecturerStatus(lecturer)} · $courseCount lớp học phần',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GovernanceLecturerDetailScreen(lecturer: lecturer),
          ),
        ),
      ),
    );
  }
}

class GovernanceLecturerDetailScreen extends StatelessWidget {
  final LecturerModel lecturer;

  const GovernanceLecturerDetailScreen({super.key, required this.lecturer});

  @override
  Widget build(BuildContext context) {
    final data = MockGovernanceData.instance;
    final courses = data.courses
        .where((course) => course.lecturer == lecturer.fullName)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết giảng viên')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GovernanceInfoLine(
                    label: 'Mã giảng viên',
                    value: lecturer.lecturerCode,
                  ),
                  GovernanceInfoLine(label: 'Họ tên', value: lecturer.fullName),
                  GovernanceInfoLine(label: 'Email', value: lecturer.email),
                  GovernanceInfoLine(
                    label: 'Bộ môn',
                    value: lecturer.department,
                  ),
                  GovernanceInfoLine(label: 'Khoa', value: lecturer.faculty),
                  GovernanceInfoLine(
                    label: 'Trạng thái',
                    value: data.lecturerStatus(lecturer),
                  ),
                  GovernanceInfoLine(
                    label: 'Số lớp phụ trách',
                    value: '${courses.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Chỉnh sửa'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _delete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Xóa'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Lớp học phần phụ trách',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (courses.isEmpty)
            const Text('Chưa được phân công lớp học phần.')
          else
            ...courses.map(
              (course) => Card(
                child: ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(
                    course.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${course.classCode} · ${course.semester}'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GovernanceAddFormScreen(
          kind: GovernanceAddKind.lecturer,
          existingData: lecturer,
        ),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa giảng viên?'),
        content: Text(
          'Bạn có chắc muốn xóa ${lecturer.fullName} '
          '(Mã: ${lecturer.lecturerCode})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    MockGovernanceData.instance.removeLecturer(lecturer.id);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Đã xóa giảng viên thành công.')),
    );
  }
}
