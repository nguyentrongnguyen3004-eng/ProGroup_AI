import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../models/governance_student_model.dart';
import '../../../widgets/governance/governance_widgets.dart';
import '../main/governance_add_form_screen.dart';
import '../tools/governance_import_screen.dart';

class GovernanceStudentScreen extends StatefulWidget {
  final bool showAppBar;
  const GovernanceStudentScreen({super.key, this.showAppBar = true});

  @override
  State<GovernanceStudentScreen> createState() =>
      _GovernanceStudentScreenState();
}

class _GovernanceStudentScreenState extends State<GovernanceStudentScreen> {
  String _query = '';
  String _classFilter = 'Tất cả';
  String _statusFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final data = MockGovernanceData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final classes =
            data.students.map((item) => item.classCode).toSet().toList()
              ..sort();
        final statuses =
            data.students.map((item) => item.status).toSet().toList()..sort();
        final students = data.students.where((student) {
          final query = _query.trim().toLowerCase();
          final matchesQuery =
              query.isEmpty ||
              student.studentCode.toLowerCase().contains(query) ||
              student.fullName.toLowerCase().contains(query) ||
              student.email.toLowerCase().contains(query) ||
              student.classCode.toLowerCase().contains(query) ||
              student.status.toLowerCase().contains(query);
          return matchesQuery &&
              (_classFilter == 'Tất cả' || student.classCode == _classFilter) &&
              (_statusFilter == 'Tất cả' || student.status == _statusFilter);
        }).toList();

        return Scaffold(
          appBar: widget.showAppBar
              ? AppBar(title: const Text('Quản lý sinh viên'))
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
                            kind: GovernanceAddKind.student,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Thêm sinh viên'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GovernanceImportScreen(
                            initialKind: GovernanceImportKind.students,
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openFilters(classes, statuses),
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Bộ lọc'),
                    ),
                    const SizedBox(width: 8),
                    if (_classFilter != 'Tất cả' || _statusFilter != 'Tất cả')
                      TextButton(
                        onPressed: () => setState(() {
                          _classFilter = 'Tất cả';
                          _statusFilter = 'Tất cả';
                        }),
                        child: const Text('Xóa bộ lọc'),
                      ),
                    const Spacer(),
                    Text('${students.length} / ${data.students.length}'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: GovernanceSearchField(
                  hint: 'Tìm theo MSSV, họ tên hoặc email',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Tất cả'),
                    ...classes.map(_filterChip),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: students.isEmpty
                    ? const Center(child: Text('Không tìm thấy sinh viên.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: students.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _studentCard(context, students[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(value),
        selected: _classFilter == value,
        onSelected: (_) => setState(() => _classFilter = value),
      ),
    );
  }

  Future<void> _openFilters(List<String> classes, List<String> statuses) async {
    var selectedClass = classes.contains(_classFilter)
        ? _classFilter
        : 'Tất cả';
    var selectedStatus = statuses.contains(_statusFilter)
        ? _statusFilter
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
                'Lọc sinh viên',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedClass,
                decoration: const InputDecoration(labelText: 'Lớp'),
                items: [
                  const DropdownMenuItem(
                    value: 'Tất cả',
                    child: Text('Tất cả'),
                  ),
                  ...classes.map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setSheetState(() => selectedClass = value);
                },
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext, {
                      'class': 'Tất cả',
                      'status': 'Tất cả',
                    }),
                    child: const Text('Xóa bộ lọc'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, {
                      'class': selectedClass,
                      'status': selectedStatus,
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
      _classFilter = filters['class'] ?? 'Tất cả';
      _statusFilter = filters['status'] ?? 'Tất cả';
    });
  }

  Widget _studentCard(BuildContext context, GovernanceStudentModel student) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          foregroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.person_outline),
        ),
        title: Text(
          student.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${student.studentCode} · ${student.classCode}\n${student.email} · ${student.status}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GovernanceStudentDetailScreen(student: student),
          ),
        ),
      ),
    );
  }
}

class GovernanceStudentDetailScreen extends StatelessWidget {
  final GovernanceStudentModel student;

  const GovernanceStudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sinh viên')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 34,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student.fullName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    student.studentCode,
                    style: const TextStyle(color: AppTheme.grayColor),
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
                children: [
                  GovernanceInfoLine(
                    label: 'Email',
                    value: student.email,
                    icon: Icons.email_outlined,
                  ),
                  GovernanceInfoLine(
                    label: 'Lớp',
                    value: student.classCode,
                    icon: Icons.school_outlined,
                  ),
                  GovernanceInfoLine(
                    label: 'Trạng thái',
                    value: student.status,
                    icon: Icons.verified_outlined,
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
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GovernanceAddFormScreen(
          kind: GovernanceAddKind.student,
          existingData: student,
        ),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa sinh viên?'),
        content: Text(
          'Bạn có chắc muốn xóa ${student.fullName} '
          '(MSSV: ${student.studentCode})?',
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
    MockGovernanceData.instance.removeStudent(student.id);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Đã xóa sinh viên thành công.')),
    );
  }
}
