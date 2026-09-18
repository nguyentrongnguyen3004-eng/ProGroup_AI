import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text('Mã học phần: ${course.code}'),

              const SizedBox(height: 5),

              Text('Lớp: ${course.classCode}'),

              const SizedBox(height: 5),

              Text('GV: ${course.lecturer}'),

              const SizedBox(height: 12),

              Chip(
                label: Text(course.status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}