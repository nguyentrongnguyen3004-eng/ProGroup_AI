import 'package:flutter/material.dart';

import '../../../data/mock/mock_group_join_requests.dart';
import '../../../data/mock/mock_groups.dart';
import '../../../models/group_join_request_model.dart';
import '../../../models/group_model.dart';

class JoinRequestScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const JoinRequestScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<JoinRequestScreen> createState() => _JoinRequestScreenState();
}

class _JoinRequestScreenState extends State<JoinRequestScreen> {
  List<GroupJoinRequestModel> get requests {
    return MockGroupJoinRequests.requests
        .where((item) => item.groupId == widget.groupId)
        .toList()
        .reversed
        .toList();
  }

  int get pendingCount {
    return requests.where((item) => item.status == 'Chờ duyệt').length;
  }

  @override
  Widget build(BuildContext context) {
    final items = requests;

    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt yêu cầu tham gia')),
      body: items.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                ...items.map(_buildRequestCard),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              child: Icon(
                Icons.how_to_reg_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    pendingCount == 0
                        ? 'Không có yêu cầu đang chờ.'
                        : '$pendingCount yêu cầu đang chờ duyệt.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(GroupJoinRequestModel request) {
    final isPending = request.status == 'Chờ duyệt';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  child: Text(
                    request.studentName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MSSV: ${request.studentMssv}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(request.status),
              ],
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                request.studentEmail,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),

            const SizedBox(height: 4),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _formatDate(request.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),

            if (isPending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _rejectRequest(request);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _approveRequest(request);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Duyệt'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;

    switch (status) {
      case 'Đã duyệt':
        color = Colors.green;
        break;
      case 'Đã từ chối':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              child: Icon(
                Icons.how_to_reg_outlined,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Chưa có yêu cầu tham gia',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Các yêu cầu tham gia nhóm sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _approveRequest(GroupJoinRequestModel request) {
    final groupIndex = MockGroups.groups.indexWhere(
      (group) => group.id == widget.groupId,
    );

    if (groupIndex == -1) {
      _showMessage('Không tìm thấy nhóm.');
      return;
    }

    final group = MockGroups.groups[groupIndex];

    if (group.memberCount >= group.maxMembers) {
      _showMessage('Nhóm đã đủ số lượng thành viên.');
      return;
    }

    if (group.members.contains(request.studentName)) {
      request.status = 'Đã duyệt';

      setState(() {});

      return;
    }

    final updatedMembers = [...group.members, request.studentName];

    final updatedGroup = GroupModel(
      id: group.id,
      courseId: group.courseId,
      name: group.name,
      leader: group.leader,
      memberCount: updatedMembers.length,
      maxMembers: group.maxMembers,
      status: group.status,
      members: updatedMembers,
    );

    MockGroups.groups[groupIndex] = updatedGroup;

    request.status = 'Đã duyệt';

    setState(() {});

    _showMessage('${request.studentName} đã được thêm vào nhóm.');
  }

  void _rejectRequest(GroupJoinRequestModel request) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Từ chối yêu cầu?'),
          content: Text(
            'Bạn có chắc muốn từ chối yêu cầu của ${request.studentName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () {
                request.status = 'Đã từ chối';

                Navigator.pop(dialogContext);

                setState(() {});

                _showMessage('Đã từ chối yêu cầu.');
              },
              child: const Text('Từ chối'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} • $hour:$minute';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
