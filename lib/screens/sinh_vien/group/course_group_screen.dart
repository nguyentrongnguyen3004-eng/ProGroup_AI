import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/data/mock/mock_groups.dart';
import 'package:progroup_ai_frontend/data/mock/mock_user.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/create_group_screen.dart';

class CourseGroupScreen extends StatefulWidget {
  final CourseModel course;

  const CourseGroupScreen({super.key, required this.course});

  @override
  State<CourseGroupScreen> createState() => _CourseGroupScreenState();
}

class _CourseGroupScreenState extends State<CourseGroupScreen> {
  CourseModel get course => widget.course;

  List<GroupModel> get courseGroups {
    return MockGroups.groups
        .where((group) => group.courseId == course.id)
        .toList();
  }

  GroupModel? get currentGroup {
    final studentName = MockUser.student.fullName;

    for (final group in courseGroups) {
      if (group.members.contains(studentName)) {
        return group;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final groups = courseGroups;
    final myGroup = currentGroup;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Nhóm lớp học phần', en: 'Course Groups'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: groups.isEmpty
            ? _buildEmptyState(context)
            : ListView(
                padding: const EdgeInsets.all(20),
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
      floatingActionButton: myGroup == null
          ? FloatingActionButton.extended(
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

  Future<void> _refresh() async {
    setState(() {});
  }

  Widget _buildCourseHeader(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.groups_outlined, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.memberCount(
                          group.memberCount,
                          group.maxMembers,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${AppLocalizations.text('Trưởng nhóm', en: 'Leader')}: ${group.leader}',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: isFull
                    ? null
                    : () {
                        _showJoinConfirmation(context, group);
                      },
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(
                  isFull
                      ? AppLocalizations.text('Nhóm đã đủ', en: 'Group Full')
                      : AppLocalizations.text(
                          'Tham gia nhóm',
                          en: 'Join Group',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    if (currentGroup != null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              _createGroup(context);
            },
            icon: const Icon(Icons.group_add_outlined),
            label: Text(
              AppLocalizations.text('Tạo nhóm mới', en: 'Create New Group'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _buildCourseHeader(context),
        const SizedBox(height: 30),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.text(
                    'Chưa có nhóm nào',
                    en: 'No Groups Yet',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.text(
                    'Lớp học phần này chưa có nhóm. Bạn có thể tạo nhóm mới.',
                    en: 'There are no groups in this class yet. You can create a new group.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _createGroup(context);
                    },
                    icon: const Icon(Icons.group_add_outlined),
                    label: Text(
                      AppLocalizations.text('Tạo nhóm', en: 'Create Group'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createGroup(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateGroupScreen(course: course)),
    );

    if (!mounted) {
      return;
    }

    if (result is GroupModel) {
      setState(() {});
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
              onPressed: () {
                Navigator.pop(dialogContext);
              },
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

  void _joinGroup(GroupModel group) {
    final studentName = MockUser.student.fullName;

    if (group.members.contains(studentName)) {
      return;
    }

    if (group.memberCount >= group.maxMembers) {
      _showMessage(
        AppLocalizations.text(
          'Nhóm đã đủ thành viên.',
          en: 'The group is full.',
        ),
      );
      return;
    }

    setState(() {
      group.members.add(studentName);
    });

    _showMessage(
      AppLocalizations.text(
        'Tham gia nhóm "${group.name}" thành công.',
        en: 'Successfully joined "${group.name}".',
      ),
    );
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
