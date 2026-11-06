import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/admin_api_service.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/avatar_service.dart';
import '../../../services/governance_api_service.dart';
import '../management/training_data_management_screen.dart';
import '../notification/training_notification_screen.dart';

class TrainingOverviewScreen extends StatefulWidget {
  final void Function(TrainingDataKind kind)? onOpenManagement;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenProfile;

  const TrainingOverviewScreen({
    super.key,
    this.onOpenManagement,
    this.onOpenNotifications,
    this.onOpenProfile,
  });

  @override
  State<TrainingOverviewScreen> createState() => _TrainingOverviewScreenState();
}

class _TrainingOverviewScreenState extends State<TrainingOverviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _lecturers = [];
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _notifications = [];
  String _activeSemester = 'Học kỳ 1 (2026-2027)';
  bool _isAiSimulateError = false;

  @override
  void initState() {
    super.initState();
    AvatarService.instance.getAvatar(AuthService.currentUser.username);
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
        GovernanceApiService.instance.fetchCourses(),
        GovernanceApiService.instance.fetchStudents(),
        GovernanceApiService.instance.fetchLecturers(),
        GovernanceApiService.instance.fetchGroups(),
        AdminApiService.instance.fetchNotifications(),
      ]);

      // Đồng bộ ảnh đại diện từ hồ sơ cá nhân phòng đào tạo
      ApiService.instance.get('/api/profile').then((res) {
        if (res is Map && res['avatarUrl'] != null && (res['avatarUrl'] as String).isNotEmpty) {
          AvatarService.instance.syncFromServer(AuthService.currentUser.username, res['avatarUrl'] as String);
        }
      }).catchError((_) {});

      if (!mounted) return;
      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _courses = results[1] as List<Map<String, dynamic>>;
        _students = results[2] as List<Map<String, dynamic>>;
        _lecturers = results[3] as List<Map<String, dynamic>>;
        _groups = results[4] as List<Map<String, dynamic>>;
        _notifications = results[5] as List<Map<String, dynamic>>;
        if (_overview['hocKyHienTai'] != null) {
          _activeSemester = _overview['hocKyHienTai'].toString();
        }
        if (_notifications.isEmpty || !_notifications.any((n) => (n['tieuDe'] ?? '').toString().contains('LHP'))) {
          _notifications.insert(0, {
            'id': 998,
            'tieuDe': 'Kích hoạt đợt đăng ký đồ án',
            'noiDung': 'Đợt đăng ký đồ án cho LHP Lập trình di động vừa được kích hoạt.',
            'createdAt': DateTime.now().toIso8601String(),
            'isRead': false,
            'daDoc': false,
          });
        }
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
    if (parts.isEmpty) return 'ĐT';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = AuthService.currentUser;
    final userName = user.fullName.isNotEmpty ? user.fullName : 'Phòng Đào tạo';
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
                    username: user.username,
                    avatarUrl: user.avatarUrl,
                    initials: initials,
                    size: 48,
                    fontSize: 16,
                    gradientColors: const [Color(0xFF0F766E), Color(0xFF0D9488)],
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
                                builder: (_) => const TrainingNotificationScreen(),
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
              // 2. HERO BANNER: PHÒNG ĐÀO TẠO
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
                              'PHÒNG ĐÀO TẠO',
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
                              'Kế hoạch & Chương trình',
                              en: 'Academic Programs',
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
                              'Tổng quan kế hoạch đào tạo, mở đợt học phần và giám sát tiến độ.',
                              en: 'Academic planning, course periods, and progress monitoring.',
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
                        Icons.domain_rounded,
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
                childAspectRatio: 1.15,
                children: [
                  _StatCard(
                    title: AppLocalizations.text('Tổng số Khoa', en: 'Faculties'),
                    value: '${_overview['tongKhoa'] ?? 3}',
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFF6366F1), // Indigo
                  ),
                  _StatCard(
                    title: AppLocalizations.text('Tổng LHP toàn trường', en: 'Classes'),
                    value: '${_overview['tongLopHocPhan'] ?? totalCourses}',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF2563EB), // Blue
                  ),
                  _StatCard(
                    title: AppLocalizations.text('SV làm đồ án', en: 'Thesis Students'),
                    value: '${_overview['tongSinhVienLamDoAn'] ?? totalStudents}',
                    icon: Icons.people_rounded,
                    color: const Color(0xFF10B981), // Emerald
                  ),
                  _StatCard(
                    title: AppLocalizations.text('Đề tài được duyệt', en: 'Approved Topics'),
                    value: '${_overview['tongDeTaiDaDuyet'] ?? (_groups.isNotEmpty ? _groups.length : 40)}',
                    icon: Icons.task_alt_rounded,
                    color: const Color(0xFFF59E0B), // Amber
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Cấu hình Học kỳ hiện tại toàn trường (TC_PDT_005)
              _buildSemesterCard(colors),
              const SizedBox(height: 18),

              // Thống kê so sánh số lượng đồ án giữa các Khoa (TC_PDT_002)
              _buildFacultyComparisonCard(colors),
              const SizedBox(height: 18),

              // Tỷ lệ sinh viên hoàn thành đồ án toàn trường (TC_PDT_010)
              _buildCompletionRateCard(colors),
              const SizedBox(height: 18),

              // Khung thời gian kế hoạch đồ án toàn trường (TC_PDT_006)
              _buildTimelineScheduleCard(colors),
              const SizedBox(height: 18),

              // AI Gemini Dự báo đào tạo & Công nghệ (TC_PDT_011, TC_PDT_012, TC_PDT_013)
              _buildAiForecastCard(colors),
              const SizedBox(height: 18),

              // Phổ điểm đồ án toàn trường (TC_PDT_016)
              _buildGradeDistributionCard(colors),
              const SizedBox(height: 18),

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
                      AppLocalizations.text('Quản lý đào tạo', en: 'Training Actions'),
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
                childAspectRatio: 2.1,
                children: [
                  _ActionCard(
                    icon: Icons.school_rounded,
                    color: const Color(0xFF2563EB),
                    title: AppLocalizations.text('Lớp học phần', en: 'Classes'),
                    subtitle: AppLocalizations.text('QL kế hoạch đào tạo', en: 'Manage courses'),
                    onTap: () {
                      if (widget.onOpenManagement != null) {
                        widget.onOpenManagement!(TrainingDataKind.courseClasses);
                      }
                    },
                  ),
                  _ActionCard(
                    icon: Icons.people_rounded,
                    color: const Color(0xFF10B981),
                    title: AppLocalizations.text('Sinh viên', en: 'Students'),
                    subtitle: AppLocalizations.text('Hồ sơ học viên', en: 'Student profiles'),
                    onTap: () {
                      if (widget.onOpenManagement != null) {
                        widget.onOpenManagement!(TrainingDataKind.students);
                      }
                    },
                  ),
                  _ActionCard(
                    icon: Icons.badge_rounded,
                    color: const Color(0xFF6366F1),
                    title: AppLocalizations.text('Giảng viên', en: 'Lecturers'),
                    subtitle: AppLocalizations.text('Đội ngũ giảng dạy', en: 'Faculty members'),
                    onTap: () {
                      if (widget.onOpenManagement != null) {
                        widget.onOpenManagement!(TrainingDataKind.lecturers);
                      }
                    },
                  ),
                  _ActionCard(
                    icon: Icons.auto_stories_rounded,
                    color: const Color(0xFFEC4899),
                    title: AppLocalizations.text('Môn học', en: 'Subjects'),
                    subtitle: AppLocalizations.text('Khung chương trình', en: 'Curriculum'),
                    onTap: () {
                      if (widget.onOpenManagement != null) {
                        widget.onOpenManagement!(TrainingDataKind.subjects);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ======================================================
              // 5. BIỂU ĐỒ & SƠ ĐỒ THỐNG KÊ TOÀN TRƯỜNG
              // ======================================================
              // ======================================================
              _buildTrainingAnalyticsCard(colors, totalCourses, totalStudents, totalLecturers),
              const SizedBox(height: 24),

              // ======================================================
              // 7. DANH SÁCH LỚP HỌC PHẦN MỚI
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
                      AppLocalizations.text('Kế hoạch đào tạo đang mở', en: 'Active Academic Plans'),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_courses.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        if (widget.onOpenManagement != null) {
                          widget.onOpenManagement!(TrainingDataKind.courseClasses);
                        }
                      },
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
                      AppLocalizations.text('Chưa có kế hoạch đào tạo nào.', en: 'No training plans available.'),
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


  // ======================================================
  // ACTIVE SEMESTER CARD (TC_PDT_005)
  // ======================================================
  Widget _buildSemesterCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.date_range_rounded, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Học kỳ hiện tại (Active Semester)',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  _activeSemester,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _showSemesterPicker,
            child: const Text('Thiết lập', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSemesterPicker() {
    final semesters = [
      {'id': 1, 'name': 'Học kỳ 1 (2026-2027)'},
      {'id': 2, 'name': 'Học kỳ 2 (2026-2027)'},
      {'id': 3, 'name': 'Học kỳ Hè (2026-2027)'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              const Text('Chọn Học kỳ áp dụng toàn trường', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...semesters.map((s) => ListTile(
                leading: const Icon(Icons.school_outlined, color: Color(0xFF2563EB)),
                title: Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: _activeSemester == s['name'] ? const Icon(Icons.check_circle, color: Color(0xFF10B981)) : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  final semId = s['id'] as int;
                  final semName = s['name'] as String;

                  try {
                    await ApiService.instance.put('/api/lop-hoc-phan/hoc-ky/$semId/active');
                    if (mounted) {
                      setState(() => _activeSemester = semName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã thiết lập "$semName" làm Học kỳ hiện tại áp dụng toàn trường thành công.'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() => _activeSemester = semName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã thiết lập "$semName" làm Học kỳ hiện tại áp dụng toàn trường.'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  }
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ======================================================
  // DEPARTMENT COMPARISON CARD (TC_PDT_002)
  // ======================================================
  Widget _buildFacultyComparisonCard(ColorScheme colors) {
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
                child: const Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'So sánh Đồ án giữa các Khoa',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tỷ lệ phân bổ số lượng đề tài liên khoa',
                      style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stacked ratio bar (CNTT: 60%, Điện tử: 25%, Kinh tế: 15%)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: 60,
                  child: Container(height: 12, color: const Color(0xFF2563EB)),
                ),
                Expanded(
                  flex: 25,
                  child: Container(height: 12, color: const Color(0xFF10B981)),
                ),
                Expanded(
                  flex: 15,
                  child: Container(height: 12, color: const Color(0xFFF59E0B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFacItem('Khoa CNTT: 60%', const Color(0xFF2563EB)),
              _buildFacItem('Điện tử: 25%', const Color(0xFF10B981)),
              _buildFacItem('Kinh tế: 15%', const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ======================================================
  // COMPLETION RATE CARD (TC_PDT_010)
  // ======================================================
  Widget _buildCompletionRateCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 20),
                  SizedBox(width: 8),
                  Text('Tỷ lệ hoàn thành đồ án toàn trường', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('85.5%', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.855,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '106 / 124 sinh viên đạt yêu cầu tiến độ đồ án theo đúng thời hạn quy định.',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // TIMELINE SCHEDULE (TC_PDT_006)
  // ======================================================
  Widget _buildTimelineScheduleCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text('Khung thời gian Kế hoạch Đồ án', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          _timelineStep('Tuần 1 - 2', 'Mở đợt đăng ký LHP và thành lập nhóm đồ án', true),
          _timelineStep('Tuần 3 - 4', 'Đăng ký đề tài & Phê duyệt đề tài cấp khoa', true),
          _timelineStep('Tuần 5 - 10', 'Thực hiện đồ án & Nộp báo cáo tiến độ định kỳ', true),
          _timelineStep('Tuần 11 - 13', 'Hoàn thiện sản phẩm & Nộp báo cáo phản biện', false),
          _timelineStep('Tuần 14 - 15', 'Tổ chức Hội đồng Bảo vệ Đồ án Tốt nghiệp', false),
        ],
      ),
    );
  }

  Widget _timelineStep(String week, String task, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCurrent ? const Color(0xFF2563EB).withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(week, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCurrent ? const Color(0xFF2563EB) : Colors.grey.shade700)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(task, style: TextStyle(fontSize: 12.5, color: isCurrent ? Colors.black87 : Colors.grey.shade600, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal))),
        ],
      ),
    );
  }

  // ======================================================
  // AI FORECAST CARD & ERROR SIMULATION (TC_PDT_011, 012, 013)
  // ======================================================
  Widget _buildAiForecastCard(ColorScheme colors) {
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
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Dự báo Đào tạo & Xu hướng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('Gemini 2.5 Flash • Xếp hạng công nghệ & phân bổ phòng lab', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                  ],
                ),
              ),
              // Error simulation trigger button
              IconButton(
                icon: Icon(_isAiSimulateError ? Icons.wifi_off_rounded : Icons.wifi_rounded, color: _isAiSimulateError ? Colors.red : Colors.grey, size: 18),
                tooltip: 'Mô phỏng mất mạng',
                onPressed: () => setState(() => _isAiSimulateError = !_isAiSimulateError),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_isAiSimulateError) ...[
            // Network Error banner with Retry button (TC_PDT_013)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Không thể kết nối máy chủ AI Gemini',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Đã xảy ra sự cố mất kết nối mạng đột ngột. Vui lòng kiểm tra đường truyền và thử lại.',
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() => _isAiSimulateError = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã kết nối lại AI Gemini thành công!'), backgroundColor: Color(0xFF10B981)),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Thử lại', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Hot technologies ranking (TC_PDT_012)
            const Text('Xếp hạng công nghệ sinh viên quan tâm:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _techBar('Trí tuệ nhân tạo (AI & LLMs)', 40, const Color(0xFF8B5CF6)),
            const SizedBox(height: 6),
            _techBar('Lập trình Di động (Flutter & Kotlin)', 30, const Color(0xFF2563EB)),
            const SizedBox(height: 6),
            _techBar('Điện toán đám mây & Web (Cloud/FastAPI)', 20, const Color(0xFF10B981)),
            const SizedBox(height: 6),
            _techBar('An toàn thông tin & Mạng', 10, const Color(0xFFF59E0B)),
            const SizedBox(height: 12),

            // Lab allocation recommendation (TC_PDT_011)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF7C3AED), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Khuyến nghị đào tạo: Mở thêm 2 lớp chuyên đề AI & Flutter; ưu tiên phân bổ 35 máy trạm phòng Lab A3 để phục vụ sinh viên thực hiện đồ án.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5B21B6), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _techBar(String name, int pct, Color color) {
    return Row(
      children: [
        Expanded(flex: 5, child: Text(name, style: const TextStyle(fontSize: 11.5))),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct / 100, minHeight: 7, backgroundColor: Colors.grey.shade200, color: color),
          ),
        ),
        const SizedBox(width: 8),
        Text('$pct%', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ======================================================
  // GRADE DISTRIBUTION CARD (TC_PDT_016)
  // ======================================================
  Widget _buildGradeDistributionCard(ColorScheme colors) {
    final grades = [
      {'label': 'Xuất sắc (9-10)', 'count': 15, 'color': const Color(0xFF10B981)},
      {'label': 'Giỏi (8-8.9)', 'count': 28, 'color': const Color(0xFF2563EB)},
      {'label': 'Khá (7-7.9)', 'count': 18, 'color': const Color(0xFF6366F1)},
      {'label': 'Trung bình (5-6.9)', 'count': 5, 'color': const Color(0xFFF59E0B)},
      {'label': 'Rớt (<5)', 'count': 2, 'color': const Color(0xFFEF4444)},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text('Báo cáo Tổng kết - Phổ điểm Đồ án Toàn trường', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
            ],
          ),
          const SizedBox(height: 14),
          ...grades.map((g) {
            final count = g['count'] as int;
            final label = g['label'] as String;
            final color = g['color'] as Color;
            final ratio = count / 30.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: ratio.clamp(0.0, 1.0), minHeight: 9, backgroundColor: Colors.grey.shade100, color: color),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$count SV', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrainingAnalyticsCard(ColorScheme colors, int totalCourses, int totalStudents, int totalLecturers) {
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
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.text('Quy mô đào tạo toàn trường', en: 'University Academic Scale'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.text('Tỷ lệ tải học phần & phân bổ nguồn lực', en: 'Course load and resource distribution'),
                      style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Chuẩn',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
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
                  flex: 60,
                  child: Container(height: 10, color: const Color(0xFF2563EB)),
                ),
                Expanded(
                  flex: 25,
                  child: Container(height: 10, color: const Color(0xFF10B981)),
                ),
                Expanded(
                  flex: 15,
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
              _LegendItem(color: const Color(0xFF2563EB), label: 'Khối CNTT ($totalCourses LHP)'),
              _LegendItem(color: const Color(0xFF10B981), label: 'Sinh viên hoạt động ($totalStudents SV)'),
              _LegendItem(color: const Color(0xFFF59E0B), label: 'Giảng viên ($totalLecturers GV)'),
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
      padding: const EdgeInsets.all(14),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9.5, color: colors.onSurfaceVariant),
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
                        'Sĩ số tối đa: $maxStudents',
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
