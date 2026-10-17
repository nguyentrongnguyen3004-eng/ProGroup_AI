import 'package:flutter/material.dart';
<<<<<<< HEAD

import '../../core/localization/app_localizations.dart';
import '../../models/lecturer_course_model.dart';
=======
import '../../core/localization/app_localizations.dart';
import '../../models/course_model.dart';
>>>>>>> origin/Frontend

class LecturerCourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const LecturerCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

<<<<<<< HEAD
    final courseColor = _getCourseColor(course.courseId);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: courseColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: courseColor.withValues(alpha: 0.28),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: courseColor,
                        size: 24,
=======
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.class_,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.code} • ${course.classCode}',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.semester,
                      style: TextStyle(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
>>>>>>> origin/Frontend
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.courseName(course.name),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: courseColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${course.code} • ${course.classCode}',
                                  style: TextStyle(
                                    color: courseColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    course.semester,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    thickness: 0.8,
                    color: colors.outlineVariant.withValues(alpha: 0.25),
                  ),
<<<<<<< HEAD
                ),
                Row(
                  children: [
                    _MiniStatPill(
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      value: '${course.studentCount}',
                      label: 'Sinh viên',
                    ),
                    const SizedBox(width: 8),
                    _MiniStatPill(
                      icon: Icons.groups_rounded,
                      iconColor: const Color(0xFF10B981),
                      value: '${course.groupCount}',
                      label: 'Nhóm',
                    ),
                    const SizedBox(width: 8),
                    _MiniStatPill(
                      icon: Icons.lightbulb_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      value: '${course.topicCount}',
                      label: 'Đề tài',
                    ),
                  ],
                ),
              ],
            ),
          ),
=======
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.people,
                    label: AppLocalizations.text('Sinh viên', en: 'Students'),
                    value: '40',
                    color: colors.primary,
                  ),
                  _StatItem(
                    icon: Icons.groups,
                    label: AppLocalizations.text('Nhóm', en: 'Groups'),
                    value: '--',
                    color: colors.secondary,
                  ),
                  _StatItem(
                    icon: Icons.topic,
                    label: AppLocalizations.text('Đề tài', en: 'Topics'),
                    value: '--',
                    color: colors.tertiary,
                  ),
                ],
              ),
            ),
          ],
>>>>>>> origin/Frontend
        ),
      ),
    );
  }
}

<<<<<<< HEAD
class _MiniStatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
=======
class _StatItem extends StatelessWidget {
  final IconData icon;
>>>>>>> origin/Frontend
  final String label;
  final String value;
  final Color color;

<<<<<<< HEAD
  const _MiniStatPill({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
=======
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
>>>>>>> origin/Frontend
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: colors.onSurface,
                    ),
                  ),
                  Text(
                    AppLocalizations.tr(label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
=======
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
>>>>>>> origin/Frontend
    );
  }
}

Color _getCourseColor(int id) {
  const palette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF0D9488), // Teal
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFD97706), // Amber
  ];
  return palette[id.abs() % palette.length];
}
