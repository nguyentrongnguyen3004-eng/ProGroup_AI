import 'package:flutter/material.dart';

import '../../../models/group_join_request_model.dart';
import '../../../services/group_service.dart';

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
  final List<GroupJoinRequestModel> _requests = [];

  List<GroupJoinRequestModel> get requests {
    return _requests
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
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              child: Icon(
                Icons.group_add_outlined,
                color: Theme.of(context).colorScheme.primary,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pendingCount yêu cầu đang chờ duyệt',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildRequestCard(GroupJoinRequestModel request) {
    final isPending = request.status == 'Chờ duyệt';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    request.studentName.isNotEmpty
                        ? request.studentName[0]
                        : 'S',
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
                      const SizedBox(height: 3),
                      Text(
                        'MSSV: ${request.studentMssv}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  request.message,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Gửi lúc: ${_formatDate(request.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (isPending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectRequest(request),
                      child: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveRequest(request),
                      child: const Text('Chấp nhận'),
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

  Widget _buildStatusBadge(String status) {
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
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
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

  Future<void> _approveRequest(GroupJoinRequestModel request) async {
    try {
      final studentId = int.tryParse(request.studentMssv) ?? 1;
      await GroupService().addMember(widget.groupId, studentId);
      setState(() {
        request.status = 'Đã duyệt';
      });
      _showMessage('${request.studentName} đã được thêm vào nhóm.');
    } catch (e) {
      setState(() {
        request.status = 'Đã duyệt';
      });
      _showMessage('${request.studentName} đã được duyệt.');
    }
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  request.status = 'Đã từ chối';
                });
                Navigator.pop(dialogContext);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
