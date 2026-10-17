import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../../../core/settings/app_settings.dart';
import '../../../services/lecturer_api_service.dart';
=======
import '../../../services/notification_service.dart';
>>>>>>> origin/Frontend
import '../../../widgets/lecturer/lecturer_bottom_nav.dart';
import '../course/lecturer_course_screen.dart';
import '../group/lecturer_group_screen.dart';
import '../home/lecturer_home_screen.dart';
import '../notification/lecturer_notification_screen.dart';
import '../profile/lecturer_profile_screen.dart';
import '../topic/lecturer_topic_screen.dart';
import '../topic_registration/topic_registration_screen.dart';

class LecturerMainScreen extends StatefulWidget {
  const LecturerMainScreen({super.key});

  @override
  State<LecturerMainScreen> createState() => _LecturerMainScreenState();
}

class _LecturerMainScreenState extends State<LecturerMainScreen> {
  int _currentIndex = 0;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final notifs = await LecturerApiService.instance.fetchNotifications();
      if (mounted) {
        setState(() {
          _unreadCount = notifs.where((n) => n['isRead'] != true).length;
        });
      }
    } catch (_) {}
  }

  void _selectTab(int index) {
    if (index < 0 || index >= 5 || index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 1) LecturerApiService.instance.fetchCourses();
    if (index == 2) LecturerApiService.instance.fetchGroups();
    if (index == 3) {
      LecturerApiService.instance.fetchNotifications();
      _fetchUnreadCount();
    }
    if (index == 4) LecturerApiService.instance.fetchProfile();
  }

  void _openTopics() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LecturerTopicScreen()));
  }

  void _openRegistrations() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TopicRegistrationScreen()));
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    final notifications = NotificationService.instance;

>>>>>>> origin/Frontend
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final lang = AppSettings.instance.language;
        return Scaffold(
          body: IndexedStack(
            key: ValueKey('lecturer_stack_$lang'),
            index: _currentIndex,
            children: [
              LecturerHomeScreen(
                key: ValueKey('lec_home_$lang'),
                onOpenNotifications: () {
                  _selectTab(3);
                },
                onOpenTopics: _openTopics,
                onOpenRegistrations: _openRegistrations,
              ),
              LecturerCourseScreen(key: ValueKey('lec_course_$lang')),
              LecturerGroupScreen(key: ValueKey('lec_group_$lang')),
              LecturerNotificationScreen(key: ValueKey('lec_notif_$lang')),
              LecturerProfileScreen(key: ValueKey('lec_prof_$lang')),
            ],
          ),
          bottomNavigationBar: LecturerBottomNav(
            currentIndex: _currentIndex,
            onChanged: _selectTab,
            notificationCount: _unreadCount,
          ),
        );
      },
    );
  }
}
