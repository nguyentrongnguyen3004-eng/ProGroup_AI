import 'package:flutter/material.dart';

import '../../../models/course_model.dart';
import '../../../models/lecturer_topic_suggestion_model.dart';
import '../../../services/course_service.dart';
import '../../../services/lecturer_topic_suggestion_service.dart';
import 'add_topic_screen.dart';

class LecturerTopicAssistantScreen extends StatefulWidget {
  const LecturerTopicAssistantScreen({super.key});

  @override
  State<LecturerTopicAssistantScreen> createState() =>
      _LecturerTopicAssistantScreenState();
}

class _LecturerTopicAssistantScreenState
    extends State<LecturerTopicAssistantScreen> {
  final _fieldController = TextEditingController();
  final _technologyController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _service = const LecturerTopicSuggestionService();

  List<CourseModel> _courses = [];
  int? _courseId;
  List<LecturerTopicSuggestionModel> _suggestions = const [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await CourseService().getMyClasses();
      if (mounted) {
        setState(() {
          _courses = courses;
          if (courses.isNotEmpty) {
            _courseId = courses.first.id;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _technologyController.dispose();
    _keywordsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_courseId == null) {
      setState(() => _error = 'Chưa có lớp học phần được phân công.');
      return;
    }
    if (_fieldController.text.trim().isEmpty &&
        _keywordsController.text.trim().isEmpty &&
        _descriptionController.text.trim().isEmpty) {
      setState(() {
        _searched = true;
        _suggestions = const [];
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
      _suggestions = const [];
    });
    try {
      final suggestions = await _service.suggest(
        courseId: _courseId!,
        field: _fieldController.text,
        technology: _technologyController.text,
        keywords: _keywordsController.text,
        description: _descriptionController.text,
      );
      if (!mounted) return;
      setState(() => _suggestions = suggestions);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Chưa thể tạo gợi ý. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useSuggestion(LecturerTopicSuggestionModel suggestion) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTopicScreen(
          courseId: _courseId ?? 0,
          initialValues: {
            'title': suggestion.title,
            'description': suggestion.description,
            'objective': suggestion.objective,
            'scope': suggestion.scope,
            'technology': suggestion.technology,
            'source': 'AI đề xuất',
          },
        ),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đề tài đã được lưu vào lớp học phần.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ lý gợi ý đề tài')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: colors.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Hệ thống sẽ gợi ý đề tài phù hợp dựa trên từ khóa, lĩnh vực và công nghệ bạn nhập.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _courseId,
            decoration: const InputDecoration(
              labelText: 'Lớp học phần',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: _courses
                .map(
                  (course) => DropdownMenuItem(
                    value: course.id,
                    child: Text(
                      '${course.code} • ${course.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _courseId = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fieldController,
            decoration: const InputDecoration(
              labelText: 'Lĩnh vực hoặc hướng nghiên cứu',
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _technologyController,
            decoration: const InputDecoration(
              labelText: 'Công nghệ ưu tiên (Flutter, AI, Cloud...)',
              prefixIcon: Icon(Icons.code_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keywordsController,
            decoration: const InputDecoration(
              labelText: 'Từ khóa mong muốn',
              prefixIcon: Icon(Icons.key_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả thêm về yêu cầu đề tài',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _generate,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_outlined),
            label: Text(_loading ? 'Đang tạo...' : 'Tạo gợi ý đề tài'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: colors.error),
            ),
          ],
          if (_searched && _suggestions.isEmpty && !_loading && _error == null) ...[
            const SizedBox(height: 24),
            const Center(
              child: Text('Không tìm thấy gợi ý phù hợp.'),
            ),
          ],
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Gợi ý đề tài (${_suggestions.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._suggestions.map(
              (suggestion) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(suggestion.description),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => _useSuggestion(suggestion),
                            icon: const Icon(Icons.add),
                            label: const Text('Sử dụng đề tài này'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
