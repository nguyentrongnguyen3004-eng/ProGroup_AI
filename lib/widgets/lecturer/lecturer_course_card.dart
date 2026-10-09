import 'package:flutter/material.dart';

import '../../models/lecturer_course_model.dart';

class LecturerCourseCard extends StatelessWidget {
  final LecturerCourseModel course;
  final VoidCallback? onTap;

  const LecturerCourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.school_outlined,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.code} • ${course.classCode}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 17,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      course.semester,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Info(
                    icon: Icons.people_outline,
                    value: '${course.studentCount}',
                    label: 'Sinh viên',
                  ),
                  _Info(
                    icon: Icons.groups_outlined,
                    value: '${course.groupCount}',
                    label: 'Nhóm',
                  ),
                  _Info(
                    icon: Icons.lightbulb_outline,
                    value: '${course.topicCount}',
                    label: 'Đề tài',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Info({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
