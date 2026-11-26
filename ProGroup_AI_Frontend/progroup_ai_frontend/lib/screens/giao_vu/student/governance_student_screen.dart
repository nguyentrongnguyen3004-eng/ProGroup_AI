import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/governance_student_model.dart';
import '../../../services/governance_api_service.dart';
import '../main/governance_add_form_screen.dart';
import '../tools/governance_import_screen.dart';

class GovernanceStudentScreen extends StatefulWidget {
  final bool showAppBar;
  const GovernanceStudentScreen({super.key, this.showAppBar = true});

  @override
  State<GovernanceStudentScreen> createState() => _GovernanceStudentScreenState();
}

class _GovernanceStudentScreenState extends State<GovernanceStudentScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<GovernanceStudentModel> _students = [];
  final Map<int, String> _facultyMap = {};
  String _query = '';
  String _classFilter = 'Tất cả';
  String _selectedCohort = 'Tất cả';
  String _facultyFilter = 'CNTT';

  @override
  void initState() {
    super.initState();
    GovernanceApiService.instance.dataVersion.addListener(_onDataChanged);
    _loadStudents();
  }

  @override
  void dispose() {
    GovernanceApiService.instance.dataVersion.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _loadStudents(forceRefresh: true);
  }

  Future<void> _loadStudents({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawList = await GovernanceApiService.instance.fetchStudents(
        forceRefresh: forceRefresh,
      );
      _facultyMap.clear();
      final parsed = rawList.map((item) {
        final idRaw = item['id'] ?? item['sinhVienId'] ?? item['SinhVienId'] ?? 0;
        final id = idRaw is int ? idRaw : int.tryParse('$idRaw') ?? 0;
        final code = (item['studentCode'] ?? item['mssv'] ?? item['MSSV'] ?? '').toString().trim();
        final rawClass = (item['lopNienChe'] ?? item['LopNienChe'] ?? item['classCode'] ?? item['lop'] ?? item['maLop'] ?? '').toString().trim();
        final maKhoa = (item['maKhoa'] ?? item['MaKhoa'] ?? 'CNTT').toString().trim();
        final tenKhoa = (item['tenKhoa'] ?? item['TenKhoa'] ?? 'Công nghệ thông tin').toString().trim();
        _facultyMap[id] = maKhoa.isNotEmpty ? maKhoa : tenKhoa;

        var cohort = (item['khoaHoc'] ?? item['KhoaHoc'] ?? '').toString().trim();
        if (cohort.isEmpty) {
          if (code.startsWith('20') || rawClass.contains('20')) {
            cohort = 'K20';
          } else if (code.startsWith('21') || rawClass.contains('21')) {
            cohort = 'K21';
          } else if (code.startsWith('22') || rawClass.contains('22')) {
            cohort = 'K22';
          } else if (code.startsWith('23') || rawClass.contains('23')) {
            cohort = 'K23';
          } else {
            cohort = 'K21';
          }
        }

        final phone = (item['soDienThoai'] ?? item['SoDienThoai'] ?? item['phone'] ?? '').toString().trim();

        return GovernanceStudentModel(
          id: id,
          studentCode: code,
          fullName: (item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '').toString().trim(),
          email: (item['email'] ?? item['Email'] ?? '').toString().trim(),
          phone: phone,
          classCode: rawClass.isNotEmpty ? rawClass : '${maKhoa.isEmpty ? "CNTT" : maKhoa}_$cohort',
          status: (item['status'] ?? (item['trangThai'] == false ? 'Đã nghỉ' : 'Đang học')).toString(),
          cohort: cohort,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _students = parsed;
        if (_facultyFilter == 'CNTT' &&
            !_facultyMap.values.any((f) => f.toUpperCase() == 'CNTT')) {
          _facultyFilter = 'Tất cả';
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải danh sách sinh viên: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final faculties = _facultyMap.values
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final facultyScopedStudents = _facultyFilter == 'Tất cả'
        ? _students
        : _students.where((s) {
            final f = (_facultyMap[s.id] ?? '').toUpperCase();
            return f == _facultyFilter.toUpperCase();
          }).toList();

    final classes = facultyScopedStudents
        .map((s) => s.classCode)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final query = _query.trim().toLowerCase();
    final filtered = facultyScopedStudents.where((student) {
      final matchesQuery = query.isEmpty ||
          student.studentCode.toLowerCase().contains(query) ||
          student.fullName.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.phone.toLowerCase().contains(query) ||
          student.classCode.toLowerCase().contains(query);

      final matchesClass = _classFilter == 'Tất cả' || student.classCode == _classFilter;
      final matchesCohort = _selectedCohort == 'Tất cả' || student.cohort == _selectedCohort;

      return matchesQuery && matchesClass && matchesCohort;
    }).toList();

    final canPop = ModalRoute.of(context)?.canPop == true;

    return Scaffold(
      appBar: (widget.showAppBar && canPop)
          ? AppBar(
              title: Text(
                AppLocalizations.text('Quản lý sinh viên', en: 'Manage Students'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                  onPressed: () => _loadStudents(forceRefresh: true),
                ),
              ],
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final ok = await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) => const GovernanceAddFormScreen(
                              kind: GovernanceAddKind.student,
                            ),
                          ),
                        );
                        if (ok == true) _loadStudents(forceRefresh: true);
                      },
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                      label: Text(
                        AppLocalizations.text('Thêm sinh viên', en: 'Add Student'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const GovernanceImportScreen(
                              initialKind: GovernanceImportKind.students,
                            ),
                          ),
                        );
                        _loadStudents(forceRefresh: true);
                      },
                      icon: const Icon(Icons.upload_file_outlined, size: 18, color: Color(0xFF2563EB)),
                      label: Text(
                        AppLocalizations.text('Nhập dữ liệu', en: 'Import Data'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: AppLocalizations.text(
                    'Tìm theo MSSV, họ tên, email hoặc SĐT',
                    en: 'Search by ID, name, email or phone',
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  ),
                ),
              ),
            ),
            if (faculties.length > 1)
              SizedBox(
                height: 40,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _facultyChip('CNTT'),
                    _facultyChip('Tất cả'),
                    ...faculties.where((f) => f.toUpperCase() != 'CNTT').map(_facultyChip),
                  ],
                ),
              ),
            // Lọc Khóa niên chế (K20, K21, K22, K23)
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _cohortChip('Tất cả'),
                  _cohortChip('K20'),
                  _cohortChip('K21'),
                  _cohortChip('K22'),
                  _cohortChip('K23'),
                ],
              ),
            ),
            if (classes.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Tất cả'),
                    ...classes.map(_filterChip),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Hiển thị ${filtered.length} sinh viên',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildStudentList(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _facultyChip(String value) {
    final isSelected = _facultyFilter == value;
    final label = value == 'Tất cả' ? 'Tất cả khoa' : 'Khoa $value';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (_) => setState(() {
          _facultyFilter = value;
          _classFilter = 'Tất cả';
        }),
      ),
    );
  }

  Widget _cohortChip(String value) {
    final isSelected = _selectedCohort == value;
    final label = value == 'Tất cả' ? 'Tất cả khóa' : 'Khóa $value';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF10B981).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF059669) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (_) => setState(() => _selectedCohort = value),
      ),
    );
  }

  Widget _filterChip(String value) {
    final isSelected = _classFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(value == 'Tất cả' ? 'Tất cả lớp' : value),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (_) => setState(() => _classFilter = value),
      ),
    );
  }

  Widget _buildStudentList(List<GovernanceStudentModel> list) {
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
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadStudents(forceRefresh: true),
                icon: const Icon(Icons.refresh),
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

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadStudents(forceRefresh: true),
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
                    Icon(Icons.people_outline, size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.text('Chưa có dữ liệu sinh viên', en: 'No students found'),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadStudents(forceRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final student = list[index];
          final phoneDisplay = student.phone.isNotEmpty ? student.phone : 'Chưa cập nhật';

          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_outline, color: Color(0xFF2563EB), size: 24),
              ),
              title: Text(
                student.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A5F)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    'MSSV: ${student.studentCode} · Lớp: ${student.classCode.isNotEmpty ? student.classCode : "—"} · ${student.cohort}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 13, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.email.isNotEmpty ? student.email : '—',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: student.phone.isNotEmpty ? const Color(0xFF10B981) : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        phoneDisplay,
                        style: TextStyle(
                          color: student.phone.isNotEmpty ? const Color(0xFF10B981) : Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: student.phone.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GovernanceStudentDetailScreen(
                      student: student,
                      faculty: _facultyMap[student.id] ?? 'CNTT',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class GovernanceStudentDetailScreen extends StatelessWidget {
  final GovernanceStudentModel student;
  final String faculty;

  const GovernanceStudentDetailScreen({
    super.key,
    required this.student,
    this.faculty = 'CNTT',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết sinh viên', en: 'Student Details'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
          children: [
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.person_outline, size: 36, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student.fullName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MSSV: ${student.studentCode}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 28),
                    _detailRow('MSSV', student.studentCode),
                    _detailRow('Lớp niên chế', student.classCode.isNotEmpty ? student.classCode : '—'),
                    _detailRow('Khóa học', student.cohort),
                    _detailRow('Khoa', faculty),
                    _detailRow('Email', student.email.isNotEmpty ? student.email : '—'),
                    _detailRow('Số điện thoại', student.phone.isNotEmpty ? student.phone : 'Chưa cập nhật'),
                    _detailRow('Trạng thái', student.status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
