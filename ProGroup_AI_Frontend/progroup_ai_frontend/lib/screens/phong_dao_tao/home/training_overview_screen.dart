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
  String _activeSemester = 'Đang tải...';
  List<Map<String, dynamic>> _semesterList = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    AvatarService.instance.getAvatar(AuthService.currentUser.username);
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });


    try {
      final results = await Future.wait([
        AdminApiService.instance.fetchOverview(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchCourses(forceRefresh: forceRefresh),
        AdminApiService.instance.fetchNotifications(forceRefresh: forceRefresh),
        ApiService.instance.get('/api/lop-hoc-phan/hoc-ky'),
      ]);

      // Đồng bộ ảnh đại diện từ hồ sơ cá nhân phòng đào tạo
      ApiService.instance.get('/api/profile').then((res) {
        if (res is Map && res['avatarUrl'] != null && (res['avatarUrl'] as String).isNotEmpty) {
          AvatarService.instance.syncFromServer(AuthService.currentUser.username, res['avatarUrl'] as String);
        }
      }).catchError((_) {});

      if (!mounted) return;

      // Parse danh sách học kỳ thực từ API
      final rawSemesters = results[3];
      List<Map<String, dynamic>> semesterList = [];
      if (rawSemesters is List) {
        semesterList = rawSemesters.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      // Học kỳ active = TrangThai == true
      final activeSem = semesterList.firstWhere(
        (s) => s['trangThai'] == true,
        orElse: () => semesterList.isNotEmpty ? semesterList.first : {},
      );
      String activeSemName = 'Chưa thiết lập';
      if (activeSem.isNotEmpty) {
        final tenHk = activeSem['tenHocKy'] ?? '';
        final namHoc = activeSem['namHoc'] ?? '';
        activeSemName = namHoc.isNotEmpty ? '$tenHk ($namHoc)' : tenHk;
      }

      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _courses = results[1] as List<Map<String, dynamic>>;
        _notifications = results[2] as List<Map<String, dynamic>>;
        _semesterList = semesterList;
        _activeSemester = activeSemName.isNotEmpty ? activeSemName : (_overview['hocKyHienTai']?.toString() ?? 'Chưa thiết lập');
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
                      minimumSize: const Size(120, 44),
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
    final int totalStudents = _overview['tongSinhVien'] as int? ?? _overview['totalStudents'] as int? ?? _overview['sinhViens'] as int? ?? 120;
    final int totalLecturers = _overview['tongGiangVien'] as int? ?? _overview['totalLecturers'] as int? ?? _overview['giangViens'] as int? ?? 18;

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
                            _loadData(forceRefresh: true);
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
                    value: '${_overview['tongDeTaiDaDuyet'] ?? _overview['tongNhom'] ?? 40}',
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
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _showSemesterPicker,
            child: const Text('Thiết lập', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSemesterPicker() async {
    var list = _semesterList;
    if (list.isEmpty) {
      try {
        final raw = await ApiService.instance.get('/api/lop-hoc-phan/hoc-ky');
        if (raw is List) {
          list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (mounted) {
            setState(() => _semesterList = list);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tải danh sách học kỳ: ${e.toString().replaceAll("Exception: ", "")}'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có dữ liệu học kỳ trong hệ thống.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    String formatRange(dynamic start, dynamic end) {
      final d1 = DateTime.tryParse((start ?? '').toString());
      final d2 = DateTime.tryParse((end ?? '').toString());
      if (d1 == null || d2 == null) return '';
      String f(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      return '${f(d1)} - ${f(d2)}';
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                const Text('Chọn Học kỳ áp dụng toàn trường', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Chỉ có duy nhất 1 học kỳ Đang mở tại một thời điểm',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ...list.map((s) {
                  final semId = s['hocKyId'] as int? ?? 0;
                  final ten = (s['tenHocKy'] ?? '').toString();
                  final nam = (s['namHoc'] ?? '').toString();
                  final semName = nam.isNotEmpty ? '$ten ($nam)' : ten;
                  final isActive = s['trangThai'] == true;
                  final statusText = (s['trangThaiText'] ?? (isActive ? 'Đang mở' : 'Đã đóng')).toString();
                  final range = formatRange(s['ngayBatDau'], s['ngayKetThuc']);

                  return ListTile(
                    leading: Icon(
                      Icons.school_outlined,
                      color: isActive ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(semName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF10B981).withValues(alpha: 0.14)
                                : Colors.grey.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isActive ? const Color(0xFF059669) : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: range.isNotEmpty ? Text(range, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)) : null,
                    trailing: isActive ? const Icon(Icons.check_circle, color: Color(0xFF10B981)) : null,
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (isActive) return;

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Xác nhận đổi Học kỳ hiện tại'),
                          content: Text(
                            'Thiết lập "$semName" làm Học kỳ hiện tại áp dụng toàn trường? Các học kỳ khác sẽ tự động chuyển sang trạng thái Đã đóng.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, false),
                              child: const Text('Hủy'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true || !mounted) return;

                      try {
                        final res = await ApiService.instance.put('/api/lop-hoc-phan/hoc-ky/$semId/active');
                        GovernanceApiService.instance.notifyDataChanged();
                        await _loadData(forceRefresh: true);
                        if (mounted) {
                          final msg = (res is Map && res['message'] != null)
                              ? res['message'].toString()
                              : 'Đã thiết lập "$semName" làm Học kỳ hiện tại áp dụng toàn trường thành công.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Không thể thiết lập học kỳ: ${e.toString().replaceAll("Exception: ", "")}'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      }
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ======================================================
  // DEPARTMENT COMPARISON CARD (TC_PDT_002)
  // ======================================================
  Widget _buildFacultyComparisonCard(ColorScheme colors) {
    final rawDepts = _overview['thongKeTheoKhoa'] as List<dynamic>? ?? [];
    final depts = rawDepts.whereType<Map>().map((d) => Map<String, dynamic>.from(d)).toList();
    final totalTopics = depts.fold<int>(0, (sum, d) => sum + ((d['soDeTai'] as num?)?.toInt() ?? 0));
    final palette = [
      const Color(0xFF2563EB),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

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
                      'Tỷ lệ phân bổ số lượng đề tài liên khoa ',
                      style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (depts.isEmpty || totalTopics == 0)
            Text(
              'Chưa có dữ liệu đề tài theo khoa.',
              style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: depts.asMap().entries.map((entry) {
                  final count = (entry.value['soDeTai'] as num?)?.toInt() ?? 0;
                  if (count <= 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: count,
                    child: Container(height: 12, color: palette[entry.key % palette.length]),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: depts.asMap().entries.map((entry) {
                final d = entry.value;
                final count = (d['soDeTai'] as num?)?.toInt() ?? 0;
                final pct = totalTopics > 0 ? ((count / totalTopics) * 100).round() : 0;
                final code = (d['maKhoa'] ?? d['tenKhoa'] ?? 'Khoa').toString();
                return _buildFacItem('$code: $pct% ($count)', palette[entry.key % palette.length]);
              }).toList(),
            ),
          ],
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
    final rate = (_overview['tyLeHoanThanh'] as num?)?.toDouble() ?? 0.0;
    final totalGroups = (_overview['tongNhom'] as num?)?.toInt() ?? 0;
    final approvedRegs = ((rate / 100.0) * totalGroups).round();

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
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tỷ lệ hoàn thành đồ án toàn trường',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text('${rate.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (rate / 100.0).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$approvedRegs / $totalGroups nhóm đồ án đã hoàn tất đăng ký đề tài chính thức.',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

 

 
  // ======================================================
  // GRADE DISTRIBUTION CARD (TC_PDT_016)
  // ======================================================
  Widget _buildGradeDistributionCard(ColorScheme colors) {
    final phoDiem = (_overview['phoDiem'] as Map?) ?? {};
    final xuatSac = (phoDiem['xuatSac'] as num?)?.toInt() ?? 0;
    final gioi = (phoDiem['gioi'] as num?)?.toInt() ?? 0;
    final kha = (phoDiem['kha'] as num?)?.toInt() ?? 0;
    final trungBinh = (phoDiem['trungBinh'] as num?)?.toInt() ?? 0;
    final rot = (phoDiem['rot'] as num?)?.toInt() ?? 0;
    final maxCount = [xuatSac, gioi, kha, trungBinh, rot, 1].reduce((a, b) => a > b ? a : b);

    final grades = [
      {'label': 'Xuất sắc (9-10)', 'count': xuatSac, 'color': const Color(0xFF10B981)},
      {'label': 'Giỏi (8-8.9)', 'count': gioi, 'color': const Color(0xFF2563EB)},
      {'label': 'Khá (7-7.9)', 'count': kha, 'color': const Color(0xFF6366F1)},
      {'label': 'Trung bình (5-6.9)', 'count': trungBinh, 'color': const Color(0xFFF59E0B)},
      {'label': 'Rớt (<5)', 'count': rot, 'color': const Color(0xFFEF4444)},
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
              Expanded(
                child: Text(
                  'Báo cáo Tổng kết - Phổ điểm Toàn trường',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...grades.map((g) {
            final count = g['count'] as int;
            final label = g['label'] as String;
            final color = g['color'] as Color;
            final ratio = count / maxCount;

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
                  Text('$count bài', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
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
    final name = (course['tenLopHocPhan'] ?? course['tenHocPhan'] ?? 'Lớp học phần').toString();
    final code = (course['maLopHocPhan'] ?? course['maHocPhan'] ?? 'Mã LHP').toString();
    final maxStudents = course['soLuongToiDa'] ?? 45;
    final faculty = (course['tenKhoa'] ?? course['maKhoa'] ?? '').toString();
    final semName = (course['tenHocKy'] ?? '').toString();
    final dotStatus = (course['trangThaiDotDangKy'] ?? 'Chưa mở').toString();
    final isOpen = dotStatus == 'Đang mở';

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
                        [
                          if (faculty.isNotEmpty) faculty,
                          if (semName.isNotEmpty) semName,
                          'Tối đa: $maxStudents',
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isOpen ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dotStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isOpen ? const Color(0xFF059669) : const Color(0xFFB45309),
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
    );
  }
}
