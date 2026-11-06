import 'package:flutter/material.dart';

import '../../../services/admin_api_service.dart';
import '../../../services/api_service.dart';
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
    final rawPhone = user['soDienThoai'] ?? user['SoDienThoai'];
    final phone = (rawPhone != null && rawPhone.toString().trim().isNotEmpty) ? rawPhone.toString().trim() : '—';
    final rawRole = user['tenVaiTro'] ?? user['TenVaiTro'] ?? user['roleName'] ?? user['RoleName'] ?? user['maVaiTro'] ?? user['MaVaiTro'] ?? user['role'] ?? user['Role'];
    final role = (rawRole != null && rawRole.toString().trim().isNotEmpty) ? rawRole.toString().trim() : '—';
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
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _isLoading ? null : _changeUserRole,
                icon: const Icon(Icons.manage_accounts_rounded),
                label: const Text(
                  'Chuyển đổi vai trò (Role Migration)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _deleteUser,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                label: const Text(
                  'Xóa tài khoản người dùng',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
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


  Future<void> _changeUserRole() async {
    final userId = _effectiveAccountId;
    if (userId <= 0) return;

    final roles = [
      {'code': 'SINHVIEN', 'name': 'Sinh viên'},
      {'code': 'GIANGVIEN', 'name': 'Giảng viên'},
      {'code': 'GIAOVUKHOA', 'name': 'Giáo vụ khoa'},
      {'code': 'PHONGDAOTAO', 'name': 'Phòng đào tạo'},
      {'code': 'ADMIN', 'name': 'Quản trị viên'},
    ];

    String selectedRole = 'GIANGVIEN';

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text('Chuyển đổi vai trò người dùng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chọn vai trò mới cho tài khoản:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                ...roles.map((r) => RadioListTile<String>(
                  title: Text(r['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: r['code']!,
                  groupValue: selectedRole,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedRole = val);
                    }
                  },
                )),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, selectedRole),
                child: const Text('Cập nhật vai trò'),
              ),
            ],
          );
        },
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.instance.put('/api/admin/users/$userId/role', {
        'maVaiTro': result,
      });

      final targetName = roles.firstWhere((r) => r['code'] == result)['name'] ?? result;

      if (mounted) {
        setState(() {
          if (_userData != null) {
            _userData!['maVaiTro'] = result;
            _userData!['tenVaiTro'] = targetName;
            _userData!['role'] = result;
            _userData!['roleName'] = targetName;
          }
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật vai trò thành công, người dùng đăng nhập lại sẽ nhận đúng quyền $targetName.'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser() async {
    final userId = _effectiveAccountId;
    if (userId <= 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Xác nhận xóa tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản này khỏi hệ thống không? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.instance.delete('/api/admin/users/$userId');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa người dùng thành công.'), backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final err = e.toString();
        final msg = err.contains('liên kết') || err.contains('ràng buộc') || err.contains('Khóa tài khoản')
            ? "Không thể xóa tài khoản do người dùng đã có dữ liệu liên kết trong hệ thống (lớp học phần, nhóm đồ án, đề tài). Khuyến nghị sử dụng chức năng 'Khóa tài khoản' để bảo toàn tính toàn vẹn dữ liệu lịch sử."
            : "Không thể xóa tài khoản do người dùng đã có dữ liệu liên kết trong hệ thống (lớp học phần, nhóm đồ án, đề tài). Khuyến nghị sử dụng chức năng 'Khóa tài khoản' để bảo toàn tính toàn vẹn dữ liệu lịch sử.";

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFFF59E0B)),
                SizedBox(width: 8),
                Text('Ràng buộc dữ liệu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: Text(msg, style: const TextStyle(fontSize: 13.5, height: 1.4)),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đã hiểu'),
              ),
            ],
          ),
        );
      }
    }
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
