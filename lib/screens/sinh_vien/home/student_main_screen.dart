import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/widgets/app_bottom_nav.dart';

import 'package:progroup_ai_frontend/screens/sinh_vien/home/home_screen.dart';
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

  final List<Widget> _pages = const [
    HomeScreen(),
    GroupScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
