import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../../../core/localization/app_localizations.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/lecturer_topic_suggestion_model.dart';
import '../../../services/gemini_service.dart';
import '../../../services/lecturer_api_service.dart';
=======
import '../../../models/course_model.dart';
import '../../../models/lecturer_topic_suggestion_model.dart';
import '../../../services/course_service.dart';
>>>>>>> origin/Frontend
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
  final _geminiService = const GeminiService();
  late final LecturerTopicSuggestionService _service;

<<<<<<< HEAD
  List<LecturerCourseModel> _courses = [];
=======
  List<CourseModel> _courses = [];
>>>>>>> origin/Frontend
  int? _courseId;
  List<LecturerTopicSuggestionModel> _suggestions = const [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  String? _geminiApiKey;
  bool _isUsingGeminiLive = false;

  @override
  void initState() {
    super.initState();
    _service = LecturerTopicSuggestionService(geminiService: _geminiService);
    _courses = LecturerApiService.instance.cachedCourses;
    if (_courses.isNotEmpty) {
      _courseId = _courses.first.courseId;
    } else {
      LecturerApiService.instance.fetchCourses().then((c) {
        if (mounted) {
          setState(() {
            _courses = c;
            if (_courseId == null && c.isNotEmpty) {
              _courseId = c.first.courseId;
            }
          });
        }
      });
    }
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await _geminiService.getApiKey();
    if (mounted) {
      setState(() => _geminiApiKey = key);
    }
  }

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
      setState(() {
        _suggestions = suggestions;
        _isUsingGeminiLive = _geminiApiKey != null && _geminiApiKey!.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception:', '').trim());
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
            'source': _isUsingGeminiLive ? 'Google Gemini AI' : 'AI đề xuất',
          },
        ),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Đề tài đã được lưu vào lớp học phần.',
              en: 'Topic has been added to the course class.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final courses = _courses;
=======
>>>>>>> origin/Frontend
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('AI Trợ lý đề tài', en: 'AI Topic Assistant'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 5),
                Text(
                  'Gemini AI Live',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          children: [
            // AI Gradient Feature Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4F46E5), // Indigo 600
                    Color(0xFF7C3AED), // Violet 600
                    Color(0xFF9333EA), // Purple 600
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Flexible(
                                  child: Text(
                                    'Khởi tạo đề tài thông minh',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Gemini Live',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Đã tích hợp sẵn Google Gemini AI để sinh đề tài tự động',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Course selection & inputs card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _courseId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.text(
                        'Lớp học phần áp dụng',
                        en: 'Target course class',
                      ),
                      prefixIcon: const Icon(
                        Icons.school_rounded,
                        color: Color(0xFF6366F1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: courses
                        .map(
                          (course) => DropdownMenuItem(
                            value: course.courseId,
                            child: Text(
                              '${course.name} • ${course.classCode}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: courses.isEmpty
                        ? null
                        : (value) => setState(() => _courseId = value),
                  ),
                  const SizedBox(height: 14),
                  _Input(
                    controller: _fieldController,
                    label: AppLocalizations.text(
                      'Lĩnh vực nghiên cứu / ứng dụng',
                      en: 'Research or application field',
                    ),
                    icon: Icons.category_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                  _Input(
                    controller: _technologyController,
                    label: AppLocalizations.text(
                      'Công nghệ dự kiến (Flutter, AI, IoT, Web...)',
                      en: 'Target technologies (Flutter, AI, IoT...)',
                    ),
                    icon: Icons.code_rounded,
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  _Input(
                    controller: _keywordsController,
                    label: AppLocalizations.text(
                      'Từ khóa chính',
                      en: 'Keywords',
                    ),
                    icon: Icons.tag_rounded,
                    iconColor: const Color(0xFF0284C7),
                  ),
                  _Input(
                    controller: _descriptionController,
                    label: AppLocalizations.text(
                      'Mô tả nhu cầu cụ thể (nếu có)',
                      en: 'Specific requirements (optional)',
                    ),
                    icon: Icons.notes_rounded,
                    iconColor: const Color(0xFF10B981),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _loading || courses.isEmpty ? null : _generate,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _loading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        _loading
                            ? AppLocalizations.text(
                                'Gemini AI đang sinh đề tài...',
                                en: 'Gemini AI is generating...',
                              )
                            : AppLocalizations.text(
                                'Tạo gợi ý đề tài với AI',
                                en: 'Generate Topic Suggestions',
                              ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 14),
              _MessageCard(message: _error!, isError: true),
            ],

            if (_searched && !_loading && _error == null && _suggestions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _MessageCard(
                  message: AppLocalizations.text(
                    'Nhập lĩnh vực, từ khóa hoặc mô tả để hệ thống gợi ý đề tài phù hợp.',
                    en: 'Enter field, keywords, or description to receive smart recommendations.',
                  ),
                ),
              ),

            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppLocalizations.text('Đề tài được gợi ý', en: 'Recommended Topics')} (${_suggestions.length})',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isUsingGeminiLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text(
                            'Google Gemini AI',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              for (final suggestion in _suggestions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SuggestionCard(
                    suggestion: suggestion,
                    onUse: () => _useSuggestion(suggestion),
                  ),
                ),
            ],
=======
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
>>>>>>> origin/Frontend
          ],
        ),
      ),
    );
  }
}
<<<<<<< HEAD

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;
  final int maxLines;

  const _Input({
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
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
          prefixIcon: Icon(icon, color: iconColor),
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            suggestion.description,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.85),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          if (suggestion.objective.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.track_changes_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppLocalizations.text('Mục tiêu', en: 'Objective')}: ${suggestion.objective}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (suggestion.technology.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: suggestion.technology
                  .split(RegExp(r'[,;]'))
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .map(
                    (tech) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        tech,
                        style: const TextStyle(
                          color: Color(0xFF0284C7),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: onUse,
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: Text(
                AppLocalizations.text(
                  'Áp dụng vào học phần',
                  en: 'Apply to Course',
                ),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? colors.errorContainer.withValues(alpha: 0.5)
            : colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError
              ? colors.error.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_rounded : Icons.info_rounded,
            color: isError ? colors.error : colors.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? colors.onErrorContainer : colors.onSurface,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
=======
>>>>>>> origin/Frontend
