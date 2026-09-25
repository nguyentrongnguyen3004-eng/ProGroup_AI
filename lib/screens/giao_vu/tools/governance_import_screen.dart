import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart' as csv;
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../data/mock/mock_governance_notifications.dart';
import '../../../models/course_model.dart';
import '../../../models/governance_student_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../models/training_import_record_model.dart';

enum GovernanceImportKind { students, lecturers, courses }

extension on GovernanceImportKind {
  String get label => switch (this) {
    GovernanceImportKind.students => 'Sinh viên',
    GovernanceImportKind.lecturers => 'Giảng viên',
    GovernanceImportKind.courses => 'Lớp học phần',
  };

  List<String> get headers => switch (this) {
    GovernanceImportKind.students => [
      'MSSV',
      'Họ tên',
      'Email',
      'Lớp',
      'Trạng thái',
    ],
    GovernanceImportKind.lecturers => [
      'Mã giảng viên',
      'Họ tên',
      'Email',
      'Bộ môn',
      'Trạng thái',
    ],
    GovernanceImportKind.courses => [
      'Mã lớp học phần',
      'Tên học phần',
      'Học kỳ',
      'Mã giảng viên',
      'Trạng thái',
    ],
  };

  String get fileName => switch (this) {
    GovernanceImportKind.students => 'mau_import_sinh_vien',
    GovernanceImportKind.lecturers => 'mau_import_giang_vien',
    GovernanceImportKind.courses => 'mau_import_lop_hoc_phan',
  };
}

class _ImportRow {
  final int line;
  final List<String> cells;

  const _ImportRow(this.line, this.cells);
}

class GovernanceImportScreen extends StatefulWidget {
  final GovernanceImportKind initialKind;

  const GovernanceImportScreen({
    super.key,
    this.initialKind = GovernanceImportKind.students,
  });

  @override
  State<GovernanceImportScreen> createState() => _GovernanceImportScreenState();
}

class _GovernanceImportScreenState extends State<GovernanceImportScreen> {
  late GovernanceImportKind _kind = widget.initialKind;
  String _format = 'csv';
  String? _fileName;
  Uint8List? _selectedBytes;
  bool _previewReady = false;
  List<_ImportRow> _validRows = [];
  List<String> _issues = [];
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import dữ liệu'),
        actions: [
          IconButton(
            tooltip: AppLocalizations.text(
              'Lịch sử import',
              en: 'Import history',
            ),
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const GovernanceImportHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          const Text(
            'Chọn loại dữ liệu, tải mẫu và kiểm tra file trước khi import.',
            style: TextStyle(color: AppTheme.grayColor),
          ),
          const SizedBox(height: 16),
          _GovernanceFlowCard(
            number: '1',
            title: 'Chọn loại dữ liệu',
            description: 'Chọn danh sách cần cập nhật.',
            child: DropdownButtonFormField<GovernanceImportKind>(
              initialValue: _kind,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Loại dữ liệu'),
              items: GovernanceImportKind.values
                  .map(
                    (kind) =>
                        DropdownMenuItem(value: kind, child: Text(kind.label)),
                  )
                  .toList(),
              onChanged: _busy
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _kind = value;
                        _clearPreview();
                      });
                    },
            ),
          ),
          const SizedBox(height: 12),
          _GovernanceFlowCard(
            number: '2',
            title: 'Chọn định dạng',
            description: 'Tải và chọn file CSV hoặc Excel .xlsx.',
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'csv', label: Text('CSV')),
                ButtonSegment(value: 'xlsx', label: Text('Excel')),
              ],
              selected: {_format},
              onSelectionChanged: _busy
                  ? null
                  : (values) => setState(() {
                      _format = values.first;
                      _clearPreview();
                    }),
            ),
          ),
          const SizedBox(height: 12),
          _GovernanceFlowCard(
            number: '3',
            title: 'Tải file mẫu',
            description:
                'Mẫu ${_kind.label.toLowerCase()} có header đúng định dạng.',
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _downloadTemplate,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Tải file mẫu'),
            ),
          ),
          const SizedBox(height: 12),
          _GovernanceFlowCard(
            number: '4',
            title: 'Chọn file',
            description: 'Chọn file $_format cho ${_kind.label.toLowerCase()}.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pickFile,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Chọn file'),
                ),
                if (_fileName != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: .45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _fileName!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Bỏ file',
                          onPressed: _busy
                              ? null
                              : () => setState(_clearPreview),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GovernanceFlowCard(
            number: '5',
            title: 'Xem trước',
            description:
                'Đọc file, kiểm tra header, số cột và dữ liệu từng dòng.',
            child: FilledButton.icon(
              onPressed: _busy ? null : _continueToPreview,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.preview_outlined),
              label: const Text('Tiếp tục xem trước'),
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          if (_previewReady) _buildPreview(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xem trước dữ liệu',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text('${_validRows.length} dòng hợp lệ · ${_issues.length} lỗi'),
            if (_issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Cần kiểm tra',
                style: TextStyle(
                  color: AppTheme.dangerColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              ..._issues
                  .take(8)
                  .map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        issue,
                        style: const TextStyle(color: AppTheme.dangerColor),
                      ),
                    ),
                  ),
              if (_issues.length > 8)
                Text('Còn ${_issues.length - 8} lỗi khác.'),
            ],
            if (_validRows.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._validRows.take(5).map(_previewRow),
              if (_validRows.length > 5)
                Text('Còn ${_validRows.length - 5} dòng hợp lệ khác.'),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _busy ? null : _confirmImport,
                icon: const Icon(Icons.check),
                label: Text('Import ${_validRows.length} dòng hợp lệ'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _previewRow(_ImportRow row) {
    final fields = <String>[];
    for (var index = 0; index < _kind.headers.length; index++) {
      fields.add('${_kind.headers[index]}: ${row.cells[index]}');
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dòng ${row.line}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            fields.join(' · '),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _clearPreview() {
    _fileName = null;
    _selectedBytes = null;
    _previewReady = false;
    _validRows = [];
    _issues = [];
  }

  Future<void> _downloadTemplate() async {
    setState(() => _busy = true);
    try {
      final csvHeader = _kind.headers.join(',');
      final bytes = _format == 'csv'
          ? Uint8List.fromList(utf8.encode('\uFEFF$csvHeader\r\n'))
          : _createExcelTemplate();
      final extension = _format;
      final mime = _format == 'csv'
          ? 'text/csv'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      final saveToDownloads =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
      final savedPath = saveToDownloads
          ? await FileSaver.instance.saveFile(
              name: _kind.fileName,
              bytes: bytes,
              fileExtension: extension,
              mimeType: MimeType.custom,
              customMimeType: mime,
            )
          : await FileSaver.instance.saveAs(
              name: _kind.fileName,
              bytes: bytes,
              fileExtension: extension,
              mimeType: MimeType.custom,
              customMimeType: mime,
            );
      if (mounted && savedPath != null) {
        _showMessage('Đã tạo file mẫu ${_kind.label}.');
      }
    } catch (_) {
      if (mounted) _showMessage('Không thể tạo file mẫu.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Uint8List _createExcelTemplate() {
    final workbook = excel.Excel.createExcel();
    final sheetName = workbook.getDefaultSheet();
    if (sheetName == null) throw StateError('Workbook has no default sheet.');
    final sheet = workbook[sheetName];
    for (var index = 0; index < _kind.headers.length; index++) {
      sheet
          .cell(
            excel.CellIndex.indexByColumnRow(columnIndex: index, rowIndex: 0),
          )
          .value = excel.TextCellValue(
        _kind.headers[index],
      );
      sheet.setColumnWidth(index, 25);
    }
    final bytes = workbook.encode();
    if (bytes == null) throw StateError('Unable to encode workbook.');
    return Uint8List.fromList(bytes);
  }

  Future<void> _pickFile() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [_format],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('Không đọc được nội dung file.');
      }
      setState(() {
        _fileName = file.name;
        _selectedBytes = bytes;
        _previewReady = false;
        _validRows = [];
        _issues = [];
      });
    } catch (error) {
      if (mounted) {
        final message = error is FormatException
            ? error.message.toString()
            : 'Không thể đọc file đã chọn.';
        setState(() {
          _fileName = 'File không hợp lệ';
          _selectedBytes = null;
          _previewReady = true;
          _validRows = [];
          _issues = [message];
        });
        _notifyImportFailure(message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueToPreview() async {
    final bytes = _selectedBytes;
    if (bytes == null) {
      _showMessage('Hãy chọn file trước khi xem trước.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final records = _format == 'csv' ? _readCsv(bytes) : _readExcel(bytes);
      _validateRecords(records, _fileName ?? 'File đã chọn');
    } catch (error) {
      if (mounted) {
        final message = error is FormatException
            ? error.message.toString()
            : 'Không thể đọc file đã chọn.';
        setState(() {
          _previewReady = true;
          _validRows = [];
          _issues = [message];
        });
        _notifyImportFailure(message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notifyImportFailure(String message) {
    MockGovernanceNotifications.instance.addNotification(
      type: 'Import dữ liệu',
      icon: Icons.error_outline,
      title: 'Import dữ liệu cần kiểm tra',
      content: message,
    );
  }

  List<List<String>> _readCsv(Uint8List bytes) {
    var content = utf8.decode(bytes, allowMalformed: true);
    content = content.replaceFirst('\uFEFF', '').trim();
    if (content.isEmpty) throw const FormatException('File CSV đang trống.');
    try {
      return csv.CsvDecoder()
          .convert(content)
          .map((row) => row.map((cell) => cell?.toString() ?? '').toList())
          .toList();
    } catch (_) {
      throw const FormatException(
        'Không thể đọc CSV. Hãy kiểm tra dấu phân cách và dấu ngoặc kép.',
      );
    }
  }

  List<List<String>> _readExcel(Uint8List bytes) {
    late excel.Excel workbook;
    try {
      workbook = excel.Excel.decodeBytes(bytes);
    } catch (_) {
      throw const FormatException('Không thể đọc file Excel .xlsx.');
    }
    if (workbook.tables.isEmpty) {
      throw const FormatException('File Excel không có sheet dữ liệu.');
    }
    final firstName = workbook.tables.keys.first;
    final sheet = workbook.tables[firstName];
    if (sheet == null) {
      throw const FormatException('Không tìm thấy sheet dữ liệu.');
    }
    return sheet.rows
        .map(
          (row) => row.map((cell) {
            final value = cell?.value;
            if (value == null) return '';
            if (value is excel.TextCellValue) return value.value.toString();
            if (value is excel.IntCellValue) return value.value.toString();
            if (value is excel.DoubleCellValue) return value.value.toString();
            if (value is excel.BoolCellValue) return value.value.toString();
            return value.toString();
          }).toList(),
        )
        .toList();
  }

  void _validateRecords(List<List<String>> records, String fileName) {
    final issues = <String>[];
    final validRows = <_ImportRow>[];
    if (records.isEmpty) throw const FormatException('File không có dữ liệu.');
    final expected = _kind.headers;
    final headers = records.first
        .map((value) => value.replaceFirst('\uFEFF', '').trim())
        .toList();
    final validHeader =
        headers.length == expected.length &&
        List<int>.generate(expected.length, (index) => index).every(
          (index) =>
              headers[index].toLowerCase() == expected[index].toLowerCase(),
        );
    if (!validHeader) {
      setState(() {
        _fileName = fileName;
        _previewReady = true;
        _validRows = [];
        _issues = [
          'Header không đúng. Cần dùng đúng thứ tự: ${expected.join(' | ')}',
        ];
      });
      _notifyImportFailure('Header file không đúng mẫu.');
      return;
    }

    final data = MockGovernanceData.instance;
    final seenCodes = <String>{};
    for (var index = 1; index < records.length; index++) {
      final line = index + 1;
      final original = records[index].map((cell) => cell.trim()).toList();
      if (original.every((cell) => cell.isEmpty)) continue;
      final rowIssues = <String>[];
      if (original.length != expected.length) {
        rowIssues.add(
          'Số cột không khớp mẫu (${original.length}/${expected.length}).',
        );
      }
      final cells = List<String>.generate(
        expected.length,
        (column) => column < original.length ? original[column] : '',
      );
      for (var column = 0; column < cells.length; column++) {
        if (cells[column].isEmpty) {
          rowIssues.add('Thiếu cột "${expected[column]}".');
        }
      }
      if (cells.length == expected.length &&
          cells.every((cell) => cell.isNotEmpty)) {
        switch (_kind) {
          case GovernanceImportKind.students:
            if (!_validEmail(cells[2])) rowIssues.add('Email không hợp lệ.');
            final code = cells[0].toLowerCase();
            if (data.students.any(
                  (item) => item.studentCode.toLowerCase() == code,
                ) ||
                !seenCodes.add(code)) {
              rowIssues.add('MSSV đã tồn tại hoặc trùng trong file.');
            }
            if (!data.courses.any(
              (course) =>
                  course.classCode.toLowerCase() == cells[3].toLowerCase(),
            )) {
              rowIssues.add(
                'Lớp "${cells[3]}" chưa có trong danh sách lớp học phần.',
              );
            }
          case GovernanceImportKind.lecturers:
            if (!_validEmail(cells[2])) rowIssues.add('Email không hợp lệ.');
            final code = cells[0].toLowerCase();
            if (data.lecturers.any(
                  (item) => item.lecturerCode.toLowerCase() == code,
                ) ||
                !seenCodes.add(code)) {
              rowIssues.add('Mã giảng viên đã tồn tại hoặc trùng trong file.');
            }
          case GovernanceImportKind.courses:
            final code = cells[0].toLowerCase();
            if (data.courses.any(
                  (item) => item.classCode.toLowerCase() == code,
                ) ||
                !seenCodes.add(code)) {
              rowIssues.add(
                'Mã lớp học phần đã tồn tại hoặc trùng trong file.',
              );
            }
            if (data.lecturerByCode(cells[3]) == null) {
              rowIssues.add('Không tìm thấy mã giảng viên "${cells[3]}".');
            }
        }
      }
      if (rowIssues.isNotEmpty) {
        issues.addAll(rowIssues.map((issue) => 'Dòng $line: $issue'));
      } else {
        validRows.add(_ImportRow(line, cells));
      }
    }
    setState(() {
      _fileName = fileName;
      _previewReady = true;
      _validRows = validRows;
      _issues = issues;
    });
    if (issues.isNotEmpty) {
      _notifyImportFailure('${issues.length} dòng cần kiểm tra.');
    }
  }

  bool _validEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  Future<void> _confirmImport() async {
    final importedCount = _validRows.length;
    final failedCount = _failedRowCount;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppLocalizations.text('Xác nhận import', en: 'Confirm import'),
        ),
        content: Text(
          AppLocalizations.text(
            'Import $importedCount dòng hợp lệ? ${failedCount > 0 ? '$failedCount dòng lỗi sẽ được bỏ qua.' : ''}',
            en: 'Import $importedCount valid rows? ${failedCount > 0 ? '$failedCount invalid rows will be skipped.' : ''}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.text('Xác nhận', en: 'Confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final data = MockGovernanceData.instance;
    switch (_kind) {
      case GovernanceImportKind.students:
        final nextId = data.nextStudentId;
        data.addStudents([
          for (var index = 0; index < importedCount; index++)
            GovernanceStudentModel(
              id: nextId + index,
              studentCode: _validRows[index].cells[0],
              fullName: _validRows[index].cells[1],
              email: _validRows[index].cells[2],
              classCode: _validRows[index].cells[3],
              status: _validRows[index].cells[4],
            ),
        ]);
      case GovernanceImportKind.lecturers:
        final nextId = data.nextLecturerId;
        final faculty = data.lecturers.isEmpty
            ? data.profile.faculty
            : data.lecturers.first.faculty;
        final rows = [
          for (var index = 0; index < importedCount; index++)
            LecturerModel(
              id: nextId + index,
              lecturerCode: _validRows[index].cells[0],
              fullName: _validRows[index].cells[1],
              email: _validRows[index].cells[2],
              faculty: faculty,
              department: _validRows[index].cells[3],
              avatar: '',
            ),
        ];
        final statuses = {
          for (var index = 0; index < importedCount; index++)
            _validRows[index].cells[0]: _validRows[index].cells[4],
        };
        data.addLecturers(rows, statuses: statuses);
      case GovernanceImportKind.courses:
        final nextId = data.nextCourseId;
        data.addCourses([
          for (var index = 0; index < importedCount; index++)
            CourseModel(
              id: nextId + index,
              code: _validRows[index].cells[0].split('-').first,
              name: _validRows[index].cells[1],
              classCode: _validRows[index].cells[0],
              semester: _validRows[index].cells[2],
              lecturer: data
                  .lecturerByCode(_validRows[index].cells[3])!
                  .fullName,
              status: _validRows[index].cells[4],
            ),
        ]);
    }
    data.recordImport(
      TrainingImportRecordModel(
        importedAt: DateTime.now(),
        dataType: _kind.label,
        fileName: _fileName ?? '',
        totalRecords: importedCount + failedCount,
        successfulRecords: importedCount,
        failedRecords: failedCount,
        status: AppLocalizations.text(
          failedCount == 0 ? 'Hoàn thành' : 'Hoàn thành một phần',
          en: failedCount == 0 ? 'Completed' : 'Partially completed',
        ),
      ),
    );
    MockGovernanceNotifications.instance.addNotification(
      type: 'Import dữ liệu',
      icon: Icons.file_download_done_outlined,
      title: 'Import dữ liệu thành công',
      content:
          'Đã import $importedCount ${_kind.label.toLowerCase()} vào dữ liệu Giáo vụ khoa.',
    );
    setState(_clearPreview);
    _showMessage(
      failedCount == 0
          ? 'Đã import $importedCount ${_kind.label.toLowerCase()}.'
          : 'Đã import $importedCount ${_kind.label.toLowerCase()}, bỏ qua $failedCount dòng lỗi.',
    );
  }

  int get _failedRowCount => _issues
      .map((issue) => RegExp(r'^Dòng (\d+):').firstMatch(issue)?.group(1))
      .whereType<String>()
      .toSet()
      .length;

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppTheme.dangerColor : null,
      ),
    );
  }
}

class _GovernanceFlowCard extends StatelessWidget {
  final String number, title, description;
  final Widget child;
  const _GovernanceFlowCard({
    required this.number,
    required this.title,
    required this.description,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Text(
                    number,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: child),
          ],
        ),
      ),
    );
  }
}

class GovernanceImportHistoryScreen extends StatelessWidget {
  const GovernanceImportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockGovernanceData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final records = data.importHistory;
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.text('Lịch sử import', en: 'Import history'),
            ),
          ),
          body: records.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 54,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.text(
                            'Chưa có lịch sử import',
                            en: 'No import history',
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.text(
                            'Các lần import đã xác nhận sẽ xuất hiện tại đây.',
                            en: 'Confirmed imports will appear here.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: records.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(_historyIcon(record.dataType)),
                        ),
                        title: Text(
                          record.dataType,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(_formatDate(record.importedAt)),
                              const SizedBox(height: 3),
                              Text(
                                AppLocalizations.text(
                                  'Tổng ${record.totalRecords} · Thành công ${record.successfulRecords} · Lỗi ${record.failedRecords}',
                                  en: 'Total ${record.totalRecords} · Imported ${record.successfulRecords} · Errors ${record.failedRecords}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 115),
                          child: Text(
                            record.status,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: record.failedRecords == 0
                                  ? colors.primary
                                  : colors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  IconData _historyIcon(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('sinh')) return Icons.people_outline;
    if (normalized.contains('giảng')) return Icons.badge_outlined;
    if (normalized.contains('lớp')) return Icons.class_outlined;
    return Icons.menu_book_outlined;
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year}  $hour:$minute';
  }
}
