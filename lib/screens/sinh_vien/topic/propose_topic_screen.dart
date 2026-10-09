import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

class ProposeTopicScreen extends StatefulWidget {
  const ProposeTopicScreen({super.key});

  @override
  State<ProposeTopicScreen> createState() => _ProposeTopicScreenState();
}

class _ProposeTopicScreenState extends State<ProposeTopicScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final objectiveController = TextEditingController();
  final scopeController = TextEditingController();
  final technologyController = TextEditingController();

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

    // ==========================================================
    // MOCK ACTION
    //
    // Sau này:
    // POST /api/topics/proposals
    //
    // Body:
    // {
    //   "title": "...",
    //   "description": "...",
    //   "objective": "...",
    //   "scope": "...",
    //   "technology": "..."
    // }
    // ==========================================================

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(
    String vi,
    String en,
    IconData icon, {
    String? hintVi,
    String? hintEn,
  }) {
    return InputDecoration(
      labelText: AppLocalizations.text(vi, en: en),
      hintText: hintVi == null
          ? null
          : AppLocalizations.text(hintVi, en: hintEn ?? hintVi),
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Đề xuất đề tài', en: 'Propose Topic'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.lightbulb_outline, size: 60),

          const SizedBox(height: 20),

          Text(
            AppLocalizations.text('Thông tin đề tài', en: 'Topic Information'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // TÊN ĐỀ TÀI
          // =====================================================
          TextField(
            controller: titleController,
            decoration: _inputDecoration(
              'Tên đề tài',
              'Topic Title',
              Icons.title,
              hintVi: 'Nhập tên đề tài',
              hintEn: 'Enter topic title',
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // MÔ TẢ
          // =====================================================
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: _inputDecoration(
              'Mô tả',
              'Description',
              Icons.description_outlined,
              hintVi: 'Nhập mô tả đề tài',
              hintEn: 'Enter topic description',
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // MỤC TIÊU
          // =====================================================
          TextField(
            controller: objectiveController,
            maxLines: 3,
            decoration: _inputDecoration(
              'Mục tiêu',
              'Objective',
              Icons.flag_outlined,
              hintVi: 'Nhập mục tiêu của đề tài',
              hintEn: 'Enter the topic objective',
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // PHẠM VI
          // =====================================================
          TextField(
            controller: scopeController,
            maxLines: 3,
            decoration: _inputDecoration(
              'Phạm vi',
              'Scope',
              Icons.workspaces_outlined,
              hintVi: 'Nhập phạm vi thực hiện',
              hintEn: 'Enter the implementation scope',
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // CÔNG NGHỆ
          // =====================================================
          TextField(
            controller: technologyController,
            decoration: _inputDecoration(
              'Công nghệ sử dụng',
              'Technology',
              Icons.code,
              hintVi: 'Flutter, ASP.NET Core, SQL Server',
              hintEn: 'Flutter, ASP.NET Core, SQL Server',
            ),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // THÔNG TIN
          // =====================================================
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.text(
                      'Đề tài sẽ được gửi đến giảng viên để xét duyệt.',
                      en: 'The topic will be sent to the lecturer for approval.',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // BUTTON GỬI ĐỀ XUẤT
          // =====================================================
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _submitProposal,
              icon: const Icon(Icons.send),
              label: Text(
                AppLocalizations.text('GỬI ĐỀ XUẤT', en: 'SUBMIT PROPOSAL'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
