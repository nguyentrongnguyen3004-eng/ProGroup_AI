import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_training_data.dart';
import '../../../models/course_model.dart';
import '../../../models/governance_student_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../models/training_subject_model.dart';
import 'training_add_form_screen.dart';
import 'training_import_screen.dart';

enum TrainingDataKind { students, lecturers, courseClasses, subjects }

extension TrainingDataKindLabel on TrainingDataKind {
  String label(BuildContext context) => switch (this) {
    TrainingDataKind.students => _text(context, 'Sinh viên', 'Students'),
    TrainingDataKind.lecturers => _text(context, 'Giảng viên', 'Lecturers'),
    TrainingDataKind.courseClasses => _text(
      context,
      'Lớp học phần',
      'Course classes',
    ),
    TrainingDataKind.subjects => _text(context, 'Học phần', 'Courses'),
  };
}

class TrainingDataManagementScreen extends StatefulWidget {
  final TrainingDataKind initialKind;

  const TrainingDataManagementScreen({
    super.key,
    this.initialKind = TrainingDataKind.students,
  });

  @override
  State<TrainingDataManagementScreen> createState() =>
      _TrainingDataManagementScreenState();
}

class _TrainingDataManagementScreenState
    extends State<TrainingDataManagementScreen> {
  late TrainingDataKind _kind = widget.initialKind;
  String _query = '';
  String _statusFilter = '';
  String _semesterFilter = '';

  @override
  Widget build(BuildContext context) {
    final data = MockTrainingData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final records = _filteredRecords(data);
        final statusFilterActive = _filterStatuses(
          data,
        ).contains(_statusFilter);
        final semesterFilterActive = _filterSemesters(
          data,
        ).contains(_semesterFilter);
        return Scaffold(
          appBar: AppBar(
            title: Text(_text(context, 'Quản lý dữ liệu', 'Data management')),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  children: [
                    DropdownButtonFormField<TrainingDataKind>(
                      initialValue: _kind,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: _text(context, 'Loại dữ liệu', 'Data type'),
                        prefixIcon: const Icon(Icons.dataset_outlined),
                      ),
                      items: TrainingDataKind.values
                          .map(
                            (kind) => DropdownMenuItem(
                              value: kind,
                              child: Text(kind.label(context)),
                            ),
                          )
                          .toList(),
                      onChanged: (kind) {
                        if (kind == null) return;
                        setState(() {
                          _kind = kind;
                          _query = '';
                          _statusFilter = '';
                          _semesterFilter = '';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TrainingAddFormScreen(kind: _kind),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(_addLabel(context)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    TrainingImportScreen(initialKind: _kind),
                              ),
                            ),
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(
                              _text(context, 'Nhập dữ liệu', 'Import data'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const TrainingImportHistoryScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.history),
                            label: Text(
                              _text(
                                context,
                                'Lịch sử­ import',
                                'Import history',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: _text(context, 'Tìm kiếm...', 'Search...'),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: _text(context, 'Xóa', 'Clear'),
                                onPressed: () => setState(() => _query = ''),
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openFilters(
                            _filterStatuses(data),
                            _filterSemesters(data),
                          ),
                          icon: const Icon(Icons.filter_list),
                          label: Text(_text(context, 'Bộ lọc', 'Filters')),
                        ),
                        const SizedBox(width: 8),
                        if (statusFilterActive || semesterFilterActive)
                          TextButton(
                            onPressed: () => setState(() {
                              _statusFilter = '';
                              _semesterFilter = '';
                            }),
                            child: Text(
                              _text(context, 'Xóa bộ lọc', 'Clear filters'),
                            ),
                          ),
                        const Spacer(),
                        Text('${records.length} / ${_totalCount(data)}'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? _EmptyDataState(
                        title:
                            _query.trim().isEmpty &&
                                _statusFilter.isEmpty &&
                                _semesterFilter.isEmpty
                            ? _text(context, 'Chưa có dữ liệu', 'No data yet')
                            : _text(
                                context,
                                'Không tìm thấy kết quả',
                                'No results found',
                              ),
                        message: _query.trim().isEmpty
                            ? _text(
                                context,
                                'Dữ liệu sẽ xuất hiện tại đây khi có bản ghi.',
                                'Records will appear here when available.',
                              )
                            : _text(
                                context,
                                'Thử tìm bằng mã hoặc tên khác.',
                                'Try searching with another code or name.',
                              ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: records.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _recordTile(context, records[index], data),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Object> _filteredRecords(MockTrainingData data) {
    final query = _query.trim().toLowerCase();
    final activeStatus = _filterStatuses(data).contains(_statusFilter)
        ? _statusFilter
        : '';
    final activeSemester = _filterSemesters(data).contains(_semesterFilter)
        ? _semesterFilter
        : '';
    bool matches(String value) => value.toLowerCase().contains(query);
    return switch (_kind) {
      TrainingDataKind.students =>
        data.students
            .where(
              (item) =>
                  (query.isEmpty ||
                      matches(
                        '${item.studentCode} ${item.fullName} ${item.email} ${item.classCode}',
                      )) &&
                  (activeStatus.isEmpty || item.status == activeStatus),
            )
            .toList(),
      TrainingDataKind.lecturers =>
        data.lecturers
            .where(
              (item) =>
                  (query.isEmpty ||
                      matches(
                        '${item.lecturerCode} ${item.fullName} ${item.email} ${item.faculty} ${item.department}',
                      )) &&
                  (activeStatus.isEmpty ||
                      data.lecturerStatus(item) == activeStatus),
            )
            .toList(),
      TrainingDataKind.courseClasses =>
        data.courseClasses
            .where(
              (item) =>
                  (query.isEmpty ||
                      matches(
                        '${item.code} ${item.name} ${item.classCode} ${item.lecturer}',
                      )) &&
                  (activeStatus.isEmpty || item.status == activeStatus) &&
                  (activeSemester.isEmpty || item.semester == activeSemester),
            )
            .toList(),
      TrainingDataKind.subjects =>
        data.subjects
            .where(
              (item) =>
                  (query.isEmpty || matches('${item.code} ${item.name}')) &&
                  (activeStatus.isEmpty || item.status == activeStatus),
            )
            .toList(),
    };
  }

  int _totalCount(MockTrainingData data) => switch (_kind) {
    TrainingDataKind.students => data.students.length,
    TrainingDataKind.lecturers => data.lecturers.length,
    TrainingDataKind.courseClasses => data.courseClasses.length,
    TrainingDataKind.subjects => data.subjects.length,
  };

  List<String> _filterStatuses(MockTrainingData data) => switch (_kind) {
    TrainingDataKind.students =>
      data.students.map((item) => item.status).toSet().toList()..sort(),
    TrainingDataKind.lecturers =>
      data.lecturers.map(data.lecturerStatus).toSet().toList()..sort(),
    TrainingDataKind.courseClasses =>
      data.courseClasses.map((item) => item.status).toSet().toList()..sort(),
    TrainingDataKind.subjects =>
      data.subjects.map((item) => item.status).toSet().toList()..sort(),
  };

  List<String> _filterSemesters(MockTrainingData data) =>
      data.courseClasses
          .map((item) => item.semester)
          .where((semester) => semester.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  Future<void> _openFilters(
    List<String> statuses,
    List<String> semesters,
  ) async {
    var selectedStatus = statuses.contains(_statusFilter) ? _statusFilter : '';
    var selectedSemester = semesters.contains(_semesterFilter)
        ? _semesterFilter
        : '';
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
                _text(
                  context,
                  'Lọc ${_kind.label(context).toLowerCase()}',
                  'Filter ${_kind.label(context).toLowerCase()}',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: InputDecoration(
                  labelText: _text(context, 'Trạng thái', 'Status'),
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(_text(context, 'Tất cả', 'All')),
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
              if (_kind == TrainingDataKind.courseClasses) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSemester,
                  decoration: InputDecoration(
                    labelText: _text(context, 'Học kỳ', 'Semester'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(_text(context, 'Tất cả', 'All')),
                    ),
                    ...semesters.map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => selectedSemester = value);
                    }
                  },
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext, {
                      'status': '',
                      'semester': '',
                    }),
                    child: Text(_text(context, 'Xóa bộ lọc', 'Clear filters')),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, {
                      'status': selectedStatus,
                      'semester': selectedSemester,
                    }),
                    child: Text(_text(context, 'Áp dụng', 'Apply')),
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
      _statusFilter = filters['status'] ?? '';
      _semesterFilter = filters['semester'] ?? '';
    });
  }

  String _addLabel(BuildContext context) => switch (_kind) {
    TrainingDataKind.students => _text(
      context,
      'Thêm sinh viên',
      'Add student',
    ),
    TrainingDataKind.lecturers => _text(
      context,
      'Thêm giảng viên',
      'Add lecturer',
    ),
    TrainingDataKind.courseClasses => _text(
      context,
      'Thêm lớp học phần',
      'Add course class',
    ),
    TrainingDataKind.subjects => _text(context, 'Thêm học phần', 'Add course'),
  };

  Widget _recordTile(BuildContext context, Object item, MockTrainingData data) {
    if (item is GovernanceStudentModel) {
      return _RecordCard(
        icon: Icons.person_outline,
        title: item.fullName,
        subtitle: '${item.studentCode} • ${item.classCode}\n${item.email}',
        trailing: item.status,
        onTap: () => _showDetails(
          context,
          record: item,
          title: item.fullName,
          icon: Icons.person_outline,
          values: [
            _DetailValue(
              _text(context, 'Mã sinh viên', 'Student ID'),
              item.studentCode,
            ),
            _DetailValue(_text(context, 'Email', 'Email'), item.email),
            _DetailValue(_text(context, 'Lớp', 'Class'), item.classCode),
            _DetailValue(_text(context, 'Trạng thái', 'Status'), item.status),
          ],
        ),
      );
    }
    if (item is LecturerModel) {
      return _RecordCard(
        icon: Icons.badge_outlined,
        title: item.fullName,
        subtitle:
            '${item.lecturerCode} • ${item.faculty}\n${item.email} · ${item.department}',
        trailing: data.lecturerStatus(item),
        onTap: () => _showDetails(
          context,
          record: item,
          title: item.fullName,
          icon: Icons.badge_outlined,
          values: [
            _DetailValue(
              _text(context, 'Mã giảng viên', 'Lecturer ID'),
              item.lecturerCode,
            ),
            _DetailValue(_text(context, 'Email', 'Email'), item.email),
            _DetailValue(_text(context, 'Khoa', 'Faculty'), item.faculty),
            _DetailValue(
              _text(context, 'Bộ môn', 'Department'),
              item.department,
            ),
            _DetailValue(
              _text(context, 'Trạng thái công tác', 'Work status'),
              data.lecturerStatus(item),
            ),
          ],
        ),
      );
    }
    if (item is CourseModel) {
      return _RecordCard(
        icon: Icons.class_outlined,
        title: '${item.classCode} • ${item.name}',
        subtitle:
            '${item.code} • ${item.semester}\n${item.lecturer.isEmpty ? _text(context, 'Chưa phân công', 'Unassigned') : item.lecturer}',
        trailing: item.status,
        onTap: () => _showCourseDetails(context, item),
      );
    }
    final subject = item as TrainingSubjectModel;
    return _RecordCard(
      icon: Icons.menu_book_outlined,
      title: subject.name,
      subtitle:
          '${subject.code} • ${subject.credits} ${_text(context, 'tín chỉ', 'credits')} · ${subject.department}',
      trailing: subject.status,
      onTap: () => _showDetails(
        context,
        record: subject,
        title: subject.name,
        icon: Icons.menu_book_outlined,
        values: [
          _DetailValue(
            _text(context, 'Mã học phần', 'Course code'),
            subject.code,
          ),
          _DetailValue(
            _text(context, 'Số tín chỉ', 'Credits'),
            '${subject.credits}',
          ),
          _DetailValue(
            _text(context, 'Bộ môn', 'Department'),
            subject.department,
          ),
          _DetailValue(_text(context, 'Trạng thái', 'Status'), subject.status),
        ],
      ),
    );
  }

  void _showCourseDetails(BuildContext context, CourseModel course) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Icon(Icons.class_outlined, color: colors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course.classCode,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailLine(
                _text(context, 'Học phần', 'Course'),
                '${course.code} • ${course.name}',
              ),
              _DetailLine(
                _text(context, 'Học kỳ', 'Semester'),
                course.semester,
              ),
              _DetailLine(
                _text(context, 'Giảng viên', 'Lecturer'),
                course.lecturer,
              ),
              _DetailLine(
                _text(context, 'Trạng thái', 'Status'),
                course.status,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _assignLecturer(context, course);
                  },
                  icon: const Icon(Icons.assignment_ind_outlined),
                  label: Text(
                    _text(context, 'Phân công giảng viên', 'Assign lecturer'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openEdit(context, course);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(_text(context, 'Chỉnh sửa', 'Edit')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _deleteRecord(context, course);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(_text(context, 'Xóa', 'Delete')),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _assignLecturer(BuildContext context, CourseModel course) async {
    final data = MockTrainingData.instance;
    String selected = course.lecturer;
    final assigned = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            _text(context, 'Phân công giảng viên', 'Assign lecturer'),
          ),
          content: DropdownButtonFormField<String>(
            initialValue:
                data.lecturers.any((lecturer) => lecturer.fullName == selected)
                ? selected
                : '',
            decoration: InputDecoration(
              labelText: _text(
                context,
                'Giảng viên phụ trách',
                'Assigned lecturer',
              ),
            ),
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(_text(context, 'Chưa phân công', 'Unassigned')),
              ),
              ...data.lecturers.map(
                (lecturer) => DropdownMenuItem(
                  value: lecturer.fullName,
                  child: Text(lecturer.fullName),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) setDialogState(() => selected = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_text(context, 'Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, selected),
              child: Text(_text(context, 'Lưu', 'Save')),
            ),
          ],
        ),
      ),
    );
    if (assigned != null && context.mounted) {
      data.assignLecturer(course.id, assigned);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              context,
              'Đã cập nhật giảng viên phụ trách.',
              'Assigned lecturer updated.',
            ),
          ),
        ),
      );
    }
  }

  void _showDetails(
    BuildContext context, {
    required Object record,
    required String title,
    required IconData icon,
    required List<_DetailValue> values,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(icon),
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: values
                .map((value) => _DetailLine(value.label, value.value))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_text(context, 'Đóng', 'Close')),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _openEdit(context, record);
            },
            icon: const Icon(Icons.edit_outlined),
            label: Text(_text(context, 'Chỉnh sửa', 'Edit')),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteRecord(context, record);
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(_text(context, 'Xóa', 'Delete')),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, Object record) async {
    final kind = switch (record) {
      GovernanceStudentModel() => TrainingDataKind.students,
      LecturerModel() => TrainingDataKind.lecturers,
      CourseModel() => TrainingDataKind.courseClasses,
      TrainingSubjectModel() => TrainingDataKind.subjects,
      _ => null,
    };
    if (kind == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TrainingAddFormScreen(kind: kind, existingData: record),
      ),
    );
  }

  Future<void> _deleteRecord(BuildContext context, Object record) async {
    final data = MockTrainingData.instance;
    final subjectClassCount = record is TrainingSubjectModel
        ? data.courseClasses.where((item) => item.code == record.code).length
        : 0;
    final (title, description, success) = switch (record) {
      GovernanceStudentModel item => (
        _text(context, 'Xóa sinh viên?', 'Delete student?'),
        _text(
          context,
          'Bạn có chắc muốn xóa ${item.fullName} (MSSV: ${item.studentCode})?',
          'Delete ${item.fullName} (${item.studentCode})?',
        ),
        _text(context, 'Đã xóa sinh viên thành công.', 'Student deleted.'),
      ),
      LecturerModel item => (
        _text(context, 'Xóa giảng viên?', 'Delete lecturer?'),
        _text(
          context,
          'Bạn có chắc muốn xóa ${item.fullName} (${item.lecturerCode})? Các lớp được phân công sẽ bỏ giảng viên.',
          'Delete ${item.fullName} (${item.lecturerCode})? Assigned classes will become unassigned.',
        ),
        _text(context, 'Đã xóa giảng viên thành công.', 'Lecturer deleted.'),
      ),
      CourseModel item => (
        _text(context, 'Xóa lớp học phần?', 'Delete course class?'),
        _text(
          context,
          'Bạn có chắc muốn xóa lớp ${item.classCode}?',
          'Delete course class ${item.classCode}?',
        ),
        _text(
          context,
          'Đã xóa lớp học phần thành công.',
          'Course class deleted.',
        ),
      ),
      TrainingSubjectModel item => (
        _text(context, 'Xóa học phần?', 'Delete course?'),
        _text(
          context,
          'Bạn có chắc muốn xóa ${item.name}? ${subjectClassCount > 0 ? 'Thao tác này cũng xóa $subjectClassCount lớp học phần liên quan.' : ''}',
          'Delete ${item.name}? ${subjectClassCount > 0 ? '$subjectClassCount related course classes will also be deleted.' : ''}',
        ),
        _text(context, 'Đã xóa học phần thành công.', 'Course deleted.'),
      ),
      _ => (
        _text(context, 'Xóa dữ liệu?', 'Delete record?'),
        _text(
          context,
          'Bạn có chắc muốn xóa?',
          'Are you sure you want to delete it?',
        ),
        _text(context, 'Đã xóa dữ liệu.', 'Record deleted.'),
      ),
    };
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_text(context, 'Hủy', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(_text(context, 'Xóa', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    switch (record) {
      case GovernanceStudentModel item:
        data.removeStudent(item.id);
      case LecturerModel item:
        data.removeLecturer(item.id);
      case CourseModel item:
        data.removeCourseClass(item.id);
      case TrainingSubjectModel item:
        data.removeSubject(item.code);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(success)));
  }
}

String _text(BuildContext context, String vi, String en) =>
    AppLocalizations.text(vi, en: en);

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  const _RecordCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              trailing,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class _DetailValue {
  final String label;
  final String value;

  const _DetailValue(this.label, this.value);
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 126,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class _EmptyDataState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyDataState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 54,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
