import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/services/student_api_service.dart';
import 'package:progroup_ai_frontend/widgets/group_card.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  int? _selectedCourseId;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;

  List<GroupModel> _groups = [];
  List<CourseModel> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        StudentApiService.instance.fetchMyGroups(),
        StudentApiService.instance.fetchMyCourses(),
      ]);

      if (!mounted) return;
      setState(() {
        _groups = results[0] as List<GroupModel>;
        _courses = results[1] as List<CourseModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<GroupModel> get _filteredGroups {
    return _groups.where((group) {
      if (_selectedCourseId != null && group.courseId != _selectedCourseId) {
        return false;
      }

      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matchesName = group.name.toLowerCase().contains(query);
        final matchesLeader = group.leader.toLowerCase().contains(query);
        if (!matchesName && !matchesLeader) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canPop = ModalRoute.of(context)?.canPop == true;
    final filteredGroups = _filteredGroups;

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(AppLocalizations.text('Nhóm', en: 'Groups')),
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF2563EB),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Large Title (Đồng bộ chuẩn Template)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!canPop) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppLocalizations.text(
                                      'Theo dõi và tham gia nhóm học tập của bạn',
                                      en: 'Track and join your study groups',
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
                    ],

                    // Select Dropdown chọn lớp học phần (Đồng bộ Template)
                    if (_courses.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
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
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                            fontWeight:
                                                _selectedCourseId == c.id
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
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Ô tìm kiếm nhóm
                    TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.text(
                          'Tìm tên nhóm hoặc trưởng nhóm...',
                          en: 'Search group or leader...',
                        ),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Danh sách nhóm
              Expanded(
                child: _buildGroupList(colors, filteredGroups),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupList(ColorScheme colors, List<GroupModel> groups) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
        ),
      );
    }

    if (_errorMessage != null && _groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: colors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.text(
                  'Không thể tải danh sách nhóm',
                  en: 'Failed to load groups',
                ),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.groups_outlined,
                  size: 52,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.text(
                  'Bạn chưa tham gia nhóm nào',
                  en: 'You have not joined any group yet',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.text(
                  'Hãy vào một lớp học phần để tạo hoặc tham gia nhóm.',
                  en: 'Open a course to create or join a group.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 76),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = groups[index];
        return GroupCard(
          group: group,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.groupDetail,
              arguments: group,
            );
          },
        );
      },
    );
  }
}
