import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/course_service.dart';
import '../../../services/topic_service.dart';
import '../../../widgets/lecturer/lecturer_course_card.dart';
import '../../../widgets/lecturer/lecturer_stat_card.dart';
import '../course/lecturer_course_detail_screen.dart';
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
  String _lecturerName = 'Giảng viên';
  String _lecturerDepartment = 'Khoa Công Nghệ Thông Tin';
  List<CourseModel> _courses = [];
  List<TopicModel> _topics = [];
  int _pendingRegistrationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && mounted) {
        _lecturerName = user.fullName.isNotEmpty ? user.fullName : 'Giảng viên';
      }

      final courses = await CourseService().getMyClasses();
      final topics = await TopicService().getLecturerTopics();
      final registrations = await TopicService().getTopicRegistrations();

      if (mounted) {
        setState(() {
          _courses = courses;
          _topics = topics;
          _pendingRegistrationCount = registrations
              .where((r) => (r['trangThai'] ?? '').toString().trim().toLowerCase() == 'chờ duyệt')
              .length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trang chủ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            tooltip: AppLocalizations.text('Làm mới', en: 'Refresh'),
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: AppLocalizations.text('Thông báo', en: 'Notifications'),
            onPressed: widget.onOpenNotifications ??
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LecturerNotificationScreen(),
                    ),
                  );
                },
            icon: Icon(Icons.notifications_outlined, color: colors.primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Text('Xin chào 👋', style: TextStyle(color: colors.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              _lecturerName,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _lecturerDepartment,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản lý lớp học phần',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Theo dõi lớp, nhóm và tiến độ đề tài.',
                          style: TextStyle(color: Colors.white70, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.school_outlined, color: Colors.white, size: 42),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                LecturerStatCard(
                  title: 'Lớp học phần',
                  value: '${_courses.length}',
                  icon: Icons.school_outlined,
                ),
                LecturerStatCard(
                  title: 'Đề tài',
                  value: '${_topics.length}',
                  icon: Icons.lightbulb_outline,
                  color: AppTheme.warningColor,
                ),
                LecturerStatCard(
                  title: 'Đăng ký chờ duyệt',
                  value: '$_pendingRegistrationCount',
                  icon: Icons.assignment_outlined,
                  color: AppTheme.dangerColor,
                ),
                LecturerStatCard(
                  title: 'Sinh viên',
                  value: '${_courses.fold<int>(0, (sum, c) => sum + 40)}',
                  icon: Icons.people_outline,
                  color: AppTheme.successColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.onOpenTopics ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LecturerTopicScreen(),
                          ),
                        );
                      },
                  icon: const Icon(Icons.lightbulb_outline),
                  label: Text(AppLocalizations.text('Đề tài', en: 'Topics')),
                ),
                OutlinedButton.icon(
                  onPressed: widget.onOpenRegistrations ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TopicRegistrationScreen(),
                          ),
                        );
                      },
                  icon: const Icon(Icons.assignment_outlined),
                  label: Text(
                    AppLocalizations.text('Đăng ký đề tài', en: 'Registrations'),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LecturerTopicProposalScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Đề xuất sinh viên'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LecturerTopicAssistantScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Gợi ý đề tài'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LecturerStatisticsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Thống kê nâng cao'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Lớp học phần phụ trách',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_courses.isEmpty)
              const _EmptySection(message: 'Chưa có lớp học phần được phân công.')
            else
              ..._courses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LecturerCourseCard(
                    course: course,
                    onTap: () {
                      final fakeModel = LecturerCourseModel(
                        id: course.id,
                        courseId: course.id,
                        code: course.code,
                        name: course.name,
                        classCode: course.classCode,
                        semester: course.semester,
                        studentCount: 40,
                        groupCount: 0,
                        topicCount: 0,
                        groupRegistrationStart: '2024-01-01',
                        groupRegistrationEnd: '2024-01-01',
                        topicRegistrationStart: '2024-01-01',
                        topicRegistrationEnd: '2024-01-01',
                        minMembers: 3,
                        maxMembers: 5,
                        status: 'Đang mở',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LecturerCourseDetailScreen(course: fakeModel),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
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
