import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../admin/admin_helpers.dart';

class AdminRoleScreen extends StatelessWidget {
  const AdminRoleScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(adminText('Quản lý vai trò', 'Role management')),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          adminText('Vai trò và quyền hạn', 'Roles and permissions'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          adminText(
            'Bảng quyền mock để tra cứu trong ứng dụng.',
            'Read-only mock permissions for in-app reference.',
          ),
        ),
        const SizedBox(height: 12),
        for (final role in MockAdminData.roles)
          Card(
            child: ExpansionTile(
              leading: Icon(
                _icon(role),
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(adminRoleText(role)),
              subtitle: Text(
                '${MockAdminData.instance.accounts.where((account) => account.role == role).length} ${adminText('tài khoản', 'accounts')}',
              ),
              children: [
                for (final permission
                    in MockAdminData.permissions[role] ?? const <String>[])
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(_permission(context, permission)),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

IconData _icon(String role) => switch (role) {
  'Sinh viên' => Icons.school_outlined,
  'Giảng viên' => Icons.co_present_outlined,
  'Giáo vụ khoa' => Icons.fact_check_outlined,
  'Phòng Đào tạo' => Icons.account_balance_outlined,
  _ => Icons.admin_panel_settings_outlined,
};

String _permission(BuildContext context, String value) => switch (value) {
  'Đăng ký lớp học phần' => adminText(value, 'Register for course classes'),
  'Tạo và tham gia nhóm' => adminText(value, 'Create and join groups'),
  'Chọn đề tài' => adminText(value, 'Choose a project topic'),
  'Chat nhóm' => adminText(value, 'Group chat'),
  'Quản lý profile' => adminText(value, 'Manage profile'),
  'Quản lý lớp học phần' => adminText(value, 'Manage course classes'),
  'Quản lý nhóm và đề tài' => adminText(value, 'Manage groups and topics'),
  'Duyệt đề tài' => adminText(value, 'Review topics'),
  'Quản lý sinh viên' => adminText(value, 'Manage students'),
  'Profile và thông báo' => adminText(value, 'Profile and notifications'),
  'Quản lý sinh viên và giảng viên' => adminText(
    value,
    'Manage students and lecturers',
  ),
  'Import dữ liệu' => adminText(value, 'Import data'),
  'CRUD dữ liệu khoa' => adminText(value, 'Manage faculty data'),
  'Quản lý sinh viên, giảng viên, học phần' => adminText(
    value,
    'Manage students, lecturers, and subjects',
  ),
  'Phân công giảng viên' => adminText(value, 'Assign lecturers'),
  'Quản lý người dùng và vai trò' => adminText(value, 'Manage users and roles'),
  'Theo dõi dữ liệu hệ thống' => adminText(value, 'View system data'),
  'Theo dõi hoạt động' => adminText(value, 'Review activity logs'),
  'Quản lý thông báo' => adminText(value, 'Manage notifications'),
  'Quản lý profile hệ thống' => adminText(value, 'Manage system profile'),
  _ => value,
};
