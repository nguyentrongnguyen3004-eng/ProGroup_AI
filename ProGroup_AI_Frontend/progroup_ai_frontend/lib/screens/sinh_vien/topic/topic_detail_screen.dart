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
  late TopicModel _topic;
  GroupModel? _myGroup;
  TopicRegistrationModel? _registration;
  TopicRegistrationModel? _otherGroupRegistration;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
    _loadGroupAndRegistration();
  }

  Future<void> _loadGroupAndRegistration() async {
    setState(() => _isLoading = true);
    _myGroup = null;
    _registration = null;
    _otherGroupRegistration = null;
    try {
      final results = await Future.wait<dynamic>([
        StudentApiService.instance.fetchMyGroups(forceRefresh: true),
        StudentApiService.instance.fetchTopicById(
          widget.topic.id,
          forceRefresh: true,
        ),
      ]);
      final myGroups = results[0] as List<GroupModel>;
      final freshTopic = results[1] as TopicModel?;
      if (freshTopic != null) {
        _topic = freshTopic;
      }

      GroupModel? foundGroup;
      for (final g in myGroups) {
        if (g.courseId == widget.course.id ||
            g.courseId == _topic.courseId ||
            (_topic.lopHocPhanId != null && g.courseId == _topic.lopHocPhanId)) {
          foundGroup = g;
          break;
        }
      }
      // Chỉ gán nhóm nếu nhóm đó thực sự thuộc học phần của đề tài
      _myGroup = foundGroup;

      if (_myGroup != null) {
        final regData = await StudentApiService.instance.fetchGroupTopicRegistration(_myGroup!.id);
        if (regData != null) {
          final regTopicId = regData['deTaiId'] as int? ?? 0;
          final regStatus = regData['trangThai'] as String? ?? 'Chờ duyệt';
          if (regTopicId == widget.topic.id) {
            _registration = TopicRegistrationModel(
              id: regData['dangKyDeTaiId'] as int? ?? 1,
              groupId: _myGroup!.id,
              topicId: widget.topic.id,
              status: regStatus,
              registeredAt: regData['ngayDangKy'] != null
                  ? DateTime.tryParse(regData['ngayDangKy'].toString()) ?? DateTime.now()
                  : DateTime.now(),
            rejectionReason: regData['rejectionReason'] as String? ??
                regData['ghiChu'] as String? ??
                regData['lyDoTuChoi'] as String? ??
                regData['lyDo'] as String? ??
                regData['reason'] as String?,
          );
          } else if (regStatus == 'Chờ duyệt' || regStatus == 'Đã duyệt') {
            _otherGroupRegistration = TopicRegistrationModel(
              id: regData['dangKyDeTaiId'] as int? ?? 1,
              groupId: _myGroup!.id,
              topicId: regTopicId,
              status: regStatus,
              registeredAt: regData['ngayDangKy'] != null
                  ? DateTime.tryParse(regData['ngayDangKy'].toString()) ?? DateTime.now()
                  : DateTime.now(),
            );
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  bool get isAvailable {
    final statusOk = _topic.status == 'Có thể đăng ký' ||
        _topic.status == 'Chưa sử dụng' ||
        _topic.status == 'Chưa đăng ký' ||
        _topic.status == 'Đang hoạt động';
    final approvalOk =
        _topic.approvalStatus == null || _topic.approvalStatus == 'Đã duyệt';
    return statusOk && approvalOk;
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

    if (!isAvailable) {
      _showMessage(
        _topic.status == 'Đã đăng ký'
            ? AppLocalizations.text(
                'Đề tài này đã hết slot (đã đủ số nhóm đăng ký).',
                en: 'This topic has no slots left.',
              )
            : AppLocalizations.text(
                'Đề tài hiện không khả dụng để đăng ký.',
                en: 'This topic is currently unavailable.',
              ),
      );
      return;
    }

    if (_otherGroupRegistration != null) {
      _showMessage(
        AppLocalizations.text(
          'Nhóm đã có đề tài đang chờ duyệt hoặc đã duyệt.',
          en: 'Your group already has an active topic registration.',
        ),
      );
      return;
    }

    final minReq = group.minMembers > 0 ? group.minMembers : 2;
    if (group.memberCount < minReq) {
      _showMessage(
        'Nhóm của bạn chưa đủ số thành viên tối thiểu (yêu cầu tối thiểu $minReq thành viên).',
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
      await StudentApiService.instance.registerTopic(group.id, _topic.id);
      _topic = _topic.copyWith(status: 'Đã đăng ký');
      _registration = TopicRegistrationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        groupId: group.id,
        topicId: _topic.id,
        status: 'Chờ duyệt',
        registeredAt: DateTime.now(),
      );
      _showMessage(
        AppLocalizations.text(
          'Đã gửi yêu cầu đăng ký đề tài.',
          en: 'Topic registration request submitted.',
        ),
      );
      await _loadGroupAndRegistration();
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
          if (widget.topic.rejectionReason != null && widget.topic.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lý do từ chối đề xuất:',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.topic.rejectionReason!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        title: AppLocalizations.text('Không thể đăng ký đề tài này', en: 'Cannot register this topic'),
        message: AppLocalizations.text(
          'Đề tài này thuộc học phần khác hoặc nhóm hiện tại của bạn không nằm trong học phần này. Vui lòng chọn đề tài đúng học phần của nhóm bạn để đăng ký.',
          en: 'This topic belongs to another course or your current group is not in this course.',
        ),
      );
    }

    if (!isAvailable) {
      final isFull = _topic.status == 'Đã đăng ký';
      return _buildNoticeCard(
        colors: colors,
        icon: isFull ? Icons.event_busy_rounded : Icons.lock_outline_rounded,
        iconColor: const Color(0xFFEF4444),
        title: isFull
            ? AppLocalizations.text('Đề tài đã hết slot (Đã đủ số nhóm)', en: 'Topic is full')
            : AppLocalizations.text('Đề tài không khả dụng', en: 'Topic unavailable'),
        message: isFull
            ? AppLocalizations.text(
                'Đề tài này đã có nhóm khác đăng ký. Vui lòng chọn đề tài khác còn trống.',
                en: 'This topic has already been registered by another group.',
              )
            : AppLocalizations.text(
                'Đề tài hiện ở trạng thái "${_topic.status}" nên không thể đăng ký.',
                en: 'This topic is currently not open for registration.',
              ),
      );
    }

    if (_otherGroupRegistration != null) {
      return _buildNoticeCard(
        colors: colors,
        icon: Icons.assignment_late_outlined,
        iconColor: const Color(0xFFF59E0B),
        title: AppLocalizations.text('Nhóm đã đăng ký đề tài khác', en: 'Group already registered'),
        message: AppLocalizations.text(
          'Nhóm của bạn đang có đề tài ở trạng thái "${_otherGroupRegistration!.status}". Mỗi nhóm chỉ được đăng ký 1 đề tài tại một thời điểm.',
          en: 'Your group already has an active topic registration.',
        ),
      );
    }

    final minReq = group.minMembers > 0 ? group.minMembers : 2;
    final hasEnoughMembers = group.memberCount >= minReq;

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
              'Nhóm đại diện: ${group.name} (${group.memberCount}/$minReq thành viên tối thiểu)',
              en: 'Your group: ${group.name} (${group.memberCount}/$minReq min members)',
            ),
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13.5),
          ),
          if (!hasEnoughMembers) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nhóm của bạn chưa đủ số thành viên tối thiểu (yêu cầu tối thiểu $minReq thành viên).',
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: (_isSubmitting || !hasEnoughMembers) ? null : _registerTopic,
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
                  : Icon(hasEnoughMembers ? Icons.send_rounded : Icons.block_rounded, size: 18),
              label: Text(
                _isSubmitting
                    ? 'Đang gửi...'
                    : !hasEnoughMembers
                        ? 'Chưa đủ thành viên tối thiểu'
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
