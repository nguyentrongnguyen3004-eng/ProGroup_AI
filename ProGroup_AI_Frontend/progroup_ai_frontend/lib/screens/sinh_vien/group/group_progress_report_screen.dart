import 'package:flutter/material.dart';
import '../../../models/group_model.dart';
import '../../../services/student_api_service.dart';

class GroupProgressReportScreen extends StatefulWidget {
  final GroupModel group;
  final String? topicTitle;

  const GroupProgressReportScreen({
    super.key,
    required this.group,
    this.topicTitle,
  });

  @override
  State<GroupProgressReportScreen> createState() => _GroupProgressReportScreenState();
}

class _GroupProgressReportScreenState extends State<GroupProgressReportScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _reports = [];

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
      final list = await StudentApiService.instance.fetchGroupReports(widget.group.id);
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


  bool _isValidUrl(String str) {
    if (str.isEmpty) return true;
    final clean = str.trim();
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) return false;
    final uri = Uri.tryParse(clean);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  static const List<Map<String, dynamic>> _milestones = [
    {
      'tuan': 1,
      'tieuDe': 'Tuần 1: Khởi động & Đặc tả yêu cầu đề tài',
      'deadline': '15/09/2026',
    },
    {
      'tuan': 3,
      'tieuDe': 'Tuần 3: Thiết kế kiến trúc hệ thống & CSDL',
      'deadline': '29/09/2026',
    },
    {
      'tuan': 6,
      'tieuDe': 'Tuần 6: Xây dựng Prototype & Core API',
      'deadline': '20/10/2026',
    },
    {
      'tuan': 9,
      'tieuDe': 'Tuần 9: Tích hợp Frontend, Backend & Kiểm thử',
      'deadline': '10/11/2026',
    },
    {
      'tuan': 12,
      'tieuDe': 'Tuần 12: Hoàn thiện đồ án, Đóng gói & Báo cáo thử',
      'deadline': '01/12/2026',
    },
  ];

  String _getDeadlineForWeek(int week) {
    final m = _milestones.where((item) => item['tuan'] == week).firstOrNull;
    if (m != null) return m['deadline'] as String;
    switch (week) {
      case 1:
        return '15/09/2026';
      case 3:
        return '29/09/2026';
      case 6:
        return '20/10/2026';
      case 9:
        return '10/11/2026';
      case 12:
        return '01/12/2026';
      default:
        return '25/12/2026';
    }
  }

  void _openSubmitDialog([int? defaultWeek]) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final weekController = TextEditingController(
      text: defaultWeek != null ? '$defaultWeek' : '${_reports.length + 1}',
    );
    final githubController = TextEditingController();
    final fileController = TextEditingController();
    final demoController = TextEditingController();
    bool isSubmitting = false;
    String? fileError;
    String? githubError;
    String? demoError;
    String? globalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.upload_file_rounded, color: Color(0xFF2563EB), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Nộp báo cáo tiến độ đồ án',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (globalError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                globalError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: weekController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tuần báo cáo (Số)',
                        prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề báo cáo *',
                        hintText: 'Ví dụ: Báo cáo tuần 1: Đặc tả yêu cầu & CSDL',
                        prefixIcon: const Icon(Icons.title_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Tóm tắt nội dung công việc đã làm',
                        hintText: 'Mô tả tóm tắt tiến độ, công việc đã hoàn thành, khó khăn...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: githubController,
                      decoration: InputDecoration(
                        labelText: 'Link mã nguồn GitHub (nếu có)',
                        hintText: 'https://github.com/...',
                        errorText: githubError,
                        prefixIcon: const Icon(Icons.code_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fileController,
                      decoration: InputDecoration(
                        labelText: 'Link file báo cáo PDF / Google Drive',
                        hintText: 'https://drive.google.com/...',
                        errorText: fileError,
                        prefixIcon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: demoController,
                      decoration: InputDecoration(
                        labelText: 'Link Video Demo / Figma (nếu có)',
                        hintText: 'https://youtube.com/ hoặc https://figma.com/...',
                        errorText: demoError,
                        prefixIcon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final title = titleController.text.trim();
                                if (title.isEmpty) {
                                  setModalState(() {
                                    globalError = 'Vui lòng nhập tiêu đề báo cáo.';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập tiêu đề báo cáo.')),
                                  );
                                  return;
                                }

                                final github = githubController.text.trim();
                                final file = fileController.text.trim();
                                final demo = demoController.text.trim();

                                final isGitInvalid = github.isNotEmpty && !_isValidUrl(github);
                                final isFileInvalid = file.isNotEmpty && !_isValidUrl(file);
                                final isDemoInvalid = demo.isNotEmpty && !_isValidUrl(demo);

                                if (isGitInvalid || isFileInvalid || isDemoInvalid) {
                                  const urlWarning = 'Vui lòng nhập đường dẫn URL hợp lệ (bắt đầu bằng http:// hoặc https://)';
                                  setModalState(() {
                                    globalError = urlWarning;
                                    githubError = isGitInvalid ? urlWarning : null;
                                    fileError = isFileInvalid ? urlWarning : null;
                                    demoError = isDemoInvalid ? urlWarning : null;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(urlWarning),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() {
                                  globalError = null;
                                  githubError = null;
                                  fileError = null;
                                  demoError = null;
                                  isSubmitting = true;
                                });

                                final week = int.tryParse(weekController.text.trim()) ?? 1;

                                try {
                                  await StudentApiService.instance.submitProgressReport(
                                    nhomId: widget.group.id,
                                    tieuDe: title,
                                    noiDung: contentController.text.trim(),
                                    githubUrl: githubController.text.trim(),
                                    fileUrl: fileController.text.trim(),
                                    demoUrl: demoController.text.trim(),
                                    tuanBaoCao: week,
                                  );

                                  if (modalContext.mounted) Navigator.pop(modalContext);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã nộp báo cáo tiến độ thành công!'),
                                        backgroundColor: Color(0xFF10B981),
                                      ),
                                    );
                                    _loadReports();
                                  }
                                } catch (e) {
                                  setModalState(() => isSubmitting = false);
                                  if (modalContext.mounted) {
                                    ScaffoldMessenger.of(modalContext).showSnackBar(
                                      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(isSubmitting ? 'Đang gửi...' : 'Nộp báo cáo ngay'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã chấm':
      case 'Đạt':
        return const Color(0xFF10B981); // Emerald
      case 'Cần chỉnh sửa':
        return const Color(0xFFF59E0B); // Amber
      case 'Không đạt':
        return const Color(0xFFEF4444); // Red
      case 'Chưa nộp':
        return const Color(0xFF6B7280); // Gray
      default:
        return const Color(0xFF2563EB); // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo tiến độ đồ án', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSubmitDialog,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Nộp báo cáo mới', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _loadReports,
          color: const Color(0xFF2563EB),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.groups_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.group.name,
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (widget.topicTitle != null && widget.topicTitle!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Đề tài: ${widget.topicTitle}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13.5),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tổng số báo cáo đã nộp: ${_reports.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                        const SizedBox(height: 10),
                        Text('Lỗi: $_errorMessage', textAlign: TextAlign.center),
                        const SizedBox(height: 14),
                        FilledButton(onPressed: _loadReports, child: const Text('Thử lại')),
                      ],
                    ),
                  ),
                )
              else ...[
                // Danh sách các cột mốc nộp báo cáo tiến độ đồ án (TC_STU_025)
                ..._milestones.map((milestone) {
                  final mWeek = milestone['tuan'] as int;
                  final mDeadline = milestone['deadline'] as String;
                  final mTitle = milestone['tieuDe'] as String;

                  final report = _reports.where((r) => r['tuanBaoCao'] == mWeek).firstOrNull;

                  if (report != null) {
                    return _buildReportCard(report, colors, mDeadline);
                  }

                  // Cột mốc chưa nộp báo cáo
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
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
                                  color: Colors.grey.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Tuần $mWeek',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14, color: Colors.orange.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Hạn chót (Deadline): $mDeadline',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Text(
                                  'Chưa nộp',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            mTitle,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có báo cáo nào được nộp cho mốc này.',
                            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _openSubmitDialog(mWeek),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.upload_file_rounded, size: 16),
                            label: const Text('Nộp báo cáo mốc này', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Các báo cáo phát sinh ở các tuần khác ngoài các mốc định sẵn
                ..._reports
                    .where((r) => !_milestones.any((m) => m['tuan'] == r['tuanBaoCao']))
                    .map((report) => _buildReportCard(report, colors, _getDeadlineForWeek(report['tuanBaoCao'] ?? 1))),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, ColorScheme colors, String deadline) {
    var status = report['trangThai']?.toString() ?? 'Đã nộp';
    if (report['diem'] != null || report['nhanXetGiangVien'] != null || status == 'Đã chấm') {
      if (status == 'Đã nộp') status = 'Đã chấm';
    }
    final statusColor = _getStatusColor(status);
    final week = report['tuanBaoCao'] ?? 1;
    final title = report['tieuDe'] ?? 'Báo cáo';
    final content = report['noiDung']?.toString() ?? '';
    final github = report['githubUrl']?.toString();
    final file = report['fileUrl']?.toString();
    final demo = report['demoUrl']?.toString();
    final feedback = report['nhanXetGiangVien']?.toString();
    final score = report['diem'];
    final lecturer = report['tenGiangVien']?.toString() ?? 'Giảng viên';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Tuần $week',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Hạn chót (Deadline): $deadline',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
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
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                content,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13.5),
              ),
            ],

            // Attachment Links
            if ((github != null && github.isNotEmpty) ||
                (file != null && file.isNotEmpty) ||
                (demo != null && demo.isNotEmpty)) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (github != null && github.isNotEmpty)
                    ActionChip(
                      avatar: const Icon(Icons.code_rounded, size: 16, color: Color(0xFF2563EB)),
                      label: const Text('GitHub', style: TextStyle(fontSize: 12)),
                      onPressed: () {},
                    ),
                  if (file != null && file.isNotEmpty)
                    ActionChip(
                      avatar: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Colors.red),
                      label: const Text('Tài liệu PDF', style: TextStyle(fontSize: 12)),
                      onPressed: () {},
                    ),
                  if (demo != null && demo.isNotEmpty)
                    ActionChip(
                      avatar: const Icon(Icons.play_circle_fill_rounded, size: 16, color: Colors.purple),
                      label: const Text('Demo / Video', style: TextStyle(fontSize: 12)),
                      onPressed: () {},
                    ),
                ],
              ),
            ],

            // Lecturer Review & Grade Box
            if ((feedback != null && feedback.isNotEmpty) || score != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rate_review_rounded, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Nhận xét từ $lecturer:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        const Spacer(),
                        if (score != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$score / 10',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (feedback != null && feedback.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        feedback,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF047857)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
