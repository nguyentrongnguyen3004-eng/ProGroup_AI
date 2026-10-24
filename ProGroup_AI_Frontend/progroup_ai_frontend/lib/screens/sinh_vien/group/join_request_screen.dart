import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/group_join_request_model.dart';
import '../../../services/student_api_service.dart';

class JoinRequestScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const JoinRequestScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<JoinRequestScreen> createState() => _JoinRequestScreenState();
}

class _JoinRequestScreenState extends State<JoinRequestScreen> {
  List<GroupJoinRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final list = await StudentApiService.instance.fetchGroupJoinRequests(widget.groupId);
      if (!mounted) return;
      setState(() {
        _requests = list.map((e) => GroupJoinRequestModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Không thể tải yêu cầu: $e');
    }
  }

  int get pendingCount {
    return _requests.where((item) => item.status == 'Chờ duyệt').length;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  Future<void> _approveRequest(GroupJoinRequestModel request) async {
    try {
      await StudentApiService.instance.respondJoinRequest(
        nhomId: widget.groupId,
        requestId: request.id,
        accept: true,
      );
      _showMessage('Đã duyệt yêu cầu! ${request.studentName} đã trở thành thành viên của nhóm.');
      _loadRequests();
    } catch (e) {
      _showMessage('Lỗi: $e');
    }
  }

  Future<void> _rejectRequest(GroupJoinRequestModel request) async {
    try {
      await StudentApiService.instance.respondJoinRequest(
        nhomId: widget.groupId,
        requestId: request.id,
        accept: false,
      );
      _showMessage('Đã từ chối yêu cầu tham gia của ${request.studentName}.');
      _loadRequests();
    } catch (e) {
      _showMessage('Lỗi: $e');
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute, $day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = _requests;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Duyệt yêu cầu tham gia', en: 'Join Requests'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 72),
                children: [
            // ======================================================
            // HERO HEADER
            // ======================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.how_to_reg_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.groupName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          pendingCount == 0
                              ? 'Không có yêu cầu nào đang chờ duyệt.'
                              : '$pendingCount sinh viên đang chờ duyệt vào nhóm.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.people_outline_rounded, size: 28, color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có yêu cầu tham gia nào.',
                        style: TextStyle(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...items.map((request) => _buildRequestCard(colors, request)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(ColorScheme colors, GroupJoinRequestModel request) {
    final isPending = request.status == 'Chờ duyệt';
    final isApproved = request.status == 'Đã chấp nhận';

    final statusBgColor = isApproved
        ? const Color(0xFF10B981).withValues(alpha: 0.12)
        : isPending
            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12);

    final statusTextColor = isApproved
        ? const Color(0xFF059669)
        : isPending
            ? const Color(0xFFD97706)
            : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    request.studentName.isNotEmpty
                        ? request.studentName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.studentName,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MSSV: ${request.studentMssv}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.email_outlined, size: 14, color: colors.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.studentEmail,
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatDate(request.createdAt),
                style: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 11),
              ),
            ],
          ),

          // ACTIONS KHI ĐANG CHỜ DUYỆT
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectRequest(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 17),
                    label: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _approveRequest(request),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 17),
                    label: const Text('Duyệt tham gia', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
