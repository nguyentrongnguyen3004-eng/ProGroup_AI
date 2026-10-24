import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../registration/governance_registration_overview_screen.dart';
import 'governance_assignment_screen.dart';
import 'governance_import_screen.dart';

class GovernanceToolsScreen extends StatelessWidget {
  const GovernanceToolsScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 80),
          children: [
            // Top Title (Unified Template)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.text('Phân công & Nghiệp vụ', en: 'Assignments & Operations'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Hero Banner
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.text('Điều phối nghiệp vụ khoa', en: 'Faculty Coordination'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.text(
                            'Phân công giảng viên, nhập dữ liệu và theo dõi đề tài toàn khoa.',
                            en: 'Assign lecturers, import files and track projects faculty-wide.',
                          ),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildToolCard(
              context,
              title: AppLocalizations.text('Phân công giảng viên', en: 'Assign Lecturer'),
              subtitle: AppLocalizations.text('Chọn lớp học phần và xác nhận giảng viên phụ trách', en: 'Select course class and confirm lecturer in charge'),
              icon: Icons.assignment_ind_rounded,
              color: const Color(0xFF10B981), // Emerald
              onTap: () => _open(context, const GovernanceAssignmentScreen()),
            ),
            const SizedBox(height: 12),
            _buildToolCard(
              context,
              title: AppLocalizations.text('Nhập dữ liệu Excel / CSV', en: 'Import Data'),
              subtitle: AppLocalizations.text('Nhập sinh viên, giảng viên và lớp học phần từ tệp', en: 'Import students, lecturers and classes from files'),
              icon: Icons.file_upload_rounded,
              color: const Color(0xFF2563EB), // Blue
              onTap: () => _open(context, const GovernanceImportScreen()),
            ),
            const SizedBox(height: 12),
            _buildToolCard(
              context,
              title: AppLocalizations.text('Theo dõi đăng ký đồ án', en: 'Topic Registrations'),
              subtitle: AppLocalizations.text('Tổng hợp nhóm và trạng thái đăng ký đề tài theo lớp', en: 'Overview groups and topic registration status by class'),
              icon: Icons.fact_check_rounded,
              color: const Color(0xFF6366F1), // Indigo
              onTap: () => _open(context, const GovernanceRegistrationOverviewScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.onSurfaceVariant.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
