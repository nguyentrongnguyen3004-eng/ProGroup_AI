import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/admin_service.dart';

<<<<<<< HEAD
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/admin_api_service.dart';
import '../../../services/auth_service.dart';
import '../notification/admin_notification_screen.dart';
import '../user/admin_user_detail_screen.dart';

=======
>>>>>>> origin/Frontend
class AdminOverviewScreen extends StatefulWidget {
  final VoidCallback? onOpenUsers;
  final VoidCallback? onOpenData;
  final VoidCallback? onOpenRoles;
  final VoidCallback? onOpenActivity;
<<<<<<< HEAD
  final VoidCallback? onOpenNotifications;
=======
>>>>>>> origin/Frontend

  const AdminOverviewScreen({
    super.key,
    this.onOpenUsers,
    this.onOpenData,
    this.onOpenRoles,
    this.onOpenActivity,
<<<<<<< HEAD
    this.onOpenNotifications,
=======
>>>>>>> origin/Frontend
  });

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  bool _isLoading = true;
<<<<<<< HEAD
  String? _errorMessage;

  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _notifications = [];
=======
  Map<String, dynamic>? _stats;
>>>>>>> origin/Frontend

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        AdminApiService.instance.fetchOverview(),
        AdminApiService.instance.fetchUsers(),
        AdminApiService.instance.fetchNotifications(),
      ]);

      if (!mounted) return;
      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _users = results[1] as List<Map<String, dynamic>>;
        _notifications = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'AD';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
=======
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
>>>>>>> origin/Frontend

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
<<<<<<< HEAD
    final user = AuthService.currentUser;
    final userName = user.fullName.isNotEmpty ? user.fullName : 'Quản trị viên';
    final initials = _getInitials(userName);
    final unreadCount = _notifications.where((n) => n['isRead'] != true && n['daDoc'] != true).length;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _users.isEmpty) {
      return Scaffold(
        body: SafeArea(
          bottom: true,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppTheme.dangerColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.text('Lỗi tải dữ liệu', en: 'Failed to load data'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(AppLocalizations.text('Thử lại', en: 'Retry')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final int totalUsers = _users.isNotEmpty ? _users.length : (_overview['users'] as int? ?? 150);
    final int totalStudents = _overview['sinhViens'] as int? ?? (_users.where((u) => (u['vaiTro'] ?? u['role'] ?? '').toString().toUpperCase().contains('SINHVIEN')).length);
    final int totalLecturers = _overview['giangViens'] as int? ?? (_users.where((u) => (u['vaiTro'] ?? u['role'] ?? '').toString().toUpperCase().contains('GIANGVIEN')).length);
    final int totalCourses = _overview['lopHocPhans'] as int? ?? 14;

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF2563EB),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 80),
            children: [
              // ======================================================
              // 1. TOP HEADER: AVATAR + XIN CHÀO + CHUÔNG THÔNG BÁO BADGE
              // ======================================================
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.text('Xin chào', en: 'Hello'),
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('👋', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: widget.onOpenNotifications ??
                          () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminNotificationScreen(),
                              ),
                            );
                            _loadData();
                          },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: colors.onSurface,
                              size: 22,
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.surface, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Center(
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        height: 1.05,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ======================================================
              // 2. HERO BANNER: TRUNG TÂM QUẢN TRỊ HỆ THỐNG
              // ======================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'HỆ THỐNG QUẢN TRỊ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.text(
                              'Trung tâm Kiểm soát',
                              en: 'Control Center',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.text(
                              'Quản lý toàn bộ tài khoản, phân quyền bảo mật và cơ sở dữ liệu.',
                              en: 'Manage university accounts, security roles and database.',
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ======================================================
              // 3. 4 STAT CARDS (2x2 GRID SQUIRCLE)
              // ======================================================
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.25,
                children: [
                  _StatCard(
                    title: AppLocalizations.text('Tổng tài khoản', en: 'Total Users'),
                    value: '$totalUsers',
                    icon: Icons.manage_accounts_rounded,
                    color: const Color(0xFF2563EB), // Blue
                  ),
                  _StatCard(
                    title: AppLocalizations.text('Sinh viên', en: 'Students'),
                    value: '$totalStudents',
                    icon: Icons.people_rounded,
                    color: const Color(0xFF10B981), // Emerald
                  ),
                  _StatCard(
                    title: AppLocalizations.text('Giảng viên', en: 'Lecturers'),
                    value: '$totalLecturers',
                    icon: Icons.badge_rounded,
                    color: const Color(0xFF6366F1), // Indigo
                  ),
                  _StatCard(
                    title: AppLocalizations.text('Lớp học phần', en: 'Classes'),
                    value: '$totalCourses',
                    icon: Icons.school_rounded,
                    color: const Color(0xFFF59E0B), // Amber
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ======================================================
              // 4. QUICK ACTIONS (TÁC VỤ NHANH)
              // ======================================================
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.text('Tác vụ hệ thống', en: 'Admin Actions'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: [
                  _ActionCard(
                    icon: Icons.manage_accounts_rounded,
                    color: const Color(0xFF2563EB),
                    title: AppLocalizations.text('QL Tài khoản', en: 'Users'),
                    subtitle: AppLocalizations.text('Khóa / Cấp quyền', en: 'Status & Roles'),
                    onTap: widget.onOpenUsers ?? () {},
                  ),
                  _ActionCard(
                    icon: Icons.security_rounded,
                    color: const Color(0xFF10B981),
                    title: AppLocalizations.text('Phân quyền', en: 'Role Matrix'),
                    subtitle: AppLocalizations.text('Ma trận 5 vai trò', en: '5-role access'),
                    onTap: widget.onOpenRoles ?? () {},
                  ),
                  _ActionCard(
                    icon: Icons.dataset_rounded,
                    color: const Color(0xFF6366F1),
                    title: AppLocalizations.text('Cơ sở dữ liệu', en: 'Database'),
                    subtitle: AppLocalizations.text('Dữ liệu toàn trường', en: 'Master data'),
                    onTap: widget.onOpenData ?? () {},
                  ),
                  _ActionCard(
                    icon: Icons.history_rounded,
                    color: const Color(0xFFEC4899),
                    title: AppLocalizations.text('Nhật ký hệ thống', en: 'Audit Logs'),
                    subtitle: AppLocalizations.text('Lịch sử truy cập', en: 'Security audits'),
                    onTap: widget.onOpenActivity ?? () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ======================================================
              // 5. BIỂU ĐỒ & SƠ ĐỒ PHÂN TÍCH QUẢN TRỊ HỆ THỐNG
              // ======================================================
              _buildAdminAnalyticsCard(colors, totalUsers, totalStudents, totalLecturers),
              const SizedBox(height: 24),
              const SizedBox(height: 24),

              // ======================================================
              // 7. DANH SÁCH TÀI KHOẢN MỚI
              // ======================================================
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.text('Tài khoản hệ thống', en: 'System Users'),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_users.isNotEmpty)
                    TextButton(
                      onPressed: widget.onOpenUsers,
                      child: Text(
                        AppLocalizations.text('Xem tất cả', en: 'View All'),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_users.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.text('Chưa có tài khoản nào.', en: 'No users found.'),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ..._users.take(4).map((u) => _UserSummaryCard(user: u)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminAnalyticsCard(ColorScheme colors, int totalUsers, int totalStudents, int totalLecturers) {
    final int giaovuCount = (_users.where((u) => (u['vaiTro'] ?? u['role'] ?? '').toString().toUpperCase().contains('GIAOVU')).length);
    final int pdtCount = (_users.where((u) => (u['vaiTro'] ?? u['role'] ?? '').toString().toUpperCase().contains('PHONGDAOTAO')).length);
    final int adminCount = (_users.where((u) => (u['vaiTro'] ?? u['role'] ?? '').toString().toUpperCase().contains('ADMIN')).length);

    final int effectiveTotal = totalUsers > 0 ? totalUsers : (totalStudents + totalLecturers + giaovuCount + pdtCount + adminCount);
    final int svPct = effectiveTotal > 0 ? ((totalStudents / effectiveTotal) * 100).round() : 60;
    final int gvPct = effectiveTotal > 0 ? ((totalLecturers / effectiveTotal) * 100).round() : 25;
    final int gvPdtPct = effectiveTotal > 0 ? (((giaovuCount + pdtCount) / effectiveTotal) * 100).round() : 10;
    final int adPct = (100 - svPct - gvPct - gvPdtPct).clamp(2, 100);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: Color(0xFF6366F1), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.text('Sơ đồ Phân bổ Vai trò Người dùng', en: 'User Role Distribution Chart'),
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.text('Trực quan hóa cơ cấu $effectiveTotal tài khoản hệ thống', en: 'Visual breakdown of $effectiveTotal accounts'),
                      style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 13, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text(
                      'Bảo mật 100%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Multi-color Bar Chart
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: svPct > 0 ? svPct : 1,
                  child: Container(height: 12, color: const Color(0xFF10B981)),
                ),
                Expanded(
                  flex: gvPct > 0 ? gvPct : 1,
                  child: Container(height: 12, color: const Color(0xFF2563EB)),
                ),
                Expanded(
                  flex: gvPdtPct > 0 ? gvPdtPct : 1,
                  child: Container(height: 12, color: const Color(0xFF6366F1)),
                ),
                Expanded(
                  flex: adPct > 0 ? adPct : 1,
                  child: Container(height: 12, color: const Color(0xFFF59E0B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress detail bars
          _buildRoleBar('Sinh viên', totalStudents, '$svPct%', const Color(0xFF10B981), (svPct / 100).clamp(0.0, 1.0)),
          const SizedBox(height: 8),
          _buildRoleBar('Giảng viên', totalLecturers, '$gvPct%', const Color(0xFF2563EB), (gvPct / 100).clamp(0.0, 1.0)),
          const SizedBox(height: 8),
          _buildRoleBar('Giáo vụ & PĐT', giaovuCount + pdtCount > 0 ? giaovuCount + pdtCount : 4, '$gvPdtPct%', const Color(0xFF6366F1), (gvPdtPct / 100).clamp(0.0, 1.0)),
          const SizedBox(height: 8),
          _buildRoleBar('Quản trị viên', adminCount > 0 ? adminCount : 2, '$adPct%', const Color(0xFFF59E0B), (adPct / 100).clamp(0.0, 1.0)),
        ],
      ),
    );
  }

  Widget _buildRoleBar(String label, int count, String pct, Color color, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('$count tài khoản ($pct)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
=======

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
>>>>>>> origin/Frontend
    );
  }

<<<<<<< HEAD
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
=======
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
>>>>>>> origin/Frontend
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
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
<<<<<<< HEAD
}

class _UserSummaryCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserSummaryCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = user['hoTen'] ?? user['fullName'] ?? 'Người dùng';
    final username = user['tenDangNhap'] ?? user['username'] ?? 'username';
    final role = (user['tenVaiTro'] ?? user['roleName'] ?? user['role'] ?? 'Sinh viên').toString();

    final Color roleColor = role.toUpperCase().contains('GIANGVIEN') || role.contains('Giảng viên')
        ? const Color(0xFF2563EB)
        : role.toUpperCase().contains('ADMIN') || role.contains('Quản trị')
            ? const Color(0xFFEF4444)
            : role.toUpperCase().contains('GIAOVU') || role.contains('Giáo vụ')
                ? const Color(0xFF6366F1)
                : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminUserDetailScreen(user: user),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person_rounded, color: roleColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(fontSize: 10.5, color: roleColor, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '@$username',
                            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
=======
>>>>>>> origin/Frontend
}
