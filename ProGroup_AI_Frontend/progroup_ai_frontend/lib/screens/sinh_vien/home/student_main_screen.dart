import 'package:flutter/material.dart';

import '../../../core/settings/app_settings.dart';
import 'package:progroup_ai_frontend/widgets/app_bottom_nav.dart';

import 'package:progroup_ai_frontend/screens/sinh_vien/home/home_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/course/course_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/group_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/notification/notification_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/profile/profile_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  void _onBottomNavTap(int index) {
    if (index < 0 || index >= 5 || index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final lang = AppSettings.instance.language;
        return Scaffold(
          body: IndexedStack(
            key: ValueKey('student_stack_$lang'),
            index: _currentIndex,
            children: [
              HomeScreen(
                key: ValueKey('home_$lang'),
                onOpenNotifications: () => _onBottomNavTap(3),
                onOpenCourses: () => _onBottomNavTap(1),
                onOpenGroups: () => _onBottomNavTap(2),
                onOpenProfile: () => _onBottomNavTap(4),
              ),
              CourseScreen(key: ValueKey('course_$lang')),
              GroupScreen(key: ValueKey('group_$lang')),
              NotificationScreen(key: ValueKey('notif_$lang')),
              ProfileScreen(key: ValueKey('prof_$lang')),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: _currentIndex,
            onTap: _onBottomNavTap,
          ),
        );
      },
    );
  }
}
