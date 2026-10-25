import 'package:flutter/material.dart';

import '../../../services/admin_api_service.dart';
import '../../admin/admin_helpers.dart';

import '../../../services/auth_service.dart';

class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({
    super.key,
    this.accountId,
    this.currentAdminId,
    this.user,
  });

  final int? accountId;
  final int? currentAdminId;
  final Map<String, dynamic>? user;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userData = widget.user;
  }

  int get _effectiveAccountId =>
      widget.accountId ??
      int.tryParse('${widget.user?['nguoiDungId'] ?? widget.user?['NguoiDungId'] ?? widget.user?['id'] ?? 0}') ??
      0;

  int get _effectiveAdminId =>
      widget.currentAdminId ??
      int.tryParse('${AuthService.currentUser.id}') ??
      0;

  Future<void> _toggleLock(bool currentLocked) async {
    final isSelf = _effectiveAccountId == _effectiveAdminId;
    if (isSelf) return;

    setState(() => _isLoading = true);
    try {
      await AdminApiService.instance.toggleUserStatus(_effectiveAccountId, currentStatus: !currentLocked);
      if (!mounted) return;
      setState(() {
        if (_userData != null) {
          _userData!['trangThai'] = currentLocked;
        }
        _isLoading = false;
      });
      showAdminMessage(
        context,
        currentLocked ? 'Đã mở khóa tài khoản.' : 'Đã khóa tài khoản.',
        currentLocked ? 'Account unlocked.' : 'Account locked.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _resetPassword() async {
    final name = _userData?['hoTen'] ?? _userData?['tenDangNhap'] ?? 'người dùng';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đặt lại mật khẩu?'),
        content: Text('Mật khẩu của "$name" sẽ được đặt lại về mật khẩu mặc định (123456aA@). Bạn có chắc chắn không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await AdminApiService.instance.resetUserPassword(_effectiveAccountId);
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đặt lại mật khẩu về "123456aA@" thành công.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userData ?? widget.user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(adminText('Chi tiết người dùng', 'User details')),
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
        body: Center(
          child: Text(adminText('Tài khoản không tìm thấy.', 'Account not found.')),
        ),
      );
    }

    final isSelf = _effectiveAccountId == _effectiveAdminId;
    final fullName = user['hoTen'] ?? user['HoTen'] ?? user['tenDangNhap'] ?? '—';
    final username = user['tenDangNhap'] ?? user['TenDangNhap'] ?? '';
    final email = user['email'] ?? user['Email'] ?? '';
    final phone = user['soDienThoai'] ?? user['SoDienThoai'] ?? '—';
    final role = user['roleName'] ?? user['RoleName'] ?? user['role'] ?? user['Role'] ?? '';
    final isLocked = user['trangThai'] == false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          adminText('Chi tiết người dùng', 'User details'),
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
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.person, size: 36, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '$fullName',
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text('$role', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 10),
                    Chip(
                      avatar: Icon(isLocked ? Icons.lock_outline : Icons.check_circle_outline, size: 16),
                      label: Text(isLocked ? 'Đã khóa' : 'Đang hoạt động'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _tile('Username', '$username'),
                    _tile('Email', '$email'),
                    _tile('Số điện thoại', '$phone'),
                    _tile('Vai trò', '$role'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (!isSelf) ...[
              OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _toggleLock(isLocked),
                icon: Icon(isLocked ? Icons.lock_open_outlined : Icons.lock_outline),
                label: Text(
                  isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _resetPassword,
                icon: const Icon(Icons.lock_reset_rounded),
                label: const Text(
                  'Đặt lại mật khẩu mặc định',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E3A5F)),
            ),
          ),
        ],
      ),
    );
  }
}
