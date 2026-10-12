import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/topic_model.dart';
import '../../../services/topic_service.dart';

class EditTopicScreen extends StatefulWidget {
  final TopicModel topic;
  const EditTopicScreen({super.key, required this.topic});

  @override
  State<EditTopicScreen> createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _targetController;
  late TextEditingController _scopeController;
  late TextEditingController _techController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic.title);
    _descController = TextEditingController(text: widget.topic.description);
    _targetController = TextEditingController(text: widget.topic.objective);
    _scopeController = TextEditingController(text: widget.topic.scope);
    _techController = TextEditingController(text: widget.topic.technology);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _scopeController.dispose();
    _techController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'tenDeTai': _titleController.text.trim(),
        'moTa': _descController.text.trim(),
        'mucTieu': _targetController.text.trim(),
        'phamVi': _scopeController.text.trim(),
        'congNgheDuKien': _techController.text.trim(),
      };

      await TopicService().updateTopic(widget.topic.id, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.text('Đã cập nhật đề tài thành công', en: 'Topic updated successfully')),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Sửa Đề Tài', en: 'Edit Topic')),
        actions: [
          if (_isSubmitting)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator()))
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _submit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Tên đề tài *', en: 'Topic Name *'),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên đề tài' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Mô tả', en: 'Description'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Mục tiêu', en: 'Objectives'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _scopeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Phạm vi', en: 'Scope'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _techController,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Công nghệ dự kiến', en: 'Expected Technologies'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
