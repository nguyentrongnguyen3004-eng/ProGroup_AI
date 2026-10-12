import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/services/group_service.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final studentCodeController = TextEditingController();

  GroupModel? foundGroup;
  bool _isSearching = false;

  @override
  void dispose() {
    studentCodeController.dispose();
    super.dispose();
  }

  Future<void> _searchGroup() async {
    final keyword = studentCodeController.text.trim();

    if (keyword.isEmpty) {
      _showMessage(
        AppLocalizations.text(
          'Vui lòng nhập thông tin tìm kiếm.',
          en: 'Please enter a search value.',
        ),
      );
      return;
    }

    setState(() => _isSearching = true);
    try {
      final id = int.tryParse(keyword);
      if (id != null) {
        final group = await GroupService().getGroupById(id);
        if (mounted) setState(() { foundGroup = group; _isSearching = false; });
        return;
      }

      final myGroups = await GroupService().getMyGroups();
      final result = myGroups.where(
        (group) =>
            group.leader.toLowerCase().contains(keyword.toLowerCase()) ||
            group.name.toLowerCase().contains(keyword.toLowerCase()),
      );

      setState(() {
        foundGroup = result.isEmpty ? null : result.first;
        _isSearching = false;
      });

      if (foundGroup == null) {
        _showMessage(
          AppLocalizations.text('Không tìm thấy nhóm.', en: 'Group not found.'),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          foundGroup = null;
          _isSearching = false;
        });
        _showMessage(
          AppLocalizations.text('Không tìm thấy nhóm.', en: 'Group not found.'),
        );
      }
    }
  }

  void _joinGroup() {
    if (foundGroup == null) return;
    _showMessage('Đã gửi yêu cầu tham gia nhóm ${foundGroup!.name}.');
    Navigator.pop(context, foundGroup);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Tham gia nhóm', en: 'Join Group')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppLocalizations.text(
              'Tìm nhóm bằng ID, tên nhóm hoặc tên trưởng nhóm.',
              en: 'Search by group ID, group name or group leader.',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: studentCodeController,
            decoration: InputDecoration(
              labelText: AppLocalizations.text(
                'Tên nhóm / Mã nhóm / Trưởng nhóm',
                en: 'Group ID / Name / Leader',
              ),
              hintText: 'Ví dụ: 1 hoặc Nhóm ProGroup',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSearching ? null : _searchGroup,
              icon: _isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(
                AppLocalizations.text('TÌM NHÓM', en: 'SEARCH GROUP'),
              ),
            ),
          ),
          const SizedBox(height: 25),
          if (foundGroup != null) _buildGroupResult(context),
        ],
      ),
    );
  }

  Widget _buildGroupResult(BuildContext context) {
    final group = foundGroup!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    group.name.isNotEmpty ? group.name.substring(0, 1) : 'G',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.name,
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
              '${AppLocalizations.text('Trưởng nhóm', en: 'Leader')}: ${group.leader}',
            ),
            const SizedBox(height: 7),
            Text(
              '${group.memberCount}/${group.maxMembers} ${AppLocalizations.text('thành viên', en: 'members')}',
            ),
            const SizedBox(height: 7),
            Text(AppLocalizations.status(group.status)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _joinGroup,
                child: Text(
                  AppLocalizations.text(
                    'GỬI YÊU CẦU THAM GIA',
                    en: 'REQUEST TO JOIN',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
