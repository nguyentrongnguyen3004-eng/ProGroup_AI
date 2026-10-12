import 'package:flutter/material.dart';

import '../../../models/topic_model.dart';
import '../../../services/topic_service.dart';

class LecturerTopicProposalScreen extends StatefulWidget {
  const LecturerTopicProposalScreen({super.key});

  @override
  State<LecturerTopicProposalScreen> createState() =>
      _LecturerTopicProposalScreenState();
}

class _LecturerTopicProposalScreenState
    extends State<LecturerTopicProposalScreen> {
  String _status = 'Tất cả';
  bool _isLoading = true;
  List<TopicModel> _studentTopics = [];

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoading = true);
    try {
      final topics = await TopicService().getLecturerTopics();
      if (mounted) {
        setState(() {
          _studentTopics = topics.where((t) => t.source.toLowerCase().contains('sinh viên')).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đề xuất đề tài của sinh viên')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _studentTopics.where((item) {
      if (_status == 'Tất cả') return true;
      return item.status == _status;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề xuất đề tài của sinh viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProposals,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              children: [
                Expanded(child: Text('${filtered.length} đề xuất')),
                DropdownButton<String>(
                  value: _status,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả')),
                    DropdownMenuItem(value: 'Chờ duyệt', child: Text('Chờ duyệt')),
                    DropdownMenuItem(value: 'Đã duyệt', child: Text('Đã duyệt')),
                    DropdownMenuItem(value: 'Từ chối', child: Text('Từ chối')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không có đề xuất nào.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.lightbulb_outline),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('Lĩnh vực/Công nghệ: ${item.technology}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.status,
                              style: const TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
