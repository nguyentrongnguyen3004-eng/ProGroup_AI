import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/data/mock/mock_courses.dart';
import 'package:progroup_ai_frontend/data/mock/mock_topic_registrations.dart';
import 'package:progroup_ai_frontend/data/mock/mock_topics.dart';
import 'package:progroup_ai_frontend/data/mock/mock_user.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/models/topic_registration_model.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late String groupName;

  @override
  void initState() {
    super.initState();

    groupName = widget.group.name;
  }

  bool get isLeader {
    return widget.group.leader == MockUser.student.fullName;
  }

  TopicRegistrationModel? get topicRegistration {
    return MockTopicRegistrations.getByGroupId(widget.group.id);
  }

  String _getTopicTitle(int topicId) {
    for (final topic in MockTopics.topics) {
      if (topic.id == topicId && topic.courseId == widget.group.courseId) {
        return topic.title;
      }
    }

    return AppLocalizations.text(
      'Không tìm thấy đề tài trong học phần này.',
      en: 'Topic not found in this course.',
    );
  }

  CourseModel? _courseForGroup() {
    for (final course in MockCourses.courses) {
      if (course.id == widget.group.courseId) return course;
    }
    return null;
  }

  void _openCourseTopics() {
    final course = _courseForGroup();
    if (course == null) {
      _showMessage(
        AppLocalizations.text(
          'Không tìm thấy học phần của nhóm.',
          en: 'The group course could not be found.',
        ),
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.topic, arguments: course);
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'Đã duyệt':
        return Colors.green;

      case 'Từ chối':
        return Colors.red;

      case 'Cần chỉnh sửa':
        return Colors.orange;

      case 'Chờ duyệt':
        return Theme.of(context).colorScheme.primary;

      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Đã duyệt':
        return Icons.check_circle_outline;

      case 'Từ chối':
        return Icons.cancel_outlined;

      case 'Cần chỉnh sửa':
        return Icons.edit_note_outlined;

      case 'Chờ duyệt':
        return Icons.hourglass_top_outlined;

      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final registration = topicRegistration;

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.chat,
                arguments: groupName,
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  child: Text(
                    groupName.isEmpty
                        ? 'G'
                        : groupName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (isLeader)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: _changeGroupAvatar,
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Center(
            child: Text(
              groupName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          if (isLeader)
            Center(
              child: TextButton.icon(
                onPressed: _renameGroup,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  AppLocalizations.text('Đổi tên nhóm', en: 'Rename group'),
                ),
              ),
            ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              AppLocalizations.memberCount(group.memberCount, group.maxMembers),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 25),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.text('Thành viên', en: 'Members'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...group.members.map((member) {
                    final leader = member == group.leader;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(member),
                      subtitle: Text(
                        AppLocalizations.role(
                          leader ? 'Trưởng nhóm' : 'Thành viên',
                        ),
                      ),
                      trailing: leader ? const Icon(Icons.star) : null,
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(
                AppLocalizations.text('Trạng thái nhóm', en: 'Group Status'),
              ),
              subtitle: Text(AppLocalizations.status(group.status)),
            ),
          ),

          const SizedBox(height: 15),

          _buildTopicRegistrationCard(context, registration),

          const SizedBox(height: 15),

          if (isLeader)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_add_alt_1),
                    title: Text(
                      AppLocalizations.text(
                        'Quản lý lời mời',
                        en: 'Manage Invitations',
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showMessage(
                        AppLocalizations.text(
                          'Màn hình quản lý lời mời đang ở chế độ demo.',
                          en: 'Invitation management is currently in demo mode.',
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.how_to_reg_outlined),
                    title: Text(
                      AppLocalizations.text(
                        'Duyệt yêu cầu tham gia',
                        en: 'Approve Join Requests',
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showMessage(
                        AppLocalizations.text(
                          'Chưa có yêu cầu tham gia mới.',
                          en: 'There are no new join requests.',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.chat,
                arguments: groupName,
              );
            },
            icon: const Icon(Icons.chat),
            label: Text(
              AppLocalizations.text('Mở chat nhóm', en: 'Open Group Chat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicRegistrationCard(
    BuildContext context,
    TopicRegistrationModel? registration,
  ) {
    if (registration == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.topic_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.text(
                        'Đề tài của nhóm',
                        en: 'Group Topic',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                AppLocalizations.text(
                  'Nhóm chưa đăng ký đề tài.',
                  en: 'The group has not registered a topic yet.',
                ),
              ),

              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: _openCourseTopics,
                icon: const Icon(Icons.search),
                label: Text(
                  AppLocalizations.text(
                    'Xem danh sách đề tài',
                    en: 'View Topics',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final statusColor = _getStatusColor(context, registration.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.topic_outlined, color: statusColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.text('Đề tài của nhóm', en: 'Group Topic'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              _getTopicTitle(registration.topicId),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(registration.status), color: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.status(registration.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              AppLocalizations.text(
                'Ngày đăng ký: ${_formatDate(registration.registeredAt)}',
                en: 'Registered: ${_formatDate(registration.registeredAt)}',
              ),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            if (registration.status == 'Từ chối' &&
                registration.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Text(
                AppLocalizations.text(
                  'Lý do từ chối: ${registration.rejectionReason}',
                  en: 'Rejection reason: ${registration.rejectionReason}',
                ),
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: () {
                _showMessage(
                  AppLocalizations.text(
                    'Chi tiết trạng thái đăng ký đang ở chế độ demo.',
                    en: 'Registration status details are currently in demo mode.',
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              label: Text(
                AppLocalizations.text('Xem trạng thái', en: 'View Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _renameGroup() {
    final controller = TextEditingController(text: groupName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.text('Đổi tên nhóm', en: 'Rename Group'),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: AppLocalizations.text('Tên nhóm', en: 'Group name'),
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
                final value = controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                setState(() {
                  groupName = value;
                });

                Navigator.pop(dialogContext);
              },
              child: Text(AppLocalizations.text('Lưu', en: 'Save')),
            ),
          ],
        );
      },
    );
  }

  void _changeGroupAvatar() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  AppLocalizations.text(
                    'Ảnh đại diện nhóm',
                    en: 'Group Avatar',
                  ),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(
                  AppLocalizations.text('Chụp ảnh', en: 'Take Photo'),
                ),
                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    AppLocalizations.text(
                      'Demo UI: camera sẽ được kết nối ở bước tích hợp Firebase Storage.',
                      en: 'Demo UI: camera will be connected when Firebase Storage is integrated.',
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(
                  AppLocalizations.text(
                    'Chọn từ thư viện',
                    en: 'Choose from Gallery',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    AppLocalizations.text(
                      'Demo UI: thư viện ảnh sẽ được kết nối ở bước tích hợp Firebase Storage.',
                      en: 'Demo UI: gallery will be connected when Firebase Storage is integrated.',
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
