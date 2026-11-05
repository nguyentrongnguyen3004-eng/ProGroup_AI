import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/lecturer_topic_proposal_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';
import '../../../services/lecturer_api_service.dart';

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
  String? _errorMessage;

  List<LecturerCourseModel> _courses = [];
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];
  List<TopicRegistrationModel> _registrations = [];
  List<LecturerTopicProposalModel> _proposals = [];

  // Toggle giữa góc nhìn Nhóm và góc nhìn Sinh viên cho biểu đồ donut
  bool _isStudentPerspective = false;

  @override
  void initState() {
    super.initState();
    _courseId = widget.initialCourseId;
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
        final loadedCourses = results[0] as List<LecturerCourseModel>;
        if (_courseId != null && loadedCourses.isNotEmpty) {
          final matched = loadedCourses.firstWhere(
            (c) => c.id == _courseId || c.courseId == _courseId,
            orElse: () => loadedCourses.first,
          );
          _courseId = matched.id;
        }
        setState(() {
          _courses = loadedCourses;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final courses = _courses;
    final selectedCourses = _courseId == null
        ? courses
        : courses.where((course) => course.id == _courseId || course.courseId == _courseId).toList();
    final validLopIds = selectedCourses.map((c) => c.id).toSet();
    final validHocPhanIds = selectedCourses.map((c) => c.courseId).toSet();

    final groups = _groups.where((g) {
      if (validLopIds.isEmpty) return true;
      return validLopIds.contains(g.courseId) || validHocPhanIds.contains(g.courseId);
    }).toList();
    final topics = _topics.where((t) {
      if (validLopIds.isEmpty) return true;
      return validLopIds.contains(t.courseId) || validHocPhanIds.contains(t.courseId);
    }).toList();

    final groupIds = groups.map((g) => g.id).toSet();
    final topicIds = topics.map((t) => t.id).toSet();

    final registrations = _registrations
        .where((item) =>
            _courseId == null
                ? (groupIds.contains(item.groupId) || topicIds.contains(item.topicId))
                : groupIds.contains(item.groupId))
        .toList();

    final proposals = _proposals.where((item) {
      if (validLopIds.isEmpty) return true;
      return validLopIds.contains(item.courseId) || validHocPhanIds.contains(item.courseId);
    }).toList();

    final approvedRegs = registrations
        .where((r) => r.status.trim().toLowerCase() == 'đã duyệt')
        .toList();
    final pendingRegs = registrations
        .where((r) => r.status.trim().toLowerCase() == 'chờ duyệt')
        .toList();
    final rejectedRegs = registrations
        .where((r) => r.status.trim().toLowerCase() == 'từ chối')
        .toList();

    final approvedGroupIds = approvedRegs
        .map((r) => r.groupId)
        .where((gid) => groupIds.contains(gid))
        .toSet();
    final pendingGroupIds = pendingRegs
        .map((r) => r.groupId)
        .where((gid) => groupIds.contains(gid) && !approvedGroupIds.contains(gid))
        .toSet();

    final groupsWithApprovedTopic = approvedGroupIds.length;
    final groupsWithPendingOnly = pendingGroupIds.length;
    final groupsWithoutTopic = (groups.length -
            groupsWithApprovedTopic -
            groupsWithPendingOnly)
        .clamp(0, groups.length);

    final totalStudents = selectedCourses.fold<int>(
      0,
      (sum, c) => sum + c.studentCount,
    );

    // ==========================================
    // TÍNH TOÁN SỐ LIỆU SINH VIÊN (STUDENT METRICS)
    // ==========================================
    // 1. Số sinh viên đã đăng ký nhóm
    final studentsWithGroup = groups.fold<int>(
      0,
      (sum, g) => sum + math.max(g.memberCount, g.members.length),
    );

    // 2. Số sinh viên chưa đăng ký nhóm
    final studentsWithoutGroup = (totalStudents - studentsWithGroup).clamp(0, totalStudents);

    // 3. Số sinh viên đã đăng ký đề tài (nhóm đã được duyệt đề tài)
    final studentsWithApprovedTopic = groups
        .where((g) => approvedGroupIds.contains(g.id))
        .fold<int>(0, (sum, g) => sum + math.max(g.memberCount, g.members.length));

    // 4. Số sinh viên đang chờ duyệt đề tài (nhóm có đơn chờ duyệt)
    final studentsWithPendingTopic = groups
        .where((g) => pendingGroupIds.contains(g.id))
        .fold<int>(0, (sum, g) => sum + math.max(g.memberCount, g.members.length));

    // 5. Số sinh viên trong nhóm nhưng nhóm chưa đăng ký/chưa có đề tài
    final studentsInGroupsWithoutTopic = groups
        .where((g) => !approvedGroupIds.contains(g.id) && !pendingGroupIds.contains(g.id))
        .fold<int>(0, (sum, g) => sum + math.max(g.memberCount, g.members.length));

    // 6. Số sinh viên chưa đăng ký đề tài (= SV trong nhóm chưa có đề tài + SV chưa có nhóm)
    final studentsWithoutTopic = (totalStudents - studentsWithApprovedTopic - studentsWithPendingTopic)
        .clamp(0, totalStudents);

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

    final studentTopicCompletionRatio = totalStudents > 0
        ? (studentsWithApprovedTopic / totalStudents).clamp(0.0, 1.0)
        : 0.0;

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
                          studentsWithGroup: studentsWithGroup,
                          studentsWithoutGroup: studentsWithoutGroup,
                          totalGroups: groups.length,
                          groupsWithApprovedTopic: groupsWithApprovedTopic,
                          openTopics: openTopics,
                          pendingCount: pendingRegs.length,
                          colors: colors,
                        ),

                        const SizedBox(height: 18),

                        // MỤC MỚI: TÌNH TRẠNG SINH VIÊN (NHÓM & ĐỀ TÀI)
                        _buildStudentRegistrationCard(
                          totalStudents: totalStudents,
                          studentsWithGroup: studentsWithGroup,
                          studentsWithoutGroup: studentsWithoutGroup,
                          studentsWithApprovedTopic: studentsWithApprovedTopic,
                          studentsWithPendingTopic: studentsWithPendingTopic,
                          studentsWithoutTopic: studentsWithoutTopic,
                          studentsInGroupsWithoutTopic: studentsInGroupsWithoutTopic,
                          totalGroups: groups.length,
                          colors: colors,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 18),

                        // Biểu đồ 1: Donut Chart - Tỷ lệ nhóm / sinh viên có đề tài
                        _buildDonutChartCard(
                          context: context,
                          approvedGroups: groupsWithApprovedTopic,
                          pendingGroups: groupsWithPendingOnly,
                          unregisteredGroups: groupsWithoutTopic,
                          totalGroups: groups.length,
                          groupCompletionRatio: completionRatio,
                          approvedStudents: studentsWithApprovedTopic,
                          pendingStudents: studentsWithPendingTopic,
                          unregisteredStudents: studentsWithoutTopic,
                          totalStudents: totalStudents,
                          studentCompletionRatio: studentTopicCompletionRatio,
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
            AppLocalizations.text('Tất cả học phần phụ trách', en: 'All Assigned Courses'),
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
                value: course.id,
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
    required int studentsWithGroup,
    required int studentsWithoutGroup,
    required int totalGroups,
    required int groupsWithApprovedTopic,
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
      childAspectRatio: 1.35,
      children: [
        _buildMetricPillCard(
          title: AppLocalizations.text('Sinh viên', en: 'Students'),
          value: totalStudents.toString(),
          subtitle: totalStudents > 0 ? '$studentsWithGroup có nhóm • $studentsWithoutGroup chưa nhóm' : null,
          icon: Icons.school_rounded,
          color: const Color(0xFF2563EB),
          colors: colors,
        ),
        _buildMetricPillCard(
          title: AppLocalizations.text('Tổng nhóm', en: 'Groups'),
          value: totalGroups.toString(),
          subtitle: totalGroups > 0 ? '$groupsWithApprovedTopic nhóm có đề tài' : null,
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
    String? subtitle,
    bool highlightBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 17),
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
                  fontSize: 21,
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
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MỤC MỚI: TÌNH TRẠNG SINH VIÊN THEO NHÓM & ĐỀ TÀI
  // ============================================================

  Widget _buildStudentRegistrationCard({
    required int totalStudents,
    required int studentsWithGroup,
    required int studentsWithoutGroup,
    required int studentsWithApprovedTopic,
    required int studentsWithPendingTopic,
    required int studentsWithoutTopic,
    required int studentsInGroupsWithoutTopic,
    required int totalGroups,
    required ColorScheme colors,
    required bool isDark,
  }) {
    final groupRatio = totalStudents > 0 ? (studentsWithGroup / totalStudents).clamp(0.0, 1.0) : 0.0;
    final groupPct = (groupRatio * 100).toStringAsFixed(1);
    final noGroupPct = (totalStudents > 0 ? ((studentsWithoutGroup / totalStudents) * 100).clamp(0.0, 100.0) : 0.0).toStringAsFixed(1);

    final approvedTopicRatio = totalStudents > 0 ? (studentsWithApprovedTopic / totalStudents).clamp(0.0, 1.0) : 0.0;
    final approvedTopicPct = (approvedTopicRatio * 100).toStringAsFixed(1);

    final pendingTopicRatio = totalStudents > 0 ? (studentsWithPendingTopic / totalStudents).clamp(0.0, 1.0) : 0.0;
    final pendingTopicPct = (pendingTopicRatio * 100).toStringAsFixed(1);

    final noTopicRatio = totalStudents > 0 ? (studentsWithoutTopic / totalStudents).clamp(0.0, 1.0) : 0.0;
    final noTopicPct = (noTopicRatio * 100).toStringAsFixed(1);

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
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
                        'Tình trạng Sinh viên (Nhóm & Đề tài)',
                        en: 'Student Group & Topic Status',
                      ),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppLocalizations.text(
                        'Thống kê số lượng sinh viên đã và chưa có nhóm, đề tài',
                        en: 'Breakdown of students with and without group/topic',
                      ),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$totalStudents SV',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // -----------------------------------------------------------------
          // 1. THAM GIA NHÓM
          // -----------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.diversity_3_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.text('1. Tham gia nhóm đồ án', en: '1. Group Membership'),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '$studentsWithGroup/$totalStudents SV (${(groupRatio * 100).toInt()}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2 Metric Boxes: Đã vào nhóm vs Chưa vào nhóm
          Row(
            children: [
              Expanded(
                child: _buildStudentMetricBox(
                  title: AppLocalizations.text('Đã đăng ký nhóm', en: 'In Group'),
                  count: studentsWithGroup,
                  total: totalStudents,
                  percentStr: '$groupPct%',
                  caption: AppLocalizations.text('Trong $totalGroups nhóm', en: 'In $totalGroups groups'),
                  color: const Color(0xFF10B981),
                  icon: Icons.check_circle_rounded,
                  colors: colors,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStudentMetricBox(
                  title: AppLocalizations.text('Chưa đăng ký nhóm', en: 'No Group'),
                  count: studentsWithoutGroup,
                  total: totalStudents,
                  percentStr: '$noGroupPct%',
                  caption: studentsWithoutGroup > 0
                      ? AppLocalizations.text('Cần ghép nhóm', en: 'Needs Group')
                      : AppLocalizations.text('Đã đủ nhóm', en: 'All Grouped'),
                  color: studentsWithoutGroup > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  icon: studentsWithoutGroup > 0 ? Icons.person_off_rounded : Icons.check_circle_outline_rounded,
                  colors: colors,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Segmented Progress Bar for Group
          _buildMultiSegmentBar(
            segments: [
              _BarSegment(value: studentsWithGroup.toDouble(), color: const Color(0xFF10B981)),
              _BarSegment(value: studentsWithoutGroup.toDouble(), color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
            ],
            total: totalStudents.toDouble(),
          ),

          const SizedBox(height: 8),

          // Alert Callout for Grouping
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: studentsWithoutGroup > 0
                  ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                  : const Color(0xFF10B981).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: studentsWithoutGroup > 0
                    ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                    : const Color(0xFF10B981).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  studentsWithoutGroup > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                  size: 16,
                  color: studentsWithoutGroup > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    studentsWithoutGroup > 0
                        ? AppLocalizations.text(
                            'Có $studentsWithoutGroup sinh viên ($noGroupPct%) chưa có nhóm. Cần nhắc nhở sinh viên ghép nhóm trước thời hạn.',
                            en: '$studentsWithoutGroup students ($noGroupPct%) have no group yet. Reminder recommended.',
                          )
                        : AppLocalizations.text(
                            'Tất cả 100% sinh viên đã tham gia đầy đủ vào các nhóm đồ án.',
                            en: '100% of students have joined a project group.',
                          ),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: studentsWithoutGroup > 0
                          ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C))
                          : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D)),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.25)),
          const SizedBox(height: 16),

          // -----------------------------------------------------------------
          // 2. NHẬN ĐỀ TÀI ĐỒ ÁN
          // -----------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in_rounded, size: 16, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.text('2. Tiến độ nhận đề tài đồ án', en: '2. Topic Assignment'),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '$studentsWithApprovedTopic/$totalStudents SV (${(approvedTopicRatio * 100).toInt()}%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3 Metric Boxes: Đã có đề tài vs Chờ duyệt vs Chưa có đề tài
          Row(
            children: [
              Expanded(
                child: _buildStudentMetricBox(
                  title: AppLocalizations.text('Đã có đề tài', en: 'With Topic'),
                  count: studentsWithApprovedTopic,
                  total: totalStudents,
                  percentStr: '$approvedTopicPct%',
                  caption: AppLocalizations.text('Đã duyệt', en: 'Approved'),
                  color: const Color(0xFF10B981),
                  icon: Icons.verified_rounded,
                  colors: colors,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStudentMetricBox(
                  title: AppLocalizations.text('Chờ duyệt', en: 'Pending'),
                  count: studentsWithPendingTopic,
                  total: totalStudents,
                  percentStr: '$pendingTopicPct%',
                  caption: AppLocalizations.text('Đang chờ', en: 'Under review'),
                  color: const Color(0xFFF59E0B),
                  icon: Icons.hourglass_top_rounded,
                  colors: colors,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStudentMetricBox(
                  title: AppLocalizations.text('Chưa có đề tài', en: 'No Topic'),
                  count: studentsWithoutTopic,
                  total: totalStudents,
                  percentStr: '$noTopicPct%',
                  caption: AppLocalizations.text('Chưa có', en: 'Needs Topic'),
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  icon: Icons.topic_outlined,
                  colors: colors,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Segmented Progress Bar for Topics
          _buildMultiSegmentBar(
            segments: [
              _BarSegment(value: studentsWithApprovedTopic.toDouble(), color: const Color(0xFF10B981)),
              _BarSegment(value: studentsWithPendingTopic.toDouble(), color: const Color(0xFFF59E0B)),
              _BarSegment(value: studentsWithoutTopic.toDouble(), color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            ],
            total: totalStudents.toDouble(),
          ),

          const SizedBox(height: 10),

          // Detailed Breakdown Explanation Note
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 15, color: colors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.text(
                        'Chi tiết phân loại đề tài sinh viên:',
                        en: 'Detailed student topic breakdown:',
                      ),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildBreakdownBullet(
                  text: '• $studentsWithApprovedTopic SV ($approvedTopicPct%): Đã có đề tài chính thức được duyệt.',
                  color: const Color(0xFF10B981),
                  colors: colors,
                ),
                if (studentsWithPendingTopic > 0)
                  _buildBreakdownBullet(
                    text: '• $studentsWithPendingTopic SV ($pendingTopicPct%): Đang có đề tài chờ phê duyệt.',
                    color: const Color(0xFFF59E0B),
                    colors: colors,
                  ),
                _buildBreakdownBullet(
                  text: '• $studentsWithoutTopic SV ($noTopicPct%): Chưa có đề tài làm đồ án, gồm:',
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  colors: colors,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '- $studentsInGroupsWithoutTopic SV đã vào nhóm nhưng nhóm chưa chọn/chưa được duyệt đề tài.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '- $studentsWithoutGroup SV chưa đăng ký vào nhóm nào.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentMetricBox({
    required String title,
    required int count,
    required int total,
    required String percentStr,
    required String caption,
    required Color color,
    required IconData icon,
    required ColorScheme colors,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'SV',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                percentStr,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              caption,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSegmentBar({
    required List<_BarSegment> segments,
    required double total,
    double height = 9,
  }) {
    if (total <= 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: Colors.grey.withValues(alpha: 0.12),
        child: Row(
          children: segments.map((seg) {
            final flex = (seg.value * 1000).toInt();
            if (flex <= 0) return const SizedBox.shrink();
            return Expanded(
              flex: flex,
              child: Container(color: seg.color),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBreakdownBullet({
    required String text,
    required Color color,
    required ColorScheme colors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
          height: 1.35,
        ),
      ),
    );
  }

  // ============================================================
  // BIỂU ĐỒ 1: DONUT RING CHART (Tiến độ đề tài: Nhóm / Sinh viên)
  // ============================================================

  Widget _buildDonutChartCard({
    required BuildContext context,
    required int approvedGroups,
    required int pendingGroups,
    required int unregisteredGroups,
    required int totalGroups,
    required double groupCompletionRatio,
    required int approvedStudents,
    required int pendingStudents,
    required int unregisteredStudents,
    required int totalStudents,
    required double studentCompletionRatio,
    required ColorScheme colors,
    required bool isDark,
  }) {
    final activeApproved = _isStudentPerspective ? approvedStudents : approvedGroups;
    final activePending = _isStudentPerspective ? pendingStudents : pendingGroups;
    final activeUnregistered = _isStudentPerspective ? unregisteredStudents : unregisteredGroups;
    final activeTotal = _isStudentPerspective ? totalStudents : totalGroups;
    final activeRatio = _isStudentPerspective ? studentCompletionRatio : groupCompletionRatio;

    final segments = [
      _ChartSegment(
        label: AppLocalizations.text('Đã có đề tài', en: 'Topic Assigned'),
        value: activeApproved.toDouble(),
        color: const Color(0xFF10B981),
      ),
      _ChartSegment(
        label: AppLocalizations.text('Chờ duyệt', en: 'Pending Approval'),
        value: activePending.toDouble(),
        color: const Color(0xFFF59E0B),
      ),
      _ChartSegment(
        label: AppLocalizations.text('Chưa có đề tài', en: 'Unassigned'),
        value: activeUnregistered.toDouble(),
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
                      _isStudentPerspective
                          ? AppLocalizations.text('Tiến độ đề tài theo sinh viên', en: 'Topic Progress by Students')
                          : AppLocalizations.text('Tiến độ gắn đề tài cho nhóm', en: 'Topic Coverage for Groups'),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _isStudentPerspective
                          ? AppLocalizations.text('Tỷ lệ sinh viên đã có đề tài được duyệt', en: 'Ratio of students with approved topics')
                          : AppLocalizations.text('Tỷ lệ nhóm đã có đề tài được duyệt', en: 'Ratio of groups with approved topics'),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Segment Switcher Button (Nhóm vs Sinh viên)
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.25)),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPerspectiveTab(
                      label: AppLocalizations.text('Nhóm', en: 'Groups'),
                      isSelected: !_isStudentPerspective,
                      onTap: () => setState(() => _isStudentPerspective = false),
                      colors: colors,
                    ),
                    _buildPerspectiveTab(
                      label: AppLocalizations.text('Sinh viên', en: 'Students'),
                      isSelected: _isStudentPerspective,
                      onTap: () => setState(() => _isStudentPerspective = true),
                      colors: colors,
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
                          '${(activeRatio * 100).toInt()}%',
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
                      count: activeApproved,
                      total: activeTotal,
                      unit: _isStudentPerspective ? 'SV' : 'nhóm',
                      color: const Color(0xFF10B981),
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                      label: AppLocalizations.text('Chờ duyệt', en: 'Pending'),
                      count: activePending,
                      total: activeTotal,
                      unit: _isStudentPerspective ? 'SV' : 'nhóm',
                      color: const Color(0xFFF59E0B),
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                      label: AppLocalizations.text('Chưa có đề tài', en: 'Unassigned'),
                      count: activeUnregistered,
                      total: activeTotal,
                      unit: _isStudentPerspective ? 'SV' : 'nhóm',
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

  Widget _buildPerspectiveTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required String label,
    required int count,
    required int total,
    required String unit,
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
          '$count $unit ($pct%)',
          style: TextStyle(
            fontSize: 12,
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
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: Color(0xFF8B5CF6),
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
                        'So sánh tỷ lệ chốt đề tài & ghép nhóm giữa các lớp',
                        en: 'Compare finalization & group rates across classes',
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
                .where((g) => g.courseId == course.id || g.courseId == course.courseId)
                .toList();
            final courseGroupIds = courseGroups.map((g) => g.id).toSet();
            final courseTopics = allTopics
                .where((t) => t.courseId == course.id || t.courseId == course.courseId)
                .toList();
            final courseApprovedGids = approvedRegs
                .where((r) => courseGroupIds.contains(r.groupId))
                .map((r) => r.groupId)
                .toSet();
            final courseApprovedCount = courseApprovedGids.length;
            final courseRatio = courseGroups.isEmpty
                ? 0.0
                : (courseApprovedCount / courseGroups.length).clamp(0.0, 1.0);
            final coursePercent = (courseRatio * 100).toInt();

            // Tính số lượng SV có nhóm và có đề tài cho lớp này
            final courseStudentsWithGroup = courseGroups.fold<int>(
              0,
              (sum, g) => sum + math.max(g.memberCount, g.members.length),
            );
            final courseStudentsWithApprovedTopic = courseGroups
                .where((g) => courseApprovedGids.contains(g.id))
                .fold<int>(0, (sum, g) => sum + math.max(g.memberCount, g.members.length));
            final courseStudentTopicPct = course.studentCount > 0
                ? ((courseStudentsWithApprovedTopic / course.studentCount) * 100).toInt()
                : 0;
            final courseStudentGroupPct = course.studentCount > 0
                ? ((courseStudentsWithGroup / course.studentCount) * 100).toInt()
                : 0;

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
                        '$courseApprovedCount/${courseGroups.length} nhóm ($coursePercent%)',
                        style: TextStyle(
                          color: barColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SV có đề tài: $courseStudentsWithApprovedTopic/${course.studentCount} ($courseStudentTopicPct%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'SV có nhóm: $courseStudentsWithGroup/${course.studentCount} ($courseStudentGroupPct%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
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

// ============================================================
// HELPER MODELS & CUSTOM PAINTER
// ============================================================

class _BarSegment {
  final double value;
  final Color color;
  const _BarSegment({required this.value, required this.color});
}

class _ChartSegment {
  final String label;
  final double value;
  final Color color;

  const _ChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });
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
