import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/topic_model.dart';
import 'package:progroup_ai_frontend/services/student_api_service.dart';
import 'package:progroup_ai_frontend/widgets/topic_card.dart';
import 'propose_topic_screen.dart';
import 'ai_topic_screen.dart';

class TopicScreen extends StatefulWidget {
  final CourseModel? course;

  const TopicScreen({super.key, this.course});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  String search = '';
  List<TopicModel> _topics = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await StudentApiService.instance.fetchTopics();
      if (!mounted) return;
      setState(() {
        _topics = data;
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

  CourseModel get currentCourse {
    return widget.course ??
        const CourseModel(
          id: 1,
          code: 'SE104',
          name: 'Đồ án Chuyên ngành',
          classCode: 'SE104.O21',
          semester: 'HK1 2026-2027',
          lecturer: 'TS. Nguyễn Văn A',
          status: 'Đang mở đăng ký',
        );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTopics = _topics.where((topic) {
      final keyword = search.trim().toLowerCase();
      if (keyword.isEmpty) return true;
      return topic.title.toLowerCase().contains(keyword) ||
          topic.description.toLowerCase().contains(keyword) ||
          topic.technology.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đề tài đồ án',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            tooltip: 'AI Gợi ý đề tài',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiTopicScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTopics,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm đề tài...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEBF3FF),
                    child: Icon(Icons.school_outlined, color: Color(0xFF2563EB)),
                  ),
                  title: Text(
                    currentCourse.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${currentCourse.classCode} • ${currentCourse.lecturer}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Có ${filteredTopics.length} đề tài',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
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
                                onPressed: _loadTopics,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : filteredTopics.isEmpty
                          ? const Center(child: Text('Không tìm thấy đề tài.'))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                              itemCount: filteredTopics.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final topic = filteredTopics[index];
                                return TopicCard(
                                  topic: topic,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.topicDetail,
                                      arguments: topic,
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        onPressed: _showProposalOptions,
        icon: const Icon(Icons.add),
        label: const Text('Đề xuất'),
      ),
    );
  }

  void _showProposalOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Đề xuất đề tài',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEBF3FF),
                    child: Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
                  ),
                  title: const Text('Tự đề xuất đề tài'),
                  subtitle: const Text('Nhập ý tưởng và thông tin đề tài.'),
                  onTap: () => _openProposalScreen(
                    sheetContext,
                    const ProposeTopicScreen(),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE9FE),
                    child: Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
                  ),
                  title: const Text('AI hỗ trợ đề xuất'),
                  subtitle: const Text('AI hỗ trợ phát triển ý tưởng đề tài.'),
                  onTap: () =>
                      _openProposalScreen(sheetContext, const AiTopicScreen()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openProposalScreen(
    BuildContext sheetContext,
    Widget proposalScreen,
  ) async {
    Navigator.of(sheetContext).pop();
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(builder: (_) => proposalScreen),
    );
    if (!mounted || result == null) return;

    if (result is! Map) {
      _showProposalMessage('Không đọc được nội dung đề xuất.', isError: true);
      return;
    }

    String value(String key) => (result[key] ?? '').toString().trim();
    final title = value('title');
    if (title.isEmpty) {
      _showProposalMessage('Đề xuất cần có tên đề tài.', isError: true);
      return;
    }

    try {
      await StudentApiService.instance.proposeTopic(
        dotDangKyId: currentCourse.id,
        tenDeTai: title,
        moTa: value('description'),
        mucTieu: value('objective'),
        phamVi: value('scope'),
        congNgheDuKien: value('technology'),
      );
      _showProposalMessage('Đã gửi đề xuất đến giảng viên để xem xét.');
      _loadTopics();
    } catch (e) {
      _showProposalMessage(
        'Lỗi khi gửi đề xuất: ${e.toString()}',
        isError: true,
      );
    }
  }

  void _showProposalMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}
