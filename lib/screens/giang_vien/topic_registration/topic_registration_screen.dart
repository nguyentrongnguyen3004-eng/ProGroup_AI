import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/topic_service.dart';

class TopicRegistrationScreen extends StatefulWidget {
  const TopicRegistrationScreen({super.key});

  @override
  State<TopicRegistrationScreen> createState() => _TopicRegistrationScreenState();
}

class _TopicRegistrationScreenState extends State<TopicRegistrationScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _registrations = [];
  String _selectedStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _fetchRegistrations();
  }

  Future<void> _fetchRegistrations() async {
    setState(() => _isLoading = true);
    try {
      final data = await TopicService().getTopicRegistrations();
      if (mounted) {
        setState(() {
          _registrations = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleDecision(int id, bool approve) async {
    final noteController = TextEditingController();
    final actionName = approve ? 'Duyệt' : 'Từ chối';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('\ đăng ký đề tài'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn \ đăng ký này không?'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú / Nhận xét',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: approve ? Colors.green : Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(actionName),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TopicService().decideRegistration(
          id,
          approve: approve,
          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        );
        _fetchRegistrations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Đã \ thành công!'),
            backgroundColor: approve ? Colors.green : Colors.orange,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  List<Map<String, dynamic>> get _filteredRegistrations {
    if (_selectedStatus == 'Tất cả') return _registrations;
    return _registrations.where((r) => r['trangThai'] == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = _filteredRegistrations;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Duyệt Đăng Ký Đề Tài', en: 'Topic Registrations')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRegistrations,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(colors),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.text('Chưa có yêu cầu đăng ký nào.', en: 'No registration requests.'),
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final id = item['dangKyDeTaiId'] as int;
                          final status = item['trangThai'] as String? ?? '';
                          final isPending = status == 'Chờ duyệt';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['deTaiTen'] ?? 'Đề tài',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: _getStatusColor(status)),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nhóm: ${item['nhomTen']} (Trưởng nhóm: ${item['truongNhomTen']})',
                                    style: TextStyle(color: colors.onSurfaceVariant),
                                  ),
                                  Text(
                                    'Lớp: ${item['lopHocPhanTen']}',
                                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                                  ),
                                  if (item['ghiChu'] != null && (item['ghiChu'] as String).isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Ghi chú: ${item['ghiChu']}',
                                      style: TextStyle(fontStyle: FontStyle.italic, color: colors.outline),
                                    ),
                                  ],
                                  if (isPending) ...[
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(foregroundColor: colors.error),
                                          onPressed: () => _handleDecision(id, false),
                                          icon: const Icon(Icons.close, size: 18),
                                          label: const Text('Từ chối'),
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton.icon(
                                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                          onPressed: () => _handleDecision(id, true),
                                          icon: const Icon(Icons.check, size: 18),
                                          label: const Text('Duyệt'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Tất cả', 'Chờ duyệt', 'Đã duyệt', 'Đã từ chối'].map((st) {
            final isSelected = _selectedStatus == st;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(st),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedStatus = st);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
        return Colors.green;
      case 'Chờ duyệt':
        return Colors.orange;
      case 'Đã từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
