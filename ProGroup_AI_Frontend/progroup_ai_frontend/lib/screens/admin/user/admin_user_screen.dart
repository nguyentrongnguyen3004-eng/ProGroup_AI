import 'package:flutter/material.dart';

import '../../../services/admin_api_service.dart';
import '../../admin/admin_helpers.dart';
import 'admin_user_detail_screen.dart';
import 'admin_user_form_screen.dart';
import 'admin_user_import_screen.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key, required this.currentAdminId});
  final int currentAdminId;

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _users = [];
  String _selectedRole = 'all';
  String _statusFilter = 'all'; // all, active, locked

  final List<Map<String, String>> _roles = [
    {'code': 'all', 'label': 'Tất cả vai trò'},
    {'code': 'SINHVIEN', 'label': 'Sinh viên'},
    {'code': 'GIANGVIEN', 'label': 'Giảng viên'},
    {'code': 'GIAOVUKHOA', 'label': 'Giáo vụ khoa'},
    {'code': 'PHONGDAOTAO', 'label': 'Phòng Đào tạo'},
    {'code': 'ADMIN', 'label': 'Quản trị viên'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roleParam = _selectedRole == 'all' ? null : _selectedRole;
      final searchParam = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();
      final data = await AdminApiService.instance.fetchUsers(role: roleParam, search: searchParam);

      if (!mounted) return;
      setState(() {
        _users = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải danh sách người dùng: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> user) async {
    final id = user['nguoiDungId'] ?? user['NguoiDungId'] ?? user['id'];
    if (id == null) return;
    final int userId = id is int ? id : int.tryParse('$id') ?? 0;
    final currentStatus = user['trangThai'] == true;

    final actionText = currentStatus ? 'khóa' : 'kích hoạt';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xác nhận $actionText tài khoản?'),
        content: Text('Bạn có chắc chắn muốn $actionText tài khoản ${user['hoTen'] ?? user['tenDangNhap']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStatus ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(currentStatus ? 'Khóa' : 'Kích hoạt'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await AdminApiService.instance.toggleUserStatus(userId, currentStatus: currentStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái tài khoản.')),
      );
      _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final totalCount = _users.length;
    final activeCount = _users.where((u) => u['trangThai'] == true).length;
    final lockedCount = _users.where((u) => u['trangThai'] == false).length;

    final filteredUsers = _users.where((u) {
      if (_statusFilter == 'active') return u['trangThai'] == true;
      if (_statusFilter == 'locked') return u['trangThai'] == false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          adminText('Quản lý người dùng', 'User Management'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Nhập người dùng từ file',
            onPressed: () async {
              final imported = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AdminUserImportScreen()),
              );
              if (imported == true) _loadUsers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: _loadUsers,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'admin_import_fab',
            mini: true,
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 3,
            tooltip: 'Import file CSV / Excel',
            onPressed: () async {
              final imported = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AdminUserImportScreen()),
              );
              if (imported == true) _loadUsers();
            },
            child: const Icon(Icons.upload_file_rounded, size: 20),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'admin_add_user_fab',
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () async {
              final added = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AdminUserFormScreen()),
              );
              if (added == true) {
                _loadUsers();
              }
            },
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(adminText('Thêm người dùng', 'Add User')),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // ======================================================
            // 1. KPI 3-STATUS FILTER CARDS
            // ======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _KpiFilterPill(
                      label: 'Tất cả',
                      count: totalCount,
                      color: const Color(0xFF2563EB),
                      isSelected: _statusFilter == 'all',
                      onTap: () => setState(() => _statusFilter = 'all'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiFilterPill(
                      label: 'Hoạt động',
                      count: activeCount,
                      color: const Color(0xFF10B981),
                      isSelected: _statusFilter == 'active',
                      onTap: () => setState(() => _statusFilter = 'active'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiFilterPill(
                      label: 'Đã khóa',
                      count: lockedCount,
                      color: const Color(0xFFEF4444),
                      isSelected: _statusFilter == 'locked',
                      onTap: () => setState(() => _statusFilter = 'locked'),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // 2. SEARCH & ROLE DROPDOWN
            // ======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _loadUsers(),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB)),
                  hintText: adminText(
                    'Tìm theo họ tên, username, email...',
                    'Search name, username, email...',
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _loadUsers();
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Role Dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedRole,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary),
                    items: _roles.map((r) {
                      return DropdownMenuItem<String>(
                        value: r['code']!,
                        child: Text(
                          r['label']!,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRole = val);
                        _loadUsers();
                      }
                    },
                  ),
                ),
              ),
            ),

            // ======================================================
            // 3. USER LIST CONTENT
            // ======================================================
            Expanded(
              child: _buildListContent(filteredUsers, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(List<Map<String, dynamic>> filteredUsers, ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
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

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              adminText('Không tìm thấy người dùng phù hợp', 'No users found'),
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final u = filteredUsers[index];
          final name = u['hoTen'] ?? u['fullName'] ?? 'Người dùng';
          final username = u['tenDangNhap'] ?? u['username'] ?? '';
          final email = u['email'] ?? '';
          final role = (u['tenVaiTro'] ?? u['roleName'] ?? u['role'] ?? 'Sinh viên').toString();
          final bool isActive = u['trangThai'] == true;

          final Color roleColor = role.toUpperCase().contains('GIANGVIEN') || role.contains('Giảng viên')
              ? const Color(0xFF2563EB)
              : role.toUpperCase().contains('ADMIN') || role.contains('Quản trị')
                  ? const Color(0xFFEF4444)
                  : role.toUpperCase().contains('GIAOVU') || role.contains('Giáo vụ')
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF10B981);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminUserDetailScreen(user: u),
                    ),
                  );
                  _loadUsers();
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.person_rounded, color: roleColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@$username • $email',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: roleColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    role,
                                    style: TextStyle(fontSize: 10.5, color: roleColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                        : const Color(0xFFEF4444).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isActive ? 'Hoạt động' : 'Đã khóa',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? const Color(0xFF059669) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: isActive ? 'Khóa tài khoản' : 'Mở khóa',
                        icon: Icon(
                          isActive ? Icons.lock_open_rounded : Icons.lock_rounded,
                          color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        onPressed: () => _toggleStatus(u),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _KpiFilterPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _KpiFilterPill({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : colors.outlineVariant.withValues(alpha: 0.4),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
