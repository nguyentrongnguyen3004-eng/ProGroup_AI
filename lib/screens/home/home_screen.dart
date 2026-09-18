import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../data/mock/mock_courses.dart';
import '../../data/mock/mock_user.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  int currentIndex = 0;

  void navigate(int index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        break;

      case 1:
        Navigator.pushNamed(
          context,
          AppRoutes.group,
        );
        break;

      case 2:
        Navigator.pushNamed(
          context,
          AppRoutes.topic,
        );
        break;

      case 3:
        Navigator.pushNamed(
          context,
          AppRoutes.profile,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockUser.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ProGroup AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào 👋',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
              ),

              const SizedBox(height: 4),

              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF0EA5E9),
                    ],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đăng ký đồ án',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Quản lý nhóm và lựa chọn đề tài '
                      'cho môn học của bạn.',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Lớp học phần',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              CourseCard(
                course: MockCourses.courses.first,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.course,
                  );
                },
              ),

              const SizedBox(height: 25),

              const Text(
                'Truy cập nhanh',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.groups,
                      title: 'Nhóm',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.group,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _QuickAction(
                      icon: Icons.lightbulb,
                      title: 'Đề tài',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.topic,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _QuickAction(
                icon: Icons.auto_awesome,
                title: 'AI hỗ trợ đề tài',
                fullWidth: true,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.topic,
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: navigate,
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool fullWidth;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}