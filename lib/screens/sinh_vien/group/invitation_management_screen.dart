import 'package:flutter/material.dart';

import '../../../data/mock/mock_group_invitations.dart';
import '../../../models/group_invitation_model.dart';

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
  List<GroupInvitationModel> get invitations {
    return MockGroupInvitations.invitations
        .where((item) => item.groupId == widget.groupId)
        .toList()
        .reversed
        .toList();
  }

  int get pendingCount {
    return invitations.where((item) => item.status == 'Chờ xử lý').length;
  }

  @override
  Widget build(BuildContext context) {
    final items = invitations;

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý lời mời')),
      body: items.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                ...items.map(_buildInvitationCard),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInviteDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Mời thành viên'),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              child: Icon(
                Icons.mark_email_unread_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    pendingCount == 0
                        ? 'Không có lời mời đang chờ.'
                        : '$pendingCount lời mời đang chờ xử lý.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationCard(GroupInvitationModel invitation) {
    final isPending = invitation.status == 'Chờ xử lý';

    final isAccepted = invitation.status == 'Đã chấp nhận';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    invitation.inviteeName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.inviteeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MSSV: ${invitation.inviteeMssv}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(invitation.status),
              ],
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Người mời: ${invitation.inviter}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),

            const SizedBox(height: 4),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _formatDate(invitation.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),

            if (isPending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _cancelInvitation(invitation);
                      },
                      child: const Text('Hủy lời mời'),
                    ),
                  ),
                ],
              ),
            ],

            if (isAccepted) ...[
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sinh viên đã chấp nhận lời mời.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;

    switch (status) {
      case 'Đã chấp nhận':
        color = Colors.green;
        break;
      case 'Đã từ chối':
        color = Colors.red;
        break;
      case 'Đã hủy':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Chưa có lời mời',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có thể mời sinh viên bằng MSSV.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog() {
    final nameController = TextEditingController();

    final mssvController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mời thành viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  hintText: 'Nguyễn Văn A',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mssvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'MSSV',
                  hintText: '22110010',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();

                final mssv = mssvController.text.trim();

                if (name.isEmpty || mssv.isEmpty) {
                  return;
                }

                final exists = MockGroupInvitations.invitations.any(
                  (item) =>
                      item.groupId == widget.groupId &&
                      item.inviteeMssv == mssv &&
                      item.status == 'Chờ xử lý',
                );

                if (exists) {
                  Navigator.pop(dialogContext);

                  _showMessage('Sinh viên này đã có lời mời đang chờ.');

                  return;
                }

                MockGroupInvitations.add(
                  GroupInvitationModel(
                    id: MockGroupInvitations.generateId(),
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    inviter: 'Nguyễn Văn An',
                    inviteeName: name,
                    inviteeMssv: mssv,
                    status: 'Chờ xử lý',
                    createdAt: DateTime.now(),
                  ),
                );

                Navigator.pop(dialogContext);

                setState(() {});

                _showMessage('Đã gửi lời mời đến $name.');
              },
              child: const Text('Gửi lời mời'),
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
          title: const Text('Hủy lời mời?'),
          content: Text(
            'Bạn có chắc muốn hủy lời mời gửi cho ${invitation.inviteeName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () {
                invitation.status = 'Đã hủy';

                Navigator.pop(dialogContext);

                setState(() {});

                _showMessage('Đã hủy lời mời.');
              },
              child: const Text('Hủy lời mời'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} • $hour:$minute';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
