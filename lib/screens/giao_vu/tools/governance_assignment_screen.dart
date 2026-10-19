import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/governance_api_service.dart';

class GovernanceAssignmentScreen extends StatefulWidget {
  const GovernanceAssignmentScreen({super.key});

  @override
  State<GovernanceAssignmentScreen> createState() => _GovernanceAssignmentScreenState();
}

class _GovernanceAssignmentScreenState extends State<GovernanceAssignmentScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _lecturers = [];

  int? _selectedCourseId;
  int? _selectedLecturerId;

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
        GovernanceApiService.instance.fetchCourses(),
        GovernanceApiService.instance.fetchLecturers(),
        GovernanceApiService.instance.fetchAssignments(),
      ]);

      if (!mounted) return;
      final courses = results[0];
      final lecturers = results[1];

      setState(() {
        _courses = courses;
        _lecturers = lecturers;
        if (_courses.isNotEmpty && _selectedCourseId == null) {
          _selectedCourseId = _courses.first['lopHocPhanId'] ?? _courses.first['LopHocPhanId'];
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu phân công: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onAssign() async {
    if (_selectedCourseId == null || _selectedLecturerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lớp học phần và giảng viên')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await GovernanceApiService.instance.assignLecturer(_selectedCourseId!, _selectedLecturerId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phân công giảng viên thành công!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phân công giảng viên: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Phân công giảng viên', en: 'Assign Lecturer'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: _buildBody(colors),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
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
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
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

    if (_courses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF2563EB),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded, size: 54, color: colors.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.text('Chưa có danh sách lớp học phần', en: 'No courses available'),
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final selectedCourse = _courses.firstWhere(
      (c) => (c['lopHocPhanId'] ?? c['LopHocPhanId']) == _selectedCourseId,
      orElse: () => _courses.first,
    );

    final courseCode = selectedCourse['maLopHocPhan'] ?? selectedCourse['MaLopHocPhan'] ?? '—';
    final courseName = selectedCourse['tenLopHocPhan'] ?? selectedCourse['TenLopHocPhan'] ?? selectedCourse['tenHocPhan'] ?? selectedCourse['TenHocPhan'] ?? '—';
    final currentLecturer = selectedCourse['giangVienTen'] ?? selectedCourse['GiangVienTen'] ?? 'Chưa phân công';
    final semester = selectedCourse['tenHocKy'] ?? selectedCourse['TenHocKy'] ?? '—';

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF2563EB),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          // Hero Banner (Chuẩn Design System Template)
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.text('Phân công Giảng viên', en: 'Assign Lecturers'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.text(
                          'Chọn lớp học phần và phân công giảng viên phụ trách.',
                          en: 'Select class and assign lecturer in charge.',
                        ),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Course Dropdown Section
          Text(
            AppLocalizations.text('Chọn lớp học phần', en: 'Select Class'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedCourseId,
                isExpanded: true,
                items: _courses.map((item) {
                  final id = item['lopHocPhanId'] ?? item['LopHocPhanId'] as int;
                  final cCode = item['maLopHocPhan'] ?? item['MaLopHocPhan'] ?? '';
                  final cName = item['tenLopHocPhan'] ?? item['TenLopHocPhan'] ?? item['tenHocPhan'] ?? item['TenHocPhan'] ?? '';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      '$cCode · $cName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: colors.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedCourseId = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Course Info Card (Bo 18dp squircle style)
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(colors, 'Mã lớp học phần', '$courseCode'),
                _infoRow(colors, 'Tên học phần', '$courseName'),
                _infoRow(colors, 'Học kỳ', '$semester'),
                _infoRow(colors, 'Giảng viên hiện tại', '$currentLecturer', highlight: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lecturer Dropdown Section
          Text(
            AppLocalizations.text('Chọn giảng viên mới', en: 'Select Lecturer'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedLecturerId,
                hint: Text('Chọn giảng viên phân công', style: TextStyle(color: colors.onSurfaceVariant)),
                isExpanded: true,
                items: _lecturers.map((item) {
                  final id = item['id'] ?? item['giangVienId'] ?? item['GiangVienId'] as int;
                  final lCode = item['lecturerCode'] ?? item['maGiangVien'] ?? item['MaGiangVien'] ?? '';
                  final lName = item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      '$lCode · $lName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: colors.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedLecturerId = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _onAssign,
              icon: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded, color: Colors.white),
              label: Text(
                _isSubmitting ? 'Đang xử lý...' : 'Xác nhận phân công',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ColorScheme colors, String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight ? const Color(0xFF2563EB) : colors.onSurface,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
