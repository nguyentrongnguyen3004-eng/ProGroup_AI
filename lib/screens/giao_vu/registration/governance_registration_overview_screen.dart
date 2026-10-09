import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../data/mock/mock_lecturer_groups.dart';
import '../../../data/mock/mock_lecturer_topic_registrations.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/course_model.dart';
import '../../../widgets/governance/governance_widgets.dart';

class GovernanceRegistrationOverviewScreen extends StatelessWidget {
  const GovernanceRegistrationOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockGovernanceData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final groups = MockLecturerGroups.groups;
        final registrations = MockLecturerTopicRegistrations.registrations;
        final approved = registrations.where(_isApproved).length;
        final pending = registrations.where(_isPending).length;
        return Scaffold(
          appBar: AppBar(title: const Text('Theo dõi đăng ký đồ án')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                    title: 'Nhóm',
                    value: '${groups.length}',
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
                    value: '$approved',
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
                'Tình hình theo lớp',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...data.courses.map(
                (course) => _courseStatus(course, groups, registrations),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _courseStatus(CourseModel course, List groups, List registrations) {
    final courseGroups = groups
        .where((group) => group.courseId == course.id)
        .toList();
    final groupIds = courseGroups.map((group) => group.id).toSet();
    final courseRegistrations = registrations
        .where((item) => groupIds.contains(item.groupId))
        .toList();
    final approved = courseRegistrations.where(_isApproved).length;
    final pending = courseRegistrations.where(_isPending).length;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${course.classCode} · ${course.semester}',
              style: const TextStyle(color: AppTheme.grayColor),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GovernanceStatusChip(label: '${courseGroups.length} nhóm'),
                GovernanceStatusChip(label: '$approved đã duyệt'),
                GovernanceStatusChip(label: '$pending chờ xử lý'),
              ],
            ),
          ],
        ),
      ),
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
}
