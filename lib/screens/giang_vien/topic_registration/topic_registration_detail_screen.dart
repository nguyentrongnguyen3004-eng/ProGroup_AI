import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_groups.dart';
import '../../../data/mock/mock_lecturer_topic_registrations.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';

class TopicRegistrationDetailScreen extends StatefulWidget {
  final TopicRegistrationModel registration;

  const TopicRegistrationDetailScreen({super.key, required this.registration});

  @override
  State<TopicRegistrationDetailScreen> createState() =>
      _TopicRegistrationDetailScreenState();
}

class _TopicRegistrationDetailScreenState
    extends State<TopicRegistrationDetailScreen> {
  TopicRegistrationModel? _current;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  TopicRegistrationModel? _findRegistration() {
    for (final item in MockLecturerTopicRegistrations.getAll()) {
      if (item.id == widget.registration.id) return item;
    }
    return null;
  }

  void _reload() {
    final latest = _findRegistration();
    if (mounted) {
      setState(() => _current = latest);
    } else {
      _current = latest;
    }
  }

  LecturerCourseModel? _courseFor(GroupModel? group) {
    if (group == null) return null;
    for (final course in MockLecturerCourses.courses) {
      if (course.courseId == group.courseId) return course;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final registration = _current ?? widget.registration;
    final exists = _current != null;
    final group = MockLecturerGroups.getById(registration.groupId);
    final topic = MockLecturerTopics.getById(registration.topicId);
    final course = _courseFor(group);
    final matches =
        group != null && topic != null && group.courseId == topic.courseId;
    final pending =
        exists &&
        registration.status.trim() == 'Chờ duyệt' &&
        course != null &&
        matches;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đăng ký đề tài')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          if (!exists)
            const _Fallback(
              message:
                  'Đăng ký không còn trong dữ liệu hiện tại. Nội dung bên dưới là thông tin gần nhất đã mở.',
            )
          else if (!matches)
            const _Fallback(
              message:
                  'Dữ liệu đăng ký chưa đầy đủ hoặc không nhất quán. Hãy kiểm tra nhóm, đề tài và học phần.',
            ),
          _RegistrationCard(registration: registration),
          const SizedBox(height: 12),
          _GroupCard(group: group, registration: registration, course: course),
          const SizedBox(height: 12),
          _TopicCard(
            topic: topic,
            registration: registration,
            group: group,
            matches: matches,
          ),
          const SizedBox(height: 12),
          _CourseCard(
            course: course,
            group: group,
            topic: topic,
            matches: matches,
          ),
          if (pending) ...[
            const SizedBox(height: 20),
            _actions(),
          ] else if (exists && registration.status.trim() == 'Chờ duyệt') ...[
            const SizedBox(height: 16),
            Text(
              'Không thể xử lý khi nhóm, đề tài chưa cùng học phần được phân công.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (exists) ...[
            const SizedBox(height: 16),
            Text(
              'Đăng ký này đã được xử lý.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actions() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OutlinedButton.icon(
        onPressed: _isUpdating ? null : _reject,
        icon: const Icon(Icons.close),
        label: const Text('Từ chối đăng ký'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.dangerColor,
          side: const BorderSide(color: AppTheme.dangerColor),
          minimumSize: const Size.fromHeight(50),
        ),
      ),
      const SizedBox(height: 10),
      ElevatedButton.icon(
        onPressed: _isUpdating ? null : _approve,
        icon: const Icon(Icons.check),
        label: const Text('Duyệt đăng ký'),
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      ),
    ],
  );

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Duyệt đăng ký đề tài?'),
        content: const Text('Đăng ký sẽ chuyển sang trạng thái “Đã duyệt”.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận duyệt'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _saveStatus('Đã duyệt');
  }

  Future<void> _reject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RegistrationRejectionDialog(),
    );

    if (!mounted || reason == null) return;
    await _saveStatus('Từ chối', rejectionReason: reason);
  }

  Future<void> _saveStatus(String status, {String? rejectionReason}) async {
    final latest = _findRegistration();
    if (latest == null) {
      _reload();
      _message('Đăng ký không còn tồn tại nên chưa thể cập nhật.');
      return;
    }
    if (latest.status.trim() != 'Chờ duyệt') {
      _reload();
      _message('Chỉ đăng ký đang chờ duyệt mới có thể được xử lý.');
      return;
    }

    setState(() => _isUpdating = true);
    MockLecturerTopicRegistrations.updateStatus(
      latest.id,
      status,
      rejectionReason: rejectionReason,
    );

    final saved = _findRegistration();
    if (!mounted) return;
    setState(() {
      _current = saved;
      _isUpdating = false;
    });

    if (saved?.status.trim() == status) {
      _message(
        status == 'Đã duyệt'
            ? 'Đã duyệt đăng ký đề tài.'
            : 'Đã từ chối đăng ký đề tài.',
      );
    } else {
      _message('Không thể lưu thay đổi đăng ký.');
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }
}

class _RegistrationRejectionDialog extends StatefulWidget {
  const _RegistrationRejectionDialog();

  @override
  State<_RegistrationRejectionDialog> createState() =>
      _RegistrationRejectionDialogState();
}

class _RegistrationRejectionDialogState
    extends State<_RegistrationRejectionDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Từ chối đăng ký'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nhập lý do để nhóm có thể điều chỉnh đăng ký.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Lý do từ chối',
              errorText: _error,
              alignLabelWithHint: true,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              setState(() => _error = 'Vui lòng nhập lý do từ chối.');
            } else {
              Navigator.pop(context, reason);
            }
          },
          child: const Text('Xác nhận từ chối'),
        ),
      ],
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final TopicRegistrationModel registration;

  const _RegistrationCard({required this.registration});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Đăng ký #${registration.id}',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(
                  label: registration.status,
                  color: _statusColor(registration.status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.schedule_outlined,
              label: 'Thời gian đăng ký',
              value: _formatDateTime(registration.registeredAt),
            ),
            if (registration.status.trim() == 'Từ chối' &&
                (registration.rejectionReason?.trim().isNotEmpty ?? false)) ...[
              const Divider(height: 22),
              Text(
                'Lý do từ chối',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                registration.rejectionReason!,
                style: TextStyle(color: colors.onSurface),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel? group;
  final TopicRegistrationModel registration;
  final LecturerCourseModel? course;

  const _GroupCard({
    required this.group,
    required this.registration,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (group == null) {
      return _IncompleteCard(
        title: 'Nhóm',
        message:
            'Không tìm thấy nhóm #${registration.groupId}; thông tin đăng ký chưa đầy đủ.',
        icon: Icons.groups_outlined,
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhóm đăng ký',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              group!.name,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Trưởng nhóm',
              value: group!.leader,
            ),
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Thành viên',
              value:
                  '${group!.memberCount}/${course?.maxMembers ?? group!.maxMembers}',
            ),
            if (course != null)
              _InfoRow(
                icon: Icons.groups_outlined,
                label: 'Giới hạn thành viên',
                value: '${course!.minMembers} - ${course!.maxMembers}',
              ),
            _InfoRow(
              icon: Icons.info_outline,
              label: 'Trạng thái nhóm',
              value: group!.status,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicModel? topic;
  final TopicRegistrationModel registration;
  final GroupModel? group;
  final bool matches;

  const _TopicCard({
    required this.topic,
    required this.registration,
    required this.group,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (topic == null) {
      return _IncompleteCard(
        title: 'Đề tài',
        message:
            'Không tìm thấy đề tài #${registration.topicId}; thông tin đăng ký chưa đầy đủ.',
        icon: Icons.lightbulb_outline,
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đề tài đăng ký',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (group != null && !matches) ...[
              const SizedBox(height: 10),
              Text(
                'Không nhất quán: đề tài thuộc học phần #${topic!.courseId}, nhóm thuộc học phần #${group!.courseId}.',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              topic!.title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (topic!.description.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                topic!.description,
                style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
              ),
            ],
            _InfoRow(
              icon: Icons.flag_outlined,
              label: 'Mục tiêu',
              value: _display(topic!.objective),
            ),
            _InfoRow(
              icon: Icons.subject_outlined,
              label: 'Phạm vi',
              value: _display(topic!.scope),
            ),
            const SizedBox(height: 2),
            _InfoRow(
              icon: Icons.link_outlined,
              label: 'Nguồn',
              value: _display(topic!.source),
            ),
            _InfoRow(
              icon: Icons.memory_outlined,
              label: 'Công nghệ',
              value: _display(topic!.technology),
            ),
            _InfoRow(
              icon: Icons.info_outline,
              label: 'Trạng thái đề tài',
              value: topic!.status,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final LecturerCourseModel? course;
  final GroupModel? group;
  final TopicModel? topic;
  final bool matches;

  const _CourseCard({
    required this.course,
    required this.group,
    required this.topic,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (group == null) {
      return const _IncompleteCard(
        title: 'Học phần',
        message:
            'Không xác định được học phần của đăng ký vì không tìm thấy nhóm.',
        icon: Icons.school_outlined,
      );
    }
    if (course == null) {
      return _IncompleteCard(
        title: 'Học phần',
        message:
            'Học phần #${group!.courseId} của nhóm không nằm trong danh sách giảng viên phụ trách.',
        icon: Icons.school_outlined,
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lớp học phần',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              course!.name,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.school_outlined,
              label: 'Mã học phần',
              value: course!.code,
            ),
            _InfoRow(
              icon: Icons.meeting_room_outlined,
              label: 'Mã lớp',
              value: course!.classCode,
            ),
            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Học kỳ',
              value: course!.semester,
            ),
            if (topic != null && !matches)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Đề tài không thuộc lớp học phần của nhóm.',
                  style: TextStyle(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncompleteCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _IncompleteCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(message, style: TextStyle(color: colors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final String message;

  const _Fallback({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: Color.lerp(AppTheme.warningColor, colors.surface, 0.88),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warningColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(color: colors.onSurface)),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color.lerp(color, colors.surface, 0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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

String _display(String value) =>
    value.trim().isEmpty ? 'Chưa có thông tin' : value;

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} • $hour:$minute';
}
