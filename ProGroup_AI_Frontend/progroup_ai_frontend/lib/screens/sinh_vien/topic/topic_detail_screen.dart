import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../models/group_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';
import '../../../services/student_api_service.dart';

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
  GroupModel? _myGroup;
  TopicRegistrationModel? _registration;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadGroupAndRegistration();
  }

  Future<void> _loadGroupAndRegistration() async {
    setState(() => _isLoading = true);
    try {
      final myGroups = await StudentApiService.instance.fetchMyGroups();
      GroupModel? foundGroup;
      for (final g in myGroups) {
        if (g.courseId == widget.course.id || g.courseId == widget.topic.courseId) {
          foundGroup = g;
          break;
        }
      }
      _myGroup = foundGroup ?? (myGroups.isNotEmpty ? myGroups.first : null);

      if (_myGroup != null) {
        final regData = await StudentApiService.instance.fetchGroupTopicRegistration(_myGroup!.id);
        if (regData != null && regData['deTaiId'] == widget.topic.id) {
          _registration = TopicRegistrationModel(
            id: regData['dangKyDeTaiId'] as int? ?? 1,
            groupId: _myGroup!.id,
            topicId: widget.topic.id,
            status: regData['trangThai'] as String? ?? 'Chờ duyệt',
            registeredAt: regData['ngayDangKy'] != null
                ? DateTime.tryParse(regData['ngayDangKy'].toString()) ?? DateTime.now()
                : DateTime.now(),
            rejectionReason: regData['ghiChu'] as String?,
          );
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  bool get isAvailable {
    return widget.topic.status == 'Có thể đăng ký' ||
        widget.topic.status == 'Chưa sử dụng' ||
        widget.topic.status == 'Chưa đăng ký';
  }

  Future<void> _registerTopic() async {
    final group = _myGroup;

    if (group == null) {
      _showMessage(
        AppLocalizations.text(
          'Bạn chưa tham gia nhóm của học phần này.',
          en: 'You have not joined a group for this course.',
        ),
      );
      return;
    }

    if (_registration != null) {
      _showMessage(
        AppLocalizations.text(
          'Nhóm đã gửi đăng ký đề tài này.',
          en: 'Your group has already registered this topic.',
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await StudentApiService.instance.registerTopic(group.id, widget.topic.id);
      _registration = TopicRegistrationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        groupId: group.id,
        topicId: widget.topic.id,
        status: 'Chờ duyệt',
        registeredAt: DateTime.now(),
      );
      _showMessage(
        AppLocalizations.text(
          'Đã gửi yêu cầu đăng ký đề tài.',
          en: 'Topic registration request submitted.',
        ),
      );
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
        return const Color(0xFF10B981);
      case 'Từ chối':
        return const Color(0xFFEF4444);
      case 'Chờ duyệt':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết đề tài', en: 'Topic details'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopicHeader(colors),
                    const SizedBox(height: 16),
                    _buildInfoCard(colors),
                    const SizedBox(height: 16),
                    if (_registration != null && _myGroup != null)
                      _buildRegistrationCard(colors, _registration!, _myGroup!),
                    if (_registration == null)
                      _buildRegistrationSection(colors, _myGroup),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTopicHeader(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.course.code,
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
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.course.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.topicText(widget.topic.title),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.text('Thông tin đề tài', en: 'Topic information'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            colors: colors,
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF2563EB),
            label: AppLocalizations.text('Giảng viên hướng dẫn', en: 'Advisor'),
            value: widget.topic.lecturerName ?? widget.course.lecturer,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            colors: colors,
            icon: Icons.source_outlined,
            iconColor: const Color(0xFF059669),
            label: AppLocalizations.text('Nguồn đề tài', en: 'Source'),
            value: widget.topic.source,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            colors: colors,
            icon: Icons.code_rounded,
            iconColor: const Color(0xFF7C3AED),
            label: AppLocalizations.text('Công nghệ', en: 'Technology'),
            value: widget.topic.technology.isNotEmpty ? widget.topic.technology : 'Chưa chỉ định',
          ),
          if (widget.topic.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.text('Mô tả', en: 'Description'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.topic.description,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
            ),
          ],
          if (widget.topic.objective.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.text('Mục tiêu', en: 'Objective'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.topic.objective,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegistrationSection(ColorScheme colors, GroupModel? group) {
    if (group == null) {
      return _buildNoticeCard(
        colors: colors,
        icon: Icons.group_off_rounded,
        iconColor: const Color(0xFFF59E0B),
        title: AppLocalizations.text('Chưa có nhóm', en: 'No group joined'),
        message: AppLocalizations.text(
          'Bạn cần tạo hoặc tham gia một nhóm đồ án trước khi đăng ký đề tài.',
          en: 'You need to join or create a group before registering for a topic.',
        ),
      );
    }

    return Container(
      width: double.infinity,
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.text('Đăng ký đề tài', en: 'Register topic'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.text(
              'Nhóm đại diện: ${group.name}',
              en: 'Your group: ${group.name}',
            ),
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _registerTopic,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isSubmitting
                    ? 'Đang gửi...'
                    : AppLocalizations.text('Gửi yêu cầu đăng ký', en: 'Submit Registration'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(
    ColorScheme colors,
    TopicRegistrationModel registration,
    GroupModel group,
  ) {
    final color = _statusColor(registration.status);

    return Container(
      width: double.infinity,
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
              Expanded(
                child: Text(
                  AppLocalizations.text('Trạng thái đăng ký', en: 'Registration status'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.status(registration.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            colors: colors,
            icon: Icons.groups_rounded,
            iconColor: const Color(0xFF2563EB),
            label: AppLocalizations.text('Nhóm', en: 'Group'),
            value: group.name,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            colors: colors,
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF8B5CF6),
            label: AppLocalizations.text('Ngày đăng ký', en: 'Registered on'),
            value: _formatDate(registration.registeredAt),
          ),
          if (registration.rejectionReason != null && registration.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              colors: colors,
              icon: Icons.info_rounded,
              iconColor: const Color(0xFFEF4444),
              label: AppLocalizations.text('Ghi chú/Lý do', en: 'Note/Reason'),
              value: registration.rejectionReason!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoticeCard({
    required ColorScheme colors,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13.5,
              height: 1.5,
            ),
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
  final ColorScheme colors;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.colors,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
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
