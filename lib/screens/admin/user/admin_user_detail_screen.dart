import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../admin/admin_helpers.dart';
import 'admin_user_form_screen.dart';

class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({
    super.key,
    required this.accountId,
    required this.currentAdminId,
  });

  final int accountId;
  final int currentAdminId;

  Future<void> _delete(BuildContext context) async {
    final account = MockAdminData.instance.accountById(accountId);
    if (account == null || accountId == currentAdminId) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(adminText('Xóa tài khoản', 'Delete account')),
        content: Text(
          adminText(
            'Bạn có chắc muốn xóa tài khoản này?',
            'Are you sure you want to delete this account?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(adminText('Hủy', 'Cancel')),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: Text(adminText('Xóa', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (MockAdminData.instance.deleteAccount(
      accountId,
      currentAdminId: currentAdminId,
    )) {
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _toggleLock(BuildContext context, bool locked) async {
    final account = MockAdminData.instance.accountById(accountId);
    if (account == null || accountId == currentAdminId) return;
    if (locked) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(adminText('Khóa tài khoản', 'Lock account')),
          content: Text(
            '${adminText('Bạn có chắc muốn khóa tài khoản', 'Lock this account')}: ${account.username}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(adminText('Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(adminText('Khóa', 'Lock')),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    final changed = MockAdminData.instance.setAccountLocked(
      accountId,
      locked: locked,
      currentAdminId: currentAdminId,
    );
    if (changed && context.mounted) {
      showAdminMessage(
        context,
        locked ? 'Đã khóa tài khoản.' : 'Đã mở khóa tài khoản.',
        locked ? 'Account locked.' : 'Account unlocked.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: MockAdminData.instance,
    builder: (context, _) {
      final account = MockAdminData.instance.accountById(accountId);
      if (account == null) {
        return Scaffold(
          appBar: AppBar(),
          body: adminEmptyState(
            context,
            'Tài khoản không còn tồn tại.',
            'This account no longer exists.',
          ),
        );
      }
      final isSelf = accountId == currentAdminId;
      final isLocked = account.status == MockAdminData.lockedStatus;
      return Scaffold(
        appBar: AppBar(
          title: Text(adminText('Chi tiết người dùng', 'User details')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    adminAvatar(context, account, radius: 42),
                    const SizedBox(height: 14),
                    Text(
                      account.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    Text(adminRoleText(account.role)),
                    const SizedBox(height: 8),
                    Chip(label: Text(adminStatusText(account.status))),
                  ],
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  _InfoTile(
                    label: adminText('Mã người dùng', 'User code'),
                    value: account.userCode,
                  ),
                  _InfoTile(label: 'Username', value: account.username),
                  _InfoTile(
                    label: adminText('Email', 'Email'),
                    value: account.email,
                  ),
                  _InfoTile(
                    label: adminText('Số điện thoại', 'Phone'),
                    value: account.phone.isEmpty ? '—' : account.phone,
                  ),
                  _InfoTile(
                    label: adminText('Ngày tạo', 'Created'),
                    value: account.createdAt == null
                        ? '—'
                        : adminDateTime(account.createdAt!),
                  ),
                  _InfoTile(
                    label: adminText('Hoạt động', 'Activity'),
                    value: MockAdminData.instance.activities
                        .where((item) => item.target == account.fullName)
                        .length
                        .toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () async {
                final saved = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminUserFormScreen(
                      account: account,
                      currentAdminId: currentAdminId,
                    ),
                  ),
                );
                if (saved == true && context.mounted) {
                  showAdminMessage(
                    context,
                    'Đã cập nhật tài khoản.',
                    'Account updated.',
                  );
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: Text(adminText('Chỉnh sửa', 'Edit')),
            ),
            OutlinedButton.icon(
              onPressed: isSelf ? null : () => _toggleLock(context, !isLocked),
              icon: Icon(
                isLocked ? Icons.lock_open_outlined : Icons.lock_outline,
              ),
              label: Text(
                adminText(
                  isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                  isLocked ? 'Unlock account' : 'Lock account',
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: isSelf ? null : () => _delete(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline),
              label: Text(adminText('Xóa tài khoản', 'Delete account')),
            ),
            if (isSelf)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  adminText(
                    'Không thể khóa hoặc xóa tài khoản Admin đang đăng nhập.',
                    'The signed-in Admin account cannot be locked or deleted.',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) =>
      ListTile(title: Text(label), subtitle: Text(value));
}
