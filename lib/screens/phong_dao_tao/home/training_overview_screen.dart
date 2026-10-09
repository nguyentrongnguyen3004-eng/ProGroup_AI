import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_training_data.dart';
import '../management/training_data_management_screen.dart';

class TrainingOverviewScreen extends StatelessWidget {
  final ValueChanged<TrainingDataKind> onOpenManagement;

  const TrainingOverviewScreen({super.key, required this.onOpenManagement});

  @override
  Widget build(BuildContext context) {
    final data = MockTrainingData.instance;
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            _text(context, 'Phòng Đào tạo', 'Academic Affairs'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              _text(context, 'Tổng quan đào tạo', 'Academic overview'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _text(
                context,
                'Quản lý sinh viên, giảng viên và dữ liệu học tập toàn trường.',
                'Manage students, lecturers, and institution-wide academic data.',
              ),
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.28,
              children: [
                _OverviewCard(
                  title: _text(context, 'Sinh viên', 'Students'),
                  value: '${data.students.length}',
                  icon: Icons.people_outline,
                  onTap: () => onOpenManagement(TrainingDataKind.students),
                ),
                _OverviewCard(
                  title: _text(context, 'Giảng viên', 'Lecturers'),
                  value: '${data.lecturers.length}',
                  icon: Icons.badge_outlined,
                  onTap: () => onOpenManagement(TrainingDataKind.lecturers),
                ),
                _OverviewCard(
                  title: _text(context, 'Lớp học phần', 'Course classes'),
                  value: '${data.courseClasses.length}',
                  icon: Icons.class_outlined,
                  onTap: () => onOpenManagement(TrainingDataKind.courseClasses),
                ),
                _OverviewCard(
                  title: _text(context, 'Học phần', 'Courses'),
                  value: '${data.subjects.length}',
                  icon: Icons.menu_book_outlined,
                  onTap: () => onOpenManagement(TrainingDataKind.subjects),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              _text(context, 'Truy cập nhanh', 'Quick access'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.people_outline,
              title: _text(context, 'Quản lý sinh viên', 'Manage students'),
              subtitle: _text(
                context,
                'Tìm kiếm hồ sơ và xem tình trạng học tập.',
                'Search records and review enrollment status.',
              ),
              onTap: () => onOpenManagement(TrainingDataKind.students),
            ),
            _QuickAction(
              icon: Icons.school_outlined,
              title: _text(
                context,
                'Quản lý lớp học phần',
                'Manage class sections',
              ),
              subtitle: _text(
                context,
                'Theo dõi học kỳ và giảng viên phụ trách.',
                'Review semesters and assigned lecturers.',
              ),
              onTap: () => onOpenManagement(TrainingDataKind.courseClasses),
            ),
          ],
        ),
      ),
    );
  }
}

String _text(BuildContext context, String vi, String en) =>
    AppLocalizations.text(vi, en: en);

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: colors.primary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
