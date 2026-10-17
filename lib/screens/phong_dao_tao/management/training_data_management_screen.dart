import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
<<<<<<< HEAD
import '../../../services/governance_api_service.dart';
=======
import '../../../services/training_data_service.dart';
import '../../../models/course_model.dart';
import '../../../models/governance_student_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../models/training_subject_model.dart';
>>>>>>> origin/Frontend
import 'training_add_form_screen.dart';
import 'training_import_screen.dart';

enum TrainingDataKind { courseClasses, students, lecturers, subjects }

extension TrainingDataKindLabel on TrainingDataKind {
  String label(BuildContext context) => switch (this) {
    TrainingDataKind.students => AppLocalizations.text('Sinh viên', en: 'Students'),
    TrainingDataKind.lecturers => AppLocalizations.text('Giảng viên', en: 'Lecturers'),
    TrainingDataKind.courseClasses => AppLocalizations.text('Lớp học phần', en: 'Classes'),
    TrainingDataKind.subjects => AppLocalizations.text('Môn học', en: 'Subjects'),
  };
}

class TrainingDataManagementScreen extends StatefulWidget {
  final TrainingDataKind initialKind;

  const TrainingDataManagementScreen({
    super.key,
    this.initialKind = TrainingDataKind.courseClasses,
  });

  @override
  State<TrainingDataManagementScreen> createState() => _TrainingDataManagementScreenState();
}

class _TrainingDataManagementScreenState extends State<TrainingDataManagementScreen> {
  late TrainingDataKind _kind = widget.initialKind;
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _lecturers = [];

  String _query = '';

  @override
<<<<<<< HEAD
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
=======
  Widget build(BuildContext context) {
    final data = TrainingDataService.instance;
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

  List<Object> _filteredRecords(TrainingDataService data) {
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

  int _totalCount(TrainingDataService data) => switch (_kind) {
    TrainingDataKind.students => data.students.length,
    TrainingDataKind.lecturers => data.lecturers.length,
    TrainingDataKind.courseClasses => data.courseClasses.length,
    TrainingDataKind.subjects => data.subjects.length,
  };

  List<String> _filterStatuses(TrainingDataService data) => switch (_kind) {
    TrainingDataKind.students =>
      data.students.map((item) => item.status).toSet().toList()..sort(),
    TrainingDataKind.lecturers =>
      data.lecturers.map(data.lecturerStatus).toSet().toList()..sort(),
    TrainingDataKind.courseClasses =>
      data.courseClasses.map((item) => item.status).toSet().toList()..sort(),
    TrainingDataKind.subjects =>
      data.subjects.map((item) => item.status).toSet().toList()..sort(),
  };

  List<String> _filterSemesters(TrainingDataService data) =>
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
>>>>>>> origin/Frontend
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        GovernanceApiService.instance.fetchCourses(),
        GovernanceApiService.instance.fetchStudents(),
        GovernanceApiService.instance.fetchLecturers(),
      ]);

<<<<<<< HEAD
      if (!mounted) return;
      setState(() {
        _courses = results[0];
        _students = results[1];
        _lecturers = results[2];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

=======
  Widget _recordTile(BuildContext context, Object item, TrainingDataService data) {
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
    final data = TrainingDataService.instance;
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
    final data = TrainingDataService.instance;
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

>>>>>>> origin/Frontend
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final query = _query.trim().toLowerCase();
    final canPop = ModalRoute.of(context)?.canPop == true;

    final List<Map<String, dynamic>> currentList;
    switch (_kind) {
      case TrainingDataKind.courseClasses:
        currentList = _courses.where((item) {
          if (query.isEmpty) return true;
          final code = (item['maLopHocPhan'] ?? item['MaLopHocPhan'] ?? '').toString().toLowerCase();
          final name = (item['tenLopHocPhan'] ?? item['TenLopHocPhan'] ?? item['tenHocPhan'] ?? item['TenHocPhan'] ?? '').toString().toLowerCase();
          final lecturer = (item['giangVienTen'] ?? item['GiangVienTen'] ?? '').toString().toLowerCase();
          return code.contains(query) || name.contains(query) || lecturer.contains(query);
        }).toList();
      case TrainingDataKind.students:
        currentList = _students.where((item) {
          if (query.isEmpty) return true;
          final code = (item['studentCode'] ?? item['mssv'] ?? item['MSSV'] ?? '').toString().toLowerCase();
          final name = (item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '').toString().toLowerCase();
          final email = (item['email'] ?? item['Email'] ?? '').toString().toLowerCase();
          return code.contains(query) || name.contains(query) || email.contains(query);
        }).toList();
      case TrainingDataKind.lecturers:
        currentList = _lecturers.where((item) {
          if (query.isEmpty) return true;
          final code = (item['lecturerCode'] ?? item['maGiangVien'] ?? item['MaGiangVien'] ?? '').toString().toLowerCase();
          final name = (item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '').toString().toLowerCase();
          final dept = (item['department'] ?? item['boMon'] ?? item['tenBoMon'] ?? '').toString().toLowerCase();
          return code.contains(query) || name.contains(query) || dept.contains(query);
        }).toList();
      case TrainingDataKind.subjects:
        final seen = <String>{};
        currentList = _courses.where((item) {
          final sCode = (item['maHocPhan'] ?? item['MaHocPhan'] ?? item['maLopHocPhan'] ?? '').toString();
          if (seen.contains(sCode)) return false;
          seen.add(sCode);
          if (query.isEmpty) return true;
          final name = (item['tenHocPhan'] ?? item['TenHocPhan'] ?? '').toString().toLowerCase();
          return sCode.toLowerCase().contains(query) || name.contains(query);
        }).toList();
    }

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(
                AppLocalizations.text('Quản lý Đào tạo', en: 'Academic Management'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                  onPressed: _loadAllData,
                ),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          _showActionMenu(context);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.text('Thêm / Nhập', en: 'Add / Import')),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Top Banner (Đồng bộ chuẩn Giảng viên)
            if (!canPop)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.text('Quản lý Đào tạo', en: 'Academic Management'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.text(
                              'Dữ liệu Lớp học phần, Sinh viên & Giảng viên',
                              en: 'Manage classes, students & faculty data',
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: _loadAllData,
                      tooltip: 'Tải lại',
                    ),
                  ],
                ),
              ),

            // 4-Tab KPI Selector Cards
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _TabPill(
                      label: 'Lớp HP',
                      count: _courses.length,
                      color: const Color(0xFF2563EB),
                      icon: Icons.school_rounded,
                      isSelected: _kind == TrainingDataKind.courseClasses,
                      onTap: () => setState(() => _kind = TrainingDataKind.courseClasses),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TabPill(
                      label: 'Sinh viên',
                      count: _students.length,
                      color: const Color(0xFF10B981),
                      icon: Icons.people_rounded,
                      isSelected: _kind == TrainingDataKind.students,
                      onTap: () => setState(() => _kind = TrainingDataKind.students),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TabPill(
                      label: 'Giảng viên',
                      count: _lecturers.length,
                      color: const Color(0xFF6366F1),
                      icon: Icons.badge_rounded,
                      isSelected: _kind == TrainingDataKind.lecturers,
                      onTap: () => setState(() => _kind = TrainingDataKind.lecturers),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TabPill(
                      label: 'Môn học',
                      count: _courses.length,
                      color: const Color(0xFFF59E0B),
                      icon: Icons.auto_stories_rounded,
                      isSelected: _kind == TrainingDataKind.subjects,
                      onTap: () => setState(() => _kind = TrainingDataKind.subjects),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: TextField(
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm ${_kind.label(context).toLowerCase()}...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB)),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  ),
                ),
              ),
            ),

            // List Content
            Expanded(
              child: _buildListContent(currentList, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(List<Map<String, dynamic>> currentList, ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAllData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (currentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Không có dữ liệu phù hợp.',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: currentList.length,
        itemBuilder: (context, index) {
          final item = currentList[index];
          return _buildItemCard(item, colors);
        },
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, ColorScheme colors) {
    final String title;
    final String subtitle;
    final String tag1;
    final String? tag2;
    final IconData icon;
    final Color color;

    switch (_kind) {
      case TrainingDataKind.courseClasses:
        title = item['tenLopHocPhan'] ?? item['TenLopHocPhan'] ?? item['tenHocPhan'] ?? 'Lớp học phần';
        subtitle = 'GV: ${item['giangVienTen'] ?? item['GiangVienTen'] ?? 'Chưa phân công'}';
        tag1 = item['maLopHocPhan'] ?? item['MaLopHocPhan'] ?? '';
        tag2 = 'Tối đa: ${item['soLuongToiDa'] ?? 45} SV';
        icon = Icons.school_rounded;
        color = const Color(0xFF2563EB);
      case TrainingDataKind.students:
        title = item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? 'Sinh viên';
        subtitle = 'Email: ${item['email'] ?? item['Email'] ?? 'Chưa có'}';
        tag1 = item['studentCode'] ?? item['mssv'] ?? item['MSSV'] ?? '';
        tag2 = 'Lớp: ${item['classCode'] ?? item['maLop'] ?? 'CNTT'}';
        icon = Icons.people_rounded;
        color = const Color(0xFF10B981);
      case TrainingDataKind.lecturers:
        title = item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? 'Giảng viên';
        subtitle = 'Bộ môn: ${item['department'] ?? item['boMon'] ?? 'Công nghệ phần mềm'}';
        tag1 = item['lecturerCode'] ?? item['maGiangVien'] ?? item['MaGiangVien'] ?? '';
        tag2 = item['email'] ?? item['Email'];
        icon = Icons.badge_rounded;
        color = const Color(0xFF6366F1);
      case TrainingDataKind.subjects:
        title = item['tenHocPhan'] ?? item['TenHocPhan'] ?? item['tenLopHocPhan'] ?? 'Học phần';
        subtitle = 'Hệ số tín chỉ: ${item['soTinChi'] ?? 3} TC';
        tag1 = item['maHocPhan'] ?? item['MaHocPhan'] ?? '';
        tag2 = 'Bắt buộc';
        icon = Icons.auto_stories_rounded;
        color = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag1,
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: colors.onSurface),
                        ),
                      ),
                      if (tag2 != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag2,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: Color(0xFF2563EB)),
                  ),
                  title: const Text('Thêm thủ công', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tạo mới lớp học phần hoặc hồ sơ'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TrainingAddFormScreen(kind: _kind)),
                    ).then((_) => _loadAllData());
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.file_upload_rounded, color: Color(0xFF10B981)),
                  ),
                  title: const Text('Nhập từ Excel / CSV', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tải lên danh sách hàng loạt'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TrainingImportScreen()),
                    ).then((_) => _loadAllData());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.14) : colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : colors.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
