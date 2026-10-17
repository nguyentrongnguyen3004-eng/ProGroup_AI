import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
<<<<<<< HEAD
import 'package:progroup_ai_frontend/screens/sinh_vien/chat/chat_screen.dart';
=======
import 'package:progroup_ai_frontend/services/course_service.dart';
>>>>>>> origin/Frontend
import 'package:progroup_ai_frontend/screens/sinh_vien/group/course_group_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/topic_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết lớp học phần', en: 'Course Details'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 72),
          children: [
            // ======================================================
            // COURSE HERO HEADER
            // ======================================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.courseName(course.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                course.code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                course.classCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

<<<<<<< HEAD
            // ======================================================
            // COURSE INFO CARD
            // ======================================================
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _InfoListTile(
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    label: AppLocalizations.text('Giảng viên phụ trách', en: 'Lecturer'),
                    value: course.lecturer,
                  ),
                  Divider(height: 1, indent: 60, color: colors.outlineVariant.withValues(alpha: 0.4)),
                  _InfoListTile(
                    icon: Icons.calendar_month_rounded,
                    iconColor: const Color(0xFF10B981),
                    label: AppLocalizations.text('Học kỳ áp dụng', en: 'Semester'),
                    value: course.semester,
                  ),
                  Divider(height: 1, indent: 60, color: colors.outlineVariant.withValues(alpha: 0.4)),
                  _InfoListTile(
                    icon: Icons.badge_rounded,
                    iconColor: const Color(0xFF6366F1),
                    label: AppLocalizations.text('Mã lớp học phần', en: 'Class Code'),
                    value: course.classCode,
                  ),
                  Divider(height: 1, indent: 60, color: colors.outlineVariant.withValues(alpha: 0.4)),
                  _InfoListTile(
                    icon: Icons.verified_user_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: AppLocalizations.text('Trạng thái học phần', en: 'Status'),
                    value: AppLocalizations.status(course.status),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // REGISTRATION SCHEDULE INFO CARD
            // ======================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          color: Color(0xFF8B5CF6),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.text('Thời hạn đăng ký', en: 'Registration Period'),
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đăng ký đề tài',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Đang mở đăng ký',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hạn nộp đề cương',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Còn 15 ngày',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // ACTIONS BUTTONS
            // ======================================================
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicScreen(course: course),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.lightbulb_rounded, size: 20),
                label: Text(
                  AppLocalizations.text('Xem danh sách đề tài', en: 'View Topics'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseGroupScreen(course: course),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.groups_rounded, size: 20),
                label: Text(
                  AppLocalizations.text('Xem danh sách nhóm trong lớp', en: 'View Course Groups'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(groupName: 'Lớp ${course.classCode}'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.chat_bubble_rounded, size: 19),
                label: Text(
                  AppLocalizations.text('Vào đoạn chat lớp học phần', en: 'Course Class Chat'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
              ),
            ),
          ],
        ),
      ),
=======
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
    return FutureBuilder<Map<String, dynamic>?>(
      future: CourseService().getRegistrationPeriod(course.id),
      builder: (context, snapshot) {
        final period = snapshot.data;
        String groupSize = '3 - 5 sinh viên';
        String regDates = '01/09/2026 - 30/11/2026';
        String topicDeadline = '30/11/2026';

        if (period != null) {
          final min = period['minMembers'] ?? 3;
          final max = period['maxMembers'] ?? 5;
          groupSize = '$min - $max sinh viên';

          if (period['ngayBatDau'] != null && period['ngayKetThuc'] != null) {
            try {
              final start = DateTime.parse(period['ngayBatDau'].toString());
              final end = DateTime.parse(period['ngayKetThuc'].toString());
              regDates =
                  '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year} - ${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
              topicDeadline =
                  '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
            } catch (_) {}
          }
        }

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
                  groupSize,
                ),
                _registrationRow(
                  context,
                  Icons.event_available_outlined,
                  'Đăng ký nhóm',
                  'Group registration',
                  regDates,
                ),
                _registrationRow(
                  context,
                  Icons.lightbulb_outline,
                  'Hạn đăng ký đề tài',
                  'Topic deadline',
                  topicDeadline,
                ),
              ],
            ),
          ),
        );
      },
>>>>>>> origin/Frontend
    );
  }
}

class _InfoListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoListTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
