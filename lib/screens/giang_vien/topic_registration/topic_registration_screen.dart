import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_groups.dart';
import '../../../data/mock/mock_lecturer_topic_registrations.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_registration_model.dart';
import 'topic_registration_detail_screen.dart';

class TopicRegistrationScreen extends StatefulWidget {
  const TopicRegistrationScreen({super.key});

  @override
  State<TopicRegistrationScreen> createState() =>
      _TopicRegistrationScreenState();
}

class _TopicRegistrationScreenState extends State<TopicRegistrationScreen> {
  static const _statuses = ['Chờ duyệt', 'Đã duyệt', 'Từ chối'];
  List<TopicRegistrationModel> _registrations = [];
  String _selectedStatus = 'Tất cả';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final assignedIds = MockLecturerCourses.courses
        .map((course) => course.courseId)
        .toSet();
    final groups = <int, GroupModel>{
      for (final group in MockLecturerGroups.groups) group.id: group,
    };
    final items = MockLecturerTopicRegistrations.getAll().where((registration) {
      final group = groups[registration.groupId];
      return group != null && assignedIds.contains(group.courseId);
    }).toList()..sort((a, b) => b.registeredAt.compareTo(a.registeredAt));

    if (mounted) {
      setState(() => _registrations = items);
    } else {
      _registrations = items;
    }
  }

  LecturerCourseModel? _courseFor(GroupModel? group) {
    if (group == null) return null;
    for (final course in MockLecturerCourses.courses) {
      if (course.courseId == group.courseId) return course;
    }
    return null;
  }

  List<TopicRegistrationModel> get _filtered {
    final query = _query.trim().toLowerCase();
    return _registrations.where((registration) {
      if (_selectedStatus != 'Tất cả' &&
          registration.status.trim() != _selectedStatus) {
        return false;
      }
      if (query.isEmpty) return true;
      final group = MockLecturerGroups.getById(registration.groupId);
      final topic = MockLecturerTopics.getById(registration.topicId);
      final course = _courseFor(group);
      final matchingTopic =
          group != null && topic != null && topic.courseId == group.courseId;
      final searchable = [
        group?.name ?? '',
        group?.leader ?? '',
        matchingTopic ? topic.title : '',
        course?.name ?? '',
        course?.code ?? '',
        course?.classCode ?? '',
        course?.semester ?? '',
      ];
      return searchable.any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  int _countFor(String status) => status == 'Tất cả'
      ? _registrations.length
      : _registrations.where((item) => item.status.trim() == status).length;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đăng ký đề tài')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm nhóm, đề tài hoặc lớp học phần',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        onPressed: () => setState(() => _query = ''),
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('Tất cả'),
                for (final status in _statuses) _filterChip(status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Trong các học phần được phân công',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '${items.length} kết quả',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? _emptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _registrationCard(context, items[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String status) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: FilterChip(
      selected: _selectedStatus == status,
      showCheckmark: false,
      label: Text('$status (${_countFor(status)})'),
      onSelected: (_) => setState(() => _selectedStatus = status),
    ),
  );

  Widget _registrationCard(
    BuildContext context,
    TopicRegistrationModel registration,
  ) {
    final colors = Theme.of(context).colorScheme;
    final group = MockLecturerGroups.getById(registration.groupId);
    final topic = MockLecturerTopics.getById(registration.topicId);
    final course = _courseFor(group);
    if (group == null || topic == null || course == null) {
      final problem = group == null
          ? 'Không tìm thấy nhóm; không xác định được học phần.'
          : topic == null
          ? 'Không tìm thấy đề tài #${registration.topicId}.'
          : course == null
          ? 'Không tìm thấy học phần được phân công.'
          : 'Đề tài không thuộc cùng học phần với nhóm.';
      return Card(
        child: ListTile(
          onTap: () => _openDetails(context, registration),
          leading: Icon(Icons.warning_amber_rounded, color: colors.error),
          title: Text(group?.name ?? 'Đăng ký #${registration.id}'),
          subtitle: Text(
            [
              if (course != null)
                '${course.code} • ${course.classCode} • ${course.semester}',
              problem,
              'Đăng ký: ${_formatDate(registration.registeredAt)}',
            ].join('\n'),
            style: TextStyle(color: colors.error),
          ),
          trailing: _StatusBadge(
            label: registration.status,
            color: _statusColor(registration.status),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(context, registration),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.groups_outlined,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.code} • ${course.classCode} • ${course.semester}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    label: registration.status,
                    color: _statusColor(registration.status),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                topic.courseId == group.courseId
                    ? topic.title
                    : 'Đề tài không thuộc học phần của nhóm.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: topic.courseId == group.courseId
                      ? colors.onSurface
                      : colors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _Metadata(icon: Icons.person_outline, label: group.leader),
                  _Metadata(
                    icon: Icons.people_outline,
                    label: '${group.memberCount} thành viên',
                  ),
                  _Metadata(
                    icon: Icons.schedule_outlined,
                    label: _formatDate(registration.registeredAt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(
    BuildContext context,
    TopicRegistrationModel registration,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            TopicRegistrationDetailScreen(registration: registration),
      ),
    );
    if (mounted) _reload();
  }

  Widget _emptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasFilter = _selectedStatus != 'Tất cả' || _query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter ? Icons.search_off_outlined : Icons.assignment_outlined,
              size: 42,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilter
                  ? 'Không có đăng ký phù hợp với bộ lọc.'
                  : 'Chưa có đăng ký đề tài phù hợp trong học phần được phân công.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Metadata({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: colors.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Color.lerp(color, colors.surface, 0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.trim()) {
    case 'Chờ duyệt':
      return AppTheme.warningColor;
    case 'Đã duyệt':
      return AppTheme.successColor;
    case 'Từ chối':
      return AppTheme.dangerColor;
    default:
      return AppTheme.grayColor;
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
