import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/course_service.dart';
import '../../../services/topic_service.dart';
import '../../../widgets/lecturer/lecturer_topic_card.dart';
import 'add_topic_screen.dart';
import 'edit_topic_screen.dart';
import 'lecturer_topic_detail_screen.dart';
import 'import_topic_screen.dart';
import 'lecturer_topic_assistant_screen.dart';

class LecturerTopicScreen extends StatefulWidget {
  final CourseModel? course;
  const LecturerTopicScreen({super.key, this.course});

  @override
  State<LecturerTopicScreen> createState() => _LecturerTopicScreenState();
}

class _LecturerTopicScreenState extends State<LecturerTopicScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';
  bool _isLoading = true;

  List<CourseModel> _assignedCourses = [];
  List<TopicModel> _allTopics = [];
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _selectedCourseId = widget.course!.id;
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final courses = await CourseService().getMyClasses();
      final topics = await TopicService().getLecturerTopics(dotDangKyId: _selectedCourseId);
      
      if (mounted) {
        setState(() {
          _assignedCourses = courses;
          if (widget.course == null && courses.isNotEmpty && _selectedCourseId == null) {
            _selectedCourseId = courses.first.id;
          }
          _allTopics = topics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _reloadTopics() async {
    setState(() => _isLoading = true);
    try {
      final topics = await TopicService().getLecturerTopics(dotDangKyId: _selectedCourseId);
      if (mounted) {
        setState(() {
          _allTopics = topics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TopicModel> get _topicsForSelectedCourses {
    return _allTopics.where((topic) {
      if (_selectedStatus != 'Tất cả' && topic.status != _selectedStatus) return false;
      if (_searchQuery.isNotEmpty && !topic.title.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();
  }

  void _handleDeleteTopic(TopicModel topic) async {
    final colors = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text('Xóa đề tài', en: 'Delete Topic')),
        content: Text(AppLocalizations.text(
          'Bạn có chắc chắn muốn xóa đề tài "\" không?',
          en: 'Are you sure you want to delete "${topic.title}"?'
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.text('Xóa', en: 'Delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TopicService().deleteTopic(topic.id);
        _reloadTopics();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.text('Đã xóa đề tài', en: 'Topic deleted')),
            backgroundColor: Colors.green,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: colors.error,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final topics = _topicsForSelectedCourses;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Quản Lý Đề Tài', en: 'Topic Management')),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LecturerTopicAssistantScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportTopicScreen()));
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          if (widget.course == null) _buildCourseSelector(colors),
          _buildFilters(colors),
          Expanded(
            child: topics.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.text('Không có đề tài nào.', en: 'No topics available.'),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LecturerTopicCard(
                          topic: topic,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LecturerTopicDetailScreen(topic: topic)),
                          ),
                          onEdit: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditTopicScreen(topic: topic)),
                            );
                            if (result == true) _reloadTopics();
                          },
                          onDelete: () => _handleDeleteTopic(topic),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTopicScreen(
                courseId: _selectedCourseId ?? 0,
              ),
            ),
          );
          if (result == true) _reloadTopics();
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.text('Thêm Đề Tài', en: 'Add Topic')),
      ),
    );
  }

  Widget _buildCourseSelector(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: colors.surface,
      child: DropdownButtonFormField<int>(
        value: _selectedCourseId,
        decoration: InputDecoration(
          labelText: AppLocalizations.text('Lớp học phần', en: 'Course'),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: _assignedCourses.map((c) {
          return DropdownMenuItem(
            value: c.id,
            child: Text('${c.code} - ${c.name}'),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() => _selectedCourseId = val);
            _reloadTopics();
          }
        },
      ),
    );
  }

  Widget _buildFilters(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.text('Tìm kiếm đề tài...', en: 'Search topics...'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Tất cả',
                'Chưa sử dụng',
                'Đã đăng ký',
              ].map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedStatus = status);
                    },
                    backgroundColor: colors.surfaceContainerHighest.withOpacity(0.3),
                    selectedColor: colors.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
