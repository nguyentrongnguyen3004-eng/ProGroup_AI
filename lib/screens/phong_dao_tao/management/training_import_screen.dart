import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart' as csv;
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_training_data.dart';
import '../../../data/mock/mock_training_notifications.dart';
import '../../../models/course_model.dart';
import '../../../models/governance_student_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../models/training_import_record_model.dart';
import '../../../models/training_subject_model.dart';
import 'training_data_management_screen.dart';

class TrainingImportScreen extends StatefulWidget {
  final TrainingDataKind initialKind;

  const TrainingImportScreen({
    super.key,
    this.initialKind = TrainingDataKind.students,
  });

  @override
  State<TrainingImportScreen> createState() => _TrainingImportScreenState();
}

class _TrainingImportScreenState extends State<TrainingImportScreen> {
  late TrainingDataKind _kind = widget.initialKind;
  String _format = 'csv';
  String? _fileName;
  Uint8List? _selectedBytes;
  bool _previewReady = false;
  bool _busy = false;
  int _totalRows = 0;
  int _invalidRows = 0;
  List<_ImportRow> _validRows = [];
  List<String> _issues = [];

  List<String> _headers(BuildContext context) => switch (_kind) {
    TrainingDataKind.students => [
      _text(context, 'MSSV', 'Student ID'),
      _text(context, 'Họ tên', 'Full name'),
      'Email',
      _text(context, 'Lớp', 'Class'),
      _text(context, 'Trạng thái', 'Status'),
    ],
    TrainingDataKind.lecturers => [
      _text(context, 'Mã giảng viên', 'Lecturer ID'),
      _text(context, 'Họ tên', 'Full name'),
      'Email',
      _text(context, 'Khoa', 'Faculty'),
      _text(context, 'Bộ môn', 'Department'),
      _text(context, 'Trạng thái', 'Work status'),
    ],
    TrainingDataKind.courseClasses => [
      _text(context, 'Mã lớp học phần', 'Class section ID'),
      _text(context, 'Mã học phần', 'Course code'),
      _text(context, 'Tên học phần', 'Course name'),
      _text(
        context,
        'Mã giảng viên (không bắt buộc)',
        'Lecturer ID (optional)',
      ),
      _text(context, 'Học kỳ', 'Semester'),
      _text(context, 'Trạng thái', 'Status'),
    ],
    TrainingDataKind.subjects => [
      _text(context, 'Mã học phần', 'Course code'),
      _text(context, 'Tên học phần', 'Course name'),
      _text(context, 'Số tín chỉ', 'Credits'),
      _text(context, 'Bộ môn', 'Department'),
      _text(context, 'Trạng thái', 'Status'),
    ],
  };

  String _kindName(BuildContext context) => _kind.label(context);

  @override
  Widget build(BuildContext context) {
    final headers = _headers(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_text(context, 'Import dữ liệu', 'Import data')),
        actions: [
          IconButton(
            tooltip: _text(context, 'Lịch sử import', 'Import history'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TrainingImportHistoryScreen(),
              ),
            ),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          Text(
            _text(
              context,
              'Chọn loại dữ liệu và kiểm tra file trước khi cập nhật danh sách.',
              'Choose a data type and review the file before updating the list.',
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          _ImportStepCard(
            number: '1',
            title: _text(context, 'Chọn loại dữ liệu', 'Choose data type'),
            description: _text(
              context,
              'Chọn danh sách cần cập nhật.',
              'Select the list to update.',
            ),
            child: DropdownButtonFormField<TrainingDataKind>(
              initialValue: _kind,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: _text(context, 'Loại dữ liệu', 'Data type'),
              ),
              items: TrainingDataKind.values
                  .map(
                    (kind) => DropdownMenuItem(
                      value: kind,
                      child: Text(kind.label(context)),
                    ),
                  )
                  .toList(),
              onChanged: _busy
                  ? null
                  : (kind) {
                      if (kind == null) return;
                      setState(() {
                        _kind = kind;
                        _clearPreview();
                      });
                    },
            ),
          ),
          const SizedBox(height: 10),
          _ImportStepCard(
            number: '2',
            title: _text(context, 'Chọn định dạng', 'Choose format'),
            description: _text(
              context,
              'Hỗ trợ CSV và Excel .xlsx.',
              'CSV and Excel .xlsx are supported.',
            ),
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
          const SizedBox(height: 10),
          _ImportStepCard(
            number: '3',
            title: _text(context, 'File mẫu', 'Template file'),
            description: _text(
              context,
              'Tải file có sẵn các cột đúng thứ tự để nhập dữ liệu.',
              'Download a template with the expected columns and order.',
            ),
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _downloadTemplate,
              icon: const Icon(Icons.download_outlined),
              label: Text(_text(context, 'Tải file mẫu', 'Download template')),
            ),
          ),
          const SizedBox(height: 10),
          _ImportStepCard(
            number: '4',
            title: _text(context, 'Chọn file', 'Choose file'),
            description: _text(
              context,
              'Chọn file $_format cho ${_kindName(context)}.',
              'Choose a $_format file for ${_kindName(context)}.',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pickFile,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(_text(context, 'Chọn file', 'Choose file')),
                ),
                if (_fileName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: .45),
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
                          tooltip: _text(context, 'Bỏ file', 'Remove file'),
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
          const SizedBox(height: 10),
          _ImportStepCard(
            number: '5',
            title: _text(
              context,
              'Kiểm tra và xem trước',
              'Validate and preview',
            ),
            description: _text(
              context,
              'Kiểm tra cột, dữ liệu thiếu, định dạng và mã bị trùng.',
              'Check columns, missing values, formats, and duplicate codes.',
            ),
            child: FilledButton.icon(
              onPressed: _busy ? null : _continueToPreview,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.preview_outlined),
              label: Text(
                _text(context, 'Tiếp tục xem trước', 'Continue to preview'),
              ),
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_previewReady) _buildPreview(headers),
        ],
      ),
    );
  }

  Widget _buildPreview(List<String> headers) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _text(context, 'Xem trước dữ liệu', 'Data preview'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CountChip(
                  label: _text(context, 'Tổng số', 'Total'),
                  value: '$_totalRows',
                ),
                _CountChip(
                  label: _text(context, 'Hợp lệ', 'Valid'),
                  value: '${_validRows.length}',
                  color: colors.primary,
                ),
                _CountChip(
                  label: _text(context, 'Lỗi', 'Errors'),
                  value: '$_invalidRows',
                  color: colors.error,
                ),
              ],
            ),
            if (_issues.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                _text(context, 'Các dòng cần kiểm tra', 'Rows to review'),
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: colors.errorContainer.withValues(alpha: .28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _issues.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: colors.outlineVariant),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      _issues[index],
                      style: TextStyle(color: colors.onSurface),
                    ),
                  ),
                ),
              ),
            ],
            if (_validRows.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                _text(context, 'Bản ghi hợp lệ', 'Valid records'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ..._validRows.take(6).map((row) => _previewRow(row, headers)),
              if (_validRows.length > 6)
                Text(
                  _text(
                    context,
                    'Còn ${_validRows.length - 6} dòng hợp lệ khác.',
                    '${_validRows.length - 6} more valid rows.',
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _confirmImport,
                  icon: const Icon(Icons.check),
                  label: Text(
                    _text(
                      context,
                      'Import ${_validRows.length} bản ghi hợp lệ',
                      'Import ${_validRows.length} valid records',
                    ),
                  ),
                ),
              ),
              if (_invalidRows > 0) ...[
                const SizedBox(height: 4),
                Text(
                  _text(
                    context,
                    'Các dòng lỗi sẽ không được import.',
                    'Rows with errors will be skipped.',
                  ),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ] else if (_issues.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _text(
                  context,
                  'File không có bản ghi để import.',
                  'The file has no records to import.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _previewRow(_ImportRow row, List<String> headers) => Card(
    margin: const EdgeInsets.only(bottom: 7),
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: .35),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_text(context, 'Dòng', 'Row')} ${row.line}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            List.generate(
              headers.length,
              (index) => '${headers[index]}: ${row.cells[index]}',
            ).join(' · '),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  void _clearPreview() {
    _fileName = null;
    _selectedBytes = null;
    _previewReady = false;
    _totalRows = 0;
    _invalidRows = 0;
    _validRows = [];
    _issues = [];
  }

  Future<void> _downloadTemplate() async {
    setState(() => _busy = true);
    try {
      final headers = _headers(context);
      final bytes = _format == 'csv'
          ? Uint8List.fromList(
              utf8.encode('\uFEFF${headers.map(_csvCell).join(',')}\r\n'),
            )
          : _createExcelTemplate(headers);
      final mime = _format == 'csv'
          ? 'text/csv'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      final fileName = _templateName(context);
      final saveToDownloads =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
      final saved = saveToDownloads
          ? await FileSaver.instance.saveFile(
              name: fileName,
              bytes: bytes,
              fileExtension: _format,
              mimeType: MimeType.custom,
              customMimeType: mime,
            )
          : await FileSaver.instance.saveAs(
              name: fileName,
              bytes: bytes,
              fileExtension: _format,
              mimeType: MimeType.custom,
              customMimeType: mime,
            );
      if (mounted && saved != null) {
        _showMessage(
          _text(context, 'Đã tạo file mẫu.', 'Template file created.'),
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          _text(
            context,
            'Không thể tạo file mẫu.',
            'Could not create the template.',
          ),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

  String _templateName(BuildContext context) => switch (_kind) {
    TrainingDataKind.students => 'mau_import_sinh_vien',
    TrainingDataKind.lecturers => 'mau_import_giang_vien',
    TrainingDataKind.courseClasses => 'mau_import_lop_hoc_phan',
    TrainingDataKind.subjects => 'mau_import_hoc_phan',
  };

  Uint8List _createExcelTemplate(List<String> headers) {
    final workbook = excel.Excel.createExcel();
    final sheetName = workbook.getDefaultSheet();
    if (sheetName == null) throw StateError('Workbook has no default sheet.');
    final sheet = workbook[sheetName];
    for (var index = 0; index < headers.length; index++) {
      sheet
          .cell(
            excel.CellIndex.indexByColumnRow(columnIndex: index, rowIndex: 0),
          )
          .value = excel.TextCellValue(
        headers[index],
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
      if (!mounted || result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (file.extension?.toLowerCase() != _format) {
        throw FormatException(
          _text(
            context,
            'File không đúng định dạng $_format.',
            'The file must use the $_format format.',
          ),
        );
      }
      if (bytes == null || bytes.isEmpty) {
        throw FormatException(
          _text(context, 'File không có dữ liệu.', 'The file is empty.'),
        );
      }
      setState(() {
        _fileName = file.name;
        _selectedBytes = bytes;
        _previewReady = false;
        _totalRows = 0;
        _invalidRows = 0;
        _validRows = [];
        _issues = [];
      });
    } catch (error) {
      if (mounted) {
        final message = error is FormatException
            ? error.message.toString()
            : _text(
                context,
                'Không thể đọc file đã chọn.',
                'Could not read the selected file.',
              );
        setState(() {
          _fileName = _text(context, 'File không hợp lệ', 'Invalid file');
          _selectedBytes = null;
          _previewReady = true;
          _totalRows = 0;
          _invalidRows = 0;
          _validRows = [];
          _issues = [message];
        });
        _showMessage(message, error: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueToPreview() async {
    final bytes = _selectedBytes;
    if (bytes == null) {
      _showMessage(
        _text(
          context,
          'Hãy chọn file trước khi xem trước.',
          'Choose a file before previewing.',
        ),
        error: true,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final records = _format == 'csv' ? _readCsv(bytes) : _readExcel(bytes);
      _validateRecords(records);
    } catch (error) {
      if (mounted) {
        final message = error is FormatException
            ? error.message.toString()
            : _text(
                context,
                'Không thể đọc file đã chọn.',
                'Could not read the selected file.',
              );
        setState(() {
          _previewReady = true;
          _totalRows = 0;
          _invalidRows = 0;
          _validRows = [];
          _issues = [message];
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<List<String>> _readCsv(Uint8List bytes) {
    final content = utf8
        .decode(bytes, allowMalformed: true)
        .replaceFirst('\uFEFF', '')
        .trim();
    if (content.isEmpty) {
      throw FormatException(
        _text(context, 'File CSV đang trống.', 'The CSV file is empty.'),
      );
    }
    try {
      return csv.CsvDecoder()
          .convert(content)
          .map(
            (row) => row.map((cell) => cell?.toString().trim() ?? '').toList(),
          )
          .toList();
    } catch (_) {
      throw FormatException(
        _text(
          context,
          'Không thể đọc CSV. Hãy kiểm tra dấu phân cách và dấu ngoặc kép.',
          'Could not read CSV. Check delimiters and quotation marks.',
        ),
      );
    }
  }

  List<List<String>> _readExcel(Uint8List bytes) {
    late excel.Excel workbook;
    try {
      workbook = excel.Excel.decodeBytes(bytes);
    } catch (_) {
      throw FormatException(
        _text(
          context,
          'Không thể đọc file Excel .xlsx.',
          'Could not read the Excel .xlsx file.',
        ),
      );
    }
    if (workbook.tables.isEmpty) {
      throw FormatException(
        _text(
          context,
          'File Excel không có sheet dữ liệu.',
          'The Excel file has no worksheets.',
        ),
      );
    }
    final sheet = workbook.tables[workbook.tables.keys.first];
    if (sheet == null) {
      throw FormatException(
        _text(context, 'Không tìm thấy sheet dữ liệu.', 'Worksheet not found.'),
      );
    }
    return sheet.rows
        .map(
          (row) => row.map((cell) {
            final value = cell?.value;
            if (value == null) return '';
            if (value is excel.TextCellValue) {
              return value.value.toString().trim();
            }
            if (value is excel.IntCellValue) return value.value.toString();
            if (value is excel.DoubleCellValue) return value.value.toString();
            if (value is excel.BoolCellValue) return value.value.toString();
            return value.toString().trim();
          }).toList(),
        )
        .toList();
  }

  void _validateRecords(List<List<String>> records) {
    if (records.isEmpty) {
      throw FormatException(
        _text(context, 'File không có dữ liệu.', 'The file has no data.'),
      );
    }
    final headers = _headers(context);
    final actualHeaders = records.first
        .map((value) => value.replaceFirst('\uFEFF', '').trim().toLowerCase())
        .toList();
    final expectedHeaders = headers
        .map((value) => value.trim().toLowerCase())
        .toList();
    if (actualHeaders.length != expectedHeaders.length ||
        List<int>.generate(
          expectedHeaders.length,
          (index) => index,
        ).any((index) => actualHeaders[index] != expectedHeaders[index])) {
      setState(() {
        _previewReady = true;
        _totalRows = 0;
        _invalidRows = 0;
        _validRows = [];
        _issues = [
          _text(
                context,
                'Thiếu hoặc sai cột. Thứ tự cần có: ',
                'Missing or incorrect columns. Expected order: ',
              ) +
              headers.join(' | '),
        ];
      });
      return;
    }

    final data = MockTrainingData.instance;
    final existingCodes = _existingCodes(data);
    final seenCodes = <String>{};
    final valid = <_ImportRow>[];
    final issues = <String>[];
    var invalidRows = 0;
    var totalRows = 0;
    for (var index = 1; index < records.length; index++) {
      final cells = records[index].map((cell) => cell.trim()).toList();
      if (cells.every((cell) => cell.isEmpty)) continue;
      totalRows++;
      final rowIssues = <String>[];
      if (cells.length != headers.length) {
        rowIssues.add(
          _text(
            context,
            'Số cột không khớp (${cells.length}/${headers.length}).',
            'Column count does not match (${cells.length}/${headers.length}).',
          ),
        );
      }
      final values = List<String>.generate(
        headers.length,
        (column) => column < cells.length ? cells[column] : '',
      );
      for (var column = 0; column < values.length; column++) {
        final optionalLecturer =
            _kind == TrainingDataKind.courseClasses && column == 3;
        if (values[column].isEmpty && !optionalLecturer) {
          rowIssues.add(
            _text(
              context,
              'Thiếu dữ liệu: ${headers[column]}.',
              'Missing value: ${headers[column]}.',
            ),
          );
        }
      }
      if (values.length == headers.length &&
          values.any((value) => value.isNotEmpty)) {
        _validateRow(values, data, existingCodes, seenCodes, rowIssues);
      }
      if (rowIssues.isEmpty) {
        valid.add(_ImportRow(index + 1, values));
      } else {
        invalidRows++;
        issues.addAll(
          rowIssues.map(
            (issue) => '${_text(context, 'Dòng', 'Row')} ${index + 1}: $issue',
          ),
        );
      }
    }
    if (totalRows == 0) {
      issues.add(
        _text(
          context,
          'File không có bản ghi dữ liệu.',
          'The file contains no data records.',
        ),
      );
    }
    setState(() {
      _previewReady = true;
      _totalRows = totalRows;
      _invalidRows = invalidRows;
      _validRows = valid;
      _issues = issues;
    });
  }

  Set<String> _existingCodes(MockTrainingData data) => switch (_kind) {
    TrainingDataKind.students =>
      data.students.map((item) => item.studentCode.toLowerCase()).toSet(),
    TrainingDataKind.lecturers =>
      data.lecturers.map((item) => item.lecturerCode.toLowerCase()).toSet(),
    TrainingDataKind.courseClasses =>
      data.courseClasses.map((item) => item.classCode.toLowerCase()).toSet(),
    TrainingDataKind.subjects =>
      data.subjects.map((item) => item.code.toLowerCase()).toSet(),
  };

  void _validateRow(
    List<String> cells,
    MockTrainingData data,
    Set<String> existingCodes,
    Set<String> seenCodes,
    List<String> issues,
  ) {
    final code = cells.first.toLowerCase();
    final codePattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{2,19}$');
    if (!codePattern.hasMatch(cells.first)) {
      issues.add(
        _text(
          context,
          'Mã không đúng định dạng.',
          'The code format is invalid.',
        ),
      );
    }
    if (existingCodes.contains(code) || !seenCodes.add(code)) {
      final label = switch (_kind) {
        TrainingDataKind.students => _text(context, 'MSSV', 'Student ID'),
        TrainingDataKind.lecturers => _text(
          context,
          'Mã giảng viên',
          'Lecturer ID',
        ),
        TrainingDataKind.courseClasses => _text(
          context,
          'Mã lớp học phần',
          'Class section ID',
        ),
        TrainingDataKind.subjects => _text(
          context,
          'Mã học phần',
          'Course code',
        ),
      };
      issues.add(
        _text(
          context,
          '$label bị trùng hoặc đã tồn tại.',
          '$label is duplicated or already exists.',
        ),
      );
    }
    switch (_kind) {
      case TrainingDataKind.students:
        if (!_validEmail(cells[2])) {
          issues.add(
            _text(
              context,
              'Email không đúng định dạng.',
              'Email format is invalid.',
            ),
          );
        }
      case TrainingDataKind.lecturers:
        if (!_validEmail(cells[2])) {
          issues.add(
            _text(
              context,
              'Email không đúng định dạng.',
              'Email format is invalid.',
            ),
          );
        }
      case TrainingDataKind.courseClasses:
        final courseCode = cells[1].toLowerCase();
        if (!data.subjects.any(
          (item) => item.code.toLowerCase() == courseCode,
        )) {
          issues.add(
            _text(
              context,
              'Không tìm thấy mã học phần ${cells[1]}.',
              'Course code ${cells[1]} was not found.',
            ),
          );
        }
        final lecturerCode = cells[3].toLowerCase();
        if (cells[3].isNotEmpty &&
            !data.lecturers.any(
              (item) => item.lecturerCode.toLowerCase() == lecturerCode,
            )) {
          issues.add(
            _text(
              context,
              'Không tìm thấy mã giảng viên ${cells[3]}.',
              'Lecturer ID ${cells[3]} was not found.',
            ),
          );
        }
      case TrainingDataKind.subjects:
        final credits = int.tryParse(cells[2]);
        if (credits == null || credits <= 0) {
          issues.add(
            _text(
              context,
              'Số tín chỉ phải là số nguyên dương.',
              'Credits must be a positive whole number.',
            ),
          );
        }
    }
  }

  bool _validEmail(String email) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

  Future<void> _confirmImport() async {
    final count = _validRows.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text(context, 'Xác nhận import', 'Confirm import')),
        content: Text(
          _text(
            context,
            'Bạn có chắc muốn import $count bản ghi hợp lệ? ${_invalidRows > 0 ? '$_invalidRows dòng lỗi sẽ được bỏ qua.' : ''}',
            'Import $count valid records? ${_invalidRows > 0 ? '$_invalidRows invalid rows will be skipped.' : ''}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_text(context, 'Hủy', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_text(context, 'Xác nhận import', 'Confirm import')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final data = MockTrainingData.instance;
    switch (_kind) {
      case TrainingDataKind.students:
        final firstId = data.nextStudentId;
        data.addStudents([
          for (var index = 0; index < count; index++)
            GovernanceStudentModel(
              id: firstId + index,
              studentCode: _validRows[index].cells[0],
              fullName: _validRows[index].cells[1],
              email: _validRows[index].cells[2],
              classCode: _validRows[index].cells[3],
              status: _validRows[index].cells[4],
            ),
        ]);
      case TrainingDataKind.lecturers:
        final firstId = data.nextLecturerId;
        final lecturers = [
          for (var index = 0; index < count; index++)
            LecturerModel(
              id: firstId + index,
              lecturerCode: _validRows[index].cells[0],
              fullName: _validRows[index].cells[1],
              email: _validRows[index].cells[2],
              faculty: _validRows[index].cells[3],
              department: _validRows[index].cells[4],
              avatar: '',
            ),
        ];
        data.addLecturers(
          lecturers,
          statuses: {for (final row in _validRows) row.cells[0]: row.cells[5]},
        );
      case TrainingDataKind.courseClasses:
        final firstId = data.nextCourseClassId;
        data.addCourseClasses([
          for (var index = 0; index < count; index++)
            CourseModel(
              id: firstId + index,
              code: _validRows[index].cells[1],
              name: _validRows[index].cells[2],
              classCode: _validRows[index].cells[0],
              semester: _validRows[index].cells[4],
              lecturer: _lecturerName(data, _validRows[index].cells[3]),
              status: _validRows[index].cells[5],
            ),
        ]);
      case TrainingDataKind.subjects:
        data.addSubjects([
          for (final row in _validRows)
            TrainingSubjectModel(
              code: row.cells[0],
              name: row.cells[1],
              credits: int.parse(row.cells[2]),
              department: row.cells[3],
              status: row.cells[4],
            ),
        ]);
    }

    final kindLabel = _kind.label(context);
    data.recordImport(
      TrainingImportRecordModel(
        importedAt: DateTime.now(),
        dataType: kindLabel,
        fileName: _fileName ?? '',
        totalRecords: _totalRows,
        successfulRecords: count,
        failedRecords: _invalidRows,
        status: _invalidRows == 0
            ? _text(context, 'Hoàn thành', 'Completed')
            : _text(context, 'Hoàn thành một phần', 'Partially completed'),
      ),
    );
    MockTrainingNotifications.instance.addNotification(
      type: _text(context, 'Import dữ liệu', 'Data import'),
      title: _text(context, 'Import dữ liệu thành công', 'Import completed'),
      content: _text(
        context,
        'Đã import $count $kindLabel.',
        'Imported $count $kindLabel.',
      ),
      icon: Icons.file_download_done_outlined,
    );
    _showMessage(
      _text(
        context,
        'Đã import $count $kindLabel.',
        'Imported $count $kindLabel.',
      ),
    );
    setState(_clearPreview);
  }

  String _lecturerName(MockTrainingData data, String lecturerCode) {
    if (lecturerCode.isEmpty) return '';
    return data.lecturers
        .firstWhere(
          (item) =>
              item.lecturerCode.toLowerCase() == lecturerCode.toLowerCase(),
        )
        .fullName;
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? colors.error : null,
        ),
      );
  }
}

String _text(BuildContext context, String vi, String en) =>
    AppLocalizations.text(vi, en: en);

class _ImportRow {
  final int line;
  final List<String> cells;

  const _ImportRow(this.line, this.cells);
}

class _ImportStepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Widget child;

  const _ImportStepCard({
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
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: child),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _CountChip({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      avatar: Text(
        value,
        style: TextStyle(
          color: color ?? colors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      label: Text(label),
      side: BorderSide(
        color: (color ?? colors.outlineVariant).withValues(alpha: .5),
      ),
    );
  }
}

class TrainingImportHistoryScreen extends StatelessWidget {
  const TrainingImportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockTrainingData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(_text(context, 'Lịch sử import', 'Import history')),
        ),
        body: data.importHistory.isEmpty
            ? _HistoryEmptyState(
                title: _text(
                  context,
                  'Chưa có lịch sử import',
                  'No import history',
                ),
                message: _text(
                  context,
                  'Các lần import đã xác nhận sẽ xuất hiện tại đây.',
                  'Confirmed imports will appear here.',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: data.importHistory.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final record = data.importHistory[index];
                  final colors = Theme.of(context).colorScheme;
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
                              _text(
                                context,
                                'Tổng ${record.totalRecords} · Thành công ${record.successfulRecords} · Lỗi ${record.failedRecords}',
                                'Total ${record.totalRecords} · Imported ${record.successfulRecords} · Errors ${record.failedRecords}',
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
      ),
    );
  }

  IconData _historyIcon(String type) {
    if (type.toLowerCase().contains('sinh')) return Icons.people_outline;
    if (type.toLowerCase().contains('giảng')) return Icons.badge_outlined;
    if (type.toLowerCase().contains('lớp')) return Icons.class_outlined;
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

class _HistoryEmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _HistoryEmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 54, color: colors.onSurfaceVariant),
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
