import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
<<<<<<< HEAD
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../services/lecturer_api_service.dart';
=======
import '../../../models/course_model.dart';
import '../../../models/group_model.dart';
import '../../../services/course_service.dart';
import '../../../services/group_service.dart';
>>>>>>> origin/Frontend
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
<<<<<<< HEAD
  String? _errorMessage;
  List<LecturerCourseModel> _courses = [];
  List<GroupModel> _groups = [];
=======
  List<CourseModel> _courses = [];
  List<GroupModel> _allGroups = [];
>>>>>>> origin/Frontend

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _selectedCourseId = widget.course?.courseId;
=======
    if (widget.course != null) {
      _selectedCourseId = widget.course.courseId ?? widget.course.id;
    }
>>>>>>> origin/Frontend
    _loadData();
  }

  Future<void> _loadData() async {
<<<<<<< HEAD
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        LecturerApiService.instance.fetchCourses(),
        LecturerApiService.instance.fetchGroups(widget.course?.courseId),
      ]);

      if (mounted) {
        setState(() {
          _courses = results[0] as List<LecturerCourseModel>;
          _groups = results[1] as List<GroupModel>;
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
=======
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
>>>>>>> origin/Frontend
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
<<<<<<< HEAD
    final canPop = ModalRoute.of(context)?.canPop == true;

    final courseById = <int, LecturerCourseModel>{
      for (final course in _courses) course.courseId: course,
    };
    if (widget.course != null) {
      courseById[widget.course!.courseId] = widget.course!;
    }

    final query = _searchQuery.trim().toLowerCase();
    final filteredGroups = _groups.where((group) {
      final course = courseById[group.courseId];
      if (widget.course != null && group.courseId != widget.course!.courseId) {
=======

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
>>>>>>> origin/Frontend
        return false;
      }
      if (widget.course == null &&
          _selectedCourseId != null &&
          group.courseId != _selectedCourseId) {
        return false;
      }

      final cName = course?.name.toLowerCase() ?? '';
      final cCode = course?.classCode.toLowerCase() ?? '';
      return query.isEmpty ||
          group.name.toLowerCase().contains(query) ||
<<<<<<< HEAD
          group.leader.toLowerCase().contains(query) ||
          cName.contains(query) ||
          cCode.contains(query);
    }).toList();

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(AppLocalizations.text('Nhóm', en: 'Groups')),
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Top Header Banner
            if (!canPop)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
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
                            AppLocalizations.text('Nhóm đồ án', en: 'Project Groups'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
=======
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
>>>>>>> origin/Frontend
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.text(
                              'Theo dõi và quản lý nhóm của sinh viên',
                              en: 'Track and manage student groups',
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: _loadData,
                      tooltip: 'Tải lại',
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canPop && widget.course != null) ...[
                    Text(
                      AppLocalizations.courseName(widget.course!.name),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.course!.code} • ${widget.course!.classCode}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (widget.course == null && _courses.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                          width: 1,
                        ),
<<<<<<< HEAD
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: _selectedCourseId,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colors.primary,
                          ),
                          dropdownColor: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.layers_rounded,
                                    size: 18,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.text(
                                        'Tất cả lớp học phần',
                                        en: 'All Course Classes',
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: _selectedCourseId == null
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: colors.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._courses.map(
                              (c) => DropdownMenuItem<int?>(
                                value: c.courseId,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        c.classCode,
                                        style: const TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.courseName(c.name),
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: _selectedCourseId == c.courseId
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: colors.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (newId) {
                            setState(() => _selectedCourseId = newId);
=======
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
>>>>>>> origin/Frontend
                          },
                        ),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.text(
                      '${filteredGroups.length} nhóm',
                      en: '${filteredGroups.length} groups',
                    ),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _buildBody(colors, filteredGroups, courseById),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ColorScheme colors,
    List<GroupModel> filteredGroups,
    Map<int, LecturerCourseModel> courseById,
  ) {
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

    if (filteredGroups.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const _EmptyGroupState(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: filteredGroups.length,
        itemBuilder: (context, index) {
          final group = filteredGroups[index];
          final course = courseById[group.courseId] ??
              LecturerCourseModel(
                id: group.courseId,
                courseId: group.courseId,
                code: 'HP',
                name: 'Lớp học phần ${group.courseId}',
                classCode: 'LHP-${group.courseId}',
                semester: 'HK1',
                studentCount: 45,
                groupCount: 0,
                topicCount: 0,
                groupRegistrationStart: '',
                groupRegistrationEnd: '',
                topicRegistrationStart: '',
                topicRegistrationEnd: '',
                minMembers: 3,
                maxMembers: 5,
                status: 'Đang mở',
              );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    '${AppLocalizations.courseName(course.name)} • ${course.classCode}',
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
    );
  }
}

class _EmptyGroupState extends StatelessWidget {
  const _EmptyGroupState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
<<<<<<< HEAD
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 56,
              color: colors.outlineVariant,
=======
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
>>>>>>> origin/Frontend
            ),
          ),
        ],
      ),
    );
  }
}
