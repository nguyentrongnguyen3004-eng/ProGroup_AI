import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/lecturer_topic_proposal_model.dart';
import '../../../services/lecturer_api_service.dart';
=======
import '../../../models/topic_model.dart';
import '../../../services/topic_service.dart';
>>>>>>> origin/Frontend

class LecturerTopicProposalScreen extends StatefulWidget {
  const LecturerTopicProposalScreen({super.key});

  @override
  State<LecturerTopicProposalScreen> createState() =>
      _LecturerTopicProposalScreenState();
}

class _LecturerTopicProposalScreenState
    extends State<LecturerTopicProposalScreen> {
  String _status = 'Tất cả';
  bool _isLoading = true;
<<<<<<< HEAD
  String? _errorMessage;
  List<LecturerTopicProposalModel> _proposals = [];
  List<LecturerCourseModel> _courses = [];

  static const _filterOptions = ['Tất cả', 'Chờ duyệt', 'Đã duyệt', 'Đã từ chối'];
=======
  List<TopicModel> _studentTopics = [];
>>>>>>> origin/Frontend

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        LecturerApiService.instance.fetchTopicProposals(),
        LecturerApiService.instance.fetchCourses(),
      ]);

      if (mounted) {
        setState(() {
          _proposals = results[0] as List<LecturerTopicProposalModel>;
          _courses = results[1] as List<LecturerCourseModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  LecturerCourseModel? _findCourse(int courseId) {
    for (final c in _courses) {
      if (c.courseId == courseId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredProposals = _proposals
        .where((item) => _status == 'Tất cả' || item.status == _status)
        .toList();

    final pendingCount = _proposals
        .where((item) => item.status == 'Chờ duyệt')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Đề xuất đề tài', en: 'Topic Proposals'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$pendingCount ${AppLocalizations.text('chờ xử lý', en: 'pending')}',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_proposals.length} ${AppLocalizations.text('tổng số đề xuất', en: 'total proposals')}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final opt = _filterOptions[index];
                  final isSelected = _status == opt;
                  final count = opt == 'Tất cả'
                      ? _proposals.length
                      : _proposals.where((p) => p.status == opt).length;

                  return FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Text(
                      '${AppLocalizations.status(opt)} ($count)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    onSelected: (_) => setState(() => _status = opt),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _buildBody(colors, filteredProposals),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ColorScheme colors,
    List<LecturerTopicProposalModel> filteredProposals,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.text('Thử lại', en: 'Retry')),
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

    if (filteredProposals.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.text(
                          'Không có đề xuất phù hợp.',
                          en: 'No matching proposals found.',
                        ),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
        itemCount: filteredProposals.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final proposal = filteredProposals[index];
          final course = _findCourse(proposal.courseId);
          return _ProposalCard(
            proposal: proposal,
            courseName: course?.name,
            classCode: course?.classCode,
            onTap: () => _showDetails(context, proposal, course),
          );
        },
      ),
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    LecturerTopicProposalModel proposal,
    LecturerCourseModel? course,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _ProposalDetailsSheet(
        proposal: proposal,
        courseName: course?.name,
        onApprove: () => _approve(sheetContext, proposal),
        onReject: () => _reject(sheetContext, proposal),
      ),
    );
  }

  Future<void> _approve(
    BuildContext sheetContext,
    LecturerTopicProposalModel proposal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.text('Duyệt đề xuất?', en: 'Approve proposal?')),
        content: Text(
          '${AppLocalizations.text('Đề tài', en: 'Topic')} "${proposal.title}" ${AppLocalizations.text('sẽ được thêm vào danh sách đề tài chính thức của lớp.', en: 'will be added to official course topics.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppLocalizations.text('Duyệt đề xuất', en: 'Approve')),
          ),
        ],
      ),
    );

    if (confirmed != true || !sheetContext.mounted) return;

    try {
      await LecturerApiService.instance.approveTopicProposal(proposal.id, true);
      if (!mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Đã duyệt đề xuất đề tài.',
              en: 'Topic proposal approved.',
            ),
          ),
        ),
      );
      _loadData();
    } catch (e) {
      if (!sheetContext.mounted) return;
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reject(
    BuildContext sheetContext,
    LecturerTopicProposalModel proposal,
  ) async {
    final reason = await showDialog<String>(
      context: sheetContext,
      builder: (_) => const _RejectionReasonDialog(),
    );
    if (reason == null || !sheetContext.mounted) return;

    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.text('Xác nhận từ chối?', en: 'Confirm Rejection?')),
        content: Text('${AppLocalizations.text('Lý do', en: 'Reason')}: $reason'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.text('Quay lại', en: 'Back')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppLocalizations.text('Xác nhận từ chối', en: 'Confirm')),
          ),
        ],
      ),
    );

    if (confirmed != true || !sheetContext.mounted) return;

    try {
      await LecturerApiService.instance.approveTopicProposal(proposal.id, false, lyDo: reason);
      if (!mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Đã từ chối đề xuất đề tài.',
              en: 'Topic proposal rejected.',
            ),
          ),
        ),
      );
      _loadData();
    } catch (e) {
      if (!sheetContext.mounted) return;
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _ProposalCard extends StatelessWidget {
  final LecturerTopicProposalModel proposal;
  final String? courseName;
  final String? classCode;
  final VoidCallback onTap;

  const _ProposalCard({
    required this.proposal,
    required this.courseName,
    required this.classCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPending = proposal.status == 'Chờ duyệt';
    final isApproved = proposal.status == 'Đã duyệt';

    final Color statusColor = isApproved
        ? AppTheme.successColor
        : isPending
        ? AppTheme.warningColor
        : AppTheme.dangerColor;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isApproved
                          ? Icons.check_circle_rounded
                          : isPending
                          ? Icons.lightbulb_rounded
                          : Icons.cancel_rounded,
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proposal.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${proposal.groupName.isNotEmpty ? proposal.groupName : 'Nhóm sinh viên'} • ${classCode ?? AppLocalizations.text('Không rõ lớp', en: 'Unknown class')}',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: proposal.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            proposal.proposerName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(proposal.createdAt),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RejectionReasonDialog extends StatefulWidget {
  const _RejectionReasonDialog();

  @override
  State<_RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<_RejectionReasonDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(AppLocalizations.text('Từ chối đề xuất', en: 'Reject Proposal')),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: AppLocalizations.text('Lý do từ chối', en: 'Rejection reason'),
          errorText: _error,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              setState(() => _error = AppLocalizations.text('Vui lòng nhập lý do từ chối.', en: 'Please enter a rejection reason.'));
            } else {
              Navigator.pop(context, reason);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.dangerColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(AppLocalizations.text('Tiếp tục', en: 'Continue')),
        ),
      ],
    );
  }
}

class _ProposalDetailsSheet extends StatelessWidget {
  final LecturerTopicProposalModel proposal;
  final String? courseName;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ProposalDetailsSheet({
    required this.proposal,
    required this.courseName,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      proposal.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: proposal.status),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: AppLocalizations.text('Lớp học phần', en: 'Course'),
                      value: courseName ?? AppLocalizations.text('Không rõ lớp', en: 'Unknown'),
                    ),
                    _DetailRow(
                      label: AppLocalizations.text('Nhóm đề xuất', en: 'Group'),
                      value: proposal.groupName.isNotEmpty ? proposal.groupName : 'Chưa có nhóm',
                    ),
                    _DetailRow(
                      label: AppLocalizations.text('Người gửi', en: 'Proposer'),
                      value: proposal.proposerName,
                    ),
                    _DetailRow(
                      label: AppLocalizations.text('Ngày gửi', en: 'Date'),
                      value: _formatDate(proposal.createdAt),
                    ),
                  ],
                ),
              ),
              _DetailText(title: AppLocalizations.text('Mô tả', en: 'Description'), value: proposal.description),
              _DetailText(title: AppLocalizations.text('Mục tiêu', en: 'Objective'), value: proposal.objective),
              _DetailText(title: AppLocalizations.text('Phạm vi', en: 'Scope'), value: proposal.scope),
              _DetailText(title: AppLocalizations.text('Công nghệ', en: 'Technology'), value: proposal.technology),
              _DetailText(title: AppLocalizations.text('Nguồn đề tài', en: 'Source'), value: proposal.source),
              if (proposal.decisionReason?.isNotEmpty == true)
                _DetailText(
                  title: AppLocalizations.text('Lý do từ chối', en: 'Rejection Reason'),
                  value: proposal.decisionReason!,
                  isAlert: true,
                ),
              if (proposal.status == 'Chờ duyệt') ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      AppLocalizations.text('Duyệt và thêm vào đề tài', en: 'Approve and add to topics'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      AppLocalizations.text('Từ chối đề xuất', en: 'Reject proposal'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dangerColor,
                      side: const BorderSide(color: AppTheme.dangerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
=======
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoading = true);
    try {
      final topics = await TopicService().getLecturerTopics();
      if (mounted) {
        setState(() {
          _studentTopics = topics.where((t) => t.source.toLowerCase().contains('sinh viên')).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đề xuất đề tài của sinh viên')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _studentTopics.where((item) {
      if (_status == 'Tất cả') return true;
      return item.status == _status;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề xuất đề tài của sinh viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProposals,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              children: [
                Expanded(child: Text('${filtered.length} đề xuất')),
                DropdownButton<String>(
                  value: _status,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả')),
                    DropdownMenuItem(value: 'Chờ duyệt', child: Text('Chờ duyệt')),
                    DropdownMenuItem(value: 'Đã duyệt', child: Text('Đã duyệt')),
                    DropdownMenuItem(value: 'Từ chối', child: Text('Từ chối')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
>>>>>>> origin/Frontend
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không có đề xuất nào.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.lightbulb_outline),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('Lĩnh vực/Công nghệ: ${item.technology}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.status,
                              style: const TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
<<<<<<< HEAD

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DetailText extends StatelessWidget {
  final String title;
  final String value;
  final bool isAlert;

  const _DetailText({
    required this.title,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isAlert ? AppTheme.dangerColor : colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? AppLocalizations.text('Chưa có thông tin.', en: 'No information.') : value,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isAlert ? AppTheme.dangerColor : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'Đã duyệt'
        ? AppTheme.successColor
        : status == 'Chờ duyệt'
        ? AppTheme.warningColor
        : AppTheme.dangerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        AppLocalizations.status(status),
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
=======
>>>>>>> origin/Frontend
