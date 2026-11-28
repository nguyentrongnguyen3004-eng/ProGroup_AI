import 'package:flutter/material.dart';

import '../../../services/admin_api_service.dart';
import '../../../services/governance_api_service.dart';
import '../../admin/admin_helpers.dart';
import 'admin_data_detail_screen.dart';

enum AdminDataType {
  students,
  lecturers,
  subjects,
  courseClasses,
  groups,
  accounts,
}

class AdminDataManagementScreen extends StatefulWidget {
  const AdminDataManagementScreen({super.key});

  @override
  State<AdminDataManagementScreen> createState() => _AdminDataManagementScreenState();
}

class _AdminDataManagementScreenState extends State<AdminDataManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _overview = {};

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AdminApiService.instance.fetchOverview();
      var sCount = data['tongSinhVien'] ?? data['totalStudents'] ?? data['sinhViens'] ?? 0;
      var lCount = data['tongGiangVien'] ?? data['totalLecturers'] ?? data['giangViens'] ?? 0;
      var cCount = data['tongLopHocPhan'] ?? data['totalCourses'] ?? data['totalClasses'] ?? 0;
      var gCount = data['tongNhom'] ?? data['totalGroups'] ?? data['nhoms'] ?? 0;
      var uCount = data['tongNguoiDung'] ?? data['totalUsers'] ?? data['users'] ?? 0;

      // Nếu số liệu vẫn là 0, tự động gọi đếm từ danh sách chi tiết của hệ thống
      if (sCount == 0 && lCount == 0 && cCount == 0) {
        try {
          final results = await Future.wait([
            GovernanceApiService.instance.fetchStudents().catchError((_) => <Map<String, dynamic>>[]),
            GovernanceApiService.instance.fetchLecturers().catchError((_) => <Map<String, dynamic>>[]),
            GovernanceApiService.instance.fetchCourses().catchError((_) => <Map<String, dynamic>>[]),
            GovernanceApiService.instance.fetchGroups().catchError((_) => <Map<String, dynamic>>[]),
            AdminApiService.instance.fetchUsers().catchError((_) => <Map<String, dynamic>>[]),
          ]);
          if (results[0].isNotEmpty) sCount = results[0].length;
          if (results[1].isNotEmpty) lCount = results[1].length;
          if (results[2].isNotEmpty) cCount = results[2].length;
          if (results[3].isNotEmpty) gCount = results[3].length;
          if (results[4].isNotEmpty) uCount = results[4].length;
        } catch (_) {}
      }

      data['totalStudents'] = sCount;
      data['totalLecturers'] = lCount;
      data['totalCourses'] = cCount;
      data['totalGroups'] = gCount;
      data['totalUsers'] = uCount;

      if (!mounted) return;
      setState(() {
        _overview = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canPop = ModalRoute.of(context)?.canPop == true;

    final items = [
      (
        AdminDataType.students,
        adminText('Sinh viên', 'Students'),
        _overview['totalStudents'] ?? _overview['tongSinhVien'] ?? 0,
        Icons.school_rounded,
        const Color(0xFF10B981),
        'Hồ sơ, tài khoản và điểm danh',
      ),
      (
        AdminDataType.lecturers,
        adminText('Giảng viên', 'Lecturers'),
        _overview['totalLecturers'] ?? _overview['tongGiangVien'] ?? 0,
        Icons.badge_rounded,
        const Color(0xFF6366F1),
        'Học vị, chuyên môn và phân công',
      ),
      (
        AdminDataType.courseClasses,
        adminText('Lớp học phần', 'Course classes'),
        _overview['totalCourses'] ?? _overview['tongLopHocPhan'] ?? 0,
        Icons.class_rounded,
        const Color(0xFF2563EB),
        'Danh sách lớp học phần theo học kỳ',
      ),
      (
        AdminDataType.groups,
        adminText('Nhóm đồ án', 'Groups'),
        _overview['totalGroups'] ?? _overview['tongNhom'] ?? 0,
        Icons.groups_rounded,
        const Color(0xFFF59E0B),
        'Các nhóm đồ án chuyên ngành & liên môn',
      ),
      (
        AdminDataType.accounts,
        adminText('Tài khoản hệ thống', 'System Accounts'),
        _overview['totalUsers'] ?? _overview['tongNguoiDung'] ?? 0,
        Icons.admin_panel_settings_rounded,
        const Color(0xFF8B5CF6),
        'Quản lý phân quyền và bảo mật đăng nhập',
      ),
    ];

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(
                adminText('Quản lý dữ liệu hệ thống', 'System Data Management'),
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
                  icon: const Icon(Icons.backup_rounded),
                  tooltip: 'Sao lưu CSDL',
                  onPressed: _showBackupDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                  onPressed: _loadOverview,
                ),
              ],
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner (Đồng bộ chuẩn Giảng viên)
            if (!canPop)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dataset_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminText('Dữ liệu hệ thống', 'System Data'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            adminText('Tổng hợp dữ liệu toàn trường', 'School-wide system data repository'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.backup_rounded, color: Colors.white),
                      tooltip: 'Sao lưu CSDL',
                      onPressed: _showBackupDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      tooltip: 'Tải lại',
                      onPressed: _loadOverview,
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _buildBody(colors, items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors, List<(AdminDataType, String, dynamic, IconData, Color, String)> items) {
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
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadOverview,
                icon: const Icon(Icons.refresh_rounded),
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
      onRefresh: _loadOverview,
      color: const Color(0xFF2563EB),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (type, title, count, icon, color, desc) = items[index];

          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminDataDetailScreen(
                      type: type,
                      title: title,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showBackupDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool isBackingUp = false;
        List<Map<String, dynamic>> backups = [];
        bool isLoadingBackups = true;

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            void loadList() async {
              setModalState(() => isLoadingBackups = true);
              final list = await AdminApiService.instance.fetchBackups();
              setModalState(() {
                backups = list;
                isLoadingBackups = false;
              });
            }

            if (isLoadingBackups && backups.isEmpty) {
              loadList();
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.backup_rounded, color: Color(0xFF2563EB), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sao lưu CSDL SQL Server',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Tự động mỗi 12h hoặc sao lưu thủ công',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isBackingUp
                              ? null
                              : () async {
                                  setModalState(() => isBackingUp = true);
                                  try {
                                    final res = await AdminApiService.instance.createBackup();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res['message']?.toString() ?? 'Sao lưu thành công!'),
                                          backgroundColor: const Color(0xFF10B981),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Lỗi sao lưu: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    setModalState(() => isBackingUp = false);
                                    loadList();
                                  }
                                },
                          icon: isBackingUp
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                          label: Text(
                            isBackingUp ? 'Đang tạo bản sao lưu...' : 'Tạo bản sao lưu mới ngay',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Danh sách bản sao lưu (${backups.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: isLoadingBackups
                            ? const Center(child: CircularProgressIndicator())
                            : backups.isEmpty
                                ? const Center(child: Text('Chưa có bản sao lưu nào.'))
                                : ListView.separated(
                                    controller: scrollCtrl,
                                    itemCount: backups.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                                    itemBuilder: (ctx, i) {
                                      final b = backups[i];
                                      final name = b['fileName']?.toString() ?? 'backup.bak';
                                      final sizeBytes = b['sizeBytes'] as int? ?? 0;
                                      final sizeMb = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
                                      final created = b['createdAt']?.toString() ?? '';
                                      final isLatest = i == 0;

                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isLatest
                                              ? const Color(0xFF2563EB).withValues(alpha: 0.06)
                                              : Colors.grey.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isLatest
                                                ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                                                : Colors.grey.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.storage_rounded,
                                              color: isLatest ? const Color(0xFF2563EB) : Colors.grey,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '$sizeMb MB · $created',
                                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isLatest)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Mới nhất',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF10B981),
                                                  ),
                                                ),
                                              ),
                                          ],
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
          },
        );
      },
    );
  }
}
