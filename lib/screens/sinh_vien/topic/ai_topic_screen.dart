import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

class AiTopicScreen extends StatefulWidget {
  const AiTopicScreen({super.key});

  @override
  State<AiTopicScreen> createState() => _AiTopicScreenState();
}

class _AiTopicScreenState extends State<AiTopicScreen> {
  final technologyController = TextEditingController();
  final requirementController = TextEditingController();

  String? selectedField;
  String selectedLevel = 'Trung bình';

  final List<String> fields = [
    'Ứng dụng di động',
    'Web',
    'AI',
    'IoT',
    'Big Data',
    'Cơ sở dữ liệu',
  ];

  final List<String> levels = ['Dễ', 'Trung bình', 'Khó'];

  bool isGenerating = false;
  List<_AiTopicSuggestion> suggestions = [];

  @override
  void dispose() {
    technologyController.dispose();
    requirementController.dispose();
    super.dispose();
  }

  String _fieldText(String value) {
    switch (value) {
      case 'Ứng dụng di động':
        return AppLocalizations.text(
          'Ứng dụng di động',
          en: 'Mobile Application',
        );
      case 'Web':
        return 'Web';
      case 'AI':
        return 'AI';
      case 'IoT':
        return 'IoT';
      case 'Big Data':
        return 'Big Data';
      case 'Cơ sở dữ liệu':
        return AppLocalizations.text('Cơ sở dữ liệu', en: 'Database');
      default:
        return value;
    }
  }

  String _levelText(String value) {
    switch (value) {
      case 'Dễ':
        return AppLocalizations.text('Dễ', en: 'Easy');
      case 'Khó':
        return AppLocalizations.text('Khó', en: 'Hard');
      default:
        return AppLocalizations.text('Trung bình', en: 'Medium');
    }
  }

  void _generateSuggestions() {
    if (selectedField == null) {
      _showMessage(
        AppLocalizations.text(
          'Vui lòng chọn lĩnh vực.',
          en: 'Please select a field.',
        ),
      );
      return;
    }

    setState(() {
      isGenerating = true;
      suggestions = [];
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      final field = selectedField!;
      final technology = technologyController.text.trim();

      setState(() {
        isGenerating = false;
        suggestions = _buildMockSuggestions(field, technology);
      });
    });
  }

  List<_AiTopicSuggestion> _buildMockSuggestions(
    String field,
    String technology,
  ) {
    switch (field) {
      case 'Ứng dụng di động':
        return [
          _AiTopicSuggestion(
            title: 'Ứng dụng quản lý đăng ký đồ án môn học',
            description:
                'Ứng dụng hỗ trợ sinh viên đăng ký nhóm, lựa chọn và quản lý đề tài đồ án môn học.',
            objective: 'Hỗ trợ quản lý quá trình đăng ký nhóm và đề tài.',
            technology: technology.isEmpty
                ? 'Flutter, ASP.NET Core, SQL Server'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Ứng dụng quản lý công việc nhóm sinh viên',
            description:
                'Ứng dụng giúp nhóm sinh viên phân công, theo dõi và cập nhật tiến độ công việc.',
            objective: 'Hỗ trợ các thành viên phối hợp và theo dõi tiến độ.',
            technology: technology.isEmpty
                ? 'Flutter, ASP.NET Core, SQL Server'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Ứng dụng hỗ trợ học tập cá nhân hóa',
            description:
                'Ứng dụng hỗ trợ sinh viên lập kế hoạch học tập và theo dõi tiến độ học tập.',
            objective: 'Giúp sinh viên quản lý kế hoạch học tập hiệu quả.',
            technology: technology.isEmpty
                ? 'Flutter, ASP.NET Core, SQL Server'
                : technology,
          ),
        ];

      case 'Web':
        return [
          _AiTopicSuggestion(
            title: 'Hệ thống quản lý đồ án sinh viên',
            description:
                'Hệ thống web hỗ trợ quản lý sinh viên, nhóm, đề tài và tiến độ đồ án.',
            objective: 'Quản lý tập trung quá trình thực hiện đồ án.',
            technology: technology.isEmpty
                ? 'ASP.NET Core, React, SQL Server'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Cổng thông tin quản lý công việc nhóm',
            description:
                'Nền tảng web hỗ trợ nhóm sinh viên phân công và theo dõi công việc.',
            objective: 'Cải thiện việc phối hợp giữa các thành viên.',
            technology: technology.isEmpty
                ? 'ASP.NET Core, React, SQL Server'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Hệ thống quản lý đăng ký học phần',
            description:
                'Hệ thống hỗ trợ sinh viên xem học phần và thực hiện đăng ký trực tuyến.',
            objective: 'Hỗ trợ quản lý quá trình đăng ký học phần.',
            technology: technology.isEmpty
                ? 'ASP.NET Core, React, SQL Server'
                : technology,
          ),
        ];

      case 'AI':
        return [
          _AiTopicSuggestion(
            title: 'Hệ thống gợi ý đề tài bằng AI',
            description:
                'Hệ thống sử dụng AI để phân tích nhu cầu và đề xuất các đề tài phù hợp cho sinh viên.',
            objective: 'Hỗ trợ sinh viên tìm kiếm ý tưởng đề tài.',
            technology: technology.isEmpty
                ? 'Flutter, ASP.NET Core, AI API'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Trợ lý AI hỗ trợ học tập',
            description:
                'Trợ lý AI hỗ trợ sinh viên tìm kiếm thông tin và giải đáp các câu hỏi học tập.',
            objective: 'Hỗ trợ sinh viên trong quá trình tự học.',
            technology: technology.isEmpty
                ? 'ASP.NET Core, AI API, SQL Server'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Hệ thống phân tích và dự đoán kết quả học tập',
            description:
                'Ứng dụng phân tích dữ liệu học tập để hỗ trợ đánh giá kết quả của sinh viên.',
            objective: 'Hỗ trợ theo dõi và phân tích kết quả học tập.',
            technology: technology.isEmpty
                ? 'Python, AI, SQL Server'
                : technology,
          ),
        ];

      case 'IoT':
        return [
          _AiTopicSuggestion(
            title: 'Hệ thống cảnh báo rò rỉ gas và cháy',
            description:
                'Hệ thống sử dụng cảm biến để phát hiện khí gas và nguy cơ cháy.',
            objective: 'Phát hiện sớm các nguy cơ và đưa ra cảnh báo.',
            technology: technology.isEmpty
                ? 'ESP32, Sensors, MQTT'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Hệ thống giám sát phòng học thông minh',
            description:
                'Hệ thống thu thập dữ liệu môi trường và hiển thị trạng thái phòng học.',
            objective: 'Theo dõi điều kiện môi trường trong phòng học.',
            technology: technology.isEmpty
                ? 'ESP32, Sensors, MQTT'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Hệ thống quản lý thiết bị IoT',
            description:
                'Ứng dụng quản lý và theo dõi trạng thái các thiết bị IoT.',
            objective: 'Quản lý tập trung các thiết bị trong hệ thống.',
            technology: technology.isEmpty
                ? 'ESP32, MQTT, ASP.NET Core'
                : technology,
          ),
        ];

      case 'Big Data':
        return [
          _AiTopicSuggestion(
            title: 'Phân tích dữ liệu học tập sinh viên',
            description:
                'Phân tích dữ liệu học tập để tìm ra xu hướng và hỗ trợ quản lý đào tạo.',
            objective: 'Khai thác dữ liệu phục vụ phân tích giáo dục.',
            technology: technology.isEmpty
                ? 'Python, Spark, SQL Server'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Hệ thống phân tích hành vi người dùng',
            description:
                'Phân tích dữ liệu hành vi để tìm ra các xu hướng sử dụng.',
            objective: 'Hỗ trợ đưa ra các thông tin từ dữ liệu lớn.',
            technology: technology.isEmpty
                ? 'Python, Spark, MongoDB'
                : technology,
          ),
          _AiTopicSuggestion(
            title: 'Hệ thống trực quan hóa dữ liệu lớn',
            description:
                'Xây dựng hệ thống hiển thị và phân tích các tập dữ liệu lớn.',
            objective: 'Hỗ trợ người dùng khai thác dữ liệu trực quan.',
            technology: technology.isEmpty
                ? 'Python, Spark, Power BI'
                : technology,
          ),
        ];

      default:
        return [
          _AiTopicSuggestion(
            title: 'Hệ thống quản lý dữ liệu sinh viên',
            description:
                'Hệ thống hỗ trợ quản lý và khai thác dữ liệu sinh viên.',
            objective: 'Quản lý dữ liệu tập trung và hiệu quả.',
            technology: technology.isEmpty
                ? 'ASP.NET Core, SQL Server'
                : technology,
          ),
        ];
    }
  }

  void _useSuggestion(_AiTopicSuggestion suggestion) {
    Navigator.pop(context, {
      'title': suggestion.title,
      'description': suggestion.description,
      'objective': suggestion.objective,
      'scope': AppLocalizations.text(
        'Sinh viên và giảng viên trong phạm vi môn học.',
        en: 'Students and lecturers within the course scope.',
      ),
      'technology': suggestion.technology,
      'source': 'AI đề xuất',
      'status': 'Chưa đăng ký',
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text(
            'AI hỗ trợ đề xuất đề tài',
            en: 'AI Topic Assistant',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // =====================================================
          // HEADER
          // =====================================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.text(
                          'Gợi ý đề tài bằng AI',
                          en: 'AI Topic Suggestions',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.text(
                          'Cung cấp thông tin để AI gợi ý các đề tài phù hợp.',
                          en: 'Provide some information and AI will suggest suitable topics.',
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =====================================================
          // FIELD
          // =====================================================
          Text(
            AppLocalizations.text('Lĩnh vực quan tâm', en: 'Field of interest'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: selectedField,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelText: AppLocalizations.text(
                'Chọn lĩnh vực',
                en: 'Select a field',
              ),
            ),
            items: fields.map((field) {
              return DropdownMenuItem(
                value: field,
                child: Text(_fieldText(field)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedField = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // =====================================================
          // TECHNOLOGY
          // =====================================================
          Text(
            AppLocalizations.text(
              'Công nghệ mong muốn',
              en: 'Preferred technology',
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: technologyController,
            decoration: InputDecoration(
              labelText: AppLocalizations.text('Công nghệ', en: 'Technology'),
              hintText: AppLocalizations.text(
                'Ví dụ: Flutter, ASP.NET Core, Python...',
                en: 'Example: Flutter, ASP.NET Core, Python...',
              ),
              prefixIcon: const Icon(Icons.code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // LEVEL
          // =====================================================
          Text(
            AppLocalizations.text('Mức độ khó', en: 'Difficulty level'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: levels.map((level) {
              final selected = selectedLevel == level;

              return ChoiceChip(
                label: Text(_levelText(level)),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    selectedLevel = level;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // ADDITIONAL REQUIREMENT
          // =====================================================
          Text(
            AppLocalizations.text(
              'Yêu cầu thêm',
              en: 'Additional requirements',
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: requirementController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: AppLocalizations.text(
                'Mô tả mong muốn',
                en: 'Describe your requirements',
              ),
              hintText: AppLocalizations.text(
                'Ví dụ: muốn làm đề tài có AI, có tính thực tế...',
                en: 'Example: a practical topic using AI...',
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 55),
                child: Icon(Icons.edit_note_outlined),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =====================================================
          // GENERATE BUTTON
          // =====================================================
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateSuggestions,
              icon: isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                isGenerating
                    ? AppLocalizations.text(
                        'Đang tạo gợi ý...',
                        en: 'Generating suggestions...',
                      )
                    : AppLocalizations.text(
                        'GỢI Ý ĐỀ TÀI',
                        en: 'GENERATE TOPICS',
                      ),
              ),
            ),
          ),

          // =====================================================
          // RESULTS
          // =====================================================
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 30),

            Row(
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.text(
                      'Đề tài AI gợi ý',
                      en: 'AI Suggested Topics',
                    ),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ...suggestions.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final suggestion = entry.value;

              return _buildSuggestionCard(context, index, suggestion);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    int index,
    _AiTopicSuggestion suggestion,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              suggestion.description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 14),

            _infoRow(
              Icons.flag_outlined,
              AppLocalizations.text('Mục tiêu', en: 'Objective'),
              suggestion.objective,
            ),

            const SizedBox(height: 10),

            _infoRow(
              Icons.code,
              AppLocalizations.text('Công nghệ', en: 'Technology'),
              suggestion.technology,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSuggestionDetail(suggestion);
                },
                icon: const Icon(Icons.visibility_outlined),
                label: Text(
                  AppLocalizations.text('Xem chi tiết', en: 'View details'),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _useSuggestion(suggestion);
                },
                icon: const Icon(Icons.edit_note),
                label: Text(
                  AppLocalizations.text(
                    'Dùng đề tài này',
                    en: 'Use this topic',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSuggestionDetail(_AiTopicSuggestion suggestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    AppLocalizations.text('Mô tả', en: 'Description'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(suggestion.description),

                  const SizedBox(height: 18),

                  Text(
                    AppLocalizations.text('Mục tiêu', en: 'Objective'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(suggestion.objective),

                  const SizedBox(height: 18),

                  Text(
                    AppLocalizations.text(
                      'Công nghệ đề xuất',
                      en: 'Suggested technology',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(suggestion.technology),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _useSuggestion(suggestion);
                      },
                      icon: const Icon(Icons.check),
                      label: Text(
                        AppLocalizations.text(
                          'Dùng đề tài này',
                          en: 'Use this topic',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AiTopicSuggestion {
  final String title;
  final String description;
  final String objective;
  final String technology;

  const _AiTopicSuggestion({
    required this.title,
    required this.description,
    required this.objective,
    required this.technology,
  });
}
