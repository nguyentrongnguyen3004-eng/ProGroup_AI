import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/governance_api_service.dart';

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
  List<Map<String, dynamic>> _periods = [];

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
        GovernanceApiService.instance.fetchRegistrationPeriods(),
      ]);

      if (!mounted) return;
      setState(() {
        _registrations = results[0];
        _courses = results[1];
        _groups = results[2];
        _periods = results[3];
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

  Future<void> _togglePeriodStatus(int periodId, String currentStatus) async {
    final nextStatus = currentStatus == 'Đang mở' ? 'Đã đóng' : 'Đang mở';
    final actionText = nextStatus == 'Đang mở' ? 'Mở đợt đăng ký' : 'Đóng đợt đăng ký';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$actionText?'),
        content: Text(
          nextStatus == 'Đang mở'
              ? 'Sinh viên sẽ có thể tiếp tục đăng ký đề tài vào đợt này.'
              : 'Sinh viên sẽ không thể đăng ký thêm đề tài vào đợt này nữa.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: nextStatus == 'Đang mở' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await GovernanceApiService.instance.updatePeriodStatus(periodId, nextStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái đợt đăng ký thành "$nextStatus".'),
            backgroundColor: nextStatus == 'Đang mở' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
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

          if (_periods.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.text('Các đợt đăng ký đồ án', en: 'Registration Periods'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                Text(
                  '${_periods.length} đợt',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._periods.map((p) {
              final periodId = p['dotDangKyId'] as int? ?? p['id'] as int? ?? 0;
              final tenDot = p['tenDot'] as String? ?? 'Đợt đăng ký';
              final lop = p['tenLopHocPhan'] ?? p['maLopHocPhan'] ?? '';
              final trangThai = p['trangThai'] as String? ?? 'Chưa mở';
              final isOpen = trangThai == 'Đang mở';

              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isOpen ? const Color(0xFF10B981).withValues(alpha: 0.4) : Colors.grey.shade200,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: isOpen ? const Color(0xFF10B981) : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenDot,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (lop.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '$lop',
                                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isOpen
                                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                        : Colors.grey.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    trangThai,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isOpen ? const Color(0xFF059669) : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          backgroundColor: isOpen
                              ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                              : const Color(0xFF10B981).withValues(alpha: 0.12),
                          foregroundColor: isOpen ? const Color(0xFFEF4444) : const Color(0xFF059669),
                        ),
                        onPressed: () => _togglePeriodStatus(periodId, trangThai),
                        child: Text(
                          isOpen ? 'Đóng đợt' : 'Mở đợt',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],

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
