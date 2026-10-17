import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/topic_model.dart';
<<<<<<< HEAD
import '../../../services/lecturer_api_service.dart';
=======
import '../../../services/topic_service.dart';
>>>>>>> origin/Frontend

class TopicImportPreviewRow {
  final int rowNumber;
  final Map<String, String> values;
  final TopicModel? topic;
  final List<String> errors;

  TopicImportPreviewRow({
    required this.rowNumber,
    required this.values,
    required this.topic,
    required this.errors,
  });

  bool get isValid => topic != null && errors.isEmpty;
}

class ImportTopicPreviewScreen extends StatefulWidget {
  final String fileName;
  final List<TopicImportPreviewRow> rows;
  final int totalRows;
  final int? courseScopeId;

  const ImportTopicPreviewScreen({
    super.key,
    required this.fileName,
    required this.rows,
    required this.totalRows,
    this.courseScopeId,
  });

  @override
  State<ImportTopicPreviewScreen> createState() =>
      _ImportTopicPreviewScreenState();
}

class _ImportTopicPreviewScreenState extends State<ImportTopicPreviewScreen> {
  bool _processing = false;
  bool _failureReported = false;

  List<TopicImportPreviewRow> get _validRows =>
      widget.rows.where((row) => row.isValid).toList();

  Future<void> _confirmImport() async {
    if (_processing) return;

    setState(() => _processing = true);

    try {
      final validRows = _validRows;

      if (validRows.isEmpty) {
        _reportImportFailure(
          widget.rows.isEmpty
              ? AppLocalizations.text(
                  'Không tìm thấy dòng đề tài trong file ${widget.fileName}.',
                  en: 'No topic rows found in file ${widget.fileName}.',
                )
              : AppLocalizations.text(
                  'Không có dòng hợp lệ trong file ${widget.fileName}. Hãy kiểm tra lỗi từng dòng.',
                  en: 'No valid rows in file ${widget.fileName}. Check each row for errors.',
                ),
        );
        return;
      }

      final validCount = validRows.length;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            AppLocalizations.text('Xác nhận import', en: 'Confirm Import'),
          ),
          content: Text(
            AppLocalizations.text(
              'Sẽ thêm $validCount đề tài hợp lệ. '
              'Các dòng lỗi sẽ được bỏ qua. Tiếp tục?',
              en: 'Will add $validCount valid topics. '
                  'Rows with errors will be skipped. Continue?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                AppLocalizations.text('Xác nhận import', en: 'Confirm Import'),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) {
        return;
      }

<<<<<<< HEAD
      final assignedCourseIds = LecturerApiService.instance.cachedCourses
          .map((course) => course.courseId)
          .toSet();

      var importedCount = 0;
      var errorCount = widget.rows.length - validRows.length;

      for (final row in validRows) {
        final topic = row.topic!;

        final isInAssignedCourse = assignedCourseIds.isEmpty || assignedCourseIds.contains(topic.courseId);
        final isInRequestedCourse =
            widget.courseScopeId == null ||
            widget.courseScopeId == topic.courseId;

        if (!isInAssignedCourse || !isInRequestedCourse) {
=======
      int importedCount = 0;
      int errorCount = 0;

      for (final row in validRows) {
        final topic = row.topic!;
        try {
          await TopicService().createTopic({
            'dotDangKyId': topic.courseId,
            'tenDeTai': topic.title,
            'moTa': topic.description,
            'mucTieu': topic.objective,
            'phamVi': topic.scope,
            'congNgheDuKien': topic.technology,
          });
          importedCount++;
        } catch (_) {
>>>>>>> origin/Frontend
          errorCount++;
        }
<<<<<<< HEAD

        try {
          await LecturerApiService.instance.createTopic(
            tenDeTai: topic.title,
            moTa: topic.description,
            mucTieu: topic.objective,
            phamVi: topic.scope,
            congNghe: topic.technology,
            dotDangKyId: topic.courseId,
          );
          importedCount++;
        } catch (_) {
          errorCount++;
        }
=======
>>>>>>> origin/Frontend
      }

      if (importedCount == 0) {
        _reportImportFailure(
<<<<<<< HEAD
          AppLocalizations.text(
            'Không còn dòng hợp lệ để import. Hãy kiểm tra lại dữ liệu.',
            en: 'No valid rows left to import. Please check data.',
          ),
=======
          'Không thể lưu đề tài nào. Vui lòng kiểm tra lại kết nối hoặc định dạng file.',
>>>>>>> origin/Frontend
        );
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
<<<<<<< HEAD
            AppLocalizations.text(
              'Đã import $importedCount đề tài, '
              '$errorCount dòng lỗi.',
              en: 'Imported $importedCount topics, '
                  '$errorCount error rows.',
            ),
=======
            'Đã import $importedCount đề tài thành công, '
            '$errorCount dòng lỗi.',
>>>>>>> origin/Frontend
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  void _reportImportFailure(String message) {
    if (_failureReported || !mounted) {
      return;
    }

    _failureReported = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.tr(message)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validCount = _validRows.length;

    final errorCount = widget.rows.length - validCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Xem trước import', en: 'Import Preview'),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _CountCard(
                      label: AppLocalizations.text('Đọc được', en: 'Read'),
                      value: widget.totalRows,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    _CountCard(
                      label: AppLocalizations.text('Hợp lệ', en: 'Valid'),
                      value: validCount,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    _CountCard(
                      label: AppLocalizations.text('Lỗi', en: 'Errors'),
                      value: errorCount,
                      color: AppTheme.dangerColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: widget.rows.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        AppLocalizations.text(
                          'Không có dòng dữ liệu để xem trước.',
                          en: 'No data rows to preview.',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: widget.rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _PreviewRowCard(row: widget.rows[index]),
                  ),
          ),
        ],
      ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _processing ? null : _confirmImport,
                icon: Icon(
                  validCount == 0
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                ),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    validCount == 0
                        ? AppLocalizations.text(
                            'Không có dòng hợp lệ',
                            en: 'No valid rows',
                          )
                        : AppLocalizations.text(
                            'Xác nhận import',
                            en: 'Confirm Import',
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRowCard extends StatelessWidget {
  final TopicImportPreviewRow row;

  const _PreviewRowCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final valid = row.isValid;

    final accent = valid ? AppTheme.successColor : AppTheme.dangerColor;

    final title = row.values['Tên đề tài']?.trim();

    final topicTitle = title == null || title.isEmpty
        ? AppLocalizations.text('(thiếu tên đề tài)', en: '(missing topic title)')
        : title;

    final id = row.topic?.id.toString() ??
        AppLocalizations.text('sẽ cấp khi hợp lệ', en: 'assigned when valid');

    final courseId = row.topic?.courseId.toString() ?? '';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  valid ? Icons.check_circle_outline : Icons.error_outline,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${AppLocalizations.text('Dòng', en: 'Row')} ${row.rowNumber}',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  valid
                      ? AppLocalizations.text('Hợp lệ', en: 'Valid')
                      : AppLocalizations.text('Lỗi', en: 'Error'),
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              topicTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            if (courseId.isNotEmpty)
              _PreviewField(
                label: AppLocalizations.text('Mã đề tài', en: 'Topic Code'),
                value: id,
              ),

            _PreviewField(
              label: AppLocalizations.text('Mô tả', en: 'Description'),
              value: row.values['Mô tả'] ?? '',
            ),

            _PreviewField(
              label: AppLocalizations.text('Mục tiêu', en: 'Objectives'),
              value: row.values['Mục tiêu'] ?? '',
            ),

            _PreviewField(
              label: AppLocalizations.text('Phạm vi', en: 'Scope'),
              value: row.values['Phạm vi'] ?? '',
            ),

            _PreviewField(
              label: AppLocalizations.text(
                'Công nghệ sử dụng',
                en: 'Technologies',
              ),
              value: row.values['Công nghệ sử dụng'] ?? '',
            ),

            _PreviewField(
              label: AppLocalizations.text(
                'Nguồn đề xuất',
                en: 'Proposed source',
              ),
              value: row.values['Nguồn đề xuất'] ?? '',
            ),

            if (row.errors.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...row.errors.map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: accent)),
                      Expanded(
                        child: Text(
                          AppLocalizations.tr(error),
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewField extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(height: 1.4),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
