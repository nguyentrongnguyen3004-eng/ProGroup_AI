import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await GovernanceApiService.instance.fetchCourses();
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canPop = ModalRoute.of(context)?.canPop == true;

    final query = _query.trim().toLowerCase();
    final filteredCourses = _courses.where((course) {
      if (query.isEmpty) return true;
      final code = (course['maLopHocPhan'] ?? course['MaLopHocPhan'] ?? '').toString().toLowerCase();
      final name = (course['tenLopHocPhan'] ?? course['TenLopHocPhan'] ?? course['tenHocPhan'] ?? course['TenHocPhan'] ?? '').toString().toLowerCase();
      final lecturer = (course['giangVienTen'] ?? course['GiangVienTen'] ?? '').toString().toLowerCase();
      return code.contains(query) || name.contains(query) || lecturer.contains(query);
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
                  onPressed: _loadCourses,
                  tooltip: 'Tải lại',
                ),
              ],
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _loadCourses,
          color: const Color(0xFF2563EB),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title if root tab
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
                        onPressed: _loadCourses,
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
                      'Tìm mã lớp, học phần hoặc giảng viên...',
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

              // Total count pill
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              const SizedBox(height: 6),

              Expanded(
                child: _buildBody(filteredCourses, colors),
              ),
            ],
          ),
        ),
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
                onPressed: _loadCourses,
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
        final id = c['lopHocPhanId'] ?? c['LopHocPhanId'] ?? c['id'];
        final code = c['maLopHocPhan'] ?? c['MaLopHocPhan'] ?? '';
        final name = c['tenLopHocPhan'] ?? c['TenLopHocPhan'] ?? c['tenHocPhan'] ?? c['TenHocPhan'] ?? 'Lớp học phần';
        final lecturer = c['giangVienTen'] ?? c['GiangVienTen'] ?? 'Chưa phân công';
        final maxStudents = c['soLuongToiDa'] ?? c['SoLuongToiDa'] ?? 45;
        final studentCount = c['soLuongSinhVien'] ?? c['studentCount'] ?? 0;

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
                            name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Giảng viên: $lecturer',
                            style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
                          ),
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
                                  code,
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

  void _showCourseDetailDialog(Map<String, dynamic> course, dynamic id) async {
    final name = course['tenLopHocPhan'] ?? course['TenLopHocPhan'] ?? 'Lớp học phần';
    final code = course['maLopHocPhan'] ?? course['MaLopHocPhan'] ?? '';

    List<dynamic> students = [];
    bool loadingStudents = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (loadingStudents) {
              if (id != null) {
                ApiService.instance.get('/api/lop-hoc-phan/$id/sinh-vien').then((data) {
                  if (data is List) {
                    setModalState(() {
                      students = data;
                      loadingStudents = false;
                    });
                  } else {
                    setModalState(() => loadingStudents = false);
                  }
                }).catchError((_) {
                  setModalState(() => loadingStudents = false);
                });
              } else {
                loadingStudents = false;
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
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
                                name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Mã lớp: $code • Danh sách sinh viên',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: loadingStudents
                        ? const Center(child: CircularProgressIndicator())
                        : students.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.text('Lớp chưa có sinh viên đăng ký.', en: 'No students enrolled.'),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                itemCount: students.length,
                                itemBuilder: (context, idx) {
                                  final s = students[idx];
                                  final sName = s['hoTen'] ?? s['HoTen'] ?? 'Sinh viên';
                                  final mssv = s['mssv'] ?? s['MSSV'] ?? '';

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                      child: Text(
                                        sName.isNotEmpty ? sName[0] : 'S',
                                        style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(sName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    subtitle: Text('MSSV: $mssv', style: const TextStyle(fontSize: 12)),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
