import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_groups.dart';
import '../../../data/mock/mock_topic_registrations.dart';
import '../../../data/mock/mock_user.dart';
import '../../../models/course_model.dart';
import '../../../models/group_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';

class TopicDetailScreen extends StatefulWidget {
  final TopicModel topic;
  final CourseModel course;

  const TopicDetailScreen({
    super.key,
    required this.topic,
    required this.course,
  });

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  GroupModel? get currentGroup {
    try {
      return MockGroups.groups.firstWhere(
        (group) =>
            group.courseId == widget.course.id &&
            group.members.contains(MockUser.student.fullName),
      );
    } catch (_) {
      return null;
    }
  }

  TopicRegistrationModel? get currentRegistration {
    final group = currentGroup;

    if (group == null) {
      return null;
    }

    return MockTopicRegistrations.getByGroupAndTopic(group.id, widget.topic.id);
  }

  bool get isAvailable {
    return widget.topic.status == 'Có thể đăng ký';
  }

  void _registerTopic() {
    final group = currentGroup;

    if (group == null) {
      _showMessage(
        AppLocalizations.text(
          'Bạn chưa tham gia nhóm của học phần này.',
          en: 'You have not joined a group for this course.',
        ),
      );
      return;
    }

    final existing = MockTopicRegistrations.getByGroupAndTopic(
      group.id,
      widget.topic.id,
    );

    if (existing != null) {
      _showMessage(
        AppLocalizations.text(
          'Nhóm đã gửi đăng ký đề tài này.',
          en: 'Your group has already registered this topic.',
        ),
      );
      return;
    }

    if (!isAvailable) {
      _showMessage(
        AppLocalizations.text(
          'Đề tài hiện không thể đăng ký.',
          en: 'This topic is currently unavailable.',
        ),
      );
      return;
    }

    final registration = TopicRegistrationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      groupId: group.id,
      topicId: widget.topic.id,
      status: 'Chờ duyệt',
      registeredAt: DateTime.now(),
    );

    MockTopicRegistrations.add(registration);

    setState(() {});

    _showMessage(
      AppLocalizations.text(
        'Đã gửi yêu cầu đăng ký đề tài.',
        en: 'Topic registration request submitted.',
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
        return const Color(0xFF16A36C);

      case 'Từ chối':
        return const Color(0xFFE55353);

      case 'Chờ duyệt':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = currentGroup;
    final registration = currentRegistration;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
        title: Text(
          AppLocalizations.text('Chi tiết đề tài', en: 'Topic details'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopicHeader(),
            const SizedBox(height: 16),

            _buildInfoCard(),

            const SizedBox(height: 16),

            if (registration != null && group != null)
              _buildRegistrationCard(registration, group),

            if (registration == null) _buildRegistrationSection(group),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3157D5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.course.code,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.course.name,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.topicText(widget.topic.title),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.text('Mô tả đề tài', en: 'Topic description'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.topicText(widget.topic.description),
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.6),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.code_outlined, color: Color(0xFF3157D5)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.text('Công nghệ', en: 'Technology'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.topic.technology,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationSection(GroupModel? group) {
    if (group == null) {
      return _buildNoticeCard(
        icon: Icons.groups_outlined,
        title: AppLocalizations.text('Chưa có nhóm', en: 'No group'),
        message: AppLocalizations.text(
          'Bạn cần tham gia hoặc tạo nhóm trong học phần này trước khi đăng ký đề tài.',
          en: 'You need to join or create a group for this course before registering a topic.',
        ),
      );
    }

    if (!isAvailable) {
      return _buildNoticeCard(
        icon: Icons.lock_outline,
        title: AppLocalizations.text(
          'Đề tài không khả dụng',
          en: 'Topic unavailable',
        ),
        message: AppLocalizations.text(
          'Đề tài này hiện không mở đăng ký.',
          en: 'This topic is currently unavailable for registration.',
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.text('Đăng ký đề tài', en: 'Register topic'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.text(
              'Nhóm của bạn: ${group.name}',
              en: 'Your group: ${group.name}',
            ),
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _registerTopic,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3157D5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.text('Đăng ký đề tài', en: 'Register topic'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(
    TopicRegistrationModel registration,
    GroupModel group,
  ) {
    final color = _statusColor(registration.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.text(
                    'Trạng thái đăng ký',
                    en: 'Registration status',
                  ),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.status(registration.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.groups_outlined,
            label: AppLocalizations.text('Nhóm', en: 'Group'),
            value: group.name,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: AppLocalizations.text('Ngày đăng ký', en: 'Registered on'),
            value: _formatDate(registration.registeredAt),
          ),
          if (registration.rejectionReason != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.info_outline,
              label: AppLocalizations.text('Lý do', en: 'Reason'),
              value: registration.rejectionReason!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoticeCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF3157D5)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.5),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: const Color(0xFF3157D5)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
