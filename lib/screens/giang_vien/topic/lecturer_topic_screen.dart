import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../widgets/lecturer/lecturer_topic_card.dart';
import 'add_topic_screen.dart';
import 'edit_topic_screen.dart';
import 'import_topic_screen.dart';
import 'lecturer_topic_detail_screen.dart';

class LecturerTopicScreen extends StatefulWidget {
  final CourseModel? course;
  final int? lecturerCourseId;

  const LecturerTopicScreen({super.key, this.course, this.lecturerCourseId});

  @override
  State<LecturerTopicScreen> createState() => _LecturerTopicScreenState();
}

class _LecturerTopicScreenState extends State<LecturerTopicScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.lecturerCourseId ?? widget.course?.id;
  }

  List<LecturerCourseModel> get _assignedCourses => MockLecturerCourses.courses;

  List<TopicModel> get _topicsForSelectedCourses {
    final assignedCourseIds = _assignedCourses
        .map((course) => course.courseId)
        .toSet();

    if (widget.course != null) {
      if (!assignedCourseIds.contains(widget.course!.id)) return [];
      return MockLecturerTopics.getByCourse(widget.course!.id);
    }

    return MockLecturerTopics.topics
        .where((topic) => assignedCourseIds.contains(topic.courseId))
        .where(
          (topic) =>
              _selectedCourseId == null || topic.courseId == _selectedCourseId,
        )
        .toList();
  }

  List<String> get _statusOptions {
    final statuses = _topicsForSelectedCourses
        .map((topic) => topic.status.trim())
        .where((status) => status.isNotEmpty)
        .toSet()
        .toList();

    return ['Tất cả', ...statuses];
  }

  List<TopicModel> get _filteredTopics {
    final query = _searchQuery.trim().toLowerCase();

    return _topicsForSelectedCourses.where((topic) {
      final matchesSearch =
          query.isEmpty ||
          topic.title.toLowerCase().contains(query) ||
          topic.description.toLowerCase().contains(query) ||
          topic.technology.toLowerCase().contains(query) ||
          topic.source.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == 'Tất cả' || topic.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _openAddTopic() async {
    final result = await Navigator.push<TopicModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTopicScreen(
          course: widget.course,
          lecturerCourseId: widget.lecturerCourseId ?? _selectedCourseId,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {
      _selectedStatus = 'Tất cả';
      if (widget.course == null && result != null) {
        _selectedCourseId = result.courseId;
      }
    });
  }

  Future<void> _openImport() async {
    final imported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ImportTopicScreen(
          course: widget.course,
          lecturerCourseId: widget.lecturerCourseId ?? _selectedCourseId,
        ),
      ),
    );
    if (!mounted || imported != true) return;
    setState(() => _selectedStatus = 'Tất cả');
  }

  Future<void> _openDetail(TopicModel topic) async {
    await Navigator.push<TopicModel>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LecturerTopicDetailScreen(course: widget.course, topic: topic),
      ),
    );

    if (!mounted) return;
    setState(() => _selectedStatus = 'Tất cả');
  }

  Future<void> _openEditTopic(TopicModel topic) async {
    final result = await Navigator.push<TopicModel>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTopicScreen(course: widget.course, topic: topic),
      ),
    );

    if (!mounted) return;
    if (result != null) {
      setState(() => _selectedStatus = 'Tất cả');
    }
  }

  Future<void> _deleteTopic(TopicModel topic) async {
    if (MockLecturerTopics.getById(topic.id) == null) {
      setState(() => _selectedStatus = 'Tất cả');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.text('Xóa đề tài?', en: 'Delete topic?'),
          ),
          content: Text(
            AppLocalizations.text(
              'Bạn có chắc muốn xóa đề tài "${topic.title}" không?',
              en: 'Are you sure you want to delete "${topic.title}"?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppLocalizations.text('Xóa', en: 'Delete')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (MockLecturerTopics.getById(topic.id) != null) {
      MockLecturerTopics.delete(topic.id);
    }

    if (!mounted) return;
    setState(() => _selectedStatus = 'Tất cả');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.text('Đã xóa đề tài.', en: 'Topic deleted.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topics = _filteredTopics;
    final colors = Theme.of(context).colorScheme;
    final currentCourse = widget.course == null
        ? null
        : _courseById(widget.course!.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Quản lý đề tài', en: 'Topic management'),
        ),
        actions: [
          IconButton(
            onPressed: _openImport,
            tooltip: AppLocalizations.text('Import CSV', en: 'Import CSV'),
            icon: const Icon(Icons.upload_file_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTopic,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.text('Thêm đề tài', en: 'Add topic')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.course != null) ...[
                  Text(
                    currentCourse?.name ?? widget.course!.name,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.course!.code} • ${widget.course!.classCode}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ] else ...[
                  Text(
                    'Đề tài trong các lớp học phần được phân công',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Tất cả học phần'),
                            selected: _selectedCourseId == null,
                            onSelected: (_) {
                              setState(() => _selectedCourseId = null);
                            },
                          ),
                        ),
                        ..._assignedCourses.map(
                          (course) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(course.classCode),
                              selected: _selectedCourseId == course.courseId,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCourseId = course.courseId;
                                  _selectedStatus = 'Tất cả';
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.text(
                      'Tìm tên, mô tả hoặc công nghệ...',
                      en: 'Search title, description or technology...',
                    ),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_statusOptions.length > 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statusOptions
                          .map(
                            (status) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _StatusFilter(
                                label: status,
                                selected: _selectedStatus == status,
                                onTap: () {
                                  setState(() => _selectedStatus = status);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: topics.isEmpty
                ? _EmptyTopicState(onAdd: _openAddTopic)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LecturerTopicCard(
                          topic: topic,
                          onTap: () => _openDetail(topic),
                          onEdit: () => _openEditTopic(topic),
                          onDelete: () => _deleteTopic(topic),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  LecturerCourseModel? _courseById(int courseId) {
    for (final course in _assignedCourses) {
      if (course.courseId == courseId) return course;
    }
    return null;
  }
}

class _StatusFilter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(AppLocalizations.status(label)),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _EmptyTopicState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyTopicState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.text('Chưa có đề tài', en: 'No topics'),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.text(
                'Không có đề tài phù hợp trong phạm vi đã chọn.',
                en: 'No topics match the selected course or filters.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(
                AppLocalizations.text('Thêm đề tài', en: 'Add topic'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
