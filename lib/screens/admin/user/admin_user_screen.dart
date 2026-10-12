import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/admin_service.dart';

class AdminUserScreen extends StatefulWidget {
  final int? currentAdminId;
  const AdminUserScreen({super.key, this.currentAdminId});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  String _selectedRole = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await AdminService().getUsers();
      if (mounted) {
        setState(() {
          _users = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _toggleUserStatus(int id, bool currentStatus, String name) async {
    final nextStatus = !currentStatus;
    final actionText = nextStatus ? 'Mở khóa' : 'Khóa';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionText tài khoản'),
        content: Text('Bạn có chắc chắn muốn $actionText tài khoản của $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: nextStatus ? Colors.green : Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService().updateUserStatus(id, nextStatus);
        _fetchUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Đã $actionText tài khoản thành công!'),
            backgroundColor: nextStatus ? Colors.green : Colors.orange,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((u) {
      if (_selectedRole != 'Tất cả' && u['role'] != _selectedRole) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (u['hoTen'] ?? '').toString().toLowerCase();
        final username = (u['tenDangNhap'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        if (!name.contains(query) && !username.contains(query) && !email.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final users = _filteredUsers;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Quản Lý Người Dùng', en: 'User Management')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, username, email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Tất cả', 'ADMIN', 'GIANGVIEN', 'SINHVIEN', 'GIAOVUKHOA', 'PHONGDAOTAO'].map((role) {
                final isSelected = _selectedRole == role;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(role),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedRole = role);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? Center(
                        child: Text(
                          'Không có người dùng nào phù hợp.',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final id = user['nguoiDungId'] as int;
                          final hoTen = user['hoTen'] as String? ?? '';
                          final username = user['tenDangNhap'] as String? ?? '';
                          final email = user['email'] as String? ?? '';
                          final roleName = user['roleName'] as String? ?? user['role'] ?? '';
                          final isActive = user['trangThai'] as bool? ?? true;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colors.primaryContainer,
                                child: Text(
                                  hoTen.isNotEmpty ? hoTen[0].toUpperCase() : 'U',
                                  style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(hoTen, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$username • $email'),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      roleName,
                                      style: TextStyle(fontSize: 11, color: colors.onSecondaryContainer),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isActive ? Icons.lock_open : Icons.lock,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                                tooltip: isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                                onPressed: () => _toggleUserStatus(id, isActive, hoTen),
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
