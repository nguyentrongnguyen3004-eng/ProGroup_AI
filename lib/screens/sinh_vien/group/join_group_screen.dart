import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/services/api_service.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final studentCodeController = TextEditingController();
  GroupModel? foundGroup;
  bool _isSearching = false;
  bool _isJoining = false;

  @override
  void dispose() {
    studentCodeController.dispose();
    super.dispose();
  }

  Future<void> _searchGroup() async {
    final keyword = studentCodeController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      _showMessage(
        AppLocalizations.text(
          'Vui lòng nhập thông tin tìm kiếm.',
          en: 'Please enter a search value.',
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      foundGroup = null;
    });

    try {
      final res = await ApiService.instance.get('/api/groups');
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

      final allGroups = list.map((e) => GroupModel.fromJson(e as Map<String, dynamic>)).toList();
      final match = allGroups.where((g) =>
          g.name.toLowerCase().contains(keyword) ||
          g.leader.toLowerCase().contains(keyword)).toList();

      if (!mounted) return;
      setState(() {
        foundGroup = match.isNotEmpty ? match.first : null;
        _isSearching = false;
      });

      if (foundGroup == null) {
        _showMessage(
          AppLocalizations.text('Không tìm thấy nhóm phù hợp.', en: 'Group not found.'),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      _showMessage('Lỗi tìm kiếm: $e');
    }
  }

  Future<void> _joinGroup() async {
    if (foundGroup == null || _isJoining) return;

    setState(() => _isJoining = true);
    try {
      await ApiService.instance.post('/api/groups/${foundGroup!.id}/join', {});
      if (!mounted) return;
      _showMessage('Đã gửi yêu cầu tham gia nhóm thành công.');
      Navigator.pop(context, foundGroup);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Tham gia nhóm', en: 'Join Group'),
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppLocalizations.text(
              'Tìm nhóm bằng tên nhóm hoặc tên trưởng nhóm.',
              en: 'Search by group name or group leader.',
            ),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: studentCodeController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchGroup(),
            decoration: InputDecoration(
              labelText: AppLocalizations.text(
                'Tên nhóm / Trưởng nhóm',
                en: 'Group / Leader',
              ),
              hintText: 'Ví dụ: Nhóm ProGroup',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _searchGroup,
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSearching ? null : _searchGroup,
              icon: _isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(AppLocalizations.text('Tìm kiếm', en: 'Search')),
            ),
          ),
          const SizedBox(height: 25),
          if (foundGroup != null) ...[
            Card(
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
                      foundGroup!.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppLocalizations.text('Trưởng nhóm', en: 'Leader')}: ${foundGroup!.leader}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.memberCount(foundGroup!.memberCount, foundGroup!.maxMembers),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isJoining ? null : _joinGroup,
                        icon: _isJoining
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.group_add),
                        label: Text(
                          _isJoining
                              ? 'Đang gửi...'
                              : AppLocalizations.text('Xin gia nhập nhóm', en: 'Request to Join'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
