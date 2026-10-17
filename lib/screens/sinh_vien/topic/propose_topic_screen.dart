import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

class ProposeTopicScreen extends StatefulWidget {
  final Map<String, dynamic>? initialValues;

  const ProposeTopicScreen({super.key, this.initialValues});

  @override
  State<ProposeTopicScreen> createState() => _ProposeTopicScreenState();
}

class _ProposeTopicScreenState extends State<ProposeTopicScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController objectiveController;
  late final TextEditingController scopeController;
  late final TextEditingController technologyController;

  @override
  void initState() {
    super.initState();
    final init = widget.initialValues ?? {};
    titleController = TextEditingController(text: init['title'] as String? ?? '');
    descriptionController = TextEditingController(text: init['description'] as String? ?? '');
    objectiveController = TextEditingController(text: init['objective'] as String? ?? '');
    scopeController = TextEditingController(text: init['scope'] as String? ?? '');
    technologyController = TextEditingController(text: init['technology'] as String? ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    objectiveController.dispose();
    scopeController.dispose();
    technologyController.dispose();
    super.dispose();
  }

  void _submitProposal() {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      _showMessage(
        AppLocalizations.text(
          'Vui lòng nhập tên đề tài.',
          en: 'Please enter the topic title.',
        ),
      );
      return;
    }

    final result = {
      'title': title,
      'description': descriptionController.text.trim(),
      'objective': objectiveController.text.trim(),
      'scope': scopeController.text.trim(),
      'technology': technologyController.text.trim(),
      'source': 'Sinh viên đề xuất',
      'status': 'Chờ duyệt',
    };

    Navigator.pop(context, result);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Đề xuất đề tài', en: 'Propose Topic'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 72),
          children: [
            // ======================================================
            // HERO BANNER
            // ======================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                      Icons.lightbulb_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.text(
                            'Khởi tạo ý tưởng đề tài',
                            en: 'Create Topic Idea',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppLocalizations.text(
                            'Điền thông tin mục tiêu, phạm vi và công nghệ để gửi giảng viên xét duyệt.',
                            en: 'Fill in details, objectives, scope and tech for lecturer review.',
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ======================================================
            // FORM INPUTS CARD
            // ======================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
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
                  // Tên đề tài
                  _FormInput(
                    controller: titleController,
                    label: AppLocalizations.text('Tên đề tài *', en: 'Topic Title *'),
                    hint: 'Nhập tên đề tài nghiên cứu hoặc ứng dụng',
                    icon: Icons.title_rounded,
                    iconColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 16),

                  // Mô tả đề tài
                  _FormInput(
                    controller: descriptionController,
                    label: AppLocalizations.text('Mô tả chi tiết', en: 'Description'),
                    hint: 'Mô tả bài toán cần giải quyết và nội dung chính',
                    icon: Icons.description_rounded,
                    iconColor: const Color(0xFF6366F1),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  // Mục tiêu
                  _FormInput(
                    controller: objectiveController,
                    label: AppLocalizations.text('Mục tiêu đề tài', en: 'Objective'),
                    hint: 'Mục tiêu cần đạt được sau khi hoàn thành',
                    icon: Icons.flag_rounded,
                    iconColor: const Color(0xFF10B981),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Phạm vi
                  _FormInput(
                    controller: scopeController,
                    label: AppLocalizations.text('Phạm vi thực hiện', en: 'Scope'),
                    hint: 'Các chức năng chính hoặc giới hạn phạm vi đề tài',
                    icon: Icons.workspaces_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Công nghệ
                  _FormInput(
                    controller: technologyController,
                    label: AppLocalizations.text('Công nghệ sử dụng', en: 'Technology'),
                    hint: 'Ví dụ: Flutter, ASP.NET Core, SQL Server, AI Gemini',
                    icon: Icons.code_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // NOTICE CARD
            // ======================================================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.text(
                        'Đề xuất sẽ được gửi đến giảng viên phụ trách để xem xét và xét duyệt.',
                        en: 'Your proposal will be sent to the lecturer for review and approval.',
                      ),
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======================================================
            // SUBMIT BUTTON
            // ======================================================
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _submitProposal,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  AppLocalizations.text('GỬI ĐỀ XUẤT ĐỀ TÀI', en: 'SUBMIT PROPOSAL'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final int maxLines;

  const _FormInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 13.5,
            ),
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
