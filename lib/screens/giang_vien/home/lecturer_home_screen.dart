import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_groups.dart';
import '../../../data/mock/mock_lecturer_notifications.dart';
import '../../../data/mock/mock_lecturer_topic_registrations.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/group_model.dart';
import '../../../models/topic_model.dart';
import '../../../widgets/lecturer/lecturer_course_card.dart';
import '../../../widgets/lecturer/lecturer_stat_card.dart';
import '../course/lecturer_course_detail_screen.dart';
import '../notification/lecturer_notification_screen.dart';
import '../topic/lecturer_topic_screen.dart';
import '../topic/lecturer_topic_assistant_screen.dart';
import '../topic_proposal/lecturer_topic_proposal_screen.dart';
import '../topic_registration/topic_registration_screen.dart';
import 'lecturer_statistics_screen.dart';

class LecturerHomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockLecturerNotifications.instance,
      builder: (context, _) => _buildHome(context),
    );
  }

  Widget _buildHome(BuildContext context) {
    final lecturer = MockLecturer.current;
    final courses = MockLecturerCourses.courses;
    final courseIds = courses.map((course) => course.courseId).toSet();

    final groups = MockLecturerGroups.groups
        .where((group) => courseIds.contains(group.courseId))
        .toList();
    final topics = MockLecturerTopics.topics
        .where((topic) => courseIds.contains(topic.courseId))
        .toList();

    final groupById = <int, GroupModel>{
      for (final group in groups) group.id: group,
    };
    final topicById = <int, TopicModel>{
      for (final topic in topics) topic.id: topic,
    };
    final registrations = MockLecturerTopicRegistrations.getAll().where((item) {
      final group = groupById[item.groupId];
      final topic = topicById[item.topicId];
      return group != null && topic != null && group.courseId == topic.courseId;
    });
    final pendingRegistrationCount = registrations
        .where((item) => item.status.trim().toLowerCase() == 'chờ duyệt')
        .length;

    final notifications = MockLecturerNotifications.instance.notifications
        .take(3)
        .toList();
    final unreadCount = MockLecturerNotifications.instance.unreadCount;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            tooltip: AppLocalizations.text('Thông báo', en: 'Notifications'),
            onPressed:
                onOpenNotifications ??
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LecturerNotificationScreen(),
                    ),
                  );
                },
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              child: Icon(Icons.notifications_outlined, color: colors.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Text('Xin chào 👋', style: TextStyle(color: colors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            lecturer.fullName,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${lecturer.faculty} • ${lecturer.department}',
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
                value: '${courses.length}',
                icon: Icons.school_outlined,
              ),
              LecturerStatCard(
                title: 'Nhóm',
                value: '${groups.length}',
                icon: Icons.groups_outlined,
                color: AppTheme.successColor,
              ),
              LecturerStatCard(
                title: 'Đề tài',
                value: '${topics.length}',
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed:
                    onOpenTopics ??
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
                onPressed:
                    onOpenRegistrations ??
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
          if (courses.isEmpty)
            const _EmptySection(message: 'Chưa có lớp học phần được phân công.')
          else
            ...courses.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LecturerCourseCard(
                  course: course,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LecturerCourseDetailScreen(course: course),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (notifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Thông báo gần đây',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...notifications.map((notification) {
              final icon = notification['icon'];
              final title = notification['title'] as String? ?? '';
              final content = notification['content'] as String? ?? '';
              final time = notification['time'] as String? ?? '';
              final isRead = notification['isRead'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isRead
                        ? colors.surfaceContainerHighest
                        : colors.primaryContainer,
                    child: Icon(
                      icon is IconData ? icon : Icons.notifications_outlined,
                      color: isRead
                          ? colors.onSurfaceVariant
                          : colors.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    time,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
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
