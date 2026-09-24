import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/data/mock/mock_courses.dart';
import 'package:progroup_ai_frontend/widgets/course_card.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Lớp học phần', en: 'Course Classes'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: MockCourses.courses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.text(
                        'Chưa có lớp học phần',
                        en: 'No course classes',
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.text(
                        'Các học phần sẽ xuất hiện tại đây khi được phân công.',
                        en: 'Assigned course classes will appear here.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: MockCourses.courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = MockCourses.courses[index];

                return CourseCard(
                  course: course,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.courseDetail,
                      arguments: course,
                    );
                  },
                );
              },
            ),
    );
  }
}
