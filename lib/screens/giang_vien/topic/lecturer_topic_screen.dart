import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../models/topic_model.dart';
<<<<<<< HEAD
import '../../../services/lecturer_api_service.dart';
=======
import '../../../services/course_service.dart';
import '../../../services/topic_service.dart';
>>>>>>> origin/Frontend
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
  bool _isLoading = true;
  String? _errorMessage;
  List<LecturerCourseModel> _courses = [];
  List<TopicModel> _topics = [];

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _selectedCourseId = widget.lecturerCourseId ?? widget.course?.id;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        LecturerApiService.instance.fetchCourses(),
        LecturerApiService.instance.fetchTopics(),
      ]);

      if (mounted) {
        setState(() {
          _courses = results[0] as List<LecturerCourseModel>;
          _topics = results[1] as List<TopicModel>;
=======
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
>>>>>>> origin/Frontend
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
<<<<<<< HEAD
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  List<TopicModel> get _topicsForSelectedCourses {
    final assignedCourseIds = _courses
        .map((course) => course.courseId)
        .toSet();

    if (widget.course != null) {
      if (assignedCourseIds.isNotEmpty && !assignedCourseIds.contains(widget.course!.id)) {
        return [];
      }
      return _topics.where((t) => t.courseId == widget.course!.id).toList();
    }

    return _topics
        .where((topic) =>
            assignedCourseIds.isEmpty ||
            assignedCourseIds.contains(topic.courseId) ||
            _selectedCourseId == null)
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
    if (result != null) {
      _loadData();
    }
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
    _loadData();
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
    _loadData();
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
      _loadData();
    }
  }

  Future<void> _deleteTopic(TopicModel topic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            AppLocalizations.text('Xóa đề tài?', en: 'Delete topic?'),
=======
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
>>>>>>> origin/Frontend
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.text('Xóa', en: 'Delete')),
          ),
<<<<<<< HEAD
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

    try {
      await LecturerApiService.instance.deleteTopic(topic.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text('Đã xóa đề tài.', en: 'Topic deleted.'),
          ),
        ),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi xóa đề tài: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
=======
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
>>>>>>> origin/Frontend
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final topics = _topicsForSelectedCourses;

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text(
          AppLocalizations.text('Quản lý đề tài', en: 'Topic management'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _openImport,
            tooltip: AppLocalizations.text('Import CSV/Excel', en: 'Import CSV/Excel'),
            icon: const Icon(Icons.upload_file_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTopic,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.text('Thêm đề tài', en: 'Add topic')),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.course != null) ...[
                    Text(
                      AppLocalizations.courseName(
                        currentCourse?.name ?? widget.course!.name,
                      ),
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
                      AppLocalizations.text(
                        'Đề tài trong các lớp học phần được phân công',
                        en: 'Topics in assigned course classes',
                      ),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    if (_courses.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  AppLocalizations.text(
                                    'Tất cả học phần',
                                    en: 'All courses',
                                  ),
                                ),
                                selected: _selectedCourseId == null,
                                onSelected: (_) {
                                  setState(() => _selectedCourseId = null);
                                },
                              ),
                            ),
                            ..._courses.map(
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
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
              child: _buildBody(colors, topics),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors, List<TopicModel> topics) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.text('Thử lại', en: 'Retry')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (topics.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const _EmptyTopicState(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
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
=======
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
>>>>>>> origin/Frontend
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

<<<<<<< HEAD
  LecturerCourseModel? _courseById(int courseId) {
    for (final course in _courses) {
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
  const _EmptyTopicState();

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
              size: 56,
              color: colors.outlineVariant,
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
          ],
=======
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
>>>>>>> origin/Frontend
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
