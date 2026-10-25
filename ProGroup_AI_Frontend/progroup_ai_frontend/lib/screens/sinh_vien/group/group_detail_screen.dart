import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/models/topic_model.dart';
import 'package:progroup_ai_frontend/models/topic_registration_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/chat/chat_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/group_progress_report_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/invitation_management_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/join_request_screen.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';
import 'package:progroup_ai_frontend/services/student_api_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late String groupName;
  TopicRegistrationModel? _topicRegistration;
  TopicModel? _registeredTopic;
  CourseModel? _course;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    groupName = widget.group.name;
    _fetchLiveDetails();
  }

  Future<void> _fetchLiveDetails() async {
    setState(() => _isLoading = true);
    try {
      final regData = await StudentApiService.instance.fetchGroupTopicRegistration(widget.group.id);
      if (regData != null) {
        final deTaiId = regData['deTaiId'] as int? ?? 0;
        _topicRegistration = TopicRegistrationModel(
          id: regData['dangKyDeTaiId'] as int? ?? 1,
          groupId: widget.group.id,
          topicId: deTaiId,
          status: regData['trangThai'] as String? ?? 'Chờ duyệt',
          registeredAt: regData['ngayDangKy'] != null
              ? DateTime.tryParse(regData['ngayDangKy'].toString()) ?? DateTime.now()
              : DateTime.now(),
          rejectionReason: regData['ghiChu'] as String?,
        );

        if (deTaiId > 0) {
          final allTopics = await StudentApiService.instance.fetchTopics();
          for (final t in allTopics) {
            if (t.id == deTaiId) {
              _registeredTopic = t;
              break;
            }
          }
          if (_registeredTopic == null && regData['tenDeTai'] != null) {
            _registeredTopic = TopicModel(
              id: deTaiId,
              courseId: widget.group.courseId,
              title: regData['tenDeTai'] as String,
              description: '',
              objective: '',
              scope: '',
              technology: '',
              source: 'Giảng viên',
              status: 'Đã đăng ký',
            );
          }
        }
      }

      final myCourses = await StudentApiService.instance.fetchMyCourses();
      for (final c in myCourses) {
        if (c.id == widget.group.courseId) {
          _course = c;
          break;
        }
      }
      if (_course == null && myCourses.isNotEmpty) {
        _course = myCourses.first;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  bool get isLeader {
    final currentName = AuthService.currentUser.fullName.toLowerCase().trim();
    return widget.group.leader.toLowerCase().trim() == currentName;
  }

  void _openCourseTopics() {
    final course = _course ??
        CourseModel(
          id: widget.group.courseId,
          code: 'LHP',
          name: 'Học phần đồ án',
          classCode: 'LHP.01',
          semester: 'HK1 2026-2027',
          lecturer: 'Giảng viên',
          status: 'Đang mở',
        );

    Navigator.pushNamed(context, AppRoutes.topic, arguments: course);
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

  void _renameGroup() {
    final controller = TextEditingController(text: groupName);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(AppLocalizations.text('Đổi tên nhóm', en: 'Rename Group')),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Tên nhóm mới', en: 'New Group Name'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await StudentApiService.instance.updateGroupName(widget.group.id, newName);
                    if (mounted) {
                      setState(() => groupName = newName);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      _showMessage(
                        AppLocalizations.text('Đã đổi tên nhóm thành công.', en: 'Group renamed successfully.'),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      _showMessage('Lỗi khi đổi tên: ${e.toString().replaceAll("Exception: ", "")}');
                    }
                  }
                }
              },
              child: Text(AppLocalizations.text('Lưu', en: 'Save')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelRegistration() async {
    final reg = _topicRegistration;
    if (reg == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy đăng ký đề tài?'),
        content: const Text('Bạn có chắc chắn muốn hủy đăng ký đề tài này để chọn đề tài khác không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Đóng')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy đăng ký'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await StudentApiService.instance.cancelTopicRegistration(reg.id);
      _showMessage('Đã hủy đăng ký đề tài thành công.');
      _fetchLiveDetails();
    } catch (e) {
      _showMessage('Lỗi: ${e.toString().replaceAll("Exception: ", "")}');
    }
  }

  Future<void> _leaveGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rời nhóm?'),
        content: const Text('Bạn có chắc chắn muốn rời khỏi nhóm này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rời nhóm'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await StudentApiService.instance.leaveGroup(widget.group.id);
      if (mounted) {
        _showMessage('Đã rời nhóm thành công.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showMessage('Lỗi: ${e.toString().replaceAll("Exception: ", "")}');
    }
  }

  Future<void> _disbandGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Giải tán nhóm?'),
        content: const Text('Hành động này sẽ xóa hoàn toàn nhóm. Bạn có chắc chắn không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Giải tán nhóm'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await StudentApiService.instance.disbandGroup(widget.group.id);
      if (mounted) {
        _showMessage('Đã giải tán nhóm thành công.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showMessage('Lỗi: ${e.toString().replaceAll("Exception: ", "")}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final group = widget.group;
    final registration = _topicRegistration;
    final topic = _registeredTopic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupName,
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    groupName: groupName,
                    groupId: group.id,
                  ),
                ),
              );
            },
            tooltip: 'Đoạn chat nhóm',
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchLiveDetails,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 72),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                groupName.isEmpty ? 'G' : groupName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            groupName,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isLeader) ...[
                            const SizedBox(height: 4),
                            TextButton.icon(
                              onPressed: _renameGroup,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text(
                                AppLocalizations.text('Đổi tên nhóm', en: 'Rename group'),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Thành viên: ${group.memberCount}/${group.maxMembers} sinh viên',
                              style: const TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.groups_rounded, color: Color(0xFF2563EB), size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.text('Danh sách thành viên', en: 'Group Members'),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${group.members.length} người',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...group.members.map((member) {
                            final isMemberLeader = member == group.leader;
                            final initials = member.isNotEmpty ? member[0].toUpperCase() : 'U';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isMemberLeader
                                          ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                                          : const Color(0xFF6366F1).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          color: isMemberLeader ? const Color(0xFFD97706) : const Color(0xFF4F46E5),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: colors.onSurface,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isMemberLeader ? 'Trưởng nhóm' : 'Thành viên',
                                          style: TextStyle(
                                            color: isMemberLeader ? const Color(0xFFD97706) : colors.onSurfaceVariant,
                                            fontSize: 12,
                                            fontWeight: isMemberLeader ? FontWeight.w700 : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isMemberLeader)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                                          SizedBox(width: 3),
                                          Text(
                                            'Trưởng nhóm',
                                            style: TextStyle(
                                              color: Color(0xFFD97706),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.lightbulb_rounded, color: Color(0xFF6366F1), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  AppLocalizations.text('Đề tài nghiên cứu của nhóm', en: 'Group Topic'),
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (registration == null) ...[
                            Text(
                              AppLocalizations.text(
                                'Nhóm chưa đăng ký đề tài nào trong học phần này.',
                                en: 'Your group has not registered any topic yet.',
                              ),
                              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13.5),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: _openCourseTopics,
                                icon: const Icon(Icons.search_rounded, size: 18),
                                label: Text(
                                  AppLocalizations.text('Khám phá & Đăng ký đề tài', en: 'Explore Topics'),
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              topic?.title ?? 'Đề tài #${registration.topicId}',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    AppLocalizations.status(registration.status),
                                    style: const TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (topic != null)
                                  Expanded(
                                    child: Text(
                                      topic.technology,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            if (isLeader && registration.status != 'Đã duyệt') ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _cancelRegistration,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                    side: const BorderSide(color: Color(0xFFEF4444)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.cancel_outlined, size: 16),
                                  label: const Text('Hủy đăng ký đề tài này', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                                  'Báo cáo tiến độ đồ án',
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
                            'Nộp báo cáo định kỳ (PDF, link Github, demo) để giảng viên theo dõi, nhận xét và chấm điểm tiến độ.',
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GroupProgressReportScreen(
                                      group: widget.group,
                                      topicTitle: _registeredTopic?.title,
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF059669),
                                side: const BorderSide(color: Color(0xFF10B981)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.upload_file_rounded, size: 18),
                              label: const Text('Xem & Nộp báo cáo tiến độ', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isLeader) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.person_add_rounded, color: Color(0xFF3B82F6), size: 19),
                              ),
                              title: Text(
                                AppLocalizations.text('Quản lý lời mời tham gia nhóm', en: 'Manage Invitations'),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                ),
                              ),
                              subtitle: Text(
                                'Mời sinh viên khác hoặc xem trạng thái lời mời đã gửi',
                                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InvitationManagementScreen(
                                      groupId: group.id,
                                      groupName: groupName,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, indent: 64, color: colors.outlineVariant.withValues(alpha: 0.4)),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.how_to_reg_rounded, color: Color(0xFF10B981), size: 19),
                              ),
                              title: Text(
                                AppLocalizations.text('Duyệt yêu cầu tham gia nhóm', en: 'Approve Join Requests'),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                ),
                              ),
                              subtitle: Text(
                                'Xem và duyệt danh sách sinh viên xin gia nhập nhóm',
                                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JoinRequestScreen(
                                      groupId: group.id,
                                      groupName: groupName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                groupName: groupName,
                                groupId: group.id,
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                        label: Text(
                          AppLocalizations.text('Mở đoạn chat nhóm', en: 'Open Group Chat'),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                    if (!isLeader) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _leaveGroup,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                          label: const Text('Rời nhóm', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                    if (isLeader && (_topicRegistration == null || _topicRegistration!.status != 'Đã duyệt')) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _disbandGroup,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.delete_forever_rounded, size: 18),
                          label: const Text('Giải tán nhóm', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
