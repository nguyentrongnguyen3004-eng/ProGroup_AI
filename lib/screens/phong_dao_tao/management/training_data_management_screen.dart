import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/governance_api_service.dart';
import 'training_add_form_screen.dart';
import 'training_import_screen.dart';

enum TrainingDataKind { courseClasses, students, lecturers, subjects }

extension TrainingDataKindLabel on TrainingDataKind {
  String label(BuildContext context) => switch (this) {
    TrainingDataKind.students => AppLocalizations.text('Sinh viên', en: 'Students'),
    TrainingDataKind.lecturers => AppLocalizations.text('Giảng viên', en: 'Lecturers'),
    TrainingDataKind.courseClasses => AppLocalizations.text('Lớp học phần', en: 'Classes'),
    TrainingDataKind.subjects => AppLocalizations.text('Môn học', en: 'Subjects'),
  };
}

class TrainingDataManagementScreen extends StatefulWidget {
  final TrainingDataKind initialKind;

  const TrainingDataManagementScreen({
    super.key,
    this.initialKind = TrainingDataKind.courseClasses,
  });

  @override
  State<TrainingDataManagementScreen> createState() => _TrainingDataManagementScreenState();
}

class _TrainingDataManagementScreenState extends State<TrainingDataManagementScreen> {
  late TrainingDataKind _kind = widget.initialKind;
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _lecturers = [];

  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        GovernanceApiService.instance.fetchCourses(),
        GovernanceApiService.instance.fetchStudents(),
        GovernanceApiService.instance.fetchLecturers(),
      ]);

      if (!mounted) return;
      setState(() {
        _courses = results[0];
        _students = results[1];
        _lecturers = results[2];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final query = _query.trim().toLowerCase();
    final canPop = ModalRoute.of(context)?.canPop == true;

    final List<Map<String, dynamic>> currentList;
    switch (_kind) {
      case TrainingDataKind.courseClasses:
        currentList = _courses.where((item) {
          if (query.isEmpty) return true;
          final code = (item['maLopHocPhan'] ?? item['MaLopHocPhan'] ?? '').toString().toLowerCase();
          final name = (item['tenLopHocPhan'] ?? item['TenLopHocPhan'] ?? item['tenHocPhan'] ?? item['TenHocPhan'] ?? '').toString().toLowerCase();
          final lecturer = (item['giangVienTen'] ?? item['GiangVienTen'] ?? '').toString().toLowerCase();
          return code.contains(query) || name.contains(query) || lecturer.contains(query);
        }).toList();
      case TrainingDataKind.students:
        currentList = _students.where((item) {
          if (query.isEmpty) return true;
          final code = (item['studentCode'] ?? item['mssv'] ?? item['MSSV'] ?? '').toString().toLowerCase();
          final name = (item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '').toString().toLowerCase();
          final email = (item['email'] ?? item['Email'] ?? '').toString().toLowerCase();
          return code.contains(query) || name.contains(query) || email.contains(query);
        }).toList();
      case TrainingDataKind.lecturers:
        currentList = _lecturers.where((item) {
          if (query.isEmpty) return true;
          final code = (item['lecturerCode'] ?? item['maGiangVien'] ?? item['MaGiangVien'] ?? '').toString().toLowerCase();
          final name = (item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '').toString().toLowerCase();
          final dept = (item['department'] ?? item['boMon'] ?? item['tenBoMon'] ?? '').toString().toLowerCase();
          return code.contains(query) || name.contains(query) || dept.contains(query);
        }).toList();
      case TrainingDataKind.subjects:
        final seen = <String>{};
        currentList = _courses.where((item) {
          final sCode = (item['maHocPhan'] ?? item['MaHocPhan'] ?? item['maLopHocPhan'] ?? '').toString();
          if (seen.contains(sCode)) return false;
          seen.add(sCode);
          if (query.isEmpty) return true;
          final name = (item['tenHocPhan'] ?? item['TenHocPhan'] ?? '').toString().toLowerCase();
          return sCode.toLowerCase().contains(query) || name.contains(query);
        }).toList();
    }

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(
                AppLocalizations.text('Quản lý Đào tạo', en: 'Academic Management'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                  onPressed: _loadAllData,
                ),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          _showActionMenu(context);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.text('Thêm / Nhập', en: 'Add / Import')),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Top Banner (Đồng bộ chuẩn Giảng viên)
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
                        Icons.school_rounded,
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
                            AppLocalizations.text('Quản lý Đào tạo', en: 'Academic Management'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.text(
                              'Dữ liệu Lớp học phần, Sinh viên & Giảng viên',
                              en: 'Manage classes, students & faculty data',
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
                      onPressed: _loadAllData,
                      tooltip: 'Tải lại',
                    ),
                  ],
                ),
              ),

            // 4-Tab KPI Selector Cards
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _TabPill(
                      label: 'Lớp HP',
                      count: _courses.length,
                      color: const Color(0xFF2563EB),
                      icon: Icons.school_rounded,
                      isSelected: _kind == TrainingDataKind.courseClasses,
                      onTap: () => setState(() => _kind = TrainingDataKind.courseClasses),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TabPill(
                      label: 'Sinh viên',
                      count: _students.length,
                      color: const Color(0xFF10B981),
                      icon: Icons.people_rounded,
                      isSelected: _kind == TrainingDataKind.students,
                      onTap: () => setState(() => _kind = TrainingDataKind.students),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TabPill(
                      label: 'Giảng viên',
                      count: _lecturers.length,
                      color: const Color(0xFF6366F1),
                      icon: Icons.badge_rounded,
                      isSelected: _kind == TrainingDataKind.lecturers,
                      onTap: () => setState(() => _kind = TrainingDataKind.lecturers),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TabPill(
                      label: 'Môn học',
                      count: _courses.length,
                      color: const Color(0xFFF59E0B),
                      icon: Icons.auto_stories_rounded,
                      isSelected: _kind == TrainingDataKind.subjects,
                      onTap: () => setState(() => _kind = TrainingDataKind.subjects),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: TextField(
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm ${_kind.label(context).toLowerCase()}...',
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

            // List Content
            Expanded(
              child: _buildListContent(currentList, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(List<Map<String, dynamic>> currentList, ColorScheme colors) {
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
                onPressed: _loadAllData,
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

    if (currentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Không có dữ liệu phù hợp.',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: currentList.length,
        itemBuilder: (context, index) {
          final item = currentList[index];
          return _buildItemCard(item, colors);
        },
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, ColorScheme colors) {
    final String title;
    final String subtitle;
    final String tag1;
    final String? tag2;
    final IconData icon;
    final Color color;

    switch (_kind) {
      case TrainingDataKind.courseClasses:
        title = item['tenLopHocPhan'] ?? item['TenLopHocPhan'] ?? item['tenHocPhan'] ?? 'Lớp học phần';
        subtitle = 'GV: ${item['giangVienTen'] ?? item['GiangVienTen'] ?? 'Chưa phân công'}';
        tag1 = item['maLopHocPhan'] ?? item['MaLopHocPhan'] ?? '';
        tag2 = 'Tối đa: ${item['soLuongToiDa'] ?? 45} SV';
        icon = Icons.school_rounded;
        color = const Color(0xFF2563EB);
      case TrainingDataKind.students:
        title = item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? 'Sinh viên';
        subtitle = 'Email: ${item['email'] ?? item['Email'] ?? 'Chưa có'}';
        tag1 = item['studentCode'] ?? item['mssv'] ?? item['MSSV'] ?? '';
        tag2 = 'Lớp: ${item['classCode'] ?? item['maLop'] ?? 'CNTT'}';
        icon = Icons.people_rounded;
        color = const Color(0xFF10B981);
      case TrainingDataKind.lecturers:
        title = item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? 'Giảng viên';
        subtitle = 'Bộ môn: ${item['department'] ?? item['boMon'] ?? 'Công nghệ phần mềm'}';
        tag1 = item['lecturerCode'] ?? item['maGiangVien'] ?? item['MaGiangVien'] ?? '';
        tag2 = item['email'] ?? item['Email'];
        icon = Icons.badge_rounded;
        color = const Color(0xFF6366F1);
      case TrainingDataKind.subjects:
        title = item['tenHocPhan'] ?? item['TenHocPhan'] ?? item['tenLopHocPhan'] ?? 'Học phần';
        subtitle = 'Hệ số tín chỉ: ${item['soTinChi'] ?? 3} TC';
        tag1 = item['maHocPhan'] ?? item['MaHocPhan'] ?? '';
        tag2 = 'Bắt buộc';
        icon = Icons.auto_stories_rounded;
        color = const Color(0xFFF59E0B);
    }

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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag1,
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: colors.onSurface),
                        ),
                      ),
                      if (tag2 != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag2,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
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
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: Color(0xFF2563EB)),
                  ),
                  title: const Text('Thêm thủ công', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tạo mới lớp học phần hoặc hồ sơ'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TrainingAddFormScreen(kind: _kind)),
                    ).then((_) => _loadAllData());
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.file_upload_rounded, color: Color(0xFF10B981)),
                  ),
                  title: const Text('Nhập từ Excel / CSV', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tải lên danh sách hàng loạt'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TrainingImportScreen()),
                    ).then((_) => _loadAllData());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.14) : colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : colors.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
