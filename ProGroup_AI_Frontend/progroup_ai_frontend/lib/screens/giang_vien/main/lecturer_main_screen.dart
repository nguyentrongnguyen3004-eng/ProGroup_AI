import 'package:flutter/material.dart';

import '../../../core/settings/app_settings.dart';
import '../../../services/app_update_service.dart';
import '../../../services/lecturer_api_service.dart';
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
  final Set<int> _initializedTabs = {0};
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.instance.autoCheckAndPrompt(context);
      }
    });
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
    setState(() {
      _initializedTabs.add(index);
      _currentIndex = index;
    });
    if (index == 3) {
      _fetchUnreadCount();
    }
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
                onOpenProfile: () => _selectTab(4),
              ),
              _initializedTabs.contains(1)
                  ? LecturerCourseScreen(key: ValueKey('lec_course_$lang'))
                  : const SizedBox.shrink(),
              _initializedTabs.contains(2)
                  ? LecturerGroupScreen(key: ValueKey('lec_group_$lang'))
                  : const SizedBox.shrink(),
              _initializedTabs.contains(3)
                  ? LecturerNotificationScreen(key: ValueKey('lec_notif_$lang'))
                  : const SizedBox.shrink(),
              _initializedTabs.contains(4)
                  ? LecturerProfileScreen(key: ValueKey('lec_prof_$lang'))
                  : const SizedBox.shrink(),
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
