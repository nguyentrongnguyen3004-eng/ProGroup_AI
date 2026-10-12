import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../models/group_model.dart';
import '../../../services/course_service.dart';
import '../../../services/group_service.dart';
import '../../../widgets/lecturer/lecturer_group_card.dart';
import 'lecturer_group_detail_screen.dart';

class LecturerGroupScreen extends StatefulWidget {
  final dynamic course;

  const LecturerGroupScreen({super.key, this.course});

  @override
  State<LecturerGroupScreen> createState() => _LecturerGroupScreenState();
}

class _LecturerGroupScreenState extends State<LecturerGroupScreen> {
  String _searchQuery = '';
  int? _selectedCourseId;
  bool _isLoading = true;
  List<CourseModel> _courses = [];
  List<GroupModel> _allGroups = [];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _selectedCourseId = widget.course.courseId ?? widget.course.id;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final courses = await CourseService().getMyClasses();
      List<GroupModel> groups = [];
      for (final c in courses) {
        try {
          final gList = await GroupService().getGroupsByCourse(c.id);
          groups.addAll(gList);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _courses = courses;
          _allGroups = groups;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.text('Danh sách nhóm', en: 'Groups')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final query = _searchQuery.trim().toLowerCase();
    final groups = _allGroups.where((group) {
      if (widget.course != null && group.courseId != _selectedCourseId) {
        return false;
      }
      if (widget.course == null &&
          _selectedCourseId != null &&
          group.courseId != _selectedCourseId) {
        return false;
      }

      return query.isEmpty ||
          group.name.toLowerCase().contains(query) ||
          group.leader.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Danh sách nhóm', en: 'Groups')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.course == null) ...[
                  Text(
                    'Các nhóm thuộc lớp học phần được phân công',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Tất cả'),
                            selected: _selectedCourseId == null,
                            onSelected: (_) {
                              setState(() => _selectedCourseId = null);
                            },
                          ),
                        ),
                        ..._courses.map(
                          (course) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(course.classCode.isNotEmpty ? course.classCode : course.code),
                              selected: _selectedCourseId == course.id,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCourseId = course.id;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.text(
                      'Tìm tên nhóm, trưởng nhóm hoặc lớp...',
                      en: 'Search group, leader or course...',
                    ),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${groups.length} nhóm',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: groups.isEmpty
                ? const _EmptyGroupState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LecturerGroupCard(
                          group: group,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LecturerGroupDetailScreen(group: group),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroupState extends StatelessWidget {
  const _EmptyGroupState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined, size: 56, color: colors.outline),
          const SizedBox(height: 12),
          Text(
            'Không tìm thấy nhóm phù hợp',
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
