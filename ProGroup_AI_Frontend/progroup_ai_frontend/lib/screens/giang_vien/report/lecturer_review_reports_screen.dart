import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/lecturer_api_service.dart';

class LecturerReviewReportsScreen extends StatefulWidget {
  const LecturerReviewReportsScreen({super.key});

  @override
  State<LecturerReviewReportsScreen> createState() => _LecturerReviewReportsScreenState();
}

class _LecturerReviewReportsScreenState extends State<LecturerReviewReportsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _reports = [];
  String _selectedFilter = 'all'; // all, pending, graded

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await LecturerApiService.instance.fetchLecturerReports();
      if (!mounted) return;
      setState(() {
        _reports = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_selectedFilter == 'pending') {
      return _reports.where((r) => r['diem'] == null).toList();
    }
    if (_selectedFilter == 'graded') {
      return _reports.where((r) => r['diem'] != null).toList();
    }
    return _reports;
  }

  void _openGradeDialog(Map<String, dynamic> report) {
    final reportId = report['baoCaoId'] as int;
    final currentScore = report['diem'] != null ? '${report['diem']}' : '';
    final scoreController = TextEditingController(text: currentScore);
    final feedbackController = TextEditingController(text: report['nhanXetGiangVien']?.toString() ?? '');
    String status = report['trangThai']?.toString() ?? 'Đạt';
    if (status == 'Đã nộp') status = 'Đạt';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.grading_rounded, color: Color(0xFF10B981), size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Đánh giá & Chấm điểm',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhóm: ${report['tenNhom'] ?? 'Nhóm đồ án'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Tuần: ${report['tuanBaoCao']} - ${report['tieuDe']}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: scoreController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Điểm số (Thang 10)',
                        hintText: 'Ví dụ: 8.5',
                        prefixIcon: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: InputDecoration(
                        labelText: 'Kết quả đánh giá',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Đạt', child: Text('Đạt')),
                        DropdownMenuItem(value: 'Cần chỉnh sửa', child: Text('Cần chỉnh sửa')),
                        DropdownMenuItem(value: 'Không đạt', child: Text('Không đạt')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => status = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Nhận xét & góp ý chi tiết cho nhóm',
                        hintText: 'Ghi rõ các điểm đã làm tốt, các lỗi cần sửa đổi...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final score = double.tryParse(scoreController.text.trim());
                          setDialogState(() => isSaving = true);
                          try {
                            await LecturerApiService.instance.gradeReport(
                              reportId,
                              diem: score,
                              nhanXet: feedbackController.text.trim(),
                              trangThai: status,
                            );

                            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã lưu đánh giá và gửi thông báo tới nhóm!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                              _loadReports();
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (dialogCtx.mounted) {
                              ScaffoldMessenger.of(dialogCtx).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isSaving ? 'Đang lưu...' : 'Lưu đánh giá'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đạt':
        return const Color(0xFF10B981);
      case 'Cần chỉnh sửa':
        return const Color(0xFFF59E0B);
      case 'Không đạt':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filteredReports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá tiến độ đồ án', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        child: Column(
          children: [
            // Filter Segment
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'all', label: Text('Tất cả (${_reports.length})')),
                  ButtonSegment(
                    value: 'pending',
                    label: Text('Chờ chấm (${_reports.where((r) => r['diem'] == null).length})'),
                  ),
                  ButtonSegment(
                    value: 'graded',
                    label: Text('Đã chấm (${_reports.where((r) => r['diem'] != null).length})'),
                  ),
                ],
                selected: {_selectedFilter},
                onSelectionChanged: (newVal) {
                  setState(() => _selectedFilter = newVal.first);
                },
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadReports,
                color: const Color(0xFF2563EB),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                                const SizedBox(height: 8),
                                Text('Lỗi: $_errorMessage'),
                                const SizedBox(height: 12),
                                FilledButton(onPressed: _loadReports, child: const Text('Thử lại')),
                              ],
                            ),
                          )
                        : filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.done_all_rounded, size: 54, color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Không có báo cáo nào trong mục này',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final r = filtered[index];
                                  final status = r['trangThai']?.toString() ?? 'Đã nộp';
                                  final statusColor = _getStatusColor(status);
                                  final groupName = r['tenNhom']?.toString() ?? 'Nhóm đồ án';
                                  final topicName = r['tenDeTai']?.toString() ?? '';
                                  final title = r['tieuDe']?.toString() ?? 'Báo cáo';
                                  final content = r['noiDung']?.toString() ?? '';
                                  final score = r['diem'];
                                  final feedback = r['nhanXetGiangVien']?.toString();
                                  final week = r['tuanBaoCao'] ?? 1;

                                  return Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Tuần $week • $groupName',
                                                  style: const TextStyle(
                                                    color: Color(0xFF2563EB),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            title,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          if (topicName.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Đề tài: $topicName',
                                              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                                            ),
                                          ],
                                          if (content.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              content,
                                              style: TextStyle(color: colors.onSurface, fontSize: 13.5),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              if (score != null) ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF10B981),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'Điểm: $score / 10',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12.5,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              const Spacer(),
                                              FilledButton.tonalIcon(
                                                onPressed: () => _openGradeDialog(r),
                                                icon: const Icon(Icons.rate_review_rounded, size: 16),
                                                label: Text(score == null ? 'Chấm điểm' : 'Sửa đánh giá'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
