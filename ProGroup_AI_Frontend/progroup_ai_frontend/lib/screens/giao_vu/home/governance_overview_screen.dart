import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/avatar_service.dart';
import '../../../services/gemini_service.dart';
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
  Map<String, dynamic> _govOverview = {};
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isSendingReminder = false;
  bool _isAnalyzingAi = false;
  String? _aiAnalysisText;
  String? _aiErrorText;

  @override
  void initState() {
    super.initState();
    AvatarService.instance.getAvatar(AuthService.currentUser.username);
    GovernanceApiService.instance.dataVersion.addListener(_onDataChanged);
    _loadData();
  }

  @override
  void dispose() {
    GovernanceApiService.instance.dataVersion.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _loadData(forceRefresh: true);
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        GovernanceApiService.instance.fetchOverview(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchCourses(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchNotifications(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchGovernanceOverview(forceRefresh: forceRefresh),
      ]);

      // Đồng bộ ảnh đại diện từ hồ sơ cá nhân giáo vụ
      ApiService.instance.get('/api/profile').then((res) {
        if (res is Map && res['avatarUrl'] != null && (res['avatarUrl'] as String).isNotEmpty) {
          AvatarService.instance.syncFromServer(AuthService.currentUser.username, res['avatarUrl'] as String);
        }
      }).catchError((_) {});

      if (!mounted) return;
      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _courses = results[1] as List<Map<String, dynamic>>;
        _notifications = results[2] as List<Map<String, dynamic>>;
        _govOverview = results[3] as Map<String, dynamic>;
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
    final int totalStudents = _govOverview['totalStudents'] as int? ??
        _overview['tongSinhVien'] as int? ??
        _overview['totalStudents'] as int? ??
        0;
    final int totalLecturers = _govOverview['totalLecturers'] as int? ??
        _overview['tongGiangVien'] as int? ??
        _overview['totalLecturers'] as int? ??
        0;
    final int totalGroups = _govOverview['totalGroups'] as int? ??
        _overview['tongNhom'] as int? ??
        _overview['totalGroups'] as int? ??
        0;

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: () => _loadData(forceRefresh: true),
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
                    username: user.username,
                    avatarUrl: user.avatarUrl,
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
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GovernanceAssignmentScreen()),
                          );
                          _loadData(forceRefresh: true);
                        },
                  ),
                  _ActionCard(
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFF10B981),
                    title: AppLocalizations.text('Đăng ký đề tài', en: 'Registrations'),
                    subtitle: AppLocalizations.text('Theo dõi đợt nộp', en: 'Monitor topics'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GovernanceRegistrationOverviewScreen()),
                      );
                      _loadData(forceRefresh: true);
                    },
                  ),
                  _ActionCard(
                    icon: Icons.school_rounded,
                    color: const Color(0xFF6366F1),
                    title: AppLocalizations.text('Lớp học phần', en: 'Courses'),
                    subtitle: AppLocalizations.text('Danh sách khoa', en: 'Faculty courses'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GovernanceCourseScreen()),
                      );
                      _loadData(forceRefresh: true);
                    },
                  ),
                  _ActionCard(
                    icon: Icons.file_upload_rounded,
                    color: const Color(0xFFEC4899),
                    title: AppLocalizations.text('Nhập Excel/CSV', en: 'Import Data'),
                    subtitle: AppLocalizations.text('Dữ liệu sinh viên/LHP', en: 'Import students/LHP'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GovernanceImportScreen()),
                      );
                      _loadData(forceRefresh: true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ======================================================
              // 5. BIỂU ĐỒ & SƠ ĐỒ PHÂN TÍCH ĐÀO TẠO (CHART / DIAGRAM)
              // ======================================================
              _buildFacultyAnalyticsCard(colors, totalCourses, totalLecturers, totalGroups),
              const SizedBox(height: 18),
              _buildAiWorkloadCard(colors),
              const SizedBox(height: 18),
              _buildTopicSourceCard(colors),
              const SizedBox(height: 18),
              _buildOverdueReportsCard(context, colors),
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
    final assignedFromCourses = _courses.where((c) {
      final gvList = c['giangViens'] as List? ?? [];
      final gvTen = (c['giangVienTen'] ?? '').toString().trim();
      return gvList.isNotEmpty || (gvTen.isNotEmpty && gvTen != 'Chưa phân công');
    }).length;
    final assignedClasses = _govOverview['assignedClasses'] as int? ?? assignedFromCourses;
    final unassignedClasses = (_courses.length - assignedClasses).clamp(0, 999);
    final approvedGroups = _govOverview['approvedGroups'] as int? ?? 0;
    final groupsWithoutTopic = _govOverview['groupsWithoutTopic'] as int? ?? 0;
    final double assignedRatio = totalCourses > 0 ? (assignedClasses / totalCourses).clamp(0.0, 1.0) : 0.0;

    final int flexAssigned = assignedClasses > 0 ? assignedClasses : 0;
    final int flexApproved = approvedGroups > 0 ? approvedGroups : 0;
    final int flexUnassigned = (unassignedClasses + groupsWithoutTopic) > 0
        ? (unassignedClasses + groupsWithoutTopic)
        : 0;
    final bool hasAnySegment = flexAssigned > 0 || flexApproved > 0 || flexUnassigned > 0;

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
              IconButton(
                tooltip: 'Cấu hình Gemini API Key',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.vpn_key_outlined, size: 18, color: Color(0xFF7C3AED)),
                onPressed: _showGeminiKeyDialog,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(assignedRatio * 100).round()}%',
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
                if (!hasAnySegment)
                  Expanded(
                    child: Container(height: 10, color: colors.surfaceContainerHighest),
                  ),
                if (flexAssigned > 0)
                  Expanded(
                    flex: flexAssigned,
                    child: Container(height: 10, color: const Color(0xFF2563EB)),
                  ),
                if (flexApproved > 0)
                  Expanded(
                    flex: flexApproved,
                    child: Container(height: 10, color: const Color(0xFF10B981)),
                  ),
                if (flexUnassigned > 0)
                  Expanded(
                    flex: flexUnassigned,
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
              _LegendItem(color: const Color(0xFF2563EB), label: 'Đã phân công ($assignedClasses/$totalCourses LHP)'),
              _LegendItem(color: const Color(0xFF10B981), label: 'Đã duyệt đề tài ($approvedGroups/$totalGroups nhóm)'),
              _LegendItem(color: const Color(0xFFF59E0B), label: 'Chưa đề tài ($groupsWithoutTopic nhóm)'),
            ],
          ),
        ],
      ),
    );
  }


  // ======================================================
  // AI GEMINI WORKLOAD ANALYSIS (TC_GVK_019 & TC_GVK_020)
  // ======================================================
  Future<void> _showGeminiKeyDialog() async {
    const gemini = GeminiService();
    final currentKey = await gemini.getApiKey();
    if (!mounted) return;
    final controller = TextEditingController(text: currentKey.startsWith('AIza') ? currentKey : '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_outlined, color: Color(0xFF7C3AED)),
            SizedBox(width: 8),
            Expanded(child: Text('Cấu hình Gemini API Key', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dán API Key hợp lệ từ Google AI Studio (bắt đầu bằng AIza...) để kích hoạt phân tích AI.',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIza...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isEmpty) return;
              await gemini.saveApiKey(key);
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Lưu & Phân tích lại'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved == true && mounted) {
      await _runAiWorkloadAnalysis();
    }
  }

  Future<void> _runAiWorkloadAnalysis() async {
    if (_isAnalyzingAi) return;
    final totalStudents = _govOverview['totalStudents'] as int? ??
        (_overview['tongSinhVien'] as int? ?? 0);
    final totalLecturers = _govOverview['totalLecturers'] as int? ??
        (_overview['tongGiangVien'] as int? ?? 0);
    final totalGroups = _govOverview['totalGroups'] as int? ??
        (_overview['tongNhom'] as int? ?? 0);

    setState(() {
      _isAnalyzingAi = true;
      _aiErrorText = null;
    });

    try {
      final result = await const GeminiService().analyzeAcademicWorkload(
        totalCourses: _courses.length,
        totalLecturers: totalLecturers,
        totalGroups: totalGroups,
        totalStudents: totalStudents,
        rethrowOnError: true,
      );
      if (!mounted) return;
      setState(() {
        _aiAnalysisText = result;
        _isAnalyzingAi = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiErrorText = e.toString().replaceAll('Exception: ', '');
        _isAnalyzingAi = false;
      });
    }
  }

  Widget _buildAiWorkloadCard(ColorScheme colors) {
    final totalStudents = _govOverview['totalStudents'] as int? ??
        (_overview['tongSinhVien'] as int? ?? 0);
    final totalLecturers = _govOverview['totalLecturers'] as int? ??
        (_overview['tongGiangVien'] as int? ?? 0);
    final ratioText = totalLecturers > 0
        ? '${(totalStudents / totalLecturers).toStringAsFixed(1)}:1'
        : '—';
    final unassigned = _govOverview['unassignedClasses'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Phân tích Khối lượng Học vụ',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Gemini AI • Tỷ lệ SV/GV và cảnh báo phân công',
                      style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cấu hình Gemini API Key',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.vpn_key_outlined, size: 18, color: Color(0xFF7C3AED)),
                onPressed: _showGeminiKeyDialog,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ratioText,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    unassigned > 0
                        ? 'Cảnh báo: Hiện còn $unassigned lớp học phần chưa được phân công giảng viên phụ trách.'
                        : 'Tất cả ${_courses.length} lớp học phần hiện đều đã được phân công giảng viên phụ trách.',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF92400E), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF4F46E5), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tổng hợp hiện tại: $totalStudents sinh viên / $totalLecturers giảng viên. Tỷ lệ trung bình $ratioText.',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF3730A3), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          if (_aiErrorText != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Không thể phân tích bằng Gemini AI: $_aiErrorText',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_aiAnalysisText != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.25)),
              ),
              child: Text(
                _aiAnalysisText!,
                style: TextStyle(fontSize: 12.5, color: colors.onSurface, height: 1.4),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isAnalyzingAi ? null : _runAiWorkloadAnalysis,
              style: FilledButton.styleFrom(
                backgroundColor: _aiErrorText != null ? const Color(0xFFDC2626) : const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isAnalyzingAi
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_aiErrorText != null ? Icons.refresh_rounded : Icons.auto_awesome, size: 18),
              label: Text(
                _isAnalyzingAi
                    ? 'Đang phân tích với Gemini AI...'
                    : (_aiErrorText != null
                        ? 'Thử lại phân tích AI'
                        : (_aiAnalysisText != null ? 'Phân tích lại với Gemini AI' : 'Phân tích ngay với Gemini AI')),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // TOPIC SOURCE & APPROVAL RATIO (TC_GVK_013) - REAL DATA
  // ======================================================
  Widget _buildTopicSourceCard(ColorScheme colors) {
    final gvTopics = _govOverview['gvTopics'] as int? ?? 0;
    final svTopics = _govOverview['svTopics'] as int? ?? 0;
    final gvPercent = ((_govOverview['gvPercent'] ?? 0) as num).toDouble();
    final svPercent = ((_govOverview['svPercent'] ?? 0) as num).toDouble();
    final approveRate = ((_govOverview['approveRate'] ?? 0) as num).toDouble();
    final approvedRegs = _govOverview['approvedRegs'] as int? ?? 0;
    final totalRegs = _govOverview['totalRegs'] as int? ?? 0;

    final gvFlex = gvTopics > 0 ? gvTopics : 0;
    final svFlex = svTopics > 0 ? svTopics : 0;
    final hasAnyTopic = gvFlex > 0 || svFlex > 0;

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
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.topic_outlined, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Báo cáo Đề tài Toàn khoa',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tỷ lệ nguồn gốc đề tài & tỷ lệ duyệt thực tế',
                      style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cấu hình Gemini API Key',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.vpn_key_outlined, size: 18, color: Color(0xFF7C3AED)),
                onPressed: _showGeminiKeyDialog,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  totalRegs > 0 ? 'Duyệt $approveRate% ($approvedRegs/$totalRegs)' : 'Duyệt $approveRate%',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (!hasAnyTopic)
                  Expanded(
                    child: Container(height: 12, color: colors.surfaceContainerHighest),
                  ),
                if (gvFlex > 0)
                  Expanded(
                    flex: gvFlex,
                    child: Container(height: 12, color: const Color(0xFF2563EB)),
                  ),
                if (svFlex > 0)
                  Expanded(
                    flex: svFlex,
                    child: Container(height: 12, color: const Color(0xFF10B981)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('GV đề xuất: $gvPercent% ($gvTopics đề tài)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('SV tự đề xuất: $svPercent% ($svTopics đề tài)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================================================
  // OVERDUE PROGRESS REPORT WARNING (TC_GVK_021) - REAL DATA
  // ======================================================
  Future<void> _confirmAndSendAllReminders(List<Map<String, dynamic>> unsubmitted) async {
    if (unsubmitted.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Expanded(child: Text('Xác nhận gửi đôn đốc', style: TextStyle(fontSize: 16))),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn gửi thông báo đôn đốc nộp báo cáo tiến độ tới ${unsubmitted.length} nhóm chưa nộp bài?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Xác nhận gửi'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSendingReminder = true);
    try {
      final res = await GovernanceApiService.instance.sendGroupReminders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((res['message'] ?? 'Đã gửi thông báo đôn đốc thành công.').toString()),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi thông báo: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    } finally {
      if (mounted) setState(() => _isSendingReminder = false);
    }
  }

  Widget _buildOverdueReportsCard(BuildContext context, ColorScheme colors) {
    final rawUnsubmitted = _govOverview['groupsNotSubmitted'] as List? ?? [];
    final unsubmitted = rawUnsubmitted
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unsubmitted.isEmpty
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.03),
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
                  color: (unsubmitted.isEmpty ? const Color(0xFF10B981) : Colors.red)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  unsubmitted.isEmpty ? Icons.check_circle_outline : Icons.timer_off_outlined,
                  color: unsubmitted.isEmpty ? const Color(0xFF059669) : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theo dõi nhóm chưa nộp Báo cáo Tiến độ',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      unsubmitted.isEmpty
                          ? 'Tất cả nhóm đã nộp báo cáo'
                          : '${unsubmitted.length} nhóm chưa có báo cáo tiến độ',
                      style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cấu hình Gemini API Key',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.vpn_key_outlined, size: 18, color: Color(0xFF7C3AED)),
                onPressed: _showGeminiKeyDialog,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (unsubmitted.isEmpty ? const Color(0xFF10B981) : Colors.red)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${unsubmitted.length} Nhóm',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: unsubmitted.isEmpty ? const Color(0xFF059669) : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          if (unsubmitted.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...unsubmitted.take(4).map((g) {
              final gName = '${g['tenNhom'] ?? 'Nhóm'} · ${g['maLop'] ?? g['tenLop'] ?? ''}';
              final topic = (g['tenDeTai'] ?? 'Chưa có đề tài').toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildOverdueItem(gName, topic, 'Chưa nộp'),
              );
            }),
            if (unsubmitted.length > 4)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Và ${unsubmitted.length - 4} nhóm khác... (Xem chi tiết trong Theo dõi đăng ký)',
                  style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSendingReminder ? null : () => _confirmAndSendAllReminders(unsubmitted),
                icon: _isSendingReminder
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 16, color: Color(0xFF2563EB)),
                label: Text(
                  _isSendingReminder ? 'Đang gửi...' : 'Gửi thông báo đôn đốc toàn bộ (${unsubmitted.length})',
                  style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverdueItem(String group, String topic, String overdueText) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A5F))),
                Text(topic, style: const TextStyle(fontSize: 11.5, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
            child: Text(overdueText, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
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
    final name = (course['tenLopHocPhan'] ?? course['tenHocPhan'] ?? 'Lớp học phần').toString();
    final code = (course['maLopHocPhan'] ?? course['maHocPhan'] ?? 'Mã LHP').toString();
    final maxStudents = course['soLuongToiDa'] ?? 45;
    final currentStudents = course['soSinhVien'] ?? course['soLuongSinhVien'] ?? 0;
    final gvList = course['giangViens'] as List? ?? [];
    final rawGv = (course['giangVienTen'] ?? '').toString().trim();
    final gvName = gvList.isNotEmpty
        ? (gvList.first['hoTen'] ?? 'Chưa phân công').toString()
        : (rawGv.isNotEmpty ? rawGv : 'Chưa phân công');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GovernanceCourseScreen()),
        ),
        child: Container(
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
                            '$currentStudents/$maxStudents SV · $gvName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: gvName == 'Chưa phân công'
                                  ? const Color(0xFFD97706)
                                  : colors.onSurfaceVariant,
                            ),
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
        ),
      ),
    );
  }
}
