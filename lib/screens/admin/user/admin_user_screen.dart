import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../../models/admin_account_model.dart';
import '../../admin/admin_helpers.dart';
import '../activity/admin_activity_log_screen.dart';
import '../role/admin_role_screen.dart';
import 'admin_user_detail_screen.dart';
import 'admin_user_form_screen.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key, required this.currentAdminId});
  final int currentAdminId;

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  final _searchController = TextEditingController();
  String _role = 'Tất cả';
  String _status = 'Tất cả';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addAccount() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminUserFormScreen()),
    );
    if (saved == true && mounted) {
      showAdminMessage(context, 'Đã thêm tài khoản.', 'Account added.');
    }
  }

  Future<void> _openAccount(AdminAccountModel account) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUserDetailScreen(
          accountId: account.id,
          currentAdminId: widget.currentAdminId,
        ),
      ),
    );
    if (changed == true && mounted) {
      showAdminMessage(context, 'Đã xóa tài khoản.', 'Account deleted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = MockAdminData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final accounts = data.filterAccounts(
          query: _searchController.text,
          role: _role,
          status: _status,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(adminText('Quản lý người dùng', 'User management')),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => value == 'roles'
                        ? const AdminRoleScreen()
                        : const AdminActivityLogScreen(),
                  ),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'roles',
                    child: Text(
                      adminText('Quản lý vai trò', 'Role management'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'activity',
                    child: Text(adminText('Nhật ký hoạt động', 'Activity log')),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addAccount,
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(adminText('Thêm người dùng', 'Add user')),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: adminText(
                      'Tìm họ tên, username, email, mã...',
                      'Search name, username, email, code...',
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _role,
                        decoration: InputDecoration(
                          labelText: adminText('Vai trò', 'Role'),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Tất cả',
                            child: Text(
                              adminText('Tất cả vai trò', 'All roles'),
                            ),
                          ),
                          for (final role in MockAdminData.roles)
                            DropdownMenuItem<String>(
                              value: role,
                              child: Text(adminRoleText(role)),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _role = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: InputDecoration(
                          labelText: adminText('Trạng thái', 'Status'),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Tất cả',
                            child: Text(
                              adminText('Tất cả trạng thái', 'All statuses'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: MockAdminData.activeStatus,
                            child: Text(
                              adminStatusText(MockAdminData.activeStatus),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: MockAdminData.lockedStatus,
                            child: Text(
                              adminStatusText(MockAdminData.lockedStatus),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _status = value);
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: adminText('Đặt lại bộ lọc', 'Reset filters'),
                      onPressed: () => setState(() {
                        _role = 'Tất cả';
                        _status = 'Tất cả';
                        _searchController.clear();
                      }),
                      icon: const Icon(Icons.filter_alt_off_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: accounts.isEmpty
                    ? adminEmptyState(
                        context,
                        'Không tìm thấy tài khoản phù hợp.',
                        'No matching accounts found.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          final locked =
                              account.status == MockAdminData.lockedStatus;
                          return Card(
                            child: ListTile(
                              leading: adminAvatar(context, account),
                              title: Text(
                                account.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${account.username} · ${account.email}\n${account.userCode} · ${adminRoleText(account.role)}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              isThreeLine: true,
                              trailing: Chip(
                                avatar: Icon(
                                  locked
                                      ? Icons.lock_outline
                                      : Icons.check_circle_outline,
                                  size: 16,
                                ),
                                label: Text(adminStatusText(account.status)),
                                visualDensity: VisualDensity.compact,
                              ),
                              onTap: () => _openAccount(account),
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
}
