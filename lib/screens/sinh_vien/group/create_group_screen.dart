import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/services/api_service.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';
import 'package:progroup_ai_frontend/services/student_api_service.dart';

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

  Future<void> _createGroup() async {
    if (isCreating) return;

    final groupName = groupNameController.text.trim();
    if (groupName.isEmpty) {
      _showError(
        AppLocalizations.text(
          'Vui lòng nhập tên nhóm.',
          en: 'Please enter a group name.',
        ),
      );
      return;
    }

    setState(() => isCreating = true);

    try {
      int dotDangKyId = widget.course.id;
      try {
        final periods = await ApiService.instance.get('/api/dot-dang-ky?lopHocPhanId=${widget.course.id}');
        if (periods is List && periods.isNotEmpty) {
          dotDangKyId = periods.first['dotDangKyId'] as int? ?? dotDangKyId;
        }
      } catch (_) {}

      final created = await StudentApiService.instance.createGroup(
        dotDangKyId: dotDangKyId,
        tenNhom: groupName,
      );

      final newGroup = GroupModel(
        id: created['nhomId'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        courseId: widget.course.id,
        name: groupName,
        leader: AuthService.currentUser.fullName,
        memberCount: 1,
        maxMembers: 5,
        status: 'Đang hoạt động',
        members: [AuthService.currentUser.fullName],
      );

      if (!mounted) return;
      Navigator.pop(context, newGroup);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => isCreating = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Tạo nhóm', en: 'Create Group'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
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
                        radius: 28,
                        backgroundColor: const Color(0xFFEBF3FF),
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
                              '${widget.course.classCode} • ${widget.course.lecturer}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
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
                  'Đặt tên cho nhóm của bạn. Tên nhóm không được trùng với nhóm khác trong cùng học phần.',
                  en: 'Choose a name for your group. The group name must be unique within this course.',
                ),
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: groupNameController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _createGroup(),
                decoration: InputDecoration(
                  labelText: AppLocalizations.text('Tên nhóm', en: 'Group Name'),
                  hintText: AppLocalizations.text('Ví dụ: ProGroup Team', en: 'Example: ProGroup Team'),
                  prefixIcon: const Icon(Icons.groups_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
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
                        Expanded(
                          child: Text(
                            AppLocalizations.text('Quy định tạo nhóm', en: 'Group Creation Rules'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
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
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isCreating ? null : _createGroup,
                  icon: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.group_add),
                  label: Text(
                    isCreating
                        ? AppLocalizations.text('Đang tạo...', en: 'Creating...')
                        : AppLocalizations.text('Tạo nhóm', en: 'Create Group'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
