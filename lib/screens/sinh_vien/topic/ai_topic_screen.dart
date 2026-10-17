import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

<<<<<<< HEAD
import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_topic_suggestion_model.dart';
import '../../../services/gemini_service.dart';
import '../../../services/student_api_service.dart';
import 'propose_topic_screen.dart';
=======
import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/topic_model.dart';
import 'package:progroup_ai_frontend/services/topic_service.dart';
import 'package:progroup_ai_frontend/models/ai_chat_message_model.dart';
import 'package:progroup_ai_frontend/models/ai_feedback_model.dart';
import 'package:progroup_ai_frontend/models/ai_topic_recommendation_model.dart';
import 'package:progroup_ai_frontend/models/ai_topic_request_model.dart';
import 'package:progroup_ai_frontend/services/ai_feedback_service.dart';
import 'package:progroup_ai_frontend/services/ai_topic_recommendation_service.dart';
>>>>>>> origin/Frontend

class AiTopicScreen extends StatefulWidget {
  final dynamic recommendationService;
  final dynamic feedbackService;

  const AiTopicScreen({
    super.key,
    this.recommendationService,
    this.feedbackService,
  });

  @override
  State<AiTopicScreen> createState() => _AiTopicScreenState();
}

class _AiTopicScreenState extends State<AiTopicScreen> {
  final _fieldController = TextEditingController();
  final _technologyController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _geminiService = const GeminiService();

  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  List<LecturerTopicSuggestionModel> _suggestions = const [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  int _topicCount = 3;

  final List<String> _quickFields = [
    'Phần mềm Web',
    'Ứng dụng Mobile',
    'Trí tuệ nhân tạo (AI)',
    'IoT & Thiết bị thông minh',
    'Thương mại điện tử',
    'Quản lý giáo dục / Y tế',
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await StudentApiService.instance.fetchMyCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        if (courses.isNotEmpty) {
          _selectedCourse = courses.first;
        }
      });
    } catch (_) {
      // Fallback
    }
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _technologyController.dispose();
    _keywordsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _generate() async {
    final courseName = _selectedCourse?.name ?? 'Đồ án Chuyên ngành';
    final classCode = _selectedCourse?.classCode ?? 'N01';
=======
  AiTopicRequestModel _currentRequest(String message) {
    return AiTopicRequestModel(
      message: message,
      learningModules: Set.unmodifiable(_selectedModules),
      applicationFields: Set.unmodifiable(_selectedFields),
      level: _selectedLevel,
      platform: _selectedPlatform,
      technology: _technologyController.text.trim(),
      priorities: Set.unmodifiable(_selectedPriorities),
    );
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _messageController.text).trim();
    if (text.isEmpty || _isTyping) return;

    final request = _currentRequest(text);
    setState(() {
      _messages.add(
        AiChatMessageModel(id: _nextMessageId++, text: text, isUser: true),
      );
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 350));
    List<TopicModel> topics = [];
    try {
      topics = await TopicService().getLecturerTopics();
    } catch (_) {}

    final recommendations = widget.recommendationService.recommend(
      request: request,
      topics: topics,
      limit: 3,
    );
    final response = recommendations.isEmpty
        ? 'Hiện chưa có đề tài trong danh mục để đối chiếu. Bạn hãy thử điều chỉnh tiêu chí.'
        : 'Mình đã xếp hạng ${recommendations.length} đề tài theo tiêu chí bạn chọn. Điểm tổng hợp kết hợp 60% điểm tiêu chí và 40% độ tương đồng văn bản.';
>>>>>>> origin/Frontend

    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
      _suggestions = const [];
    });

    try {
      final suggestions = await _geminiService.generateTopicSuggestions(
        courseName: courseName,
        classCode: classCode,
        field: _fieldController.text.trim(),
        technology: _technologyController.text.trim(),
        keywords: _keywordsController.text.trim(),
        description: _descriptionController.text.trim(),
        topicCount: _topicCount,
      );

      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _useSuggestionForProposal(LecturerTopicSuggestionModel suggestion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProposeTopicScreen(
          initialValues: {
            'title': suggestion.title,
            'description': suggestion.description,
            'objective': suggestion.objective,
            'scope': suggestion.scope,
            'technology': suggestion.technology,
          },
        ),
      ),
    );
  }

  void _copyToClipboard(LecturerTopicSuggestionModel suggestion) {
    final text = '''
Tên đề tài: ${suggestion.title}
Mục tiêu: ${suggestion.objective}
Phạm vi: ${suggestion.scope}
Công nghệ: ${suggestion.technology}
Mô tả: ${suggestion.description}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép thông tin đề tài vào bộ nhớ tạm.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('AI Gợi ý đề tài', en: 'AI Topic Generator'),
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
            // 1. AI Feature Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4F46E5), // Indigo
                    Color(0xFF7C3AED), // Violet
                    Color(0xFF9333EA), // Purple
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
              child: Row(
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
                        const Text(
                          'Cố vấn Đề tài AI Sinh viên',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Nhập định hướng mong muốn, AI sẽ tạo danh sách đề tài chi tiết cho bạn.',
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
            ),

            const SizedBox(height: 16),

            // 2. Input Form Card
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
                  // Lớp học phần
                  if (_courses.isNotEmpty) ...[
                    DropdownButtonFormField<CourseModel>(
                      initialValue: _selectedCourse,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.text('Lớp học phần đang học', en: 'Enrolled Course Class'),
                        prefixIcon: const Icon(Icons.school_rounded, color: Color(0xFF6366F1)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _courses.map((course) {
                        return DropdownMenuItem<CourseModel>(
                          value: course,
                          child: Text(
                            '${course.name} • ${course.classCode}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCourse = val),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Lĩnh vực
                  _buildInput(
                    controller: _fieldController,
                    label: 'Lĩnh vực nghiên cứu / bài toán thực tế',
                    hintText: 'Ví dụ: Y tế, Giáo dục, Thương mại điện tử, Quản lý kho...',
                    icon: Icons.category_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                  ),

                  // Chip gợi ý nhanh lĩnh vực
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _quickFields.map((f) {
                      final isSelected = _fieldController.text == f;
                      return ActionChip(
                        label: Text(f, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : null)),
                        backgroundColor: isSelected ? const Color(0xFF8B5CF6) : null,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () {
                          setState(() {
                            _fieldController.text = f;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Công nghệ
                  _buildInput(
                    controller: _technologyController,
                    label: 'Công nghệ dự kiến (Framework, Ngôn ngữ, Cloud)',
                    hintText: 'Ví dụ: Flutter, React Native, Node.js, Spring Boot, AI, IoT...',
                    icon: Icons.code_rounded,
                    iconColor: const Color(0xFFF59E0B),
                  ),

                  // Từ khóa
                  _buildInput(
                    controller: _keywordsController,
                    label: 'Từ khóa chính',
                    hintText: 'Ví dụ: Tối ưu lộ trình, Nhận diện khuôn mặt, Đặt lịch hẹn...',
                    icon: Icons.tag_rounded,
                    iconColor: const Color(0xFF0284C7),
                  ),

                  // Mô tả nhu cầu
                  _buildInput(
                    controller: _descriptionController,
                    label: 'Mô tả nhu cầu hoặc yêu cầu riêng của nhóm (tùy chọn)',
                    hintText: 'Ví dụ: Muốn làm ứng dụng có tính năng thanh toán, đồ án 3 thành viên...',
                    icon: Icons.notes_rounded,
                    iconColor: const Color(0xFF10B981),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 10),

                  // Số lượng đề tài muốn gợi ý
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.format_list_numbered_rounded, size: 20, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.text('Số lượng đề tài cần gợi ý:', en: 'Number of topics to suggest:'),
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [3, 5, 10].map((count) {
                          final isSelected = _topicCount == count;
                          return ChoiceChip(
                            label: Text(
                              '$count ${AppLocalizations.text('đề tài', en: 'topics')}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF4F46E5) : null,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.18),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _topicCount = count);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Nút tạo gợi ý
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _generate,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: _loading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        _loading ? 'Gemini AI đang sinh $_topicCount đề tài...' : 'Tạo $_topicCount gợi ý đề tài với AI',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 3. Danh sách kết quả gợi ý
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
                      'Danh sách đề tài AI gợi ý (${_suggestions.length})',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
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
                          'Google Gemini',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._suggestions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final s = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#$index',
                                style: const TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.title,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Technology chip
                        if (s.technology.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.code_rounded, size: 14, color: Color(0xFFD97706)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    s.technology,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFFD97706),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Objective & Scope
                        if (s.objective.isNotEmpty)
                          _buildDetailRow(Icons.flag_rounded, 'Mục tiêu:', s.objective, colors),
                        if (s.scope.isNotEmpty)
                          _buildDetailRow(Icons.crop_free_rounded, 'Phạm vi:', s.scope, colors),
                        if (s.description.isNotEmpty)
                          _buildDetailRow(Icons.description_outlined, 'Mô tả:', s.description, colors),

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // Actions
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _copyToClipboard(s),
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: Text(
                                AppLocalizations.text('Sao chép', en: 'Copy'),
                                style: const TextStyle(fontSize: 12.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () => _useSuggestionForProposal(s),
                              icon: const Icon(Icons.send_rounded, size: 16),
                              label: Text(
                                AppLocalizations.text('Đề xuất đề tài này', en: 'Propose Topic'),
                                style: const TextStyle(fontSize: 12.5),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ] else if (_searched && !_loading && _error == null) ...[
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Không có đề tài nào được tạo. Hãy thử thay đổi từ khóa hoặc công nghệ.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.5, color: colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: iconColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}