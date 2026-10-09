import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;

  const CourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.courseName(course.name),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '${AppLocalizations.t('courseCode')}: ${course.classCode}',
                    ),
                    SizedBox(height: 3),
                    Text(
                      '${AppLocalizations.t('lecturer')}: ${course.lecturer}',
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
