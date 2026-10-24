import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/lecturer_api_service.dart';
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
  List<LecturerCourseModel> _courses = [];

  String _selectedFormat = 'csv';

  int? get _fixedCourseId => widget.lecturerCourseId ?? widget.course?.id;

  bool get _hasValidFixedCourse =>
      _fixedCourseId != null &&
      _courses.any(
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

    _courses = LecturerApiService.instance.cachedCourses;
    final fixedCourseId = _fixedCourseId;

    if (fixedCourseId != null &&
        _courses.any(
          (course) => course.courseId == fixedCourseId,
        )) {
      _selectedCourseId = fixedCourseId;
    }

    if (_courses.isEmpty) {
      LecturerApiService.instance.fetchCourses().then((c) {
        if (mounted) {
          setState(() {
            _courses = c;
            if (_selectedCourseId == null && c.isNotEmpty) {
              _selectedCourseId = fixedCourseId ?? c.first.courseId;
            }
          });
        }
      });
    }
  }

  // ============================================================
  // DOWNLOAD TEMPLATE
  // ============================================================

  Future<void> _downloadTemplate() async {
    LecturerCourseModel? course;
    for (final c in _courses) {
      if (c.courseId == (_effectiveCourseId ?? -1)) {
        course = c;
        break;
      }
    }

    if (_effectiveCourseId == null || course == null) {
      _showMessage(
        AppLocalizations.text(
          'Vui lòng chọn lớp học phần trước.',
          en: 'Please select a course class first.',
        ),
        error: true,
      );
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
        _showMessage(
          AppLocalizations.text(
            'Đã tải file mẫu CSV cho lớp $classCode.',
            en: 'Downloaded CSV template for class $classCode.',
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          AppLocalizations.text(
            'Không thể tạo file mẫu CSV.',
            en: 'Could not create CSV template.',
          ),
          error: true,
        );
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
        _showMessage(
          AppLocalizations.text(
            'Đã tải file Excel mẫu cho lớp $classCode.',
            en: 'Downloaded Excel template for class $classCode.',
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          AppLocalizations.text(
            'Không thể tạo file Excel mẫu.',
            en: 'Could not create Excel template.',
          ),
          error: true,
        );
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
        _showMessage(
          AppLocalizations.text(
            'Vui lòng chọn file CSV.',
            en: 'Please select a CSV file.',
          ),
          error: true,
        );
        return;
      }

      // ========================================================
      // CHECK XLSX
      // ========================================================

      if (_selectedFormat == 'xlsx' && extension != 'xlsx') {
        _showMessage(
          AppLocalizations.text(
            'Vui lòng chọn file Excel có định dạng .xlsx.',
            en: 'Please select an Excel file in .xlsx format.',
          ),
          error: true,
        );
        return;
      }

      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        _showMessage(
          AppLocalizations.text(
            'Không đọc được nội dung file.',
            en: 'Could not read file content.',
          ),
          error: true,
        );
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
          _reportImportFailure(
            AppLocalizations.text(
              'File CSV đang trống.',
              en: 'CSV file is empty.',
            ),
          );
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
        AppLocalizations.text(
          'Không đọc được file CSV. Hãy lưu CSV với mã hóa UTF-8 rồi thử lại.',
          en: 'Could not read CSV file. Please save CSV with UTF-8 encoding and try again.',
        ),
      );
    } catch (_) {
      _reportImportFailure(
        AppLocalizations.text(
          'Không thể đọc file đã chọn.',
          en: 'Could not read selected file.',
        ),
      );
    }
  }

  // ============================================================
  // CONTINUE TO PREVIEW
  // ============================================================

  Future<void> _continueToPreview() async {
    final courseScopeId = _effectiveCourseId;

    if (courseScopeId == null) {
      _showMessage(
        AppLocalizations.text(
          'Hãy chọn lớp học phần trước khi nhập file.',
          en: 'Please select a course class before importing file.',
        ),
        error: true,
      );
      return;
    }

    if (_selectedFileName == null) {
      _showMessage(
        AppLocalizations.text(
          'Vui lòng chọn file trước.',
          en: 'Please select a file first.',
        ),
        error: true,
      );
      return;
    }

    if (_selectedFormat == 'csv' &&
        (_fileContent == null || _fileContent!.trim().isEmpty)) {
      _showMessage(
        AppLocalizations.text(
          'Không có nội dung CSV để đọc.',
          en: 'No CSV content to read.',
        ),
        error: true,
      );
      return;
    }

    if (_selectedFormat == 'xlsx' &&
        (_selectedExcelBytes == null || _selectedExcelBytes!.isEmpty)) {
      _showMessage(
        AppLocalizations.text(
          'Không có dữ liệu Excel để đọc.',
          en: 'No Excel data to read.',
        ),
        error: true,
      );
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

        _reportImportFailure(
          AppLocalizations.text(
            'Không thể phân tích file $_formatLabel.',
            en: 'Could not parse $_formatLabel file.',
          ),
        );
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
      _reportImportFailure(
        AppLocalizations.text(
          'File không có dòng đề tài để xem trước.',
          en: 'File has no topic rows to preview.',
        ),
      );
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

    _showMessage(AppLocalizations.tr(message), error: true);
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
        content: Text(AppLocalizations.tr(message)),
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

    LecturerCourseModel? selectedCourse;
    for (final c in _courses) {
      if (c.courseId == (_effectiveCourseId ?? -1)) {
        selectedCourse = c;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Import đề tài', en: 'Import Topics'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          // ======================================================
          // STEP 1
          // ======================================================
          _FlowCard(
            number: '1',
            title: AppLocalizations.text('Chọn lớp học phần', en: 'Select Course Class'),
            description: AppLocalizations.text(
              'Mỗi file chỉ nhập đề tài cho một lớp học phần. '
              'ID đề tài và trạng thái được hệ thống xử lý tự động.',
              en: 'Each file only imports topics for one course class. '
                  'Topic ID and status are automatically handled by the system.',
            ),
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: _effectiveCourseId,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Lớp học phần', en: 'Course class'),
                prefixIcon: const Icon(Icons.school_outlined),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _courses
                  .map(
                    (course) => DropdownMenuItem(
                      value: course.courseId,
                      child: Text(
                        '${AppLocalizations.courseName(course.name)} • ${course.classCode}',
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
            title: AppLocalizations.text('Chọn định dạng file', en: 'Select File Format'),
            description: AppLocalizations.text(
              'Bạn có thể nhập dữ liệu bằng CSV hoặc Excel (.xlsx).',
              en: 'You can import data using CSV or Excel (.xlsx).',
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FormatCard(
                    icon: Icons.description_outlined,
                    title: 'CSV',
                    subtitle: AppLocalizations.text('File text', en: 'Text file'),
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
            title: AppLocalizations.text('Tải file mẫu', en: 'Download Template'),
            description: selectedCourse == null
                ? AppLocalizations.text(
                    'Chọn lớp học phần để tải file mẫu.',
                    en: 'Select a course class to download template.',
                  )
                : AppLocalizations.text(
                    'File mẫu dành cho '
                    '${selectedCourse.name} • '
                    '${selectedCourse.classCode}. '
                    'File không chứa dữ liệu mẫu.',
                    en: 'Template for '
                    '${AppLocalizations.courseName(selectedCourse.name)} • '
                    '${selectedCourse.classCode}. '
                    'File contains no sample data.',
                  ),
            child: OutlinedButton.icon(
              onPressed: _busy || _effectiveCourseId == null
                  ? null
                  : _downloadTemplate,
              icon: Icon(
                _selectedFormat == 'csv'
                    ? Icons.description_outlined
                    : Icons.table_chart_outlined,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _selectedFormat == 'csv'
                      ? AppLocalizations.text('Tải mẫu CSV', en: 'Download CSV template')
                      : AppLocalizations.text('Tải mẫu Excel', en: 'Download Excel template'),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ======================================================
          // STEP 4
          // ======================================================
          _FlowCard(
            number: '4',
            title: AppLocalizations.text('Chọn file', en: 'Select File'),
            description: selectedCourse == null
                ? AppLocalizations.text(
                    'Chọn lớp học phần để tiếp tục.',
                    en: 'Select a course class to proceed.',
                  )
                : AppLocalizations.text(
                    'Chọn file $_formatLabel để nhập vào '
                    '${selectedCourse.name} • '
                    '${selectedCourse.classCode}.',
                    en: 'Select $_formatLabel file to import into '
                    '${AppLocalizations.courseName(selectedCourse.name)} • '
                    '${selectedCourse.classCode}.',
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy || _effectiveCourseId == null
                      ? null
                      : _pickFile,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppLocalizations.text(
                        'Chọn file $_formatLabel',
                        en: 'Choose $_formatLabel file',
                      ),
                    ),
                  ),
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
            title: AppLocalizations.text(
              'Xem trước trước khi nhập',
              en: 'Preview Before Import',
            ),
            description: AppLocalizations.text(
              'Các cột gồm: Tên đề tài, Mô tả, Mục tiêu, Phạm vi, '
              'Công nghệ sử dụng và Nguồn đề xuất. '
              'ID và trạng thái được hệ thống xử lý tự động.',
              en: 'Columns include: Topic Name, Description, Objective, Scope, '
                  'Technology, and Source. '
                  'ID and status are automatically managed by the system.',
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
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppLocalizations.text(
                    'Tiếp tục xem trước',
                    en: 'Continue to preview',
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            AppLocalizations.text(
              'Các dòng trống sẽ được bỏ qua. '
              'Các dòng thiếu dữ liệu hoặc sai số cột sẽ được báo lỗi '
              'trong màn hình xem trước.',
              en: 'Empty rows will be skipped. '
                  'Rows with missing data or incorrect column count will show errors '
                  'in the preview screen.',
            ),
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB).withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF2563EB) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: selected ? const Color(0xFF2563EB) : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$number. $title',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 14),
          child,
        ],
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

    final nextId = DateTime.now().millisecondsSinceEpoch;
    const defaultStatus = 'Đang hoạt động';

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
    final assignedCourseIds = LecturerApiService.instance.cachedCourses
        .map((course) => course.courseId)
        .toSet();

    if (assignedCourseIds.isNotEmpty && !assignedCourseIds.contains(courseScopeId)) {
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
