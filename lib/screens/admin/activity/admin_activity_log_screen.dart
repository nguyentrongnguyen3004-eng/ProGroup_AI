import 'package:flutter/material.dart';

import '../../../models/admin_activity_model.dart';
import '../../admin/admin_helpers.dart';

class AdminActivityLogScreen extends StatefulWidget {
  const AdminActivityLogScreen({super.key});

  @override
  State<AdminActivityLogScreen> createState() => _AdminActivityLogScreenState();
}

class _AdminActivityLogScreenState extends State<AdminActivityLogScreen> {
  final _query = TextEditingController();
  final String _action = 'Tất cả';

  final List<AdminActivityModel> _activities = [
    AdminActivityModel(
      id: 1,
      actor: 'Admin',
      role: 'Admin',
      action: 'Đăng nhập',
      target: 'Hệ thống',
      description: 'Tài khoản Admin đăng nhập thành công.',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      status: 'Thành công',
    ),
  ];

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim().toLowerCase();
    final entries = _activities.where((item) {
      final matchesQuery = q.isEmpty ||
          [item.actor, item.action, item.target, item.description, item.role]
              .any((v) => v.toLowerCase().contains(q));
      return matchesQuery && (_action == 'Tất cả' || item.action == _action);
    }).toList();

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          adminText('Nhật ký hoạt động', 'Activity Log'),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _query,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                  hintText: adminText('Tìm hoạt động, người thực hiện...', 'Search activity or actor...'),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 54, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            adminText('Không có hoạt động nào.', 'No activity found.'),
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          elevation: 0,
                          color: colors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.history, color: Color(0xFF2563EB), size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.action} · ${entry.target}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colors.onSurface),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        entry.description,
                                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        adminDateTime(entry.time),
                                        style: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
