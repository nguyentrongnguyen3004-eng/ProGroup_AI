import 'package:flutter/material.dart';

import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../widgets/lecturer/lecturer_course_card.dart';
import 'lecturer_course_detail_screen.dart';

class LecturerCourseScreen extends StatelessWidget {
  const LecturerCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = MockLecturerCourses.courses;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lớp học phần',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: courses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Chưa có lớp học phần được phân công.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Padding(
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
                );
              },
            ),
    );
  }
}
