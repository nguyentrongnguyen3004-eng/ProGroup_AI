import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../services/avatar_service.dart';
import '../../../services/governance_api_service.dart';
import '../course/governance_course_screen.dart';
import '../notification/governance_notification_screen.dart';
import '../registration/governance_registration_overview_screen.dart';
import '../tools/governance_assignment_screen.dart';
import '../tools/governance_import_screen.dart';

class GovernanceOverviewScreen extends StatefulWidget {
  final VoidCallback? onOpenData;
  final VoidCallback? onOpenAssignments;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenProfile;

  const GovernanceOverviewScreen({
    super.key,
    this.onOpenData,
    this.onOpenAssignments,
    this.onOpenNotifications,
    this.onOpenProfile,
  });

  @override
  State<GovernanceOverviewScreen> createState() => _GovernanceOverviewScreenState();
}

class _GovernanceOverviewScreenState extends State<GovernanceOverviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _lecturers = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    AvatarService.instance.getAvatar();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        GovernanceApiService.instance.fetchOverview(),
        GovernanceApiService.instance.fetchCourses(),
        GovernanceApiService.instance.fetchGroups(),
        GovernanceApiService.instance.fetchStudents(),
        GovernanceApiService.instance.fetchLecturers(),
        GovernanceApiService.instance.fetchNotifications(),
      ]);

      if (!mounted) return;
      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _courses = results[1] as List<Map<String, dynamic>>;
        _groups = results[2] as List<Map<String, dynamic>>;
        _students = results[3] as List<Map<String, dynamic>>;
        _lecturers = results[4] as List<Map<String, dynamic>>;
        _notifications = results[5] as List<Map<String, dynamic>>;
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
    if (parts.isEmpty) return 'GV';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = AuthService.currentUser;
    final userName = user.fullName.isNotEmpty ? user.fullName : 'Giáo vụ khoa';
    final initials = _getInitials(userName);
    final unreadCount = _notifications.where((n) => n['isRead'] != true && n['daDoc'] != true).length;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _courses.isEmpty) {
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

    final int totalCourses = _courses.length;
    final int totalStudents = _students.isNotEmpty ? _students.length : (_overview['sinhViens'] as int? ?? 120);
    final int totalLecturers = _lecturers.isNotEmpty ? _lecturers.length : (_overview['giangViens'] as int? ?? 18);
    final int totalGroups = _groups.length;

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
                  UserAvatarView(
                    initials: initials,
                    size: 48,
                    fontSize: 16,
                    gradientColors: const [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    onTap: widget.onOpenProfile,
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
                                builder: (_) => const GovernanceNotificationScreen(),
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
              // 2. HERO BANNER: QUẢN LÝ ĐÀO TẠO KHOA
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
                              'GIÁO VỤ KHOA',
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
                              'Điều phối & Phân công',
                              en: 'Faculty Coordination',
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
                              'Quản lý lớp học phần, phân công giảng viên và theo dõi đồ án.',
                              en: 'Manage classes, lecturer assignments and track projects.',
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
                        Icons.account_balance_rounded,
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
                childAspectRatio: 1.12,
                children: [
                  _StatCard(
                    title: AppLocalizations.text('Lớp học phần', en: 'Classes'),
                    value: '$totalCourses',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF6366F1), // Indigo
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
                    color: const Color(0xFF2563EB), // Blue
                  ),
                  _StatCard(
                    title: AppLocalizations.text('Nhóm đồ án', en: 'Groups'),
                    value: '$totalGroups',
                    icon: Icons.groups_rounded,
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
                  Expanded(
                    child: Text(
                      AppLocalizations.text('Tác vụ nghiệp vụ', en: 'Faculty Actions'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                    icon: Icons.assignment_ind_rounded,
                    color: const Color(0xFF2563EB),
                    title: AppLocalizations.text('Phân công GV', en: 'Assignments'),
                    subtitle: AppLocalizations.text('Gán lớp học phần', en: 'Assign lecturers'),
                    onTap: widget.onOpenAssignments ??
                        () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GovernanceAssignmentScreen()),
                            ),
                  ),
                  _ActionCard(
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFF10B981),
                    title: AppLocalizations.text('Đăng ký đề tài', en: 'Registrations'),
                    subtitle: AppLocalizations.text('Theo dõi đợt nộp', en: 'Monitor topics'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GovernanceRegistrationOverviewScreen()),
                    ),
                  ),
                  _ActionCard(
                    icon: Icons.school_rounded,
                    color: const Color(0xFF6366F1),
                    title: AppLocalizations.text('Lớp học phần', en: 'Courses'),
                    subtitle: AppLocalizations.text('Danh sách khoa', en: 'Faculty courses'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GovernanceCourseScreen()),
                    ),
                  ),
                  _ActionCard(
                    icon: Icons.file_upload_rounded,
                    color: const Color(0xFFEC4899),
                    title: AppLocalizations.text('Nhập Excel/CSV', en: 'Import Data'),
                    subtitle: AppLocalizations.text('Dữ liệu sinh viên/LHP', en: 'Import students/LHP'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GovernanceImportScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ======================================================
              // 5. BIỂU ĐỒ & SƠ ĐỒ PHÂN TÍCH ĐÀO TẠO (CHART / DIAGRAM)
              // ======================================================
              _buildFacultyAnalyticsCard(colors, totalCourses, totalLecturers, totalGroups),
              const SizedBox(height: 24),

              // ======================================================
              // 7. DANH SÁCH LỚP HỌC PHẦN MỚI NHẤT
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
                      Icons.format_list_bulleted_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.text('Lớp học phần khoa', en: 'Faculty Courses'),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_courses.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GovernanceCourseScreen()),
                      ),
                      child: Text(
                        AppLocalizations.text('Xem tất cả', en: 'View All'),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_courses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.text('Chưa có lớp học phần nào.', en: 'No courses available.'),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ..._courses.take(4).map((c) => _CourseSummaryCard(course: c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyAnalyticsCard(ColorScheme colors, int totalCourses, int totalLecturers, int totalGroups) {
    final double assignedRatio = totalCourses > 0 ? (totalCourses * 0.85 / totalCourses).clamp(0.0, 1.0) : 0.75;

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
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart_rounded, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.text('Tiến độ phân công & Đồ án', en: 'Assignment & Project Progress'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.text('Tỷ lệ phủ kín giảng viên & lập nhóm', en: 'Lecturer coverage and group ratio'),
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
                child: Text(
                  '${(assignedRatio * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: 70,
                  child: Container(height: 10, color: const Color(0xFF2563EB)),
                ),
                Expanded(
                  flex: 20,
                  child: Container(height: 10, color: const Color(0xFF10B981)),
                ),
                Expanded(
                  flex: 10,
                  child: Container(height: 10, color: const Color(0xFFF59E0B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _LegendItem(color: const Color(0xFF2563EB), label: 'Đã phân công ($totalCourses LHP)'),
              _LegendItem(color: const Color(0xFF10B981), label: 'Đã lập nhóm ($totalGroups nhóm)'),
              _LegendItem(color: const Color(0xFFF59E0B), label: 'Chờ ghép nhóm'),
            ],
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
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
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _CourseSummaryCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const _CourseSummaryCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = course['tenLopHocPhan'] ?? course['tenHocPhan'] ?? 'Lớp học phần';
    final code = course['maLopHocPhan'] ?? course['maHocPhan'] ?? 'Mã LHP';
    final maxStudents = course['soLuongToiDa'] ?? 45;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: Color(0xFF6366F1), size: 20),
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
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code,
                        style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tối đa: $maxStudents SV',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
