import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
<<<<<<< HEAD
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/models/topic_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/course/course_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/notification/notification_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/ai_topic_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/topic_screen.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';
import 'package:progroup_ai_frontend/services/student_api_service.dart';
import 'package:progroup_ai_frontend/widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenCourses;
  final VoidCallback? onOpenGroups;

  const HomeScreen({
    super.key,
    this.onOpenNotifications,
    this.onOpenCourses,
    this.onOpenGroups,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<CourseModel> _courses = [];
  List<GroupModel> _myGroups = [];
  List<TopicModel> _topics = [];
  int _unreadCount = 0;

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
        StudentApiService.instance.fetchMyCourses(),
        StudentApiService.instance.fetchMyGroups(),
        StudentApiService.instance.fetchTopics(),
        StudentApiService.instance.fetchUnreadCount(),
      ]);

      if (!mounted) return;

      setState(() {
        _courses = results[0] as List<CourseModel>;
        _myGroups = results[1] as List<GroupModel>;
        _topics = results[2] as List<TopicModel>;
        _unreadCount = results[3] as int;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
=======
import 'package:progroup_ai_frontend/models/user_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/course/course_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/notification/notification_screen.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';
import 'package:progroup_ai_frontend/services/course_service.dart';
import 'package:progroup_ai_frontend/services/notification_service.dart';
import 'package:progroup_ai_frontend/widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
>>>>>>> origin/Frontend

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CourseModel> courses = [];
  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await AuthService().getCurrentUser();
      final list = await CourseService().getCourses();
      if (mounted) {
        setState(() {
          currentUser = user;
          courses = list;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _openCourseDetail(BuildContext context, CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
    );
  }

  void _openAiTopic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiTopicScreen()),
    );
  }

  void _openNotifications(BuildContext context) {
    if (widget.onOpenNotifications != null) {
      widget.onOpenNotifications!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationScreen()),
      ).then((_) => _loadData());
    }
  }

  String _getInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'SV';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final user = AuthService.currentUser;
    final colors = Theme.of(context).colorScheme;
    final initials = _getInitials(user.fullName);

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF2563EB),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 76),
            children: [
              // ======================================================
              // TOP HEADER: AVATAR + XIN CHÀO + CHUÔNG THÔNG BÁO BADGE
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
                          user.fullName,
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
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openNotifications(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
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
                            if (_unreadCount > 0)
                              Positioned(
                                top: 4,
                                right: 4,
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
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.35),
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
                                      _unreadCount > 99
                                          ? '99+'
                                          : '$_unreadCount',
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
              // BANNER GEMINI AI LIVE (CỐ VẤN ĐỀ TÀI)
              // ======================================================
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _openAiTopic(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
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
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        color: Colors.white, size: 13),
                                    SizedBox(width: 4),
                                    Text(
                                      'Gemini AI Live',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.text(
                                  'Cố vấn đề tài thông minh',
                                  en: 'Smart Topic Advisor',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppLocalizations.text(
                                  'Khám phá đề tài, gợi ý công nghệ & tư vấn trực tiếp cùng Gemini AI.',
                                  en:
                                      'Explore topics, get tech advice & chat live with Gemini AI.',
                                ),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ======================================================
              // STATS ROW: 3 SQUIRCLE KPI CARDS
              // ======================================================
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: AppLocalizations.text('Lớp học', en: 'Courses'),
                      count: _isLoading ? '...' : '${_courses.length}',
                      icon: Icons.school_rounded,
                      color: const Color(0xFF2563EB),
                      onTap: widget.onOpenCourses,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: AppLocalizations.text('Nhóm', en: 'Groups'),
                      count: _isLoading ? '...' : '${_myGroups.length}',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF10B981),
                      onTap: widget.onOpenGroups,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: AppLocalizations.text('Đề tài', en: 'Topics'),
                      count: _isLoading ? '...' : '${_topics.length}',
                      icon: Icons.lightbulb_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        if (_courses.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TopicScreen(course: _courses.first),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TopicScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ======================================================
              // MY COURSES SECTION
              // ======================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.text(
                        'Lớp học phần của tôi',
                        en: 'My Course Classes',
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.onOpenCourses != null)
                    TextButton(
                      onPressed: widget.onOpenCourses,
                      child: Text(
                        AppLocalizations.text('Xem tất cả', en: 'View All'),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  ),
                )
              else if (_errorMessage != null && _courses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: colors.error, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.error, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              else if (_courses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.text(
                        'Chưa có lớp học phần nào.',
                        en: 'No course classes registered.',
                      ),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ..._courses.map((course) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CourseCard(
                      course: course,
                      onTap: () => _openCourseDetail(context, course),
                    ),
                  );
                }),

              const SizedBox(height: 12),

              // ======================================================
              // RECENT ACTIVITY & GROUP STATUS
              // ======================================================
              Text(
                AppLocalizations.text(
                    'Hoạt động & Trạng thái', en: 'Recent Status'),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.groups_rounded,
                            color: Color(0xFF10B981), size: 20),
                      ),
                      title: Text(
                        _myGroups.isNotEmpty
                            ? _myGroups.first.name
                            : AppLocalizations.groupName('Nhóm học tập'),
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
=======
    final userName = currentUser?.fullName ?? 'Sinh viên';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ProGroup AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          AnimatedBuilder(
            animation: NotificationService.instance,
            builder: (context, _) {
              final hasUnread = NotificationService.instance.unreadCount > 0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      _openNotifications(context);
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 10,
                      top: 9,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              Text(
                AppLocalizations.text('Xin chào 👋', en: 'Hello 👋'),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.text(
                              'Đăng ký đồ án',
                              en: 'Project Registration',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.text(
                              'Quản lý nhóm và lựa chọn đề tài cho môn học.',
                              en: 'Manage groups and choose topics for your course.',
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 42),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.text(
                      'Lớp học phần của tôi',
                      en: 'My Course Classes',
                    ),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.text(
                      '${courses.length} lớp',
                      en: '${courses.length} classes',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (courses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.text(
                          'Chưa có lớp học phần.',
                          en: 'No course classes yet.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
>>>>>>> origin/Frontend
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...courses.map((course) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CourseCard(
                      course: course,
                      onTap: () => _openCourseDetail(context, course),
                    ),
                  );
                }),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.text('Hoạt động gần đây', en: 'Recent Activity'),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.groups)),
                      title: const Text('Nhóm ProGroup'),
                      subtitle: Text(
<<<<<<< HEAD
                        _myGroups.isNotEmpty
                            ? 'Thành viên nhóm: ${_myGroups.first.members.length} sinh viên'
                            : AppLocalizations.text(
                                'Bạn đang tham gia nhóm.',
                                en: 'You are in this group.',
                              ),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12.5,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: widget.onOpenGroups,
                    ),
                    if (_courses.isNotEmpty) ...[
                      Divider(
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                          height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lightbulb_rounded,
                              color: Color(0xFFF59E0B), size: 20),
                        ),
                        title: Text(
                          AppLocalizations.text(
                              'Đăng ký đề tài học phần',
                              en: 'Register Course Topic'),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                        subtitle: Text(
                          'Lớp ${_courses.first.classCode} đang mở đăng ký.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12.5,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openCourseDetail(context, _courses.first),
=======
                        AppLocalizations.text(
                          'Bạn đang là thành viên nhóm.',
                          en: 'You are a group member.',
                        ),
                      ),
                    ),
                    if (courses.isNotEmpty) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.lightbulb_outline),
                        ),
                        title: Text(
                          AppLocalizations.text(
                            'Đăng ký đề tài',
                            en: 'Register Topic',
                          ),
                        ),
                        subtitle: Text(
                          courses.first.name,
                        ),
                        onTap: () => _openCourseDetail(context, courses.first),
>>>>>>> origin/Frontend
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
<<<<<<< HEAD
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 10),
                Text(
                  count,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
=======
>>>>>>> origin/Frontend
        ),
      ),
    );
  }
}
