import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/topic_model.dart';
import 'edit_topic_screen.dart';

class LecturerTopicDetailScreen extends StatefulWidget {
  final TopicModel topic;

  const LecturerTopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  State<LecturerTopicDetailScreen> createState() => _LecturerTopicDetailScreenState();
}

class _LecturerTopicDetailScreenState extends State<LecturerTopicDetailScreen> {
  late TopicModel _topic;

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Chi Tiết Đề Tài', en: 'Topic Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTopicScreen(topic: _topic),
                ),
              );
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colors),
            const SizedBox(height: 24),
            _buildInfoCard(colors),
            const SizedBox(height: 24),
            _buildStatusCard(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _topic.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_topic.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(_topic.status),
                ),
              ),
              child: Text(
                _topic.status,
                style: TextStyle(
                  color: _getStatusColor(_topic.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Mã ĐT: ${_topic.id}',
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ColorScheme colors) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              AppLocalizations.text('Mô tả', en: 'Description'),
              _topic.description,
              Icons.description,
              colors,
            ),
            const Divider(height: 32),
            _buildInfoSection(
              AppLocalizations.text('Mục tiêu', en: 'Objectives'),
              _topic.objective,
              Icons.track_changes,
              colors,
            ),
            const Divider(height: 32),
            _buildInfoSection(
              AppLocalizations.text('Phạm vi', en: 'Scope'),
              _topic.scope,
              Icons.center_focus_strong,
              colors,
            ),
            const Divider(height: 32),
            _buildInfoSection(
              AppLocalizations.text('Công nghệ dự kiến', en: 'Expected Technologies'),
              _topic.technology,
              Icons.computer,
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(ColorScheme colors) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: colors.secondary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.text('Thông tin bổ sung', en: 'Additional Information'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              AppLocalizations.text('Nguồn đề tài', en: 'Source'),
              _topic.source,
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
      case 'Đã đăng ký':
        return Colors.green;
      case 'Chờ duyệt':
        return Colors.orange;
      case 'Chưa sử dụng':
        return Colors.blue;
      case 'Từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
