import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_notifications.dart';
import '../../../data/mock/mock_lecturer_topic_proposals.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/lecturer_topic_proposal_model.dart';
import '../../../models/topic_model.dart';

class LecturerTopicProposalScreen extends StatefulWidget {
  const LecturerTopicProposalScreen({super.key});

  @override
  State<LecturerTopicProposalScreen> createState() =>
      _LecturerTopicProposalScreenState();
}

class _LecturerTopicProposalScreenState
    extends State<LecturerTopicProposalScreen> {
  String _status = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final store = MockLecturerTopicProposals.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final proposals = store.proposals
            .where((item) => _status == 'Tất cả' || item.status == _status)
            .toList();
        final pending = store.proposals
            .where((item) => item.status == 'Chờ duyệt')
            .length;
        return Scaffold(
          appBar: AppBar(title: const Text('Đề xuất đề tài')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    Expanded(child: Text('$pending đề xuất đang chờ xử lý')),
                    DropdownButton<String>(
                      value: _status,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: 'Tất cả',
                          child: Text('Tất cả'),
                        ),
                        DropdownMenuItem(
                          value: 'Chờ duyệt',
                          child: Text('Chờ duyệt'),
                        ),
                        DropdownMenuItem(
                          value: 'Đã duyệt',
                          child: Text('Đã duyệt'),
                        ),
                        DropdownMenuItem(
                          value: 'Đã từ chối',
                          child: Text('Đã từ chối'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: proposals.isEmpty
                    ? const Center(child: Text('Không có đề xuất phù hợp.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: proposals.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final proposal = proposals[index];
                          final course = MockLecturerCourses.getByCourseId(
                            proposal.courseId,
                          );
                          return Card(
                            child: ListTile(
                              onTap: () => _showDetails(context, proposal),
                              leading: const CircleAvatar(
                                child: Icon(Icons.lightbulb_outline),
                              ),
                              title: Text(
                                proposal.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                proposal.groupName +
                                    ' • ' +
                                    (course?.classCode ?? 'Không rõ lớp'),
                              ),
                              trailing: _StatusBadge(status: proposal.status),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    LecturerTopicProposalModel proposal,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ProposalDetailsSheet(
        proposal: proposal,
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
        title: const Text('Duyệt đề xuất?'),
        content: Text(
          'Đề tài "' +
              proposal.title +
              '" sẽ được thêm vào danh sách đề tài chính thức của lớp.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Duyệt đề xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true || !sheetContext.mounted) return;
    final course = MockLecturerCourses.getByCourseId(proposal.courseId);
    if (course == null ||
        MockLecturerTopicProposals.instance.getById(proposal.id)?.status !=
            'Chờ duyệt') {
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        const SnackBar(content: Text('Đề xuất không còn chờ xử lý.')),
      );
      return;
    }
    final alreadyExists = MockLecturerTopics.topics.any(
      (topic) =>
          topic.courseId == proposal.courseId &&
          topic.title.trim().toLowerCase() ==
              proposal.title.trim().toLowerCase(),
    );
    if (!alreadyExists) {
      final id =
          MockLecturerTopics.topics.fold<int>(
            0,
            (maximum, topic) => topic.id > maximum ? topic.id : maximum,
          ) +
          1;
      MockLecturerTopics.add(
        TopicModel(
          id: id,
          courseId: proposal.courseId,
          title: proposal.title,
          description: proposal.description,
          objective: proposal.objective,
          scope: proposal.scope,
          technology: proposal.technology,
          source: proposal.source,
          status: 'Đang hoạt động',
        ),
      );
    }
    MockLecturerTopicProposals.instance.decide(proposal.id, 'Đã duyệt');
    MockLecturerNotifications.instance.addNotification(
      type: 'Đề xuất',
      icon: Icons.check_circle_outline,
      title: 'Đã duyệt đề xuất đề tài',
      content: alreadyExists
          ? 'Đề tài "' + proposal.title + '" đã có sẵn trong ' + course.name
          : 'Đề tài "' + proposal.title + '" đã được thêm vào ' + course.name,
    );
    Navigator.of(sheetContext).pop();
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
        title: const Text('Xác nhận từ chối?'),
        content: Text('Lý do: ' + reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
    if (confirmed != true || !sheetContext.mounted) return;
    if (MockLecturerTopicProposals.instance.getById(proposal.id)?.status !=
        'Chờ duyệt') {
      return;
    }
    MockLecturerTopicProposals.instance.decide(
      proposal.id,
      'Đã từ chối',
      decisionReason: reason,
    );
    MockLecturerNotifications.instance.addNotification(
      type: 'Đề xuất',
      icon: Icons.cancel_outlined,
      title: 'Đã từ chối đề xuất đề tài',
      content: 'Đề xuất "' + proposal.title + '" đã được cập nhật.',
    );
    Navigator.of(sheetContext).pop();
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
      title: const Text('Từ chối đề xuất'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Lý do từ chối',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              setState(() => _error = 'Vui lòng nhập lý do từ chối.');
            } else {
              Navigator.pop(context, reason);
            }
          },
          child: const Text('Tiếp tục'),
        ),
      ],
    );
  }
}

class _ProposalDetailsSheet extends StatelessWidget {
  final LecturerTopicProposalModel proposal;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ProposalDetailsSheet({
    required this.proposal,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final course = MockLecturerCourses.getByCourseId(proposal.courseId);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                proposal.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              _DetailRow(label: 'Trạng thái', value: proposal.status),
              _DetailRow(label: 'Lớp', value: course?.name ?? 'Không rõ lớp'),
              _DetailRow(label: 'Nhóm', value: proposal.groupName),
              _DetailRow(label: 'Người đề xuất', value: proposal.proposerName),
              _DetailRow(
                label: 'Ngày gửi',
                value: _formatDate(proposal.createdAt),
              ),
              _DetailText(title: 'Mô tả', value: proposal.description),
              _DetailText(title: 'Mục tiêu', value: proposal.objective),
              _DetailText(title: 'Phạm vi', value: proposal.scope),
              _DetailText(title: 'Công nghệ', value: proposal.technology),
              _DetailText(title: 'Nguồn', value: proposal.source),
              if (proposal.decisionReason?.isNotEmpty == true)
                _DetailText(
                  title: 'Lý do từ chối',
                  value: proposal.decisionReason!,
                ),
              if (proposal.status == 'Chờ duyệt') ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Duyệt và thêm vào đề tài'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Từ chối đề xuất'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.dangerColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(label + ': ' + value),
  );
}

class _DetailText extends StatelessWidget {
  final String title;
  final String value;

  const _DetailText({required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(value.isEmpty ? 'Chưa có thông tin.' : value),
      ],
    ),
  );
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) =>
    value.day.toString().padLeft(2, '0') +
    '/' +
    value.month.toString().padLeft(2, '0') +
    '/' +
    value.year.toString();
