import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/governance_api_service.dart';

class GovernanceAssignmentScreen extends StatefulWidget {
  final int? initialCourseId;

  const GovernanceAssignmentScreen({super.key, this.initialCourseId});

  @override
  State<GovernanceAssignmentScreen> createState() => _GovernanceAssignmentScreenState();
}

class _GovernanceAssignmentScreenState extends State<GovernanceAssignmentScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _lecturers = [];
  List<Map<String, dynamic>> _assignments = [];

  int? _selectedCourseId;
  int? _selectedLecturerId;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.initialCourseId;
    _loadData();
  }

  int? _courseIdOf(Map<String, dynamic> c) {
    final raw = c['lopHocPhanId'] ?? c['LopHocPhanId'] ?? c['id'];
    return raw is int ? raw : int.tryParse('$raw');
  }

  int? _lecturerIdOf(Map<String, dynamic> l) {
    final raw = l['giangVienId'] ?? l['GiangVienId'] ?? l['id'];
    return raw is int ? raw : int.tryParse('$raw');
  }

  /// Lấy thông tin giảng viên hiện tại của một lớp học phần (ưu tiên dữ liệu assignments mới nhất)
  ({int? id, String name}) _resolveCurrentLecturer(Map<String, dynamic> course) {
    final cid = _courseIdOf(course);
    if (cid != null) {
      final activeAssign = _assignments.where((a) {
        final aCourseId = a['lopHocPhanId'] ?? a['LopHocPhanId'];
        final isActive = a['trangThai'] ?? a['TrangThai'] ?? true;
        return aCourseId == cid && isActive == true;
      }).toList();
      if (activeAssign.isNotEmpty) {
        final a = activeAssign.first;
        final gvId = a['giangVienId'] ?? a['GiangVienId'];
        final gvName = (a['hoTen'] ?? a['HoTen'] ?? '').toString().trim();
        if (gvName.isNotEmpty) {
          return (
            id: gvId is int ? gvId : int.tryParse('$gvId'),
            name: gvName,
          );
        }
      }
    }

    final gvList = course['giangViens'] as List? ?? [];
    if (gvList.isNotEmpty && gvList.first is Map) {
      final first = gvList.first as Map;
      final gvId = first['giangVienId'] ?? first['GiangVienId'];
      final gvName = (first['hoTen'] ?? first['HoTen'] ?? '').toString().trim();
      if (gvName.isNotEmpty) {
        return (
          id: gvId is int ? gvId : int.tryParse('$gvId'),
          name: gvName,
        );
      }
    }

    final rawName = (course['giangVienTen'] ?? course['GiangVienTen'] ?? '').toString().trim();
    final rawId = course['giangVienId'] ?? course['GiangVienId'];
    final parsedId = rawId is int ? rawId : int.tryParse('$rawId');
    if (rawName.isNotEmpty && rawName != 'Chưa phân công') {
      return (id: parsedId, name: rawName);
    }

    return (id: null, name: 'Chưa phân công');
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        GovernanceApiService.instance.fetchCourses(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchLecturers(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchAssignments(forceRefresh: forceRefresh),
      ]);

      if (!mounted) return;
      final courses = results[0];
      final lecturers = results[1];
      final assignments = results[2];

      setState(() {
        _courses = courses;
        _lecturers = lecturers;
        _assignments = assignments;
        final courseIds = _courses.map(_courseIdOf).whereType<int>().toSet();
        if (_selectedCourseId == null || !courseIds.contains(_selectedCourseId)) {
          _selectedCourseId = courseIds.isNotEmpty ? courseIds.first : null;
        }
        final lecturerIds = _lecturers.map(_lecturerIdOf).whereType<int>().toSet();
        if (_selectedLecturerId != null && !lecturerIds.contains(_selectedLecturerId)) {
          _selectedLecturerId = null;
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

  Future<bool> _showConfirmDialog({
    required String title,
    required IconData icon,
    required Color accentColor,
    required String message,
    required List<({String label, String value})> details,
    String? warning,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(icon, color: accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            ...details.map((d) => _confirmRow(d.label, d.value)),
            if (warning != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: accentColor),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _onAssign() async {
    if (_selectedCourseId == null || _selectedLecturerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lớp học phần và giảng viên')),
      );
      return;
    }

    final selectedCourse = _courses.firstWhere(
      (c) => _courseIdOf(c) == _selectedCourseId,
      orElse: () => _courses.first,
    );
    final selectedLecturer = _lecturers.firstWhere(
      (l) => _lecturerIdOf(l) == _selectedLecturerId,
      orElse: () => _lecturers.first,
    );

    final current = _resolveCurrentLecturer(selectedCourse);
    final isAlreadyAssignedToSame = current.id != null && current.id == _selectedLecturerId;
    if (isAlreadyAssignedToSame) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giảng viên này đã được phân công cho lớp học phần từ trước.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    final cName = selectedCourse['tenLopHocPhan'] ??
        selectedCourse['TenLopHocPhan'] ??
        selectedCourse['tenHocPhan'] ??
        '—';
    final cCode = selectedCourse['maLopHocPhan'] ?? selectedCourse['MaLopHocPhan'] ?? '—';
    final lName = selectedLecturer['fullName'] ??
        selectedLecturer['hoTen'] ??
        selectedLecturer['HoTen'] ??
        '—';
    final lCode = selectedLecturer['lecturerCode'] ??
        selectedLecturer['maGiangVien'] ??
        selectedLecturer['MaGiangVien'] ??
        '—';

    final isReassign = current.id != null;
    final confirmed = await _showConfirmDialog(
      title: isReassign ? 'Xác nhận đổi giảng viên' : 'Xác nhận phân công',
      icon: Icons.assignment_ind_rounded,
      accentColor: const Color(0xFF2563EB),
      message: isReassign
          ? 'Bạn có chắc chắn muốn đổi giảng viên phụ trách cho lớp học phần này?'
          : 'Bạn có chắc chắn muốn phân công giảng viên phụ trách lớp học phần này?',
      details: [
        (label: 'Lớp học phần', value: '$cName ($cCode)'),
        if (isReassign) (label: 'GV hiện tại', value: current.name),
        (label: isReassign ? 'GV mới' : 'Giảng viên', value: '$lName · $lCode'),
      ],
      warning: isReassign
          ? 'Phân công cũ sẽ được chuyển giao và gửi thông báo tới cả hai giảng viên.'
          : null,
      confirmLabel: isReassign ? 'Xác nhận đổi GV' : 'Xác nhận phân công',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      if (isReassign) {
        await GovernanceApiService.instance.updateAssignment(_selectedCourseId!, _selectedLecturerId!);
      } else {
        await GovernanceApiService.instance.assignLecturer(_selectedCourseId!, _selectedLecturerId!);
      }
      if (!mounted) return;
      await _loadData(forceRefresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isReassign
                ? 'Đã đổi giảng viên phụ trách thành "$lName"!'
                : 'Phân công giảng viên "$lName" thành công!',
          ),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi phân công: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _onCancelAssignment(Map<String, dynamic> course) async {
    final cid = _courseIdOf(course);
    if (cid == null) return;
    final current = _resolveCurrentLecturer(course);
    if (current.id == null) return;

    final cName = course['tenLopHocPhan'] ?? course['tenHocPhan'] ?? '—';
    final cCode = course['maLopHocPhan'] ?? '—';

    final confirmed = await _showConfirmDialog(
      title: 'Xác nhận hủy phân công',
      icon: Icons.person_remove_rounded,
      accentColor: const Color(0xFFEF4444),
      message: 'Bạn có chắc chắn muốn hủy phân công giảng viên khỏi lớp học phần này?',
      details: [
        (label: 'Lớp học phần', value: '$cName ($cCode)'),
        (label: 'Giảng viên', value: current.name),
      ],
      warning: 'Chỉ hủy được khi lớp chưa có nhóm sinh viên đăng ký đề tài.',
      confirmLabel: 'Xác nhận hủy',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await GovernanceApiService.instance.deleteAssignment(cid);
      if (!mounted) return;
      await _loadData(forceRefresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy phân công giảng viên. Lớp quay về trạng thái chưa phân công.'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
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
            onPressed: () => _loadData(forceRefresh: true),
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
                onPressed: () => _loadData(forceRefresh: true),
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
        onRefresh: () => _loadData(forceRefresh: true),
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
      (c) => _courseIdOf(c) == _selectedCourseId,
      orElse: () => _courses.first,
    );

    final courseCode = selectedCourse['maLopHocPhan'] ?? selectedCourse['MaLopHocPhan'] ?? '—';
    final courseName = selectedCourse['tenLopHocPhan'] ??
        selectedCourse['TenLopHocPhan'] ??
        selectedCourse['tenHocPhan'] ??
        selectedCourse['TenHocPhan'] ??
        '—';
    final semester = '${selectedCourse['tenHocKy'] ?? '—'} ${selectedCourse['namHoc'] ?? ''}'.trim();
    final currentLecturer = _resolveCurrentLecturer(selectedCourse);
    final isAssigned = currentLecturer.id != null;

    return RefreshIndicator(
      onRefresh: () => _loadData(forceRefresh: true),
      color: const Color(0xFF2563EB),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
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
                  final id = _courseIdOf(item);
                  final cCode = item['maLopHocPhan'] ?? item['MaLopHocPhan'] ?? '';
                  final cName = item['tenLopHocPhan'] ??
                      item['TenLopHocPhan'] ??
                      item['tenHocPhan'] ??
                      item['TenHocPhan'] ??
                      '';
                  final cur = _resolveCurrentLecturer(item);
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      '$cCode · $cName (${cur.id != null ? cur.name : "Chưa phân công"})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, color: colors.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedCourseId = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Course Info Card
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isAssigned
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : const Color(0xFFD97706).withValues(alpha: 0.4),
              ),
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
                _infoRow(colors, 'Học kỳ', semester),
                _infoRow(
                  colors,
                  'Trạng thái phân công',
                  isAssigned ? 'Đã phân công' : 'Chưa phân công',
                  valueColor: isAssigned ? const Color(0xFF059669) : const Color(0xFFD97706),
                  highlight: true,
                ),
                _infoRow(
                  colors,
                  'Giảng viên hiện tại',
                  currentLecturer.name,
                  valueColor: isAssigned ? const Color(0xFF2563EB) : const Color(0xFFD97706),
                  highlight: true,
                ),
                if (isAssigned) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : () => _onCancelAssignment(selectedCourse),
                      icon: const Icon(Icons.person_remove_outlined, size: 18, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Hủy phân công giảng viên',
                        style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lecturer Dropdown Section
          Text(
            isAssigned
                ? AppLocalizations.text('Chọn giảng viên mới (Đổi phân công)', en: 'Select New Lecturer')
                : AppLocalizations.text('Chọn giảng viên phân công', en: 'Select Lecturer'),
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
                  final id = _lecturerIdOf(item);
                  final lCode = item['lecturerCode'] ?? item['maGiangVien'] ?? item['MaGiangVien'] ?? '';
                  final lName = item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '';
                  final spec = (item['chuyenMon'] ?? '').toString().trim();
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      spec.isNotEmpty ? '$lCode · $lName ($spec)' : '$lCode · $lName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, color: colors.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedLecturerId = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

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
                _isSubmitting
                    ? 'Đang xử lý...'
                    : (isAssigned ? 'Đổi giảng viên phụ trách' : 'Xác nhận phân công'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Danh sách tình trạng phân công tất cả các lớp học phần
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tình trạng phân công các lớp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
              ),
              Text(
                '${_courses.where((c) => _resolveCurrentLecturer(c).id != null).length}/${_courses.length} lớp đã gán',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._courses.map((c) {
            final cid = _courseIdOf(c);
            final cCode = c['maLopHocPhan'] ?? '—';
            final cName = c['tenLopHocPhan'] ?? c['tenHocPhan'] ?? '—';
            final cur = _resolveCurrentLecturer(c);
            final assigned = cur.id != null;
            final isSelected = cid == _selectedCourseId;

            return Card(
              elevation: 0,
              color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.05) : Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : (assigned ? Colors.grey.shade200 : const Color(0xFFFCD34D)),
                ),
              ),
              child: ListTile(
                onTap: () => setState(() => _selectedCourseId = cid),
                leading: CircleAvatar(
                  backgroundColor: assigned
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : const Color(0xFFD97706).withValues(alpha: 0.12),
                  child: Icon(
                    assigned ? Icons.check_circle_outline : Icons.pending_outlined,
                    color: assigned ? const Color(0xFF059669) : const Color(0xFFD97706),
                    size: 20,
                  ),
                ),
                title: Text(
                  '$cCode · $cName',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  assigned ? 'GV: ${cur.name}' : 'Chưa phân công giảng viên',
                  style: TextStyle(
                    fontSize: 12,
                    color: assigned ? const Color(0xFF059669) : const Color(0xFFD97706),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: assigned
                    ? IconButton(
                        tooltip: 'Hủy phân công',
                        icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 20),
                        onPressed: _isSubmitting ? null : () => _onCancelAssignment(c),
                      )
                    : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _infoRow(
    ColorScheme colors,
    String label,
    String value, {
    bool highlight = false,
    Color? valueColor,
  }) {
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
                color: valueColor ?? (highlight ? const Color(0xFF2563EB) : colors.onSurface),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
