import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/data/mock/mock_groups.dart';
import 'package:progroup_ai_frontend/data/mock/mock_user.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';

class CreateGroupScreen extends StatefulWidget {
  final CourseModel course;

  const CreateGroupScreen({super.key, required this.course});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();

  static const int maxGroupsPerCourse = 10;

  bool isCreating = false;

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  // ============================================================
  // GET GROUPS OF CURRENT COURSE
  // ============================================================

  List<GroupModel> get courseGroups {
    return MockGroups.groups
        .where((group) => group.courseId == widget.course.id)
        .toList();
  }

  // ============================================================
  // NORMALIZE GROUP NAME
  // ============================================================

  String _normalizeGroupName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  // ============================================================
  // CHECK DUPLICATE GROUP NAME
  // ============================================================

  bool _isDuplicateGroupName(String name) {
    final normalizedName = _normalizeGroupName(name);

    return courseGroups.any(
      (group) => _normalizeGroupName(group.name) == normalizedName,
    );
  }

  // ============================================================
  // CREATE GROUP
  // ============================================================

  void _createGroup() {
    if (isCreating) {
      return;
    }

    final groupName = groupNameController.text.trim();

    // ----------------------------------------------------------
    // EMPTY NAME
    // ----------------------------------------------------------

    if (groupName.isEmpty) {
      _showError(
        AppLocalizations.text(
          'Vui lòng nhập tên nhóm.',
          en: 'Please enter a group name.',
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // GROUP COUNT
    // ----------------------------------------------------------

    if (courseGroups.length >= maxGroupsPerCourse) {
      _showError(
        AppLocalizations.text(
          'Học phần này đã đủ $maxGroupsPerCourse nhóm. '
          'Không thể tạo thêm nhóm.',
          en:
              'This course already has $maxGroupsPerCourse groups. '
              'No more groups can be created.',
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // DUPLICATE NAME
    // ----------------------------------------------------------

    if (_isDuplicateGroupName(groupName)) {
      _showError(
        AppLocalizations.text(
          'Tên nhóm "$groupName" đã tồn tại trong học phần này. '
          'Vui lòng chọn tên khác.',
          en:
              'The group name "$groupName" already exists in this course. '
              'Please choose another name.',
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // START CREATING
    // ----------------------------------------------------------

    setState(() {
      isCreating = true;
    });

    // ----------------------------------------------------------
    // CREATE MOCK GROUP
    // ----------------------------------------------------------

    final newGroup = GroupModel(
      id: _generateMockGroupId(),
      courseId: widget.course.id,
      name: groupName,
      leader: MockUser.student.fullName,
      memberCount: 1,
      maxMembers: 5,
      status: 'Đang hoạt động',
      members: [MockUser.student.fullName],
    );

    // Lưu nhóm vào mock data
    MockGroups.addGroup(newGroup);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }

      Navigator.pop(context, newGroup);
    });
  }

  // ============================================================
  // GENERATE MOCK GROUP ID
  // ============================================================

  int _generateMockGroupId() {
    if (MockGroups.groups.isEmpty) {
      return 1;
    }

    final maxId = MockGroups.groups
        .map((group) => group.id)
        .reduce((a, b) => a > b ? a : b);

    return maxId + 1;
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final currentGroups = courseGroups.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Tạo nhóm', en: 'Create Group')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // COURSE INFORMATION
              // ==================================================
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Icon(
                          Icons.school_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.course.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${widget.course.classCode} • '
                              '${widget.course.lecturer}',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              AppLocalizations.text(
                                'Đã có $currentGroups/$maxGroupsPerCourse nhóm',
                                en: '$currentGroups/$maxGroupsPerCourse groups created',
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // TITLE
              // ==================================================
              Text(
                AppLocalizations.text(
                  'Thông tin nhóm',
                  en: 'Group Information',
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                AppLocalizations.text(
                  'Đặt tên cho nhóm của bạn. Tên nhóm không được trùng '
                  'với nhóm khác trong cùng học phần.',
                  en:
                      'Choose a name for your group. The group name must '
                      'be unique within this course.',
                ),
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // GROUP NAME
              // ==================================================
              TextField(
                controller: groupNameController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  _createGroup();
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.text(
                    'Tên nhóm',
                    en: 'Group Name',
                  ),
                  hintText: AppLocalizations.text(
                    'Ví dụ: ProGroup Team',
                    en: 'Example: ProGroup Team',
                  ),
                  prefixIcon: const Icon(Icons.groups_outlined),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // RULES
              // ==================================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.text(
                            'Quy định tạo nhóm',
                            en: 'Group Creation Rules',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      AppLocalizations.text(
                        '• Tối đa $maxGroupsPerCourse nhóm trong một học phần.',
                        en: '• Maximum $maxGroupsPerCourse groups per course.',
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      AppLocalizations.text(
                        '• Tên nhóm không được trùng trong cùng học phần.',
                        en: '• Group names must be unique within the course.',
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      AppLocalizations.text(
                        '• Mỗi nhóm mặc định tối đa 5 thành viên.',
                        en: '• Each group can have up to 5 members by default.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // CREATE BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: isCreating ? null : _createGroup,
                  icon: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.group_add),
                  label: Text(
                    isCreating
                        ? AppLocalizations.text(
                            'Đang tạo...',
                            en: 'Creating...',
                          )
                        : AppLocalizations.text('Tạo nhóm', en: 'Create Group'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
