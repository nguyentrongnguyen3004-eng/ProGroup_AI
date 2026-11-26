import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/governance_api_service.dart';

class GovernanceCourseScreen extends StatefulWidget {
  final bool showAppBar;
  const GovernanceCourseScreen({super.key, this.showAppBar = true});

  @override
  State<GovernanceCourseScreen> createState() => _GovernanceCourseScreenState();
}

class _GovernanceCourseScreenState extends State<GovernanceCourseScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _courses = [];
  String _query = '';
  String _semesterFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    GovernanceApiService.instance.dataVersion.addListener(_onDataChanged);
    _loadCourses();
  }

  @override
  void dispose() {
    GovernanceApiService.instance.dataVersion.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _loadCourses(forceRefresh: true);
  }

  Future<void> _loadCourses({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await GovernanceApiService.instance.fetchCourses(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _courses = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải danh sách lớp học phần: $e';
        _isLoading = false;
      });
    }
  }

  String _courseSemester(Map<String, dynamic> c) {
    final hk = (c['tenHocKy'] ?? c['TenHocKy'] ?? '').toString().trim();
    final nh = (c['namHoc'] ?? c['NamHoc'] ?? '').toString().trim();
    return '$hk $nh'.trim();
  }

  String _courseLecturer(Map<String, dynamic> c) {
    final gvs = c['giangViens'] as List? ?? [];
    if (gvs.isNotEmpty && gvs.first is Map) {
      final name = (gvs.first['hoTen'] ?? gvs.first['HoTen'] ?? '').toString().trim();
      if (name.isNotEmpty) return name;
    }
    final ten = (c['giangVienTen'] ?? c['GiangVienTen'] ?? '').toString().trim();
    return ten.isNotEmpty ? ten : 'Chưa phân công';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canPop = ModalRoute.of(context)?.canPop == true;

    final semesters = _courses
        .map(_courseSemester)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final query = _query.trim().toLowerCase();
    final filteredCourses = _courses.where((course) {
      final sem = _courseSemester(course);
      if (_semesterFilter != 'Tất cả' && sem != _semesterFilter) return false;
      if (query.isEmpty) return true;
      final code = (course['maLopHocPhan'] ?? course['MaLopHocPhan'] ?? '').toString().toLowerCase();
      final maHP = (course['maHocPhan'] ?? course['MaHocPhan'] ?? '').toString().toLowerCase();
      final name = (course['tenLopHocPhan'] ?? course['TenLopHocPhan'] ?? course['tenHocPhan'] ?? course['TenHocPhan'] ?? '').toString().toLowerCase();
      final lecturer = _courseLecturer(course).toLowerCase();
      return code.contains(query) || maHP.contains(query) || name.contains(query) || lecturer.contains(query);
    }).toList();

    return Scaffold(
      appBar: (widget.showAppBar && canPop)
          ? AppBar(
              title: Text(
                AppLocalizations.text('Lớp học phần khoa', en: 'Faculty Course Classes'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => _loadCourses(forceRefresh: true),
                  tooltip: 'Tải lại',
                ),
              ],
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: () => _loadCourses(forceRefresh: true),
          color: const Color(0xFF2563EB),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!canPop || !widget.showAppBar)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.text('Lớp học phần', en: 'Course Classes'),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
                        onPressed: () => _loadCourses(forceRefresh: true),
                        tooltip: 'Tải lại',
                      ),
                    ],
                  ),
                ),

              // Search Box
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  onChanged: (val) => setState(() => _query = val),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.text(
                      'Tìm mã lớp, mã môn, học phần hoặc giảng viên...',
                      en: 'Search class, course code or lecturer...',
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB)),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
              ),

              if (semesters.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _semesterChip('Tất cả'),
                      ...semesters.map(_semesterChip),
                    ],
                  ),
                ),

              // Total count pill
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tổng cộng: ${filteredCourses.length} lớp',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _buildBody(filteredCourses, colors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _semesterChip(String value) {
    final isSelected = _semesterFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(value == 'Tất cả' ? 'Tất cả học kỳ' : value),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (_) => setState(() => _semesterFilter = value),
      ),
    );
  }

  Widget _buildBody(List<Map<String, dynamic>> filteredCourses, ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadCourses(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
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

    if (filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.text('Không tìm thấy lớp học phần nào.', en: 'No course classes found.'),
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final c = filteredCourses[index];
        final rawId = c['lopHocPhanId'] ?? c['LopHocPhanId'] ?? c['id'];
        final id = rawId is int ? rawId : int.tryParse('$rawId');
        final code = c['maLopHocPhan'] ?? c['MaLopHocPhan'] ?? '';
        final name = c['tenLopHocPhan'] ?? c['TenLopHocPhan'] ?? c['tenHocPhan'] ?? c['TenHocPhan'] ?? 'Lớp học phần';
        final lecturer = _courseLecturer(c);
        final isAssigned = lecturer != 'Chưa phân công';
        final maxStudents = c['soLuongToiDa'] ?? c['SoLuongToiDa'] ?? 45;
        final studentCount = c['soSinhVien'] ?? c['soLuongSinhVien'] ?? c['studentCount'] ?? 0;
        final groupCount = c['soNhom'] ?? c['SoNhom'] ?? 0;
        final semester = _courseSemester(c);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showCourseDetailDialog(c, id),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.school_rounded, color: Color(0xFF6366F1), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isAssigned ? Icons.person_outline : Icons.warning_amber_rounded,
                                size: 14,
                                color: isAssigned ? const Color(0xFF059669) : const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'GV: $lecturer',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: isAssigned ? colors.onSurfaceVariant : const Color(0xFFD97706),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (semester.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              semester,
                              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$code',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Sĩ số: $studentCount / $maxStudents',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$groupCount nhóm',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCourseDetailDialog(Map<String, dynamic> course, int? id) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CourseDetailSheet(
        course: course,
        courseId: id,
        lecturerName: _courseLecturer(course),
      ),
    );
  }
}

class _CourseDetailSheet extends StatefulWidget {
  final Map<String, dynamic> course;
  final int? courseId;
  final String lecturerName;

  const _CourseDetailSheet({
    required this.course,
    required this.courseId,
    required this.lecturerName,
  });

  @override
  State<_CourseDetailSheet> createState() => _CourseDetailSheetState();
}

class _CourseDetailSheetState extends State<_CourseDetailSheet> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail({bool forceRefresh = false}) async {
    final id = widget.courseId;
    if (id == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        GovernanceApiService.instance.fetchClassStudents(id, forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchClassGroups(id, forceRefresh: forceRefresh),
      ]);
      if (!mounted) return;
      setState(() {
        _students = results[0];
        _groups = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải chi tiết lớp học phần: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.course['tenLopHocPhan'] ??
        widget.course['TenLopHocPhan'] ??
        widget.course['tenHocPhan'] ??
        'Lớp học phần';
    final code = widget.course['maLopHocPhan'] ?? widget.course['MaLopHocPhan'] ?? '';

    return DefaultTabController(
      length: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.86,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mã lớp: $code  ·  GV: ${widget.lecturerName}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Tải lại',
                    onPressed: () => _loadDetail(forceRefresh: true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            TabBar(
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF2563EB),
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Sinh viên (${_students.length})'),
                Tab(text: 'Nhóm & Đề tài (${_groups.length})'),
              ],
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
                                const SizedBox(height: 8),
                                Text(_error!, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _loadDetail(forceRefresh: true),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : TabBarView(
                          children: [
                            _buildStudentsTab(),
                            _buildGroupsTab(),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    if (_students.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.text('Lớp chưa có sinh viên đăng ký.', en: 'No students enrolled.'),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _students.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final s = _students[idx];
        final sName = (s['hoTen'] ?? s['HoTen'] ?? 'Sinh viên').toString();
        final mssv = (s['mssv'] ?? s['MSSV'] ?? '—').toString();
        final email = (s['email'] ?? s['Email'] ?? '—').toString();
        final phone = (s['soDienThoai'] ?? '').toString().trim();
        final lopNC = (s['lopNienChe'] ?? s['LopNienChe'] ?? '—').toString();
        final trangThai = (s['trangThai'] ?? s['TrangThai'] ?? 'Đang học').toString();
        final daCoNhom = s['daCoNhom'] == true;
        final tenNhom = (s['tenNhom'] ?? 'Chưa có nhóm').toString();
        final tenDeTai = (s['tenDeTai'] ?? 'Chưa đăng ký đề tài').toString();

        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  child: Text(
                    sName.isNotEmpty ? sName[0].toUpperCase() : 'S',
                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: trangThai == 'Đang học'
                                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              trangThai,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: trangThai == 'Đang học' ? const Color(0xFF059669) : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MSSV: $mssv  ·  Lớp: $lopNC',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 12, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: daCoNhom
                                  ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                                  : Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tenNhom,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: daCoNhom ? const Color(0xFF2563EB) : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                          if (daCoNhom)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: s['daCoDeTai'] == true
                                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tenDeTai,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: s['daCoDeTai'] == true ? const Color(0xFF059669) : Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    if (_groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Chưa có nhóm đồ án nào trong lớp học phần này.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final g = _groups[idx];
        final gName = (g['tenNhom'] ?? 'Nhóm đồ án').toString();
        final membersList = (g['thanhViens'] as List? ?? []);
        final membersCount = (g['thanhVienCount'] as int?) ?? membersList.length;
        final truong = (g['truongNhom'] ?? '—').toString();
        final deTai = g['deTai'] as Map?;
        final pendingDeTai = g['pendingDeTai'] as Map?;
        final tenDeTai = deTai?['tenDeTai'] ?? pendingDeTai?['tenDeTai'] ?? g['tenDeTai'];
        final trangThaiDeTai = (g['trangThaiDeTai'] ?? '').toString();
        final isGV = (deTai?['doGiangVienDeXuat'] ?? pendingDeTai?['doGiangVienDeXuat']) == true;
        final gvHD = (deTai?['giangVien'] ?? pendingDeTai?['giangVien'] ?? '').toString();
        final isApproved = deTai != null;
        final isPending = pendingDeTai != null && deTai == null;
        final isRejected = !isApproved && !isPending && trangThaiDeTai == 'Từ chối';

        Color borderColor;
        Color badgeColor;
        Color badgeText;
        String badgeLabel;
        if (isApproved) {
          borderColor = const Color(0xFF10B981).withValues(alpha: 0.5);
          badgeColor = const Color(0xFF10B981).withValues(alpha: 0.12);
          badgeText = const Color(0xFF059669);
          badgeLabel = 'Đã duyệt đề tài';
        } else if (isPending) {
          borderColor = const Color(0xFFD97706).withValues(alpha: 0.5);
          badgeColor = Colors.amber.withValues(alpha: 0.14);
          badgeText = const Color(0xFFD97706);
          badgeLabel = 'Chờ duyệt';
        } else if (isRejected) {
          borderColor = const Color(0xFFEF4444).withValues(alpha: 0.45);
          badgeColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
          badgeText = const Color(0xFFEF4444);
          badgeLabel = 'Bị từ chối';
        } else {
          borderColor = Colors.grey.shade300;
          badgeColor = Colors.grey.withValues(alpha: 0.12);
          badgeText = Colors.grey.shade700;
          badgeLabel = 'Chưa có đề tài';
        }

        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$gName ($membersCount thành viên)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Color(0xFF1E3A5F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Trưởng nhóm: $truong',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                if (membersList.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: membersList.map((m) {
                      final mName = (m['hoTen'] ?? '').toString();
                      final mCode = (m['mssv'] ?? '').toString();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mCode.isNotEmpty ? '$mName ($mCode)' : mName,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                if (tenDeTai != null && tenDeTai.toString().isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.topic_outlined, size: 15, color: Color(0xFF2563EB)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Đề tài: $tenDeTai',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (gvHD.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isGV ? Icons.school_outlined : Icons.person_outline,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${isGV ? "GV đề xuất" : "SV đề xuất"} · GVHD: $gvHD',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else
                  Text(
                    'Nhóm chưa đăng ký đề tài',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
