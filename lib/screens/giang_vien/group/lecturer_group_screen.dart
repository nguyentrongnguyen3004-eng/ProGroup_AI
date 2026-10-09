import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_groups.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../widgets/lecturer/lecturer_group_card.dart';
import 'lecturer_group_detail_screen.dart';

class LecturerGroupScreen extends StatefulWidget {
  final LecturerCourseModel? course;

  const LecturerGroupScreen({super.key, this.course});

  @override
  State<LecturerGroupScreen> createState() => _LecturerGroupScreenState();
}

class _LecturerGroupScreenState extends State<LecturerGroupScreen> {
  String _searchQuery = '';
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.course?.courseId;
  }

  @override
  Widget build(BuildContext context) {
    final courses = MockLecturerCourses.courses;
    final courseById = <int, LecturerCourseModel>{
      for (final course in courses) course.courseId: course,
    };
    if (widget.course != null) {
      courseById[widget.course!.courseId] = widget.course!;
    }

    final query = _searchQuery.trim().toLowerCase();
    final groups = MockLecturerGroups.groups.where((group) {
      final course = courseById[group.courseId];
      if (course == null) return false;
      if (widget.course != null && group.courseId != widget.course!.courseId) {
        return false;
      }
      if (widget.course == null &&
          _selectedCourseId != null &&
          group.courseId != _selectedCourseId) {
        return false;
      }

      return query.isEmpty ||
          group.name.toLowerCase().contains(query) ||
          group.leader.toLowerCase().contains(query) ||
          course.name.toLowerCase().contains(query) ||
          course.classCode.toLowerCase().contains(query);
    }).toList();

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Danh sách nhóm', en: 'Groups')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.course != null) ...[
                  Text(
                    widget.course!.name,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.course!.code} • ${widget.course!.classCode}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
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
                        ...courses.map(
                          (course) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(course.classCode),
                              selected: _selectedCourseId == course.courseId,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCourseId = course.courseId;
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final course = courseById[group.courseId]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 6,
                              ),
                              child: Text(
                                '${course.name} • ${course.classCode}',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            LecturerGroupCard(
                              group: group,
                              minMembers: course.minMembers,
                              maxMembers: course.maxMembers,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LecturerGroupDetailScreen(
                                      course: course,
                                      group: group,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 64,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.text('Chưa có nhóm', en: 'No groups'),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.text(
                'Chưa có nhóm nào trong các lớp được phân công.',
                en: 'There are no groups in the assigned courses yet.',
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
