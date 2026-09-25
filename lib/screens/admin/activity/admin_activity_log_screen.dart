import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../admin/admin_helpers.dart';

class AdminActivityLogScreen extends StatefulWidget {
  const AdminActivityLogScreen({super.key});

  @override
  State<AdminActivityLogScreen> createState() => _AdminActivityLogScreenState();
}

class _AdminActivityLogScreenState extends State<AdminActivityLogScreen> {
  final _query = TextEditingController();
  String _action = 'Tất cả';
  String _role = 'Tất cả';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: MockAdminData.instance,
    builder: (context, _) {
      final all = MockAdminData.instance.activities;
      final actions = all.map((item) => item.action).toSet().toList()..sort();
      final entries = all.where((item) {
        final q = _query.text.trim().toLowerCase();
        final matchesQuery =
            q.isEmpty ||
            [
              item.actor,
              item.action,
              item.target,
              item.description,
              item.role,
            ].any((value) => value.toLowerCase().contains(q));
        return matchesQuery &&
            (_action == 'Tất cả' || item.action == _action) &&
            (_role == 'Tất cả' || item.role == _role);
      }).toList()..sort((a, b) => b.time.compareTo(a.time));
      return Scaffold(
        appBar: AppBar(
          title: Text(adminText('Nhật ký hoạt động', 'Activity log')),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _query,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: adminText(
                    'Tìm hoạt động, người thực hiện...',
                    'Search activity or actor...',
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _action,
                      decoration: InputDecoration(
                        labelText: adminText('Hành động', 'Action'),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Tất cả',
                          child: Text(adminText('Tất cả', 'All')),
                        ),
                        for (final action in actions)
                          DropdownMenuItem<String>(
                            value: action,
                            child: Text(adminActivityActionText(action)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _action = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _role,
                      decoration: InputDecoration(
                        labelText: adminText('Vai trò', 'Role'),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Tất cả',
                          child: Text(adminText('Tất cả', 'All')),
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
                  IconButton(
                    tooltip: adminText('Đặt lại bộ lọc', 'Reset filters'),
                    onPressed: () => setState(() {
                      _action = 'Tất cả';
                      _role = 'Tất cả';
                      _query.clear();
                    }),
                    icon: const Icon(Icons.filter_alt_off_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? adminEmptyState(
                      context,
                      'Không có hoạt động phù hợp.',
                      'No matching activity found.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.history),
                            ),
                            title: Text(
                              '${adminActivityActionText(entry.action)} · ${entry.target}',
                            ),
                            subtitle: Text(
                              '${adminActivityDescriptionText(entry.description)}\n${adminText('Quản trị viên hệ thống', 'System Administrator')} · ${adminRoleText(entry.role)}\n${adminDateTime(entry.time)}',
                            ),
                            isThreeLine: true,
                            trailing: Chip(
                              label: Text(entry.status),
                              visualDensity: VisualDensity.compact,
                            ),
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
