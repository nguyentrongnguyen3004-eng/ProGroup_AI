import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../../data/mock/mock_groups.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../data/mock/mock_training_data.dart';
import '../../admin/admin_helpers.dart';

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({
    super.key,
    required this.onOpenUsers,
    required this.onOpenData,
    required this.onOpenRoles,
    required this.onOpenActivity,
  });

  final VoidCallback onOpenUsers;
  final VoidCallback onOpenData;
  final VoidCallback onOpenRoles;
  final VoidCallback onOpenActivity;

  @override
  Widget build(BuildContext context) {
    final admin = MockAdminData.instance;
    final training = MockTrainingData.instance;
    final governance = MockGovernanceData.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([admin, training, governance]),
      builder: (context, _) {
        final roleCounts = {
          for (final role in MockAdminData.roles)
            role: admin.accounts
                .where((account) => account.role == role)
                .length,
        };
        final importCount =
            training.importHistory.length + governance.importHistory.length;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              adminText('Quản trị hệ thống', 'System administration'),
            ),
            actions: [
              IconButton(
                tooltip: adminText('Nhật ký hoạt động', 'Activity log'),
                onPressed: onOpenActivity,
                icon: const Icon(Icons.history),
              ),
              IconButton(
                tooltip: adminText('Quản lý vai trò', 'Role management'),
                onPressed: onOpenRoles,
                icon: const Icon(Icons.admin_panel_settings_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                adminText('Tổng quan hệ thống', 'System overview'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _SectionTitle(adminText('Tài khoản', 'Accounts')),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatCard(
                    label: adminText('Tổng người dùng', 'Total users'),
                    value: '${admin.accounts.length}',
                    icon: Icons.people_alt_outlined,
                  ),
                  for (final role in MockAdminData.roles)
                    _StatCard(
                      label: _translatedRole(role),
                      value: '${roleCounts[role]}',
                      icon: _roleIcon(role),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(adminText('Dữ liệu nền', 'System data')),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatCard(
                    label: adminText('Sinh viên', 'Students'),
                    value: '${training.students.length}',
                    icon: Icons.school_outlined,
                  ),
                  _StatCard(
                    label: adminText('Giảng viên', 'Lecturers'),
                    value: '${training.lecturers.length}',
                    icon: Icons.person_outline,
                  ),
                  _StatCard(
                    label: adminText('Học phần', 'Subjects'),
                    value: '${training.subjects.length}',
                    icon: Icons.menu_book_outlined,
                  ),
                  _StatCard(
                    label: adminText('Lớp học phần', 'Course classes'),
                    value: '${training.courseClasses.length}',
                    icon: Icons.class_outlined,
                  ),
                  _StatCard(
                    label: adminText('Nhóm/đồ án', 'Groups/projects'),
                    value: '${MockGroups.groups.length}',
                    icon: Icons.groups_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(adminText('Trạng thái hệ thống', 'System status')),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(
                        adminText(
                          'Tài khoản đang hoạt động',
                          'Active accounts',
                        ),
                      ),
                      trailing: Text('${admin.activeCount}'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(
                        adminText('Tài khoản đã khóa', 'Locked accounts'),
                      ),
                      trailing: Text('${admin.lockedCount}'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person_add_alt_1_outlined),
                      title: Text(
                        adminText('Tài khoản mới thêm', 'New accounts added'),
                      ),
                      trailing: Text('${admin.newlyAddedCount}'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.upload_file_outlined),
                      title: Text(
                        adminText('Lượt import gần đây', 'Recent imports'),
                      ),
                      trailing: Text('$importCount'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onOpenUsers,
                    icon: const Icon(Icons.people_outline),
                    label: Text(adminText('Người dùng', 'Users')),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onOpenData,
                    icon: const Icon(Icons.storage_outlined),
                    label: Text(adminText('Dữ liệu', 'Data')),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenRoles,
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: Text(adminText('Vai trò', 'Roles')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SectionTitle(
                      adminText('Hoạt động gần đây', 'Recent activity'),
                    ),
                  ),
                  TextButton(
                    onPressed: onOpenActivity,
                    child: Text(adminText('Xem tất cả', 'View all')),
                  ),
                ],
              ),
              for (final activity in admin.activities.take(4))
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(
                      '${adminActivityActionText(activity.action)} · ${activity.target}',
                    ),
                    subtitle: Text(
                      '${adminActivityDescriptionText(activity.description)}\n${adminDateTime(activity.time)}',
                    ),
                    isThreeLine: true,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

String _translatedRole(String role) =>
    role == 'Admin' ? adminText('Admin', 'Admins') : adminRoleText(role);

IconData _roleIcon(String role) => switch (role) {
  'Sinh viên' => Icons.school_outlined,
  'Giảng viên' => Icons.co_present_outlined,
  'Giáo vụ khoa' => Icons.fact_check_outlined,
  'Phòng Đào tạo' => Icons.account_balance_outlined,
  _ => Icons.admin_panel_settings_outlined,
};

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 42) / 2,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
