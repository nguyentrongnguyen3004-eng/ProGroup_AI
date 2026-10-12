import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/topic_model.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';
import 'package:progroup_ai_frontend/services/course_service.dart';
import 'package:progroup_ai_frontend/services/topic_service.dart';
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
  CourseModel? _activeCourse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _activeCourse = widget.course;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_activeCourse == null) {
        final courses = await CourseService().getCourses();
        if (courses.isNotEmpty) {
          _activeCourse = courses.first;
        }
      }

      if (_activeCourse != null) {
        final list = await TopicService().getTopicsByPeriod(_activeCourse!.id);
        if (mounted) {
          setState(() {
            _topics = list;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {
      // If error or empty period, try lecturer topics
      try {
        final list = await TopicService().getLecturerTopics();
        if (mounted) {
          setState(() {
            _topics = list;
            _isLoading = false;
          });
          return;
        }
      } catch (_) {}
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final course = _activeCourse;

    final filtered = _topics.where((topic) {
      final keyword = search.trim().toLowerCase();
      if (keyword.isEmpty) return true;
      return topic.title.toLowerCase().contains(keyword) ||
          topic.description.toLowerCase().contains(keyword) ||
          topic.technology.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề tài'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm đề tài...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (course != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.school_outlined)),
                  title: Text(
                    course.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${course.classCode} • ${course.lecturer}'),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Có ${filtered.length} đề tài',
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
                : filtered.isEmpty
                    ? const Center(child: Text('Không tìm thấy đề tài.'))
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final topic = filtered[index];
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
                  leading: const CircleAvatar(child: Icon(Icons.edit_outlined)),
                  title: const Text('Tự đề xuất đề tài'),
                  subtitle: const Text('Nhập ý tưởng và thông tin đề tài.'),
                  onTap: () => _openProposalScreen(
                    sheetContext,
                    const ProposeTopicScreen(),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.auto_awesome)),
                  title: const Text('AI hỗ trợ đề xuất'),
                  subtitle: const Text('AI hỗ trợ phát triển ý tưởng đề tài.'),
                  onTap: () => _openProposalScreen(
                    sheetContext,
                    const AiTopicScreen(),
                  ),
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
      final user = await AuthService().getCurrentUser();
      await TopicService().createTopic({
        'tenDeTai': title,
        'moTa': value('description'),
        'mucTieu': value('objective'),
        'phamVi': value('scope'),
        'congNghe': value('technology'),
        'dotDangKyId': _activeCourse?.id ?? 1,
        'soThanhVienToiDa': 5,
        'nguoiDeXuat': user?.fullName ?? 'Sinh viên',
      });
      _showProposalMessage('Đã gửi đề xuất đến giảng viên để xem xét.');
      _loadData();
    } catch (e) {
      _showProposalMessage('Đã gửi đề xuất: ${e.toString()}');
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
