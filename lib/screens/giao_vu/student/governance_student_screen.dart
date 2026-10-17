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
  String _query = '';
  String _classFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawList = await GovernanceApiService.instance.fetchStudents();
      final parsed = rawList.map((item) {
        return GovernanceStudentModel(
          id: item['id'] ?? item['sinhVienId'] ?? item['SinhVienId'] ?? 0,
          studentCode: (item['studentCode'] ?? item['mssv'] ?? item['MSSV'] ?? '').toString(),
          fullName: (item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '').toString(),
          email: (item['email'] ?? item['Email'] ?? '').toString(),
          classCode: (item['classCode'] ?? item['lop'] ?? item['maLop'] ?? '').toString(),
          status: (item['status'] ?? (item['trangThai'] == false ? 'Đã nghỉ' : 'Đang học')).toString(),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _students = parsed;
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
    final classes = _students
        .map((s) => s.classCode)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final query = _query.trim().toLowerCase();
    final filtered = _students.where((student) {
      final matchesQuery = query.isEmpty ||
          student.studentCode.toLowerCase().contains(query) ||
          student.fullName.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.classCode.toLowerCase().contains(query);

      final matchesClass = _classFilter == 'Tất cả' || student.classCode == _classFilter;

      return matchesQuery && matchesClass;
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
                  onPressed: _loadStudents,
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
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GovernanceAddFormScreen(
                            kind: GovernanceAddKind.student,
                          ),
                        ),
                      ),
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
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GovernanceImportScreen(
                            initialKind: GovernanceImportKind.students,
                          ),
                        ),
                      ),
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
                    'Tìm theo MSSV, họ tên hoặc email',
                    en: 'Search by ID, name or email',
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
            if (classes.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Tất cả'),
                    ...classes.map(_filterChip),
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

  Widget _filterChip(String value) {
    final isSelected = _classFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(value),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB).withOpacity(0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                onPressed: _loadStudents,
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
        onRefresh: _loadStudents,
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
      onRefresh: _loadStudents,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final student = list[index];
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
                  color: const Color(0xFF2563EB).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_outline, color: Color(0xFF2563EB), size: 24),
              ),
              title: Text(
                student.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A5F)),
              ),
              subtitle: Text(
                '${student.studentCode} · ${student.classCode.isNotEmpty ? student.classCode : "Chưa có lớp"}\n${student.email}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GovernanceStudentDetailScreen(student: student),
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

  const GovernanceStudentDetailScreen({super.key, required this.student});

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
                        color: const Color(0xFF2563EB).withOpacity(0.12),
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
                      student.studentCode,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 28),
                    _detailRow('Email', student.email),
                    _detailRow('Lớp sinh hoạt', student.classCode.isNotEmpty ? student.classCode : '—'),
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
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
