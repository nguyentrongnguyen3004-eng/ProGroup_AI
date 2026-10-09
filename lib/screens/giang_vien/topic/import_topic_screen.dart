import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_notifications.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/course_model.dart';
import '../../../models/topic_model.dart';
import 'import_topic_preview_screen.dart';

class ImportTopicScreen extends StatefulWidget {
  final CourseModel? course;
  final int? lecturerCourseId;

  const ImportTopicScreen({super.key, this.course, this.lecturerCourseId});

  @override
  State<ImportTopicScreen> createState() => _ImportTopicScreenState();
}

class _ImportTopicScreenState extends State<ImportTopicScreen> {
  String? _selectedFileName;

  String? _fileContent;

  Uint8List? _selectedExcelBytes;

  bool _busy = false;

  int? _selectedCourseId;

  String _selectedFormat = 'csv';

  int? get _fixedCourseId => widget.lecturerCourseId ?? widget.course?.id;

  bool get _hasValidFixedCourse =>
      _fixedCourseId != null &&
      MockLecturerCourses.courses.any(
        (course) => course.courseId == _fixedCourseId,
      );

  int? get _effectiveCourseId =>
      _hasValidFixedCourse ? _fixedCourseId : _selectedCourseId;

  String get _formatLabel {
    return _selectedFormat == 'csv' ? 'CSV' : 'Excel (.xlsx)';
  }

  @override
  void initState() {
    super.initState();

    final fixedCourseId = _fixedCourseId;

    if (fixedCourseId != null &&
        MockLecturerCourses.courses.any(
          (course) => course.courseId == fixedCourseId,
        )) {
      _selectedCourseId = fixedCourseId;
    }
  }

  // ============================================================
  // DOWNLOAD TEMPLATE
  // ============================================================

  Future<void> _downloadTemplate() async {
    final course = MockLecturerCourses.getByCourseId(_effectiveCourseId ?? -1);

    if (_effectiveCourseId == null || course == null) {
      _showMessage('Vui lòng chọn lớp học phần trước.', error: true);
      return;
    }

    if (_selectedFormat == 'csv') {
      await _downloadCsvTemplate(course);
    } else {
      await _downloadExcelTemplate(course);
    }
  }

  // ============================================================
  // CSV TEMPLATE
  // ============================================================

  Future<void> _downloadCsvTemplate(dynamic course) async {
    try {
      final courseName = course.name.toString();
      final classCode = course.classCode.toString();

      final title = 'DANH SÁCH ĐỀ TÀI - $courseName - $classCode';

      // Chỉ tạo:
      // Dòng 1: Tiêu đề
      // Dòng 2: Header
      //
      // Không có dữ liệu mẫu.
      final templateRecords = <List<String>>[
        [title, '', '', '', '', ''],
        TopicCsvParser.headers,
      ];

      final encodedTemplate = csv.encode(templateRecords);

      final template = '\uFEFF$encodedTemplate';

      final bytes = Uint8List.fromList(utf8.encode(template));

      final saveToDownloads =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

      final savedPath = saveToDownloads
          ? await FileSaver.instance.saveFile(
              name: 'template_de_tai_$classCode',
              bytes: bytes,
              fileExtension: 'csv',
              mimeType: MimeType.custom,
              customMimeType: 'text/csv',
            )
          : await FileSaver.instance.saveAs(
              name: 'template_de_tai_$classCode',
              bytes: bytes,
              fileExtension: 'csv',
              mimeType: MimeType.custom,
              customMimeType: 'text/csv',
            );

      if (savedPath != null && mounted) {
        _showMessage('Đã tải file mẫu CSV cho lớp $classCode.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể tạo file mẫu CSV.', error: true);
      }
    }
  }

  // ============================================================
  // EXCEL TEMPLATE
  // ============================================================

  Future<void> _downloadExcelTemplate(dynamic course) async {
    try {
      final courseName = course.name.toString();
      final classCode = course.classCode.toString();

      final workbook = excel.Excel.createExcel();

      // Excel.createExcel() tạo sẵn Sheet1.
      // Đổi tên Sheet1 thành Danh sách đề tài.
      final defaultSheetName = workbook.getDefaultSheet();

      if (defaultSheetName == null) {
        throw Exception('Không tìm thấy sheet mặc định.');
      }

      if (defaultSheetName != 'Danh sách đề tài') {
        workbook.rename(defaultSheetName, 'Danh sách đề tài');
      }

      // Lấy chính sheet vừa đổi tên, không tạo sheet mới.
      final sheet = workbook['Danh sách đề tài'];

      final title = 'DANH SÁCH ĐỀ TÀI - $courseName - $classCode';

      // ==========================================================
      // TITLE
      // ==========================================================

      sheet.merge(
        excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        excel.CellIndex.indexByColumnRow(
          columnIndex: TopicCsvParser.headers.length - 1,
          rowIndex: 0,
        ),
      );

      final titleCell = sheet.cell(
        excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      );

      titleCell.value = excel.TextCellValue(title);

      titleCell.cellStyle = excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Center,
        verticalAlign: excel.VerticalAlign.Center,
        fontSize: 15,
      );

      // ==========================================================
      // HEADER
      // ==========================================================

      final headerStyle = excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Center,
        verticalAlign: excel.VerticalAlign.Center,
      );

      for (var index = 0; index < TopicCsvParser.headers.length; index++) {
        final cell = sheet.cell(
          excel.CellIndex.indexByColumnRow(columnIndex: index, rowIndex: 1),
        );

        cell.value = excel.TextCellValue(TopicCsvParser.headers[index]);

        cell.cellStyle = headerStyle;
      }

      // ==========================================================
      // KHÔNG TẠO DỮ LIỆU MẪU
      // ==========================================================
      //
      // Chỉ có:
      // Row 1: Tiêu đề
      // Row 2: Header
      //
      // Người dùng sẽ tự nhập dữ liệu đề tài.
      //

      // ==========================================================
      // COLUMN WIDTH
      // ==========================================================

      sheet.setColumnWidth(0, 32);
      sheet.setColumnWidth(1, 42);
      sheet.setColumnWidth(2, 38);
      sheet.setColumnWidth(3, 28);
      sheet.setColumnWidth(4, 35);
      sheet.setColumnWidth(5, 25);

      // ==========================================================
      // ROW HEIGHT
      // ==========================================================

      sheet.setRowHeight(0, 30);
      sheet.setRowHeight(1, 30);

      // ==========================================================
      // ENCODE
      // ==========================================================

      final encodedBytes = workbook.encode();

      if (encodedBytes == null) {
        throw Exception('Không thể tạo dữ liệu Excel.');
      }

      final bytes = Uint8List.fromList(encodedBytes);

      final saveToDownloads =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

      final savedPath = saveToDownloads
          ? await FileSaver.instance.saveFile(
              name: 'template_de_tai_$classCode',
              bytes: bytes,
              fileExtension: 'xlsx',
              mimeType: MimeType.custom,
              customMimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            )
          : await FileSaver.instance.saveAs(
              name: 'template_de_tai_$classCode',
              bytes: bytes,
              fileExtension: 'xlsx',
              mimeType: MimeType.custom,
              customMimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            );

      if (savedPath != null && mounted) {
        _showMessage('Đã tải file Excel mẫu cho lớp $classCode.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể tạo file Excel mẫu.', error: true);
      }
    }
  }
  // ============================================================
  // PICK FILE
  // ============================================================

  Future<void> _pickFile() async {
    try {
      final allowedExtensions = _selectedFormat == 'csv'
          ? const ['csv']
          : const ['xlsx'];

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty || !mounted) {
        return;
      }

      final file = result.files.single;

      final extension = file.extension?.toLowerCase() ?? '';

      // ========================================================
      // CHECK CSV
      // ========================================================

      if (_selectedFormat == 'csv' && extension != 'csv') {
        _showMessage('Vui lòng chọn file CSV.', error: true);
        return;
      }

      // ========================================================
      // CHECK XLSX
      // ========================================================

      if (_selectedFormat == 'xlsx' && extension != 'xlsx') {
        _showMessage(
          'Vui lòng chọn file Excel có định dạng .xlsx.',
          error: true,
        );
        return;
      }

      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        _showMessage('Không đọc được nội dung file.', error: true);
        return;
      }

      // ========================================================
      // CSV
      // ========================================================

      if (_selectedFormat == 'csv') {
        final content = utf8
            .decode(bytes, allowMalformed: false)
            .replaceFirst('\uFEFF', '');

        if (content.trim().isEmpty) {
          _reportImportFailure('File CSV đang trống.');
          return;
        }

        setState(() {
          _selectedFileName = file.name;
          _fileContent = content;
          _selectedExcelBytes = null;
        });
      }
      // ========================================================
      // EXCEL
      // ========================================================
      else {
        setState(() {
          _selectedFileName = file.name;
          _selectedExcelBytes = bytes;
          _fileContent = null;
        });
      }
    } on FormatException {
      _reportImportFailure(
        'Không đọc được file CSV. '
        'Hãy lưu CSV với mã hóa UTF-8 rồi thử lại.',
      );
    } catch (_) {
      _reportImportFailure('Không thể đọc file đã chọn.');
    }
  }

  // ============================================================
  // CONTINUE TO PREVIEW
  // ============================================================

  Future<void> _continueToPreview() async {
    final courseScopeId = _effectiveCourseId;

    if (courseScopeId == null) {
      _showMessage('Hãy chọn lớp học phần trước khi nhập file.', error: true);
      return;
    }

    if (_selectedFileName == null) {
      _showMessage('Vui lòng chọn file trước.', error: true);
      return;
    }

    if (_selectedFormat == 'csv' &&
        (_fileContent == null || _fileContent!.trim().isEmpty)) {
      _showMessage('Không có nội dung CSV để đọc.', error: true);
      return;
    }

    if (_selectedFormat == 'xlsx' &&
        (_selectedExcelBytes == null || _selectedExcelBytes!.isEmpty)) {
      _showMessage('Không có dữ liệu Excel để đọc.', error: true);
      return;
    }

    setState(() {
      _busy = true;
    });

    late final List<TopicImportPreviewRow> rows;

    try {
      if (_selectedFormat == 'csv') {
        rows = TopicCsvParser.parse(
          _fileContent!,
          courseScopeId: courseScopeId,
        );
      } else {
        rows = TopicExcelParser.parse(
          _selectedExcelBytes!,
          courseScopeId: courseScopeId,
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
        });

        _reportImportFailure(error.message);
      }

      return;
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
        });

        _reportImportFailure('Không thể phân tích file $_formatLabel.');
      }

      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
    });

    if (rows.isEmpty) {
      _reportImportFailure('File không có dòng đề tài để xem trước.');
      return;
    }

    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ImportTopicPreviewScreen(
          fileName: _selectedFileName ?? 'topics.$_selectedFormat',
          rows: rows,
          totalRows: rows.length,
          courseScopeId: courseScopeId,
        ),
      ),
    );

    if (imported == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  // ============================================================
  // CHANGE FORMAT
  // ============================================================

  void _changeFormat(String format) {
    if (_selectedFormat == format) {
      return;
    }

    setState(() {
      _selectedFormat = format;
      _selectedFileName = null;
      _fileContent = null;
      _selectedExcelBytes = null;
    });
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _reportImportFailure(String message) {
    if (!mounted) {
      return;
    }

    MockLecturerNotifications.instance.addNotification(
      type: 'Import',
      icon: Icons.error_outline,
      title: 'Import đề tài không thành công',
      content: message,
    );

    _showMessage(message, error: true);
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final selectedCourse = MockLecturerCourses.getByCourseId(
      _effectiveCourseId ?? -1,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Import đề tài')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ======================================================
          // STEP 1
          // ======================================================
          _FlowCard(
            number: '1',
            title: 'Chọn lớp học phần',
            description:
                'Mỗi file chỉ nhập đề tài cho một lớp học phần. '
                'ID đề tài và trạng thái được hệ thống xử lý tự động.',
            child: DropdownButtonFormField<int>(
              initialValue: _effectiveCourseId,
              decoration: const InputDecoration(
                labelText: 'Lớp học phần',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: MockLecturerCourses.courses
                  .map(
                    (course) => DropdownMenuItem(
                      value: course.courseId,
                      child: Text(
                        '${course.name} • ${course.classCode}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _hasValidFixedCourse
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCourseId = value;
                        _selectedFileName = null;
                        _fileContent = null;
                        _selectedExcelBytes = null;
                      });
                    },
            ),
          ),

          const SizedBox(height: 14),

          // ======================================================
          // STEP 2
          // ======================================================
          _FlowCard(
            number: '2',
            title: 'Chọn định dạng file',
            description: 'Bạn có thể nhập dữ liệu bằng CSV hoặc Excel (.xlsx).',
            child: Row(
              children: [
                Expanded(
                  child: _FormatCard(
                    icon: Icons.description_outlined,
                    title: 'CSV',
                    subtitle: 'File text',
                    selected: _selectedFormat == 'csv',
                    onTap: () => _changeFormat('csv'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _FormatCard(
                    icon: Icons.table_chart_outlined,
                    title: 'Excel',
                    subtitle: '.xlsx',
                    selected: _selectedFormat == 'xlsx',
                    onTap: () => _changeFormat('xlsx'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ======================================================
          // STEP 3
          // ======================================================
          _FlowCard(
            number: '3',
            title: 'Tải file mẫu',
            description: selectedCourse == null
                ? 'Chọn lớp học phần để tải file mẫu.'
                : 'File mẫu dành cho '
                      '${selectedCourse.name} • '
                      '${selectedCourse.classCode}. '
                      'File không chứa dữ liệu mẫu.',
            child: OutlinedButton.icon(
              onPressed: _busy || _effectiveCourseId == null
                  ? null
                  : _downloadTemplate,
              icon: Icon(
                _selectedFormat == 'csv'
                    ? Icons.description_outlined
                    : Icons.table_chart_outlined,
              ),
              label: Text(
                _selectedFormat == 'csv' ? 'Tải mẫu CSV' : 'Tải mẫu Excel',
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ======================================================
          // STEP 4
          // ======================================================
          _FlowCard(
            number: '4',
            title: 'Chọn file',
            description: selectedCourse == null
                ? 'Chọn lớp học phần để tiếp tục.'
                : 'Chọn file $_formatLabel để nhập vào '
                      '${selectedCourse.name} • '
                      '${selectedCourse.classCode}.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy || _effectiveCourseId == null
                      ? null
                      : _pickFile,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text('Chọn file $_formatLabel'),
                ),

                if (_selectedFileName != null) ...[
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.successColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedFileName!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ======================================================
          // STEP 5
          // ======================================================
          _FlowCard(
            number: '5',
            title: 'Xem trước trước khi nhập',
            description:
                'Các cột gồm: Tên đề tài, Mô tả, Mục tiêu, Phạm vi, '
                'Công nghệ sử dụng và Nguồn đề xuất. '
                'ID và trạng thái được hệ thống xử lý tự động.',
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

          const SizedBox(height: 12),

          Text(
            'Các dòng trống sẽ được bỏ qua. '
            'Các dòng thiếu dữ liệu hoặc sai số cột sẽ được báo lỗi '
            'trong màn hình xem trước.',
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FORMAT CARD
// ============================================================================

class _FormatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _FormatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? colors.primary : colors.onSurfaceVariant,
              size: 28,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            if (selected) Icon(Icons.check_circle, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FLOW CARD
// ============================================================================

class _FlowCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Widget child;

  const _FlowCard({
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
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Text(number),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(description, style: const TextStyle(height: 1.45)),

            const SizedBox(height: 14),

            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CSV PARSER
// ============================================================================

class TopicCsvParser {
  // --------------------------------------------------------------------------
  // HEADER
  // --------------------------------------------------------------------------

  static const List<String> headers = [
    'Tên đề tài',
    'Mô tả',
    'Mục tiêu',
    'Phạm vi',
    'Công nghệ sử dụng',
    'Nguồn đề xuất',
  ];

  // --------------------------------------------------------------------------
  // PARSE CSV
  // --------------------------------------------------------------------------

  static List<TopicImportPreviewRow> parse(
    String content, {
    int? courseScopeId,
  }) {
    if (courseScopeId == null) {
      throw const FormatException('Hãy chọn lớp học phần trước khi nhập.');
    }

    _validateCourse(courseScopeId);

    final normalizedContent = content.replaceFirst('\uFEFF', '');

    if (normalizedContent.trim().isEmpty) {
      throw const FormatException('File CSV đang trống.');
    }

    late final List<List<dynamic>> decoded;

    try {
      decoded = csv.decode(normalizedContent);
    } catch (_) {
      throw const FormatException('File CSV không đúng định dạng.');
    }

    if (decoded.isEmpty) {
      throw const FormatException('Không tìm thấy dữ liệu CSV.');
    }

    final records = decoded
        .map(
          (record) => record
              .map((cell) => cell == null ? '' : cell.toString())
              .toList(),
        )
        .toList();

    return _parseRecords(
      records,
      courseScopeId: courseScopeId,
      sourceName: 'CSV',
    );
  }

  // --------------------------------------------------------------------------
  // PARSE RECORDS
  // --------------------------------------------------------------------------

  static List<TopicImportPreviewRow> _parseRecords(
    List<List<String>> records, {
    required int courseScopeId,
    required String sourceName,
  }) {
    if (records.isEmpty) {
      throw FormatException('File $sourceName không có dữ liệu.');
    }

    final headerIndex = _findHeaderIndex(records);

    if (headerIndex == -1) {
      throw FormatException(
        'Không tìm thấy dòng tiêu đề cột '
        'trong file $sourceName.',
      );
    }

    final normalizedHeaders = records[headerIndex]
        .map((value) => value.trim().toLowerCase())
        .toList();

    final expected = headers.map((value) => value.toLowerCase()).toSet();

    final present = normalizedHeaders.toSet();

    final missing = headers
        .where((value) => !present.contains(value.toLowerCase()))
        .toList();

    final extra = normalizedHeaders
        .where((value) => value.isNotEmpty && !expected.contains(value))
        .toSet()
        .toList();

    final duplicated = normalizedHeaders
        .where(
          (value) =>
              value.isNotEmpty &&
              normalizedHeaders.where((header) => header == value).length > 1,
        )
        .toSet()
        .toList();

    if (missing.isNotEmpty ||
        extra.isNotEmpty ||
        duplicated.isNotEmpty ||
        normalizedHeaders.length != headers.length) {
      final details = <String>[
        if (missing.isNotEmpty) 'thiếu: ${missing.join(', ')}',
        if (extra.isNotEmpty) 'không hợp lệ: ${extra.join(', ')}',
        if (duplicated.isNotEmpty) 'bị lặp: ${duplicated.join(', ')}',
      ];

      throw FormatException(
        'Header $sourceName cần đúng '
        '${headers.length} cột '
        '(${details.join('; ')}).',
      );
    }

    final columnIndexes = <String, int>{
      for (var index = 0; index < normalizedHeaders.length; index++)
        normalizedHeaders[index]: index,
    };

    final dataRows = <_CsvDataRow>[];

    for (var index = headerIndex + 1; index < records.length; index++) {
      final cells = records[index];

      if (cells.every((cell) => cell.trim().isEmpty)) {
        continue;
      }

      dataRows.add(_CsvDataRow(rowNumber: index + 1, cells: cells));
    }

    final nextId =
        MockLecturerTopics.topics.fold<int>(
          0,
          (maximum, topic) => topic.id > maximum ? topic.id : maximum,
        ) +
        1;

    final validStatuses = MockLecturerTopics.topics
        .map((topic) => topic.status.trim())
        .where((status) => status.isNotEmpty)
        .toSet();

    final defaultStatus = validStatuses.isNotEmpty
        ? validStatuses.first
        : 'Đang hoạt động';

    return List<TopicImportPreviewRow>.generate(dataRows.length, (index) {
      final row = dataRows[index];

      final values = <String, String>{};

      for (final header in headers) {
        final normalizedHeader = header.toLowerCase();

        final cellIndex = columnIndexes[normalizedHeader]!;

        values[header] = cellIndex < row.cells.length
            ? row.cells[cellIndex].trim()
            : '';
      }

      final errors = <String>[];

      // --------------------------------------------------------
      // CHECK COLUMN COUNT
      // --------------------------------------------------------

      if (row.cells.length != headers.length) {
        errors.add(
          'Số cột là '
          '${row.cells.length}; yêu cầu đúng '
          '${headers.length} cột.',
        );
      }

      // --------------------------------------------------------
      // CHECK EMPTY DATA
      // --------------------------------------------------------

      for (final field in headers) {
        if (values[field]!.trim().isEmpty) {
          errors.add('$field không được để trống.');
        }
      }

      TopicModel? topic;

      // --------------------------------------------------------
      // CREATE TOPIC
      // --------------------------------------------------------

      if (errors.isEmpty) {
        topic = TopicModel(
          id: nextId + index,
          courseId: courseScopeId,
          title: values['Tên đề tài']!,
          description: values['Mô tả']!,
          objective: values['Mục tiêu']!,
          scope: values['Phạm vi']!,
          technology: values['Công nghệ sử dụng']!,
          source: values['Nguồn đề xuất']!,
          status: defaultStatus,
        );
      }

      return TopicImportPreviewRow(
        rowNumber: row.rowNumber,
        values: values,
        topic: topic,
        errors: errors,
      );
    });
  }

  // --------------------------------------------------------------------------
  // FIND HEADER
  // --------------------------------------------------------------------------

  static int _findHeaderIndex(List<List<String>> records) {
    for (var index = 0; index < records.length; index++) {
      final row = records[index]
          .map((value) => value.trim().toLowerCase())
          .toList();

      if (row.length != headers.length) {
        continue;
      }

      final normalized = row.toSet();

      final expected = headers.map((value) => value.toLowerCase()).toSet();

      if (normalized.length == expected.length &&
          normalized.containsAll(expected)) {
        return index;
      }
    }

    return -1;
  }

  // --------------------------------------------------------------------------
  // VALIDATE COURSE
  // --------------------------------------------------------------------------

  static void _validateCourse(int courseScopeId) {
    final assignedCourseIds = MockLecturerCourses.courses
        .map((course) => course.courseId)
        .toSet();

    if (!assignedCourseIds.contains(courseScopeId)) {
      throw const FormatException('Lớp học phần không thuộc phân công.');
    }
  }
}

// ============================================================================
// EXCEL PARSER
// ============================================================================

class TopicExcelParser {
  static List<TopicImportPreviewRow> parse(
    Uint8List bytes, {
    int? courseScopeId,
  }) {
    if (courseScopeId == null) {
      throw const FormatException('Hãy chọn lớp học phần trước khi nhập.');
    }

    TopicCsvParser._validateCourse(courseScopeId);

    late excel.Excel workbook;

    try {
      workbook = excel.Excel.decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(
        'Không thể đọc file Excel. '
        'Hãy kiểm tra file .xlsx.',
      );
    }

    if (workbook.tables.isEmpty) {
      throw const FormatException('File Excel không có sheet dữ liệu.');
    }

    final firstSheetName = workbook.tables.keys.first;

    final sheet = workbook.tables[firstSheetName];

    if (sheet == null) {
      throw const FormatException('Không tìm thấy sheet dữ liệu.');
    }

    final records = <List<String>>[];

    for (final row in sheet.rows) {
      final values = <String>[];

      for (final cell in row) {
        final value = cell?.value;

        if (value == null) {
          values.add('');
        } else if (value is excel.TextCellValue) {
          values.add(value.value.toString());
        } else if (value is excel.IntCellValue) {
          values.add(value.value.toString());
        } else if (value is excel.DoubleCellValue) {
          values.add(value.value.toString());
        } else if (value is excel.BoolCellValue) {
          values.add(value.value.toString());
        } else {
          values.add(value.toString());
        }
      }

      records.add(values);
    }

    if (records.isEmpty) {
      throw const FormatException('File Excel đang trống.');
    }

    return TopicCsvParser._parseRecords(
      records,
      courseScopeId: courseScopeId,
      sourceName: 'Excel',
    );
  }
}

// ============================================================================
// CSV DATA ROW
// ============================================================================

class _CsvDataRow {
  final int rowNumber;

  final List<String> cells;

  const _CsvDataRow({required this.rowNumber, required this.cells});
}
