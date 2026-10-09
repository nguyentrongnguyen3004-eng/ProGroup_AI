import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_notifications.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/topic_model.dart';

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
              ? 'Không tìm thấy dòng đề tài trong file ${widget.fileName}.'
              : 'Không có dòng hợp lệ trong file ${widget.fileName}. Hãy kiểm tra lỗi từng dòng.',
        );
        return;
      }

      final validCount = validRows.length;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Xác nhận import'),
          content: Text(
            'Sẽ thêm $validCount đề tài hợp lệ. '
            'Các dòng lỗi sẽ được bỏ qua. Tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xác nhận import'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) {
        return;
      }

      final assignedCourseIds = MockLecturerCourses.courses
          .map((course) => course.courseId)
          .toSet();

      final validStatuses = MockLecturerTopics.topics
          .map((topic) => topic.status.trim())
          .where((status) => status.isNotEmpty)
          .toSet();

      final usedIds = MockLecturerTopics.topics
          .map((topic) => topic.id)
          .toSet();

      var importedCount = 0;

      var errorCount = widget.rows.length - validRows.length;

      for (final row in validRows) {
        final topic = row.topic!;

        final isInAssignedCourse = assignedCourseIds.contains(topic.courseId);

        final isInRequestedCourse =
            widget.courseScopeId == null ||
            widget.courseScopeId == topic.courseId;

        final isValidStatus =
            validStatuses.isEmpty ||
            validStatuses.contains(topic.status.trim());

        final hasDuplicateId = usedIds.contains(topic.id);

        if (!isInAssignedCourse ||
            !isInRequestedCourse ||
            !isValidStatus ||
            hasDuplicateId) {
          errorCount++;
          continue;
        }

        MockLecturerTopics.add(topic);

        usedIds.add(topic.id);

        importedCount++;
      }

      if (importedCount == 0) {
        _reportImportFailure(
          'Không còn dòng hợp lệ để import. Hãy kiểm tra lại dữ liệu.',
        );
        return;
      }

      MockLecturerNotifications.instance.addNotification(
        type: 'Import',
        icon: Icons.upload_file_outlined,
        title: 'Import đề tài thành công',
        content:
            'Đã import $importedCount đề tài, '
            '$errorCount dòng lỗi từ file ${widget.fileName}.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã import $importedCount đề tài, '
            '$errorCount dòng lỗi.',
          ),
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

    MockLecturerNotifications.instance.addNotification(
      type: 'Import',
      icon: Icons.error_outline,
      title: 'Import đề tài không thành công',
      content: message,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validCount = _validRows.length;

    final errorCount = widget.rows.length - validCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Xem trước import')),
      body: Column(
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
                      label: 'Đọc được',
                      value: widget.totalRows,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    _CountCard(
                      label: 'Hợp lệ',
                      value: validCount,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    _CountCard(
                      label: 'Lỗi',
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
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Không có dòng dữ liệu để xem trước.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _PreviewRowCard(row: widget.rows[index]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
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
                label: Text(
                  validCount == 0 ? 'Không có dòng hợp lệ' : 'Xác nhận import',
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
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
        ? '(thiếu tên đề tài)'
        : title;

    final id = row.topic?.id.toString() ?? 'sẽ cấp khi hợp lệ';

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
                    'Dòng ${row.rowNumber}',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  valid ? 'Hợp lệ' : 'Lỗi',
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
              _PreviewField(label: 'Mã đề tài', value: id),

            _PreviewField(label: 'Mô tả', value: row.values['Mô tả'] ?? ''),

            _PreviewField(
              label: 'Mục tiêu',
              value: row.values['Mục tiêu'] ?? '',
            ),

            _PreviewField(label: 'Phạm vi', value: row.values['Phạm vi'] ?? ''),

            _PreviewField(
              label: 'Công nghệ sử dụng',
              value: row.values['Công nghệ sử dụng'] ?? '',
            ),

            _PreviewField(
              label: 'Nguồn đề xuất',
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
                          error,
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
