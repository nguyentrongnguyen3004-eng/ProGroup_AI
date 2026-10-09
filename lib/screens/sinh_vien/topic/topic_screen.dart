import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/data/mock/mock_courses.dart';
import 'package:progroup_ai_frontend/data/mock/mock_groups.dart';
import 'package:progroup_ai_frontend/data/mock/mock_topics.dart';
import 'package:progroup_ai_frontend/data/mock/mock_user.dart';
import 'package:progroup_ai_frontend/data/mock/mock_lecturer_topic_proposals.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/lecturer_topic_proposal_model.dart';
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

  // ============================================================
  // CURRENT COURSE
  // ============================================================

  CourseModel get currentCourse {
    return widget.course ?? MockCourses.courses.first;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------
    // CHỈ LẤY ĐỀ TÀI CỦA HỌC PHẦN HIỆN TẠI
    // ----------------------------------------------------------

    final courseTopics = MockTopics.getByCourse(currentCourse.id);

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    final topics = courseTopics.where((topic) {
      final keyword = search.trim().toLowerCase();

      if (keyword.isEmpty) {
        return true;
      }

      return topic.title.toLowerCase().contains(keyword) ||
          topic.description.toLowerCase().contains(keyword) ||
          topic.technology.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Đề tài')),

      body: Column(
        children: [
          // ======================================================
          // SEARCH
          // ======================================================
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

          // ======================================================
          // COURSE INFORMATION
          // ======================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.school_outlined)),
                title: Text(
                  currentCourse.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${currentCourse.classCode} • '
                  '${currentCourse.lecturer}',
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ======================================================
          // TOPIC COUNT
          // ======================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Có ${topics.length} đề tài',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ======================================================
          // TOPIC LIST
          // ======================================================
          Expanded(
            child: topics.isEmpty
                ? const Center(child: Text('Không tìm thấy đề tài.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: topics.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final topic = topics[index];

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

      // ==========================================================
      // PROPOSE
      // ==========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showProposalOptions,
        icon: const Icon(Icons.add),
        label: const Text('Đề xuất'),
      ),
    );
  }

  // ============================================================
  // PROPOSAL OPTIONS
  // ============================================================

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

                // ==================================================
                // TỰ ĐỀ XUẤT
                // ==================================================
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.edit_outlined)),
                  title: const Text('Tự đề xuất đề tài'),
                  subtitle: const Text('Nhập ý tưởng và thông tin đề tài.'),
                  onTap: () => _openProposalScreen(
                    sheetContext,
                    const ProposeTopicScreen(),
                  ),
                ),

                // ==================================================
                // AI
                // ==================================================
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.auto_awesome)),
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
    final result = await Navigator.of(
      context,
    ).push<Object?>(MaterialPageRoute<Object?>(builder: (_) => proposalScreen));
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

    final currentStudent = MockUser.student.fullName;
    String? groupName;
    for (final group in MockGroups.groups) {
      if (group.courseId == currentCourse.id &&
          group.members.contains(currentStudent)) {
        groupName = group.name;
        break;
      }
    }

    final proposals = MockLecturerTopicProposals.instance.proposals;
    final nextId = proposals.isEmpty
        ? 1
        : proposals
                  .map((proposal) => proposal.id)
                  .reduce((maximum, id) => id > maximum ? id : maximum) +
              1;
    MockLecturerTopicProposals.instance.add(
      LecturerTopicProposalModel(
        id: nextId,
        courseId: currentCourse.id,
        title: title,
        description: value('description'),
        objective: value('objective'),
        scope: value('scope'),
        technology: value('technology'),
        source: value('source').isEmpty ? 'Sinh viên đề xuất' : value('source'),
        proposerName: currentStudent,
        groupName: groupName ?? 'Đề xuất cá nhân',
        status: 'Chờ duyệt',
        createdAt: DateTime.now(),
      ),
    );
    _showProposalMessage('Đã gửi đề xuất đến giảng viên để xem xét.');
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
