import 'package:flutter/material.dart';

import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../models/lecturer_topic_suggestion_model.dart';
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

  int? _courseId = MockLecturerCourses.courses.isEmpty
      ? null
      : MockLecturerCourses.courses.first.courseId;
  List<LecturerTopicSuggestionModel> _suggestions = const [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

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
          lecturerCourseId: _courseId,
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
    final courses = MockLecturerCourses.courses;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gợi ý đề tài mock')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: colors.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Đây là gợi ý mô phỏng chạy trên dữ liệu nhập. '
                'Ứng dụng chưa gọi dịch vụ AI hoặc API bên ngoài.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _courseId,
            decoration: const InputDecoration(
              labelText: 'Lớp học phần',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: courses
                .map(
                  (course) => DropdownMenuItem(
                    value: course.courseId,
                    child: Text(
                      course.name + ' • ' + course.classCode,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: courses.isEmpty
                ? null
                : (value) => setState(() => _courseId = value),
          ),
          const SizedBox(height: 12),
          _Input(
            controller: _fieldController,
            label: 'Lĩnh vực',
            icon: Icons.category_outlined,
          ),
          _Input(
            controller: _technologyController,
            label: 'Công nghệ dự kiến',
            icon: Icons.code_outlined,
          ),
          _Input(
            controller: _keywordsController,
            label: 'Từ khóa',
            icon: Icons.tag_outlined,
          ),
          _Input(
            controller: _descriptionController,
            label: 'Mô tả nhu cầu',
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: _loading || courses.isEmpty ? null : _generate,
            icon: _loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_outlined),
            label: Text(_loading ? 'Đang tạo gợi ý...' : 'Tạo gợi ý'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _MessageCard(message: _error!, isError: true),
          ],
          if (_searched && !_loading && _error == null && _suggestions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: _MessageCard(
                message: 'Nhập lĩnh vực, từ khóa hoặc mô tả để nhận gợi ý.',
              ),
            ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Gợi ý tham khảo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            for (final suggestion in _suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SuggestionCard(
                  suggestion: suggestion,
                  onUse: () => _useSuggestion(suggestion),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  const _Input({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final LecturerTopicSuggestionModel suggestion;
  final VoidCallback onUse;

  const _SuggestionCard({required this.suggestion, required this.onUse});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(suggestion.description),
            const SizedBox(height: 8),
            Text(
              'Mục tiêu: ' + suggestion.objective,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Công nghệ: ' + suggestion.technology,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onUse,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Dùng cho đề tài mới'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageCard({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError ? colors.error : colors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
