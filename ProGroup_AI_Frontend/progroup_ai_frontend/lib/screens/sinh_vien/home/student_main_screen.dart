import 'package:flutter/material.dart';

import '../../../core/settings/app_settings.dart';
import '../../../services/app_update_service.dart';
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
  final Set<int> _initializedTabs = {0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.instance.autoCheckAndPrompt(context);
      }
    });
  }

  void _onBottomNavTap(int index) {
    if (index < 0 || index >= 5 || index == _currentIndex) return;
    setState(() {
      _initializedTabs.add(index);
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
              _initializedTabs.contains(1)
                  ? CourseScreen(key: ValueKey('course_$lang'))
                  : const SizedBox.shrink(),
              _initializedTabs.contains(2)
                  ? GroupScreen(key: ValueKey('group_$lang'))
                  : const SizedBox.shrink(),
              _initializedTabs.contains(3)
                  ? NotificationScreen(key: ValueKey('notif_$lang'))
                  : const SizedBox.shrink(),
              _initializedTabs.contains(4)
                  ? ProfileScreen(key: ValueKey('prof_$lang'))
                  : const SizedBox.shrink(),
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
