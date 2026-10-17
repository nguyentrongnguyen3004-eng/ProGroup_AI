import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../course/governance_course_screen.dart';
import '../lecturer/governance_lecturer_screen.dart';
import '../student/governance_student_screen.dart';

enum GovernanceDataKind { students, lecturers, courses }

extension GovernanceDataKindLabel on GovernanceDataKind {
  String get label => switch (this) {
    GovernanceDataKind.students => 'Sinh viên',
    GovernanceDataKind.lecturers => 'Giảng viên',
    GovernanceDataKind.courses => 'Lớp học phần',
  };
}

class GovernanceDataManagementScreen extends StatefulWidget {
  const GovernanceDataManagementScreen({super.key});

  @override
  State<GovernanceDataManagementScreen> createState() => _GovernanceDataManagementScreenState();
}

class _GovernanceDataManagementScreenState extends State<GovernanceDataManagementScreen> {
  GovernanceDataKind _kind = GovernanceDataKind.courses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Top Banner (Đồng bộ chuẩn Giảng viên)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.text('Dữ liệu khoa', en: 'Faculty Data'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.text(
                            'Quản lý Lớp học phần, Sinh viên & Giảng viên',
                            en: 'Manage classes, students & lecturers',
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3-Tab KPI Selector Cards (Unified Design System)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _TabPill(
                      label: 'Lớp HP',
                      color: const Color(0xFF6366F1), // Indigo
                      icon: Icons.school_rounded,
                      isSelected: _kind == GovernanceDataKind.courses,
                      onTap: () => setState(() => _kind = GovernanceDataKind.courses),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabPill(
                      label: 'Sinh viên',
                      color: const Color(0xFF10B981), // Emerald
                      icon: Icons.people_rounded,
                      isSelected: _kind == GovernanceDataKind.students,
                      onTap: () => setState(() => _kind = GovernanceDataKind.students),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabPill(
                      label: 'Giảng viên',
                      color: const Color(0xFF2563EB), // Blue
                      icon: Icons.badge_rounded,
                      isSelected: _kind == GovernanceDataKind.lecturers,
                      onTap: () => setState(() => _kind = GovernanceDataKind.lecturers),
                    ),
                  ),
                ],
              ),
            ),

            // Data Content Stack
            Expanded(
              child: IndexedStack(
                index: _kind == GovernanceDataKind.courses
                    ? 0
                    : (_kind == GovernanceDataKind.students ? 1 : 2),
                children: const [
                  GovernanceCourseScreen(showAppBar: false),
                  GovernanceStudentScreen(showAppBar: false),
                  GovernanceLecturerScreen(showAppBar: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.14) : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : colors.outlineVariant.withValues(alpha: 0.35),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
