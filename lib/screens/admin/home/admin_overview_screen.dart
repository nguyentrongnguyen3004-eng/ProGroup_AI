import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/admin_service.dart';

class AdminOverviewScreen extends StatefulWidget {
  final VoidCallback? onOpenUsers;
  final VoidCallback? onOpenData;
  final VoidCallback? onOpenRoles;
  final VoidCallback? onOpenActivity;

  const AdminOverviewScreen({
    super.key,
    this.onOpenUsers,
    this.onOpenData,
    this.onOpenRoles,
    this.onOpenActivity,
  });

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await AdminService().getStats();
      if (mounted) {
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Tổng Quan Quản Trị', en: 'Admin Overview')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    AppLocalizations.text('Số Liệu Thống Kê Hệ Thống', en: 'System Statistics'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard(
                        'Tổng người dùng',
                        '${_stats?['totalUsers'] ?? 0}',
                        Icons.people,
                        Colors.blue,
                        colors,
                      ),
                      _buildStatCard(
                        'Sinh viên',
                        '${_stats?['totalStudents'] ?? 0}',
                        Icons.school,
                        Colors.green,
                        colors,
                      ),
                      _buildStatCard(
                        'Giảng viên',
                        '${_stats?['totalLecturers'] ?? 0}',
                        Icons.person_pin,
                        Colors.orange,
                        colors,
                      ),
                      _buildStatCard(
                        'Lớp học phần',
                        '${_stats?['totalCourses'] ?? 0}',
                        Icons.class_,
                        Colors.purple,
                        colors,
                      ),
                      _buildStatCard(
                        'Đề tài đồ án',
                        '${_stats?['totalTopics'] ?? 0}',
                        Icons.topic,
                        Colors.teal,
                        colors,
                      ),
                      _buildStatCard(
                        'Nhóm đồ án',
                        '${_stats?['totalGroups'] ?? 0}',
                        Icons.groups,
                        Colors.indigo,
                        colors,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor, ColorScheme colors) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: accentColor.withValues(alpha: 0.15),
              child: Icon(icon, color: accentColor),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
