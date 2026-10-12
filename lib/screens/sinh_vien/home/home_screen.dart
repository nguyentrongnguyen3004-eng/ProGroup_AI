import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/user_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/course/course_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/notification/notification_screen.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';
import 'package:progroup_ai_frontend/services/course_service.dart';
import 'package:progroup_ai_frontend/services/notification_service.dart';
import 'package:progroup_ai_frontend/widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      ),
                    ],
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
