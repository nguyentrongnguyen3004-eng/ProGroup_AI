import 'package:flutter/material.dart';
<<<<<<< HEAD

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';
import '../../../services/lecturer_api_service.dart';
import 'topic_registration_detail_screen.dart';
=======
import '../../../core/localization/app_localizations.dart';
import '../../../services/topic_service.dart';
>>>>>>> origin/Frontend

class TopicRegistrationScreen extends StatefulWidget {
  const TopicRegistrationScreen({super.key});

  @override
  State<TopicRegistrationScreen> createState() => _TopicRegistrationScreenState();
}

class _TopicRegistrationScreenState extends State<TopicRegistrationScreen> {
<<<<<<< HEAD
  static const _statuses = ['Chờ duyệt', 'Đã duyệt', 'Từ chối'];
  List<TopicRegistrationModel> _registrations = [];
  List<LecturerCourseModel> _courses = [];
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];

  bool _isLoading = true;
  String? _errorMessage;
=======
  bool _isLoading = true;
  List<Map<String, dynamic>> _registrations = [];
>>>>>>> origin/Frontend
  String _selectedStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        LecturerApiService.instance.fetchTopicRegistrations(),
        LecturerApiService.instance.fetchCourses(),
        LecturerApiService.instance.fetchGroups(),
        LecturerApiService.instance.fetchTopics(),
      ]);

      final rawRegs = results[0] as List<Map<String, dynamic>>;
      final courses = results[1] as List<LecturerCourseModel>;
      final groups = results[2] as List<GroupModel>;
      final topics = results[3] as List<TopicModel>;

      final parsed = rawRegs.map((r) => TopicRegistrationModel.fromJson(r)).toList();

      if (mounted) {
        setState(() {
          _registrations = parsed;
          _courses = courses;
          _groups = groups;
          _topics = topics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  GroupModel? _findGroup(int groupId) {
    for (final g in _groups) {
      if (g.id == groupId) return g;
    }
    return null;
  }

  TopicModel? _findTopic(int topicId) {
    for (final t in _topics) {
      if (t.id == topicId) return t;
    }
    return null;
  }

  LecturerCourseModel? _findCourse(int? courseId) {
    if (courseId == null) return null;
    for (final c in _courses) {
      if (c.courseId == courseId) return c;
    }
    return null;
  }

  List<TopicRegistrationModel> get _filtered {
    final query = _query.trim().toLowerCase();
    return _registrations.where((registration) {
      if (_selectedStatus != 'Tất cả' &&
          registration.status.trim() != _selectedStatus) {
        return false;
      }
      if (query.isEmpty) return true;
      final group = _findGroup(registration.groupId);
      final topic = _findTopic(registration.topicId);
      final course = _findCourse(group?.courseId ?? topic?.courseId);

      final searchable = [
        group?.name ?? '',
        group?.leader ?? '',
        topic?.title ?? '',
        course?.name ?? '',
        course?.code ?? '',
        course?.classCode ?? '',
        course?.semester ?? '',
      ];
      return searchable.any((value) => value.toLowerCase().contains(query));
    }).toList();
=======
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
>>>>>>> origin/Frontend
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
<<<<<<< HEAD
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text(
            'Quản lý đăng ký đề tài',
            en: 'Manage Topic Registrations',
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: AppLocalizations.text(
                    'Tìm nhóm, đề tài hoặc lớp học phần',
                    en: 'Search group, topic, or course class',
                  ),
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: AppLocalizations.text(
                            'Xóa tìm kiếm',
                            en: 'Clear search',
                          ),
                          onPressed: () => setState(() => _query = ''),
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('Tất cả'),
                  for (final status in _statuses) _filterChip(status),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.text(
                        'Danh sách đăng ký đề tài',
                        en: 'Topic registration list',
                      ),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${items.length} ${AppLocalizations.text('kết quả', en: 'results')}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(colors, items),
            ),
          ],
        ),
=======
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
>>>>>>> origin/Frontend
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildBody(ColorScheme colors, List<TopicRegistrationModel> items) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.text('Thử lại', en: 'Retry')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: _emptyState(context),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _registrationCard(context, items[index]),
      ),
    );
  }

  Widget _filterChip(String status) {
    final label = status == 'Tất cả'
        ? AppLocalizations.text('Tất cả', en: 'All')
        : AppLocalizations.status(status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: _selectedStatus == status,
        showCheckmark: false,
        label: Text('$label (${_countFor(status)})'),
        onSelected: (_) => setState(() => _selectedStatus = status),
      ),
    );
  }

  Widget _registrationCard(
    BuildContext context,
    TopicRegistrationModel registration,
  ) {
    final colors = Theme.of(context).colorScheme;
    final group = _findGroup(registration.groupId);
    final topic = _findTopic(registration.topicId);
    final course = _findCourse(group?.courseId ?? topic?.courseId);

    final isApproved = registration.status == 'Đã duyệt';
    final isPending = registration.status == 'Chờ duyệt';
    final statusColor = isApproved
        ? AppTheme.successColor
        : isPending
        ? AppTheme.warningColor
        : AppTheme.dangerColor;

    final groupName = group?.name ?? 'Nhóm #${registration.groupId}';
    final topicTitle = topic?.title ?? 'Đề tài #${registration.topicId}';

    return Container(
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
      child: InkWell(
        onTap: () => _openDetails(context, registration),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Color(0xFF2563EB),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.groupName(groupName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (course != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${course.code} • ${course.classCode}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      AppLocalizations.status(registration.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.topicText(topicTitle),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  if (group != null && group.leader.isNotEmpty)
                    _Metadata(icon: Icons.person_outline, label: group.leader),
                  if (group != null)
                    _Metadata(
                      icon: Icons.people_outline,
                      label: '${group.memberCount} thành viên',
                    ),
                  _Metadata(
                    icon: Icons.schedule_outlined,
                    label: _formatDate(registration.registeredAt),
                  ),
                ],
              ),
            ],
          ),
=======
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
>>>>>>> origin/Frontend
        ),
      ),
    );
  }

<<<<<<< HEAD
  Future<void> _openDetails(
    BuildContext context,
    TopicRegistrationModel registration,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            TopicRegistrationDetailScreen(registration: registration),
      ),
    );
    if (mounted) _loadData();
  }

  Widget _emptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasFilter = _selectedStatus != 'Tất cả' || _query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter ? Icons.search_off_outlined : Icons.assignment_outlined,
              size: 48,
              color: colors.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilter
                  ? AppLocalizations.text(
                      'Không có đăng ký phù hợp với bộ lọc.',
                      en: 'No registrations match the filter.',
                    )
                  : AppLocalizations.text(
                      'Chưa có đăng ký đề tài nào.',
                      en: 'No topic registrations yet.',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Metadata({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
=======
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
>>>>>>> origin/Frontend
