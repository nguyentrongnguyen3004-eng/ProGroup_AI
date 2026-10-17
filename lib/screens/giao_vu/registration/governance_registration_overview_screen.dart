import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../../../core/localization/app_localizations.dart';
import '../../../services/governance_api_service.dart';
=======
import '../../../core/theme/app_theme.dart';
import '../../../models/course_model.dart';
import '../../../services/governance_data_service.dart';
import '../../../services/group_service.dart';
import '../../../services/topic_service.dart';
import '../../../widgets/governance/governance_widgets.dart';
>>>>>>> origin/Frontend

class GovernanceRegistrationOverviewScreen extends StatefulWidget {
  const GovernanceRegistrationOverviewScreen({super.key});

  @override
  State<GovernanceRegistrationOverviewScreen> createState() => _GovernanceRegistrationOverviewScreenState();
}

class _GovernanceRegistrationOverviewScreenState extends State<GovernanceRegistrationOverviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _registrations = [];
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        GovernanceApiService.instance.fetchTopicRegistrations(),
        GovernanceApiService.instance.fetchCourses(),
        GovernanceApiService.instance.fetchGroups(),
      ]);

      if (!mounted) return;
      setState(() {
        _registrations = results[0];
        _courses = results[1];
        _groups = results[2];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu đăng ký đồ án: $e';
        _isLoading = false;
      });
    }
  }

  bool _isApproved(Map<String, dynamic> reg) {
    final status = (reg['status'] ?? reg['trangThai'] ?? reg['trangThaiDuyet'] ?? '').toString().toLowerCase();
    return status.contains('duyệt') || status.contains('approved') || status.contains('đã');
  }

  bool _isPending(Map<String, dynamic> reg) {
    final status = (reg['status'] ?? reg['trangThai'] ?? reg['trangThaiDuyet'] ?? '').toString().toLowerCase();
    return status.contains('chờ') || status.contains('pending');
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final approvedCount = _registrations.where(_isApproved).length;
    final pendingCount = _registrations.where(_isPending).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Theo dõi đăng ký đồ án', en: 'Topic Registrations'),
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
=======
    final data = GovernanceDataService.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final groups = GroupService.groups;
        final registrations = TopicService.registrations;
        final approved = registrations.where(_isApproved).length;
        final pending = registrations.where(_isPending).length;
        return Scaffold(
          appBar: AppBar(title: const Text('Theo dõi đăng ký đồ án')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  GovernanceStatCard(
                    title: 'Lớp học phần',
                    value: '${data.courses.length}',
                    icon: Icons.school_outlined,
                  ),
                  GovernanceStatCard(
                    title: 'Sinh viên',
                    value: '${data.students.length}',
                    icon: Icons.people_outline,
                    color: AppTheme.successColor,
                  ),
                  GovernanceStatCard(
                    title: 'Nhóm',
                    value: '${groups.length}',
                    icon: Icons.groups_outlined,
                    color: AppTheme.warningColor,
                  ),
                  GovernanceStatCard(
                    title: 'Đề tài',
                    value: '${TopicService.topics.length}',
                    icon: Icons.lightbulb_outline,
                  ),
                  GovernanceStatCard(
                    title: 'Đăng ký đã duyệt',
                    value: '$approved',
                    icon: Icons.task_alt,
                    color: AppTheme.successColor,
                  ),
                  GovernanceStatCard(
                    title: 'Chờ xử lý',
                    value: '$pending',
                    icon: Icons.pending_actions_outlined,
                    color: AppTheme.warningColor,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Tình hình theo lớp',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...data.courses.map(
                (course) => _courseStatus(course, groups, registrations),
              ),
            ],
>>>>>>> origin/Frontend
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: _buildBody(approvedCount, pendingCount),
      ),
    );
  }

  Widget _buildBody(int approvedCount, int pendingCount) {
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
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // Stat Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _buildStatCard(
                title: 'Lớp học phần',
                value: '${_courses.length}',
                icon: Icons.school_outlined,
                color: const Color(0xFF2563EB),
              ),
              _buildStatCard(
                title: 'Nhóm đồ án',
                value: '${_groups.length}',
                icon: Icons.groups_outlined,
                color: const Color(0xFF059669),
              ),
              _buildStatCard(
                title: 'Đăng ký đã duyệt',
                value: '$approvedCount',
                icon: Icons.task_alt,
                color: const Color(0xFF10B981),
              ),
              _buildStatCard(
                title: 'Chờ duyệt',
                value: '$pendingCount',
                icon: Icons.pending_actions_outlined,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            AppLocalizations.text('Tình hình theo lớp học phần', en: 'Classes Status'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 12),

          if (_courses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.text('Chưa có dữ liệu lớp học phần', en: 'No classes available'),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._courses.map((course) {
              final cCode = course['maLopHocPhan'] ?? course['MaLopHocPhan'] ?? '—';
              final cName = course['tenLopHocPhan'] ?? course['TenLopHocPhan'] ?? course['tenHocPhan'] ?? course['TenHocPhan'] ?? '—';
              final lecturer = course['giangVienTen'] ?? course['GiangVienTen'] ?? 'Chưa phân công';

              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.school_outlined, color: Color(0xFF2563EB), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$cName',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1E3A5F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mã lớp: $cCode',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Giảng viên: $lecturer',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
