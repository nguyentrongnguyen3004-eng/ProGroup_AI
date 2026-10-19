import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/lecturer_api_service.dart';
import '../../../widgets/lecturer/lecturer_course_card.dart';
import '../../../widgets/lecturer/lecturer_stat_card.dart';
import '../course/lecturer_course_detail_screen.dart';
import '../notification/lecturer_notification_detail_screen.dart';
import '../notification/lecturer_notification_screen.dart';
import '../topic/lecturer_topic_assistant_screen.dart';
import '../topic/lecturer_topic_screen.dart';
import '../topic_proposal/lecturer_topic_proposal_screen.dart';
import '../topic_registration/topic_registration_screen.dart';
import 'lecturer_statistics_screen.dart';

class LecturerHomeScreen extends StatefulWidget {
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenTopics;
  final VoidCallback? onOpenRegistrations;

  const LecturerHomeScreen({
    super.key,
    this.onOpenNotifications,
    this.onOpenTopics,
    this.onOpenRegistrations,
  });

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  LecturerModel? _lecturer;
  List<LecturerCourseModel> _courses = [];
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];
  List<Map<String, dynamic>> _registrations = [];
  List<Map<String, dynamic>> _notifications = [];

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
        LecturerApiService.instance.fetchProfile(),
        LecturerApiService.instance.fetchCourses(),
        LecturerApiService.instance.fetchGroups(),
        LecturerApiService.instance.fetchTopics(),
        LecturerApiService.instance.fetchTopicRegistrations(),
        LecturerApiService.instance.fetchNotifications(),
      ]);

      if (mounted) {
        setState(() {
          _lecturer = results[0] as LecturerModel?;
          _courses = results[1] as List<LecturerCourseModel>;
          _groups = results[2] as List<GroupModel>;
          _topics = results[3] as List<TopicModel>;
          _registrations = results[4] as List<Map<String, dynamic>>;
          _notifications = results[5] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        body: SafeArea(
          bottom: true,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
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

    final lecturerName = _lecturer?.fullName ?? 'Giảng viên';
    final courseIds = _courses.map((c) => c.courseId).toSet();

    final filteredGroups = _groups.where((g) => courseIds.isEmpty || courseIds.contains(g.courseId)).toList();
    final filteredTopics = _topics.where((t) => courseIds.isEmpty || courseIds.contains(t.courseId)).toList();

    final pendingRegistrationCount = _registrations.where((item) {
      final status = (item['status'] ?? item['trangThai'] ?? '').toString().toLowerCase();
      return status.contains('chờ duyệt') || status.contains('pending');
    }).length;

    final recentNotifications = _notifications.take(3).toList();
    final unreadCount = _notifications.where((n) => n['isRead'] != true).length;

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 80),
            children: [
              // Top Header: Avatar + Xin chào + Nút Chuông thông báo
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
                        _getInitials(lecturerName),
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
                          lecturerName,
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
                                builder: (_) => const LecturerNotificationScreen(),
                              ),
                            );
                            _loadData();
                          },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colors.surface,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
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
              // Current semester gradient card
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AppLocalizations.text('HỌC KỲ HIỆN TẠI', en: 'CURRENT SEMESTER'),
                              style: const TextStyle(
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
                              'Quản lý lớp học phần',
                              en: 'Course Class Management',
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
                              'Theo dõi lớp, nhóm và tiến độ đề tài.',
                              en: 'Track classes, groups, and topic progress.',
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
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 4 Stat Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
                children: [
                  LecturerStatCard(
                    title: 'Lớp học phần',
                    value: '${_courses.length}',
                    icon: Icons.school_outlined,
                  ),
                  LecturerStatCard(
                    title: 'Nhóm',
                    value: '${filteredGroups.length}',
                    icon: Icons.groups_outlined,
                    color: AppTheme.successColor,
                  ),
                  LecturerStatCard(
                    title: 'Đề tài',
                    value: '${filteredTopics.length}',
                    icon: Icons.lightbulb_outline,
                    color: AppTheme.warningColor,
                  ),
                  LecturerStatCard(
                    title: 'Đăng ký chờ duyệt',
                    value: '$pendingRegistrationCount',
                    icon: Icons.assignment_outlined,
                    color: AppTheme.dangerColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Quick Actions
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
                      AppLocalizations.text('Tác vụ nhanh', en: 'Quick Actions'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                  _QuickActionCard(
                    icon: Icons.lightbulb_rounded,
                    color: const Color(0xFFF59E0B),
                    title: AppLocalizations.text('Đề tài', en: 'Topics'),
                    subtitle: AppLocalizations.text('Kho đề tài', en: 'Topic list'),
                    onTap: widget.onOpenTopics ??
                        () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LecturerTopicScreen(),
                            ),
                          );
                          _loadData();
                        },
                  ),
                  _QuickActionCard(
                    icon: Icons.assignment_rounded,
                    color: const Color(0xFF2563EB),
                    title: AppLocalizations.text(
                      'Đăng ký đề tài',
                      en: 'Registrations',
                    ),
                    subtitle: AppLocalizations.text(
                      'Duyệt nhóm đăng ký',
                      en: 'Group registrations',
                    ),
                    onTap: widget.onOpenRegistrations ??
                        () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TopicRegistrationScreen(),
                            ),
                          );
                          _loadData();
                        },
                  ),
                  _QuickActionCard(
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFF10B981),
                    title: AppLocalizations.text(
                      'Đề xuất sinh viên',
                      en: 'Student Proposals',
                    ),
                    subtitle: AppLocalizations.text(
                      'Ý tưởng của SV',
                      en: 'Student ideas',
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LecturerTopicProposalScreen(),
                        ),
                      );
                      _loadData();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.analytics_rounded,
                    color: const Color(0xFFEC4899),
                    title: AppLocalizations.text(
                      'Thống kê nâng cao',
                      en: 'Advanced Stats',
                    ),
                    subtitle: AppLocalizations.text(
                      'Báo cáo phân tích',
                      en: 'Analytics reports',
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LecturerStatisticsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _AiAssistantBanner(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LecturerTopicAssistantScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Assigned Courses Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.text(
                        'Lớp học phần phụ trách',
                        en: 'Assigned Course Classes',
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_courses.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_courses.length} ${AppLocalizations.text('lớp', en: 'classes')}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_courses.isEmpty)
                _EmptySection(
                  message: AppLocalizations.text(
                    'Chưa có lớp học phần được phân công.',
                    en: 'No assigned course classes yet.',
                  ),
                )
              else
                ..._courses.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LecturerCourseCard(
                      course: course,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LecturerCourseDetailScreen(course: course),
                          ),
                        );
                        _loadData();
                      },
                    ),
                  ),
                ),
              if (recentNotifications.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.text(
                          'Thông báo gần đây',
                          en: 'Recent Notifications',
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onOpenNotifications ??
                          () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LecturerNotificationScreen(),
                              ),
                            );
                            _loadData();
                          },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.text('Xem tất cả', en: 'View all'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: colors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...recentNotifications.map((notification) {
                  return _NotificationItemCard(
                    notification: notification,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LecturerNotificationDetailScreen(
                            notification: notification,
                          ),
                        ),
                      );
                      _loadData();
                    },
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'GV';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
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
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
              width: 1.1,
            ),
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
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: colors.onSurfaceVariant,
                      ),
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

class _AiAssistantBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _AiAssistantBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.text(
                              'Gợi ý đề tài AI',
                              en: 'AI Topic Assistant',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.text(
                        'Trợ lý thông minh hỗ trợ tạo & gợi ý đề tài',
                        en: 'Smart assistant for topic generation & ideas',
                      ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItemCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;

  const _NotificationItemCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = notification['icon'];
    final title = notification['title'] as String? ?? '';
    final content = notification['content'] as String? ?? '';
    final time = notification['time'] as String? ?? '';
    final isRead = notification['isRead'] == true;

    final lowerTitle = title.toLowerCase();
    final Color badgeColor = isRead
        ? colors.onSurfaceVariant
        : (lowerTitle.contains('đề tài') || lowerTitle.contains('topic'))
            ? const Color(0xFFF59E0B)
            : (lowerTitle.contains('sinh viên') ||
                    lowerTitle.contains('nhóm') ||
                    lowerTitle.contains('student'))
                ? const Color(0xFF10B981)
                : const Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? colors.outlineVariant.withValues(alpha: 0.3)
              : badgeColor.withValues(alpha: 0.35),
          width: isRead ? 1 : 1.2,
        ),
        boxShadow: isRead
            ? null
            : [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon is IconData ? icon : Icons.notifications_rounded,
                    color: badgeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.tr(title),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppLocalizations.tr(content),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: TextStyle(
                              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
