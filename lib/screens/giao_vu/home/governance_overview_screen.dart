import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../data/mock/mock_lecturer_groups.dart';
import '../../../data/mock/mock_lecturer_topic_registrations.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../widgets/governance/governance_widgets.dart';
import '../registration/governance_registration_overview_screen.dart';
import '../tools/governance_assignment_screen.dart';
import '../tools/governance_import_screen.dart';

class GovernanceOverviewScreen extends StatelessWidget {
  const GovernanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockGovernanceData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final registrations = MockLecturerTopicRegistrations.registrations;
        final pending = registrations.where(_isPending).length;
        return Scaffold(
          appBar: AppBar(title: const Text('Giáo vụ khoa')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                'Tổng quan dữ liệu khoa',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Quản lý danh sách, phân công và theo dõi đăng ký đồ án.',
                style: TextStyle(color: AppTheme.grayColor),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  GovernanceStatCard(
                    title: 'Lớp học phần',
                    value: '${data.courses.length}',
                    icon: Icons.school_outlined,
                  ),
                  GovernanceStatCard(
                    title: 'Sinh viên',
                    value: '${data.students.length}',
                    icon: Icons.people_outline,
                    color: AppTheme.successColor,
                  ),
                  GovernanceStatCard(
                    title: 'Giảng viên',
                    value: '${data.lecturers.length}',
                    icon: Icons.badge_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  GovernanceStatCard(
                    title: 'Nhóm',
                    value: '${MockLecturerGroups.groups.length}',
                    icon: Icons.groups_outlined,
                    color: AppTheme.warningColor,
                  ),
                  GovernanceStatCard(
                    title: 'Đề tài',
                    value: '${MockLecturerTopics.topics.length}',
                    icon: Icons.lightbulb_outline,
                  ),
                  GovernanceStatCard(
                    title: 'Đăng ký đã duyệt',
                    value: '${registrations.where(_isApproved).length}',
                    icon: Icons.task_alt,
                    color: AppTheme.successColor,
                  ),
                  GovernanceStatCard(
                    title: 'Chờ xử lý',
                    value: '$pending',
                    icon: Icons.pending_actions_outlined,
                    color: AppTheme.warningColor,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Tác vụ nhanh',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              GovernanceActionCard(
                title: 'Import dữ liệu',
                subtitle:
                    'Nhập danh sách sinh viên, giảng viên hoặc lớp học phần.',
                icon: Icons.upload_file_outlined,
                onTap: () => _open(context, const GovernanceImportScreen()),
              ),
              GovernanceActionCard(
                title: 'Phân công giảng viên',
                subtitle: 'Xem và cập nhật giảng viên phụ trách lớp.',
                icon: Icons.assignment_ind_outlined,
                onTap: () => _open(context, const GovernanceAssignmentScreen()),
              ),
              GovernanceActionCard(
                title: 'Theo dõi đăng ký đồ án',
                subtitle: 'Xem số nhóm và trạng thái đăng ký đề tài.',
                icon: Icons.fact_check_outlined,
                onTap: () => _open(
                  context,
                  const GovernanceRegistrationOverviewScreen(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static bool _isPending(dynamic registration) {
    final status = registration.status.toString().toLowerCase();
    return status.startsWith('ch') ||
        status.contains('chá»') ||
        status.contains('pending');
  }

  static bool _isApproved(dynamic registration) {
    final status = registration.status.toString().toLowerCase();
    return !_isPending(registration) &&
        registration.rejectionReason == null &&
        (status.contains('duy') || status.contains('approved'));
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
