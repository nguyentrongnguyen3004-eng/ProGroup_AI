import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/group_invitation_model.dart';
import '../../../services/student_api_service.dart';

class InvitationManagementScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const InvitationManagementScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<InvitationManagementScreen> createState() =>
      _InvitationManagementScreenState();
}

class _InvitationManagementScreenState
    extends State<InvitationManagementScreen> {
  List<GroupInvitationModel> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoading = true);
    try {
      final list = await StudentApiService.instance.fetchGroupInvitations(widget.groupId);
      if (!mounted) return;
      setState(() {
        _invitations = list.map((e) => GroupInvitationModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Không thể tải danh sách lời mời: $e');
    }
  }

  int get pendingCount {
    return _invitations.where((item) => item.status == 'Chờ xử lý').length;
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

  void _showInviteDialog() {
    final mssvController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(AppLocalizations.text('Mời thành viên mới', en: 'Invite Member')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mssvController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.text('Mã số sinh viên (MSSV)', en: 'Student ID'),
                  prefixIcon: const Icon(Icons.badge_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final mssv = mssvController.text.trim();
                if (mssv.isEmpty) {
                  _showMessage('Vui lòng nhập MSSV của sinh viên.');
                  return;
                }

                Navigator.pop(dialogContext);
                try {
                  await StudentApiService.instance.inviteMember(
                    nhomId: widget.groupId,
                    mssv: mssv,
                  );
                  _showMessage('Đã gửi lời mời tham gia nhóm tới sinh viên MSSV $mssv.');
                  _loadInvitations();
                } catch (e) {
                  _showMessage('Lỗi: $e');
                }
              },
              child: Text(AppLocalizations.text('Gửi lời mời', en: 'Send Invitation')),
            ),
          ],
        );
      },
    );
  }

  void _cancelInvitation(GroupInvitationModel invitation) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(AppLocalizations.text('Hủy lời mời', en: 'Cancel Invitation')),
          content: Text('Bạn có chắc muốn hủy lời mời gửi tới ${invitation.inviteeName.isNotEmpty ? invitation.inviteeName : invitation.inviteeMssv}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.text('Không', en: 'No')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await StudentApiService.instance.cancelInvitation(
                    nhomId: widget.groupId,
                    invitationId: invitation.id,
                  );
                  _showMessage('Đã hủy lời mời.');
                  _loadInvitations();
                } catch (e) {
                  _showMessage('Lỗi: $e');
                }
              },
              child: Text(AppLocalizations.text('Hủy lời mời', en: 'Cancel')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = _invitations;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Quản lý lời mời', en: 'Manage Invitations'),
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
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
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
                      Icons.mark_email_unread_rounded,
                      color: Colors.white,
                      size: 24,
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
                              ? 'Không có lời mời nào đang chờ phản hồi.'
                              : '$pendingCount lời mời đang chờ phản hồi.',
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
                        child: Icon(Icons.mail_outline_rounded, size: 28, color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có lời mời nào được gửi.',
                        style: TextStyle(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...items.map((invitation) => _buildInvitationCard(colors, invitation)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInviteDialog,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(
          AppLocalizations.text('Mời thành viên', en: 'Invite Member'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildInvitationCard(ColorScheme colors, GroupInvitationModel invitation) {
    final isPending = invitation.status == 'Chờ xử lý';
    final isAccepted = invitation.status == 'Đã chấp nhận';

    final statusBgColor = isAccepted
        ? const Color(0xFF10B981).withValues(alpha: 0.12)
        : isPending
            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.12);

    final statusTextColor = isAccepted
        ? const Color(0xFF059669)
        : isPending
            ? const Color(0xFFD97706)
            : Colors.grey.shade700;

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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    invitation.inviteeName.isNotEmpty
                        ? invitation.inviteeName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
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
                      invitation.inviteeName,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MSSV: ${invitation.inviteeMssv}',
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
                  invitation.status,
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
          Text(
            'Người gửi lời mời: ${invitation.inviter}',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _cancelInvitation(invitation),
                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                label: const Text(
                  'Hủy lời mời',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
