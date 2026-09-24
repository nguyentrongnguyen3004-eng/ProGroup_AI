import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/course_group_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết lớp học phần', en: 'Course Details'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCourseHeader(context),
          const SizedBox(height: 16),
          _buildCourseInfo(context),
          const SizedBox(height: 16),
          _buildRegistrationInfo(context),
          const SizedBox(height: 20),
          _buildActions(context),
        ],
      ),
    );
  }

  // ============================================================
  // COURSE HEADER
  // ============================================================

  Widget _buildCourseHeader(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.menu_book_outlined,
                color: primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${course.code} • ${course.classCode}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COURSE INFORMATION
  // ============================================================

  Widget _buildCourseInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _infoRow(
              context,
              Icons.person_outline,
              'Giảng viên',
              'Lecturer',
              course.lecturer,
            ),
            _infoRow(
              context,
              Icons.calendar_month_outlined,
              'Học kỳ',
              'Semester',
              course.semester,
            ),
            _infoRow(
              context,
              Icons.school_outlined,
              'Mã lớp',
              'Class Code',
              course.classCode,
            ),
            _infoRow(
              context,
              Icons.info_outline,
              'Trạng thái',
              'Status',
              AppLocalizations.status(course.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String viLabel,
    String enLabel,
    String value,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.text(viLabel, en: enLabel),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ============================================================
  // REGISTRATION INFORMATION
  // ============================================================

  Widget _buildRegistrationInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.text(
                'Thông tin đăng ký',
                en: 'Registration Information',
              ),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _registrationRow(
              context,
              Icons.groups_outlined,
              'Số thành viên nhóm',
              'Group size',
              '3 - 5 sinh viên',
            ),
            _registrationRow(
              context,
              Icons.event_available_outlined,
              'Đăng ký nhóm',
              'Group registration',
              '01/09/2026 - 15/09/2026',
            ),
            _registrationRow(
              context,
              Icons.lightbulb_outline,
              'Hạn đăng ký đề tài',
              'Topic deadline',
              '20/09/2026',
            ),
          ],
        ),
      ),
    );
  }

  Widget _registrationRow(
    BuildContext context,
    IconData icon,
    String viLabel,
    String enLabel,
    String value,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.text(viLabel, en: enLabel),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        // ========================================================
        // VIEW TOPICS
        // ========================================================
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.topic, arguments: course);
            },
            icon: const Icon(Icons.lightbulb_outline),
            label: Text(AppLocalizations.text('Xem đề tài', en: 'View Topics')),
          ),
        ),

        const SizedBox(height: 12),

        // ========================================================
        // VIEW GROUPS
        // ========================================================
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseGroupScreen(course: course),
                ),
              );
            },
            icon: const Icon(Icons.groups_outlined),
            label: Text(AppLocalizations.text('Xem nhóm', en: 'View Groups')),
          ),
        ),
      ],
    );
  }
}
