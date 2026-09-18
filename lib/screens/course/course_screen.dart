import 'package:flutter/material.dart';

import '../../data/mock/mock_courses.dart';
import '../../widgets/course_card.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lớp học phần',
        ),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: MockCourses.courses.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final course =
              MockCourses.courses[index];

          return CourseCard(
            course: course,
          );
        },
      ),
    );
  }
}