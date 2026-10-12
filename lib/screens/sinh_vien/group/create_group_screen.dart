import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  final CourseModel course;

  const CreateGroupScreen({super.key, required this.course});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();

  bool isCreating = false;

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _createGroup() async {
    if (isCreating) return;

    final groupName = groupNameController.text.trim();
    if (groupName.isEmpty) {
      _showError(
        AppLocalizations.text('Vui lòng nhập tên nhóm.', en: 'Please enter a group name.')
      );
      return;
    }

    setState(() => isCreating = true);

    try {
      await GroupService().createGroup(widget.course.id, groupName);
      if (!mounted) return;
      
      _showSuccess(
        AppLocalizations.text('Tạo nhóm "\" thành công.', en: 'Group created successfully.')
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
      setState(() => isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Tạo Nhóm', en: 'Create Group')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Tên nhóm', en: 'Group Name'),
                hintText: AppLocalizations.text('Nhập tên nhóm', en: 'Enter group name'),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _createGroup(),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: isCreating ? null : _createGroup,
              icon: isCreating 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.group_add),
              label: Text(
                AppLocalizations.text('TẠO NHÓM', en: 'CREATE GROUP')
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
