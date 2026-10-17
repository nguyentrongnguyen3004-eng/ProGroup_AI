import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/lecturer_model.dart';
import '../../../services/governance_api_service.dart';
import '../main/governance_add_form_screen.dart';
import '../tools/governance_import_screen.dart';

class GovernanceLecturerScreen extends StatefulWidget {
  final bool showAppBar;
  const GovernanceLecturerScreen({super.key, this.showAppBar = true});

  @override
  State<GovernanceLecturerScreen> createState() => _GovernanceLecturerScreenState();
}

class _GovernanceLecturerScreenState extends State<GovernanceLecturerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<LecturerModel> _lecturers = [];
  String _query = '';
  String _facultyFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadLecturers();
  }

  Future<void> _loadLecturers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawList = await GovernanceApiService.instance.fetchLecturers();
      final parsed = rawList.map((item) {
        return LecturerModel(
          id: item['id'] ?? item['giangVienId'] ?? item['GiangVienId'] ?? 0,
          lecturerCode: (item['lecturerCode'] ?? item['maGiangVien'] ?? item['MaGiangVien'] ?? '').toString(),
          fullName: (item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '').toString(),
          email: (item['email'] ?? item['Email'] ?? '').toString(),
          faculty: (item['faculty'] ?? item['khoa'] ?? item['tenKhoa'] ?? 'Khoa Công nghệ thông tin').toString(),
          department: (item['department'] ?? item['boMon'] ?? item['tenBoMon'] ?? 'Công nghệ phần mềm').toString(),
          avatar: (item['avatar'] ?? '').toString(),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _lecturers = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải danh sách giảng viên: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final faculties = _lecturers
        .map((item) => item.faculty)
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final query = _query.trim().toLowerCase();
    final filtered = _lecturers.where((lecturer) {
      final matchesQuery = query.isEmpty ||
          lecturer.lecturerCode.toLowerCase().contains(query) ||
          lecturer.fullName.toLowerCase().contains(query) ||
          lecturer.email.toLowerCase().contains(query) ||
          lecturer.faculty.toLowerCase().contains(query) ||
          lecturer.department.toLowerCase().contains(query);

      final matchesFaculty = _facultyFilter == 'Tất cả' || lecturer.faculty == _facultyFilter;
      return matchesQuery && matchesFaculty;
    }).toList();

    final canPop = ModalRoute.of(context)?.canPop == true;

    return Scaffold(
      appBar: (widget.showAppBar && canPop)
          ? AppBar(
              title: Text(
                AppLocalizations.text('Quản lý giảng viên', en: 'Manage Lecturers'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                  onPressed: _loadLecturers,
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
                            kind: GovernanceAddKind.lecturer,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                      label: Text(
                        AppLocalizations.text('Thêm giảng viên', en: 'Add Lecturer'),
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
                            initialKind: GovernanceImportKind.lecturers,
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
                    'Tìm theo mã GV, họ tên, bộ môn...',
                    en: 'Search by ID, name, department...',
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
            if (faculties.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Tất cả'),
                    ...faculties.map(_filterChip),
                  ],
                ),
              ),
            Expanded(
              child: _buildLecturerList(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String value) {
    final isSelected = _facultyFilter == value;
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
        onSelected: (_) => setState(() => _facultyFilter = value),
      ),
    );
  }

  Widget _buildLecturerList(List<LecturerModel> list) {
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
                onPressed: _loadLecturers,
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
        onRefresh: _loadLecturers,
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
                    Icon(Icons.badge_outlined, size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.text('Chưa có dữ liệu giảng viên', en: 'No lecturers found'),
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
      onRefresh: _loadLecturers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final lecturer = list[index];
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
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.badge_outlined, color: Color(0xFF7C3AED), size: 24),
              ),
              title: Text(
                lecturer.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A5F)),
              ),
              subtitle: Text(
                '${lecturer.lecturerCode} · ${lecturer.department}\n${lecturer.email}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GovernanceLecturerDetailScreen(lecturer: lecturer),
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

class GovernanceLecturerDetailScreen extends StatelessWidget {
  final LecturerModel lecturer;

  const GovernanceLecturerDetailScreen({super.key, required this.lecturer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết giảng viên', en: 'Lecturer Details'),
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
                        color: const Color(0xFF7C3AED).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.badge_outlined, size: 36, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lecturer.fullName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lecturer.lecturerCode,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 28),
                    _detailRow('Email', lecturer.email),
                    _detailRow('Khoa', lecturer.faculty),
                    _detailRow('Bộ môn', lecturer.department),
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
