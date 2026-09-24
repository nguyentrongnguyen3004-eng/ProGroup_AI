import 'package:flutter/material.dart';

import '../../../data/mock/mock_lecturer_notifications.dart';
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

  late final List<Widget> _pages = [
    LecturerHomeScreen(
      onOpenNotifications: () => _selectTab(3),
      onOpenTopics: _openTopics,
      onOpenRegistrations: _openRegistrations,
    ),
    const LecturerCourseScreen(),
    const LecturerGroupScreen(),
    const LecturerNotificationScreen(),
    const LecturerProfileScreen(),
  ];

  void _selectTab(int index) {
    if (index < 0 || index >= _pages.length || index == _currentIndex) return;
    setState(() => _currentIndex = index);
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
    final notifications = MockLecturerNotifications.instance;

    return AnimatedBuilder(
      animation: notifications,
      builder: (context, _) => Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: LecturerBottomNav(
          currentIndex: _currentIndex,
          onChanged: _selectTab,
          notificationCount: notifications.unreadCount,
        ),
      ),
    );
  }
}
