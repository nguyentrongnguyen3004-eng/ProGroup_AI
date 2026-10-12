import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/topic_service.dart';

class AddTopicScreen extends StatefulWidget {
  final int courseId;
  final Map<String, dynamic>? initialValues;
  const AddTopicScreen({super.key, required this.courseId, this.initialValues});

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();
  final _scopeController = TextEditingController();
  final _techController = TextEditingController();

  bool _isSubmitting = false;


  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _titleController.text = widget.initialValues!['title'] ?? '';
      _descController.text = widget.initialValues!['description'] ?? '';
      _targetController.text = widget.initialValues!['objective'] ?? '';
      _scopeController.text = widget.initialValues!['scope'] ?? '';
      _techController.text = widget.initialValues!['technology'] ?? '';
    }
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
      // In a real flow, dotDangKyId should be fetched from the course.
      // Assuming courseId and dotDangKyId are mapped for now, or courseId is passed.
      // Currently our API uses DotDangKyId, so we pass widget.courseId as a placeholder.
      final data = {
        'dotDangKyId': widget.courseId, 
        'tenDeTai': _titleController.text.trim(),
        'moTa': _descController.text.trim(),
        'mucTieu': _targetController.text.trim(),
        'phamVi': _scopeController.text.trim(),
        'congNgheDuKien': _techController.text.trim(),
      };

      await TopicService().createTopic(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.text('Đã thêm đề tài thành công', en: 'Topic added successfully')),
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
        title: Text(AppLocalizations.text('Thêm Đề Tài', en: 'Add Topic')),
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
