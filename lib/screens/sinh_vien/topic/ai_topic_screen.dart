import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/data/mock/mock_topics.dart';
import 'package:progroup_ai_frontend/models/ai_chat_message_model.dart';
import 'package:progroup_ai_frontend/models/ai_feedback_model.dart';
import 'package:progroup_ai_frontend/models/ai_topic_recommendation_model.dart';
import 'package:progroup_ai_frontend/models/ai_topic_request_model.dart';
import 'package:progroup_ai_frontend/services/ai_feedback_service.dart';
import 'package:progroup_ai_frontend/services/ai_topic_recommendation_service.dart';

class AiTopicScreen extends StatefulWidget {
  const AiTopicScreen({
    super.key,
    this.recommendationService = const AiTopicRecommendationService(),
    this.feedbackService,
  });

  final AiTopicRecommendationService recommendationService;
  final AiFeedbackService? feedbackService;

  @override
  State<AiTopicScreen> createState() => _AiTopicScreenState();
}

class _AiTopicScreenState extends State<AiTopicScreen> {
  final _messageController = TextEditingController();
  final _technologyController = TextEditingController();
  final _scrollController = ScrollController();
  late final AiFeedbackService _feedbackService;

  final List<AiChatMessageModel> _messages = [
    const AiChatMessageModel(
      id: 0,
      text:
          'Xin chào! Mình có thể giúp bạn tìm đề tài phù hợp với môn học, lĩnh vực và định hướng của bạn. Hãy chọn tiêu chí hoặc gửi yêu cầu bằng tin nhắn.',
      isUser: false,
    ),
  ];

  final Map<String, List<String>> _learningModules = {
    'Công nghệ thông tin': [
      'Lập trình Web',
      'Lập trình Mobile',
      'Trí tuệ nhân tạo',
      'Machine Learning',
      'Cơ sở dữ liệu',
      'Phân tích thiết kế hệ thống',
      'Công nghệ phần mềm',
      'IoT',
      'Big Data',
    ],
    'Kinh tế - Kinh doanh': [
      'Quản trị kinh doanh',
      'Marketing',
      'Tài chính - Ngân hàng',
      'Kế toán',
      'Thương mại điện tử',
      'Kinh doanh quốc tế',
    ],
    'Kỹ thuật': [
      'Cơ khí',
      'Cơ điện tử',
      'Điện - Điện tử',
      'Tự động hóa',
      'Công nghệ ô tô',
      'Robot',
    ],
    'Công nghệ thực phẩm': [
      'An toàn thực phẩm',
      'Chế biến thực phẩm',
      'Kiểm nghiệm thực phẩm',
    ],
  };

  final List<String> _applicationFields = [
    'Công nghệ thông tin',
    'Kinh doanh',
    'Marketing',
    'Tài chính - Ngân hàng',
    'Thực phẩm',
    'Cơ khí',
    'Cơ điện tử',
    'Điện - Điện tử',
    'Tự động hóa',
    'Ô tô',
    'Logistics',
    'Nông nghiệp',
    'Y tế',
    'Giáo dục',
    'Du lịch',
    'Môi trường',
    'Sản xuất',
    'Thương mại điện tử',
    'An toàn thông tin',
    'Trí tuệ nhân tạo',
  ];

  final List<String> _priorities = [
    'Dễ triển khai',
    'Tính thực tế',
    'Tính sáng tạo',
    'Có AI',
    'Phù hợp thời gian',
    'Phù hợp kỹ năng',
    'Khả năng mở rộng',
    'Phù hợp đồ án tốt nghiệp',
    'Có thể phát triển thành sản phẩm',
  ];

  final List<String> _levels = ['Cơ bản', 'Trung bình', 'Nâng cao'];
  final List<String> _platforms = ['Web', 'Mobile', 'Web + Mobile'];
  final Set<String> _selectedModules = {};
  final Set<String> _selectedFields = {};
  final Set<String> _selectedPriorities = {};

  String _selectedLevel = 'Trung bình';
  String _selectedPlatform = 'Web';
  String _conversationId = DateTime.now().microsecondsSinceEpoch.toString();
  int _nextMessageId = 1;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _feedbackService = widget.feedbackService ?? AiFeedbackService();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _technologyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
    if (!mounted) return;

    final recommendations = widget.recommendationService.recommend(
      request: request,
      topics: MockTopics.topics,
      limit: 3,
    );
    final response = recommendations.isEmpty
        ? 'Hiện chưa có đề tài trong danh mục để đối chiếu. Bạn hãy thử điều chỉnh tiêu chí.'
        : 'Mình đã xếp hạng ${recommendations.length} đề tài theo tiêu chí bạn chọn. Điểm tổng hợp kết hợp 60% điểm tiêu chí và 40% độ tương đồng văn bản.';

    setState(() {
      _isTyping = false;
      _messages.add(
        AiChatMessageModel(
          id: _nextMessageId++,
          text: response,
          isUser: false,
          recommendations: recommendations,
          request: request,
        ),
      );
    });
    _scrollToBottom();
  }

  Future<void> _showMultiSelectDialog({
    required String title,
    required List<String> options,
    required Set<String> selected,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.72,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: options.map((option) {
                          return CheckboxListTile(
                            value: selected.contains(option),
                            title: Text(option),
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selected.add(option);
                                } else {
                                  selected.remove(option);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showModuleSelector() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.75,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Module học tập',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: _learningModules.entries.map((entry) {
                          return ExpansionTile(
                            title: Text(entry.key),
                            children: entry.value.map((module) {
                              return CheckboxListTile(
                                value: _selectedModules.contains(module),
                                title: Text(module),
                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      _selectedModules.add(module);
                                    } else {
                                      _selectedModules.remove(module);
                                    }
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAdvancedOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.viewInsetsOf(context).bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tùy chỉnh đề xuất',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    const Text('Cấp độ kỹ thuật'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _levels.map((level) {
                        return ChoiceChip(
                          label: Text(level),
                          selected: _selectedLevel == level,
                          onSelected: (_) {
                            setModalState(() => _selectedLevel = level);
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Nền tảng'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _platforms.map((platform) {
                        return ChoiceChip(
                          label: Text(platform),
                          selected: _selectedPlatform == platform,
                          onSelected: (_) {
                            setModalState(() => _selectedPlatform = platform);
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _technologyController,
                      decoration: const InputDecoration(
                        labelText: 'Công nghệ mong muốn',
                        hintText: 'Flutter, ASP.NET Core, Python...',
                        prefixIcon: Icon(Icons.code),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Lưu tùy chỉnh'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showFeedbackDialog(AiChatMessageModel message) async {
    const reasons = [
      'Không đúng lĩnh vực',
      'Không đúng mức độ',
      'Không đúng nền tảng',
      'Thiếu thông tin',
      'Đề tài không thực tế',
      'Khác',
    ];
    String? selectedReason;
    final commentController = TextEditingController();
    final result = await showDialog<(String, String?)>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Điều gì chưa phù hợp?'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...reasons.map((reason) {
                      return RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) =>
                            setDialogState(() => selectedReason = value),
                      );
                    }),
                    if (selectedReason == 'Khác')
                      TextField(
                        controller: commentController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả thêm',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: selectedReason == null
                      ? null
                      : () => Navigator.pop(
                            dialogContext,
                            (selectedReason!, commentController.text.trim()),
                          ),
                  child: const Text('Gửi nhận xét'),
                ),
              ],
            );
          },
        );
      },
    );
    commentController.dispose();
    if (result == null || !mounted) return;
    await _saveFeedback(
      message,
      helpful: false,
      reason: result.$1,
      comment: result.$2,
    );
  }

  Future<void> _saveFeedback(
    AiChatMessageModel message, {
    required bool helpful,
    String? reason,
    String? comment,
  }) async {
    if (message.request == null) return;
    final index = _messages.indexWhere((item) => item.id == message.id);
    if (index < 0 || _messages[index].helpful != null) return;

    setState(() {
      _messages[index] = _messages[index].copyWith(
        helpful: helpful,
        feedbackReason: reason,
      );
    });
    await _feedbackService.submit(
      AiFeedbackModel(
        conversationId: _conversationId,
        messageId: message.id,
        userMessage: message.request!.message,
        aiResponse: message.text,
        request: message.request!,
        helpful: helpful,
        feedbackReason: reason,
        comment: comment?.isEmpty == true ? null : comment,
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cảm ơn bạn đã gửi phản hồi.')),
      );
    }
  }

  void _useSuggestion(AiTopicRecommendationModel recommendation) {
    final topic = recommendation.topic;
    Navigator.pop(context, {
      'title': topic.title,
      'description': topic.description,
      'objective': topic.objective,
      'scope': topic.scope,
      'technology': topic.technology,
      'source': 'AI đề xuất',
      'status': 'Chưa đăng ký',
    });
  }

  void _showTopicDetail(AiTopicRecommendationModel recommendation) {
    final topic = recommendation.topic;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _detailSection('Mô tả', topic.description),
                _detailSection('Mục tiêu', topic.objective),
                _detailSection('Phạm vi', topic.scope),
                _detailSection('Công nghệ', topic.technology),
                Text(
                  'Điểm phù hợp: ${(recommendation.finalScore * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _useSuggestion(recommendation);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Dùng đề tài này'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  String _selectionSummary(Set<String> values, String empty) {
    if (values.isEmpty) return empty;
    if (values.length <= 2) return values.join(', ');
    return '${values.take(2).join(', ')} +${values.length - 2}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _resetConversation() async {
    setState(() {
      _messages
        ..clear()
        ..add(
          const AiChatMessageModel(
            id: 0,
            text:
                'Xin chào! Mình có thể giúp bạn tìm đề tài phù hợp. Hãy chọn tiêu chí hoặc gửi yêu cầu bằng tin nhắn.',
            isUser: false,
          ),
        );
      _nextMessageId = 1;
      _conversationId = DateTime.now().microsecondsSinceEpoch.toString();
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('ProGroup AI', en: 'ProGroup AI')),
        actions: [
          IconButton(
            onPressed: _resetConversation,
            tooltip: 'Cuộc trò chuyện mới',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Trợ lý tìm và phát triển đề tài',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _showAdvancedOptions,
                  tooltip: 'Cấp độ, nền tảng và công nghệ',
                  color: Colors.white,
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          _buildSelectors(),
          _buildQuickActions(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Đang xếp hạng đề tài...'),
                ],
              ),
            ),
          _buildInput(theme),
        ],
      ),
    );
  }

  Widget _buildSelectors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _selectorButton(
                  icon: Icons.school_outlined,
                  title: 'Module học tập',
                  value: _selectionSummary(
                    _selectedModules,
                    'Chọn module',
                  ),
                  onTap: _showModuleSelector,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _selectorButton(
                  icon: Icons.category_outlined,
                  title: 'Lĩnh vực',
                  value: _selectionSummary(_selectedFields, 'Chọn lĩnh vực'),
                  onTap: () => _showMultiSelectDialog(
                    title: 'Lĩnh vực ứng dụng',
                    options: _applicationFields,
                    selected: _selectedFields,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _selectorButton(
            icon: Icons.flag_outlined,
            title: 'Ưu tiên',
            value: _selectionSummary(
              _selectedPriorities,
              'Chọn định hướng ưu tiên',
            ),
            onTap: () => _showMultiSelectDialog(
              title: 'Định hướng ưu tiên',
              options: _priorities,
              selected: _selectedPriorities,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectorButton({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: [
          ActionChip(
            avatar: const Icon(Icons.lightbulb_outline, size: 18),
            label: const Text('Gợi ý đề tài'),
            onPressed: () => _sendMessage(
              'Hãy đề xuất 3 đề tài phù hợp với thông tin tôi đã chọn.',
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.analytics_outlined, size: 18),
            label: const Text('Phân tích đề tài'),
            onPressed: () => _sendMessage(
              'Hãy phân tích hướng đề tài phù hợp với tôi.',
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.account_tree_outlined, size: 18),
            label: const Text('Chức năng'),
            onPressed: () => _sendMessage(
              'Hãy gợi ý chức năng chính cho đề tài phù hợp.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhập yêu cầu cho AI...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isTyping ? null : () => _sendMessage(),
              tooltip: 'Gửi',
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(AiChatMessageModel message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        width: isUser ? null : double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? theme.colorScheme.onPrimary : null,
                height: 1.4,
              ),
            ),
            if (message.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (var index = 0;
                  index < message.recommendations.length;
                  index++)
                _buildRecommendationCard(
                  message.recommendations[index],
                  index + 1,
                ),
            ],
            if (!isUser && message.request != null) ...[
              const Divider(height: 20),
              _buildFeedback(message),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    AiTopicRecommendationModel recommendation,
    int rank,
  ) {
    final topic = recommendation.topic;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 13,
                child: Text('$rank', style: theme.textTheme.labelSmall),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  topic.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text('${(recommendation.finalScore * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 8),
          Text(topic.description),
          const SizedBox(height: 6),
          Text(
            'Công nghệ: ${topic.technology}',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Điểm tiêu chí ${(recommendation.weightedScore * 100).round()}% '
            '• Văn bản ${(recommendation.cosineSimilarity * 100).round()}%',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => _showTopicDetail(recommendation),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Chi tiết'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _useSuggestion(recommendation),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Dùng đề tài'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(AiChatMessageModel message) {
    if (message.helpful != null) {
      return Row(
        children: [
          Icon(
            message.helpful! ? Icons.thumb_up_alt : Icons.thumb_down_alt,
            size: 17,
            color: message.helpful! ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message.helpful!
                  ? 'Cảm ơn bạn, phản hồi đã được ghi nhận.'
                  : 'Đã ghi nhận: ${message.feedbackReason}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            'Câu trả lời này có hữu ích không?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          onPressed: () => _saveFeedback(message, helpful: true),
          tooltip: 'Hữu ích',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.thumb_up_alt_outlined, size: 19),
        ),
        IconButton(
          onPressed: () => _showFeedbackDialog(message),
          tooltip: 'Chưa phù hợp',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.thumb_down_alt_outlined, size: 19),
        ),
      ],
    );
  }
}