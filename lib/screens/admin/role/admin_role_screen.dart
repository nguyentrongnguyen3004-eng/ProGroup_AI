import 'package:flutter/material.dart';

<<<<<<< HEAD
=======
import '../../../services/admin_data_service.dart';
>>>>>>> origin/Frontend
import '../../admin/admin_helpers.dart';

class AdminRoleScreen extends StatelessWidget {
  const AdminRoleScreen({super.key});

  static const List<String> roles = [
    'Sinh viên',
    'Giảng viên',
    'Giáo vụ khoa',
    'Phòng Đào tạo',
    'Admin',
  ];

  static const Map<String, List<String>> permissions = {
    'Sinh viên': [
      'Xem danh sách đề tài đồ án',
      'Đăng ký đề tài & ghép nhóm',
      'Nhận phản hồi đánh giá AI',
      'Nhận thông báo tiến độ',
    ],
    'Giảng viên': [
      'Quản lý đề tài phụ trách',
      'Duyệt nhóm đăng ký đề tài',
      'Chấm điểm và phản hồi sinh viên',
      'Gợi ý đề tài qua AI Assistant',
    ],
    'Giáo vụ khoa': [
      'Phân công giảng viên phụ trách LHP',
      'Import danh sách sinh viên & LHP',
      'Theo dõi tiến độ đăng ký đồ án',
      'Gửi thông báo toàn khoa',
    ],
    'Phòng Đào tạo': [
      'Quản lý danh mục học phần toàn trường',
      'Import và đồng bộ dữ liệu đào tạo',
      'Quản lý đợt đăng ký đồ án',
      'Báo cáo thống kê toàn trường',
    ],
    'Admin': [
      'Toàn quyền quản trị tài khoản',
      'Phân quyền và khóa/mở tài khoản',
      'Giám sát hoạt động và bảo mật',
      'Cấu hình thông số hệ thống',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          adminText('Quản lý vai trò', 'Role Management'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
<<<<<<< HEAD
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
=======
        const SizedBox(height: 6),
        Text(
          adminText(
            'Bảng quyền hạn tra cứu trong ứng dụng.',
            'Permission reference matrix in the system.',
          ),
        ),
        const SizedBox(height: 12),
        for (final role in AdminDataService.roles)
          Card(
            child: ExpansionTile(
              leading: Icon(
                _icon(role),
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(adminRoleText(role)),
              subtitle: Text(
                '${AdminDataService.instance.accounts.where((account) => account.role == role).length} ${adminText('tài khoản', 'accounts')}',
              ),
              children: [
                for (final permission
                    in AdminDataService.permissions[role] ?? const <String>[])
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(_permission(context, permission)),
                  ),
              ],
>>>>>>> origin/Frontend
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            // Hero Banner
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminText('Vai trò & Phân quyền', 'Roles & Permissions'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          adminText(
                            'Danh mục vai trò và bảng quyền truy cập trong hệ thống.',
                            'System role definitions and access matrices.',
                          ),
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            for (final role in roles)
              Card(
                elevation: 0,
                color: colors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: ExpansionTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_icon(role), color: const Color(0xFF2563EB), size: 24),
                  ),
                  title: Text(
                    adminRoleText(role),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colors.onSurface),
                  ),
                  subtitle: Text(
                    '${(permissions[role] ?? []).length} ${adminText("quyền hạn", "permissions")}',
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                  ),
                  children: [
                    for (final perm in permissions[role] ?? <String>[])
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 18),
                        title: Text(perm, style: TextStyle(fontSize: 13, color: colors.onSurface)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String role) => switch (role) {
    'Sinh viên' => Icons.school_outlined,
    'Giảng viên' => Icons.badge_outlined,
    'Giáo vụ khoa' => Icons.account_balance_outlined,
    'Phòng Đào tạo' => Icons.domain_outlined,
    _ => Icons.admin_panel_settings_outlined,
  };
}
