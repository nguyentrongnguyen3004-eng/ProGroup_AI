import 'dart:math' as math;
import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../../../core/localization/app_localizations.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/lecturer_topic_proposal_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';
import '../../../services/lecturer_api_service.dart';
=======
import '../../../core/theme/app_theme.dart';
import '../../../models/course_model.dart';
import '../../../models/group_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/course_service.dart';
import '../../../services/group_service.dart';
import '../../../services/topic_service.dart';
import '../../../widgets/lecturer/lecturer_stat_card.dart';
>>>>>>> origin/Frontend

class LecturerStatisticsScreen extends StatefulWidget {
  final int? initialCourseId;
  const LecturerStatisticsScreen({super.key, this.initialCourseId});

  @override
  State<LecturerStatisticsScreen> createState() =>
      _LecturerStatisticsScreenState();
}

class _LecturerStatisticsScreenState extends State<LecturerStatisticsScreen> {
  int? _courseId;
  bool _isLoading = true;
<<<<<<< HEAD
  String? _errorMessage;

  List<LecturerCourseModel> _courses = [];
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];
  List<TopicRegistrationModel> _registrations = [];
  List<LecturerTopicProposalModel> _proposals = [];
=======
  List<CourseModel> _courses = [];
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];
  List<Map<String, dynamic>> _registrations = [];
>>>>>>> origin/Frontend

  @override
  void initState() {
    super.initState();
    _courseId = widget.initialCourseId;
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
        LecturerApiService.instance.fetchCourses(),
        LecturerApiService.instance.fetchGroups(),
        LecturerApiService.instance.fetchTopics(),
        LecturerApiService.instance.fetchTopicRegistrations(),
        LecturerApiService.instance.fetchTopicProposals(),
      ]);

      final rawRegs = results[3] as List<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _courses = results[0] as List<LecturerCourseModel>;
          _groups = results[1] as List<GroupModel>;
          _topics = results[2] as List<TopicModel>;
          _registrations = rawRegs.map((r) => TopicRegistrationModel.fromJson(r)).toList();
          _proposals = results[4] as List<LecturerTopicProposalModel>;
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
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final courses = await CourseService().getMyClasses();
      final topics = await TopicService().getLecturerTopics();
      final registrations = await TopicService().getTopicRegistrations();

      List<GroupModel> allGroups = [];
      for (final c in courses) {
        try {
          final gList = await GroupService().getGroupsByCourse(c.id);
          allGroups.addAll(gList);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _courses = courses;
          _topics = topics;
          _registrations = registrations;
          _groups = allGroups;
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
<<<<<<< HEAD
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final courses = _courses;
    final selectedCourses = _courseId == null
        ? courses
        : courses.where((course) => course.courseId == _courseId).toList();
    final courseIds = selectedCourses.map((c) => c.courseId).toSet();

    final groups = _groups
        .where((g) => courseIds.isEmpty || courseIds.contains(g.courseId))
        .toList();
    final topics = _topics
        .where((t) => courseIds.isEmpty || courseIds.contains(t.courseId))
        .toList();

    final groupIds = groups.map((g) => g.id).toSet();
    final topicIds = topics.map((t) => t.id).toSet();

    final registrations = _registrations
        .where((item) =>
            groupIds.isEmpty ||
            topicIds.isEmpty ||
            (groupIds.contains(item.groupId) && topicIds.contains(item.topicId)))
        .toList();

    final proposals = _proposals
        .where((item) => courseIds.isEmpty || courseIds.contains(item.courseId))
        .toList();

    final approvedRegs = registrations
        .where((r) => r.status.trim().toLowerCase() == 'đã duyệt')
        .toList();
    final pendingRegs = registrations
        .where((r) => r.status.trim().toLowerCase() == 'chờ duyệt')
        .toList();
    final rejectedRegs = registrations
        .where((r) => r.status.trim().toLowerCase() == 'từ chối')
        .toList();

    final groupsWithApprovedTopic = approvedRegs
        .map((r) => r.groupId)
        .toSet()
        .length;
    final groupsWithPendingOnly = pendingRegs
        .map((r) => r.groupId)
        .where((gid) => !approvedRegs.any((ar) => ar.groupId == gid))
        .toSet()
        .length;
    final groupsWithoutTopic = (groups.length -
            groupsWithApprovedTopic -
            groupsWithPendingOnly)
        .clamp(0, groups.length);

    final totalStudents = selectedCourses.fold<int>(
      0,
      (sum, c) => sum + c.studentCount,
    );
    final openTopics = topics
        .where(
          (t) =>
              t.status.toLowerCase().contains('hoạt động') ||
              t.status.toLowerCase().contains('mở') ||
              t.status.toLowerCase().contains('chưa sử dụng'),
        )
        .length;

    final completionRatio = groups.isEmpty
        ? 0.0
        : (groupsWithApprovedTopic / groups.length).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Thống kê nâng cao', en: 'Advanced Analytics'),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
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
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      children: [
                        // Filter card
                        _buildCourseFilter(courses, colors),

                        const SizedBox(height: 16),

                        // Top KPI Summary Cards (4 Cards in 2x2 Grid)
                        _buildKpiGrid(
                          totalStudents: totalStudents,
                          totalGroups: groups.length,
                          openTopics: openTopics,
                          pendingCount: pendingRegs.length,
                          colors: colors,
                        ),

                        const SizedBox(height: 18),

                        // Biểu đồ 1: Donut Chart - Tỷ lệ nhóm có đề tài
                        _buildDonutChartCard(
                          context: context,
                          approved: groupsWithApprovedTopic,
                          pending: groupsWithPendingOnly,
                          unregistered: groupsWithoutTopic,
                          totalGroups: groups.length,
                          completionRatio: completionRatio,
                          colors: colors,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 18),

                        // Biểu đồ 2: Horizontal Bar Breakdown - Trạng thái đăng ký & Đề xuất
                        _buildRegistrationPipelineCard(
                          approved: approvedRegs.length,
                          pending: pendingRegs.length,
                          rejected: rejectedRegs.length,
                          proposals: proposals.length,
                          colors: colors,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 18),

                        // Biểu đồ 3: So sánh giữa các lớp học phần
                        _buildCourseComparisonCard(
                          selectedCourses: selectedCourses,
                          approvedRegs: approvedRegs,
                          allGroups: _groups,
                          allTopics: _topics,
                          colors: colors,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ============================================================
  // COURSE FILTER SELECTOR
  // ============================================================

  Widget _buildCourseFilter(
    List<LecturerCourseModel> courses,
    ColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _courseId,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.primary,
          ),
          hint: Text(
            AppLocalizations.text('Tất cả học phần', en: 'All Courses'),
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.text(
                        'Tất cả học phần phụ trách',
                        en: 'All Assigned Courses',
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...courses.map(
              (course) => DropdownMenuItem<int?>(
                value: course.courseId,
                child: Row(
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${AppLocalizations.courseName(course.name)} (${course.classCode})',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _courseId = value),
        ),
      ),
    );
  }

  // ============================================================
  // TOP KPI GRID
  // ============================================================

  Widget _buildKpiGrid({
    required int totalStudents,
    required int totalGroups,
    required int openTopics,
    required int pendingCount,
    required ColorScheme colors,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricPillCard(
          title: AppLocalizations.text('Sinh viên', en: 'Students'),
          value: totalStudents.toString(),
          icon: Icons.school_rounded,
          color: const Color(0xFF2563EB),
          colors: colors,
        ),
        _buildMetricPillCard(
          title: AppLocalizations.text('Tổng nhóm', en: 'Groups'),
          value: totalGroups.toString(),
          icon: Icons.groups_rounded,
          color: const Color(0xFF10B981),
          colors: colors,
        ),
        _buildMetricPillCard(
          title: AppLocalizations.text('Đề tài khả dụng', en: 'Open Topics'),
          value: openTopics.toString(),
          icon: Icons.lightbulb_rounded,
          color: const Color(0xFF8B5CF6),
          colors: colors,
        ),
        _buildMetricPillCard(
          title: AppLocalizations.text('Chờ phê duyệt', en: 'Pending'),
          value: pendingCount.toString(),
          icon: Icons.pending_actions_rounded,
          color: pendingCount > 0
              ? const Color(0xFFF59E0B)
              : const Color(0xFF6B7280),
          highlightBadge: pendingCount > 0,
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildMetricPillCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ColorScheme colors,
    bool highlightBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlightBadge
              ? color.withValues(alpha: 0.4)
              : colors.outlineVariant.withValues(alpha: 0.3),
          width: highlightBadge ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
=======
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thống kê nâng cao')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final selectedCourses = _courseId == null
        ? _courses
        : _courses.where((c) => c.id == _courseId).toList();
    final selectedCourseIds = selectedCourses.map((c) => c.id).toSet();

    final filteredGroups = _groups
        .where((g) => _courseId == null || selectedCourseIds.contains(g.courseId))
        .toList();
    final filteredTopics = _topics
        .where((t) => _courseId == null || selectedCourseIds.contains(t.courseId))
        .toList();

    final pendingCount = _registrations
        .where((r) => (r['trangThai'] ?? '').toString().trim().toLowerCase() == 'chờ duyệt')
        .length;
    final approvedCount = _registrations
        .where((r) => (r['trangThai'] ?? '').toString().trim().toLowerCase() == 'đã duyệt')
        .length;
    final rejectedCount = _registrations
        .where((r) => (r['trangThai'] ?? '').toString().trim().toLowerCase() == 'đã từ chối')
        .length;

    final stats = <String, int>{
      'Lớp học phần': selectedCourses.length,
      'Nhóm': filteredGroups.length,
      'Đề tài': filteredTopics.length,
      'Đăng ký chờ duyệt': pendingCount,
      'Đăng ký đã duyệt': approvedCount,
      'Đăng ký bị từ chối': rejectedCount,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê nâng cao'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStats,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int?>(
            value: _courseId,
            decoration: const InputDecoration(labelText: 'Phạm vi học phần'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả học phần'),
              ),
              ..._courses.map(
                (course) => DropdownMenuItem<int?>(
                  value: course.id,
                  child: Text('${course.code} • ${course.name}'),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _courseId = value),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.48,
            children: [
              for (final entry in stats.entries)
                LecturerStatCard(
                  title: entry.key,
                  value: entry.value.toString(),
                  icon: _statIcon(entry.key),
                  color: _statColor(entry.key),
                ),
            ],
>>>>>>> origin/Frontend
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (highlightBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.text('Cần xử lý', en: 'Action'),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BIỂU ĐỒ 1: DONUT RING CHART (Tiến độ phủ đề tài cho nhóm)
  // ============================================================

  Widget _buildDonutChartCard({
    required BuildContext context,
    required int approved,
    required int pending,
    required int unregistered,
    required int totalGroups,
    required double completionRatio,
    required ColorScheme colors,
    required bool isDark,
  }) {
    final segments = [
      _ChartSegment(
        label: AppLocalizations.text('Đã có đề tài', en: 'Topic Assigned'),
        value: approved.toDouble(),
        color: const Color(0xFF10B981),
      ),
      _ChartSegment(
        label: AppLocalizations.text('Chờ duyệt', en: 'Pending Approval'),
        value: pending.toDouble(),
        color: const Color(0xFFF59E0B),
      ),
      _ChartSegment(
        label: AppLocalizations.text('Chưa đăng ký', en: 'Unregistered'),
        value: unregistered.toDouble(),
        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.donut_large_rounded,
                  size: 18,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.text(
                        'Tiến độ gắn đề tài cho nhóm',
                        en: 'Topic Coverage for Groups',
                      ),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppLocalizations.text(
                        'Tỷ lệ nhóm đã có đề tài được duyệt',
                        en: 'Ratio of groups with approved topics',
                      ),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Donut Chart + Legend Center
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _DonutChartPainter(
                        segments: segments,
                        strokeWidth: 16,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(completionRatio * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          AppLocalizations.text('Hoàn tất', en: 'Done'),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Legend items
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      label: AppLocalizations.text('Đã duyệt', en: 'Approved'),
                      count: approved,
                      total: totalGroups,
                      color: const Color(0xFF10B981),
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                      label: AppLocalizations.text('Chờ duyệt', en: 'Pending'),
                      count: pending,
                      total: totalGroups,
                      color: const Color(0xFFF59E0B),
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                      label: AppLocalizations.text('Chưa đăng ký', en: 'Unregistered'),
                      count: unregistered,
                      total: totalGroups,
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFF94A3B8),
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String label,
    required int count,
    required int total,
    required Color color,
    required ColorScheme colors,
  }) {
    final pct = total > 0 ? ((count / total) * 100).toInt() : 0;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '$count ($pct%)',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BIỂU ĐỒ 2: REGISTRATION PIPELINE BREAKDOWN
  // ============================================================

  Widget _buildRegistrationPipelineCard({
    required int approved,
    required int pending,
    required int rejected,
    required int proposals,
    required ColorScheme colors,
    required bool isDark,
  }) {
    final total = approved + pending + rejected;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.text(
                        'Phân bổ hồ sơ đăng ký',
                        en: 'Registration Pipeline',
                      ),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppLocalizations.text(
                        'Chi tiết trạng thái đơn đăng ký & đề xuất',
                        en: 'Detailed breakdown of registrations & proposals',
                      ),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildProgressBarRow(
            label: AppLocalizations.text('Đơn đã duyệt', en: 'Approved'),
            count: approved,
            total: total,
            color: const Color(0xFF10B981),
            colors: colors,
          ),
          const SizedBox(height: 12),
          _buildProgressBarRow(
            label: AppLocalizations.text('Đang chờ xử lý', en: 'Pending'),
            count: pending,
            total: total,
            color: const Color(0xFFF59E0B),
            colors: colors,
          ),
          const SizedBox(height: 12),
          _buildProgressBarRow(
            label: AppLocalizations.text('Bị từ chối', en: 'Rejected'),
            count: rejected,
            total: total,
            color: const Color(0xFFEF4444),
            colors: colors,
          ),

          if (proposals > 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.text(
                      'Đề xuất đề tài từ sinh viên',
                      en: 'Student-initiated Proposals',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$proposals',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBarRow({
    required String label,
    required int count,
    required int total,
    required Color color,
    required ColorScheme colors,
  }) {
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final percent = (ratio * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count ($percent%)',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 9,
            width: double.infinity,
            color: color.withValues(alpha: 0.12),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BIỂU ĐỒ 3: SO SÁNH GIỮA CÁC LỚP HỌC PHẦN
  // ============================================================

  Widget _buildCourseComparisonCard({
    required List<LecturerCourseModel> selectedCourses,
    required List<TopicRegistrationModel> approvedRegs,
    required List<GroupModel> allGroups,
    required List<TopicModel> allTopics,
    required ColorScheme colors,
    required bool isDark,
  }) {
    if (selectedCourses.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  size: 18,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.text(
                        'Tiến độ theo từng lớp học phần',
                        en: 'Progress by Course Class',
                      ),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppLocalizations.text(
                        'So sánh tỷ lệ chốt đề tài giữa các lớp',
                        en: 'Compare finalization rates across classes',
                      ),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...selectedCourses.map((course) {
            final courseGroups = allGroups
                .where((g) => g.courseId == course.courseId)
                .toList();
            final courseTopics = allTopics
                .where((t) => t.courseId == course.courseId)
                .toList();
            final courseApprovedCount = approvedRegs
                .where((r) => courseGroups.any((cg) => cg.id == r.groupId))
                .length;
            final courseRatio = courseGroups.isEmpty
                ? 0.0
                : (courseApprovedCount / courseGroups.length).clamp(0.0, 1.0);
            final coursePercent = (courseRatio * 100).toInt();

            final barColor = courseRatio >= 0.75
                ? const Color(0xFF10B981)
                : (courseRatio >= 0.4
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444));

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.courseName(course.name),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course.classCode,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${course.studentCount} SV • ${courseGroups.length} Nhóm • ${courseTopics.length} Đề tài',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$courseApprovedCount/${courseGroups.length} ($coursePercent%)',
                        style: TextStyle(
                          color: barColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 8,
                      width: double.infinity,
                      color: barColor.withValues(alpha: 0.12),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: courseRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
// ============================================================
// DONUT CHART PAINTER & SEGMENT MODEL
// ============================================================

class _ChartSegment {
  final String label;
  final double value;
  final Color color;

  const _ChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });
=======
IconData _statIcon(String label) {
  if (label.contains('Lớp')) return Icons.school_outlined;
  if (label.contains('Nhóm')) return Icons.groups_outlined;
  if (label.contains('Đề tài')) return Icons.lightbulb_outline;
  if (label.contains('chờ')) return Icons.pending_actions_outlined;
  if (label.contains('đã duyệt')) return Icons.check_circle_outline;
  if (label.contains('từ chối')) return Icons.cancel_outlined;
  return Icons.assignment_outlined;
>>>>>>> origin/Frontend
}

class _DonutChartPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  final double strokeWidth;

  const _DonutChartPainter({
    required this.segments,
    this.strokeWidth = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    if (total == 0) {
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -math.pi / 2;
    const gapAngle = 0.05;

    final activeSegments = segments.where((s) => s.value > 0).toList();
    final hasMultiple = activeSegments.length > 1;

    for (final seg in activeSegments) {
      final sweepAngle = (seg.value / total) * 2 * math.pi;
      final effectiveSweep = hasMultiple
          ? (sweepAngle - gapAngle).clamp(0.01, 2 * math.pi)
          : sweepAngle;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        startAngle + (hasMultiple ? gapAngle / 2 : 0),
        effectiveSweep,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
