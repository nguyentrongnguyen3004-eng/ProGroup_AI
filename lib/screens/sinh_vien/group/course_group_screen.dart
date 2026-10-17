import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/create_group_screen.dart';
import 'package:progroup_ai_frontend/services/api_service.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';

class CourseGroupScreen extends StatefulWidget {
  final CourseModel course;

  const CourseGroupScreen({super.key, required this.course});

  @override
  State<CourseGroupScreen> createState() => _CourseGroupScreenState();
}

class _CourseGroupScreenState extends State<CourseGroupScreen> {
  CourseModel get course => widget.course;
  List<GroupModel> _groups = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      dynamic res;
      try {
        res = await ApiService.instance.get('/api/groups?lopHocPhanId=${course.id}');
      } catch (_) {
        res = await ApiService.instance.get('/api/groups');
      }

      final List<dynamic> list;
      if (res is List) {
        list = res;
      } else if (res is Map && res['value'] is List) {
        list = res['value'] as List;
      } else if (res is Map && res['data'] is List) {
        list = res['data'] as List;
      } else {
        list = [];
      }

      final allGroups = list
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final filtered = allGroups
          .where((g) => g.courseId == course.id || g.courseId == 0 || allGroups.length <= 5)
          .toList();

      if (!mounted) return;
      setState(() {
        _groups = filtered.isNotEmpty ? filtered : allGroups;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  GroupModel? get currentGroup {
    final studentName = AuthService.currentUser.fullName.toLowerCase().trim();

    for (final group in _groups) {
      if (group.leader.toLowerCase().trim() == studentName) return group;
      for (final m in group.members) {
        if (m.toLowerCase().trim() == studentName) return group;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    final myGroup = currentGroup;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Nhóm lớp học phần', en: 'Course Groups'),
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
        child: RefreshIndicator(
          onRefresh: _loadGroups,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _loadGroups,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  : groups.isEmpty
                      ? _buildEmptyState(context)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 72),
                          children: [
                            _buildCourseHeader(context),
                            const SizedBox(height: 16),
                            if (myGroup != null) ...[
                              _buildMyGroup(context, myGroup),
                              const SizedBox(height: 20),
                            ],
                            _buildGroupSection(context, groups, myGroup),
                            const SizedBox(height: 20),
                            _buildBottomActions(context),
                          ],
                        ),
        ),
      ),
      floatingActionButton: myGroup == null
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              onPressed: () {
                _createGroup(context);
              },
              icon: const Icon(Icons.group_add_outlined),
              label: Text(
                AppLocalizations.text('Tạo nhóm', en: 'Create Group'),
              ),
            )
          : null,
    );
  }

  Widget _buildCourseHeader(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.menu_book_outlined,
                color: primaryColor,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.code} • ${course.classCode}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGroup(BuildContext context, GroupModel group) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups_outlined, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.text('Nhóm của bạn', en: 'Your Group'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              group.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.memberCount(group.memberCount, group.maxMembers),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openGroupDetail(context, group);
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  AppLocalizations.text('Vào nhóm', en: 'Enter Group'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSection(
    BuildContext context,
    List<GroupModel> groups,
    GroupModel? myGroup,
  ) {
    final otherGroups = groups
        .where((group) => myGroup == null || group.id != myGroup.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.text(
            'Các nhóm trong lớp',
            en: 'Groups in this Class',
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (otherGroups.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                AppLocalizations.text(
                  'Bạn đang tham gia nhóm duy nhất trong lớp.',
                  en: 'You are currently in the only group in this class.',
                ),
              ),
            ),
          )
        else
          ...otherGroups.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGroupCard(context, group, myGroup),
            ),
          ),
      ],
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    GroupModel group,
    GroupModel? myGroup,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isFull = group.memberCount >= group.maxMembers;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isFull ? Colors.red : Colors.green).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFull
                        ? AppLocalizations.text('Đã đầy', en: 'Full')
                        : AppLocalizations.text('Còn chỗ', en: 'Open'),
                    style: TextStyle(
                      color: isFull ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${AppLocalizations.text('Trưởng nhóm', en: 'Leader')}: ${group.leader}',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.memberCount(
                    group.memberCount,
                    group.maxMembers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _openGroupDetail(context, group);
                    },
                    child: Text(
                      AppLocalizations.text('Chi tiết', en: 'Details'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (myGroup != null || isFull)
                        ? null
                        : () {
                            _showJoinConfirmation(context, group);
                          },
                    child: Text(
                      AppLocalizations.text('Tham gia', en: 'Join'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 72),
      children: [
        _buildCourseHeader(context),
        const SizedBox(height: 40),
        Icon(
          Icons.groups_outlined,
          size: 70,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.text('Chưa có nhóm nào', en: 'No Groups Yet'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.text(
            'Lớp học phần này hiện chưa có nhóm nào được tạo. Hãy là người đầu tiên tạo nhóm!',
            en: 'This course has no groups yet. Be the first to create one!',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _createGroup(context),
            icon: const Icon(Icons.group_add_outlined),
            label: Text(AppLocalizations.text('Tạo nhóm mới', en: 'Create Group')),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.text('Hành động khác', en: 'Other Actions'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.joinGroup);
                    },
                    icon: const Icon(Icons.search),
                    label: Text(
                      AppLocalizations.text('Tìm nhóm', en: 'Search Group'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showMessage('Đang đồng bộ danh sách lời mời.');
                    },
                    icon: const Icon(Icons.mail_outline),
                    label: Text(
                      AppLocalizations.text('Lời mời', en: 'Invitations'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateGroupScreen(course: course)),
    );

    if (!mounted) return;
    if (result != null) {
      _loadGroups();
    }
  }

  void _showJoinConfirmation(BuildContext context, GroupModel group) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.text('Tham gia nhóm', en: 'Join Group')),
          content: Text(
            AppLocalizations.text(
              'Bạn có muốn tham gia nhóm "${group.name}" không?',
              en: 'Do you want to join "${group.name}"?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _joinGroup(group);
              },
              child: Text(AppLocalizations.text('Tham gia', en: 'Join')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _joinGroup(GroupModel group) async {
    try {
      await ApiService.instance.post('/api/groups/${group.id}/join', {});
      _showMessage('Gửi yêu cầu tham gia nhóm thành công.');
      _loadGroups();
    } catch (e) {
      _showMessage('Thông báo: $e');
    }
  }

  void _openGroupDetail(BuildContext context, GroupModel group) {
    Navigator.pushNamed(context, AppRoutes.groupDetail, arguments: group);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
