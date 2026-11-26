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
  String _selectedSpec = 'Tất cả';

  @override
  void initState() {
    super.initState();
    GovernanceApiService.instance.dataVersion.addListener(_onDataChanged);
    _loadLecturers();
  }

  @override
  void dispose() {
    GovernanceApiService.instance.dataVersion.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _loadLecturers(forceRefresh: true);
  }

  String _normalizeVi(String input) {
    const withDiacritics = 'àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ';
    const withoutDiacritics = 'aaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyy';
    final lower = input.toLowerCase().trim();
    final buffer = StringBuffer();
    for (var i = 0; i < lower.length; i++) {
      final idx = withDiacritics.indexOf(lower[i]);
      buffer.write(idx >= 0 ? withoutDiacritics[idx] : lower[i]);
    }
    return buffer.toString();
  }

  bool _hasMeaningfulResearchSpec(LecturerModel lecturer) {
    final specNorm = _normalizeVi(lecturer.chuyenMon);
    if (specNorm.isEmpty) return false;
    return specNorm != '-' &&
        specNorm != '—' &&
        specNorm != 'n/a' &&
        specNorm != 'na' &&
        specNorm != 'chua cap nhat' &&
        specNorm != 'khong' &&
        specNorm != 'none';
  }

  bool _matchesResearchSpec(LecturerModel lecturer, String selectedSpec) {
    if (selectedSpec == 'Tất cả') return true;
    final hasSpec = _hasMeaningfulResearchSpec(lecturer);
    if (selectedSpec == 'Có hướng NC') return hasSpec;
    if (selectedSpec == 'Chưa có hướng NC') return !hasSpec;

    if (!hasSpec) return false;
    final specNorm = _normalizeVi(lecturer.chuyenMon);
    final selectedNorm = _normalizeVi(selectedSpec);
    if (specNorm.contains(selectedNorm)) return true;

    // Ánh xạ nhóm hướng nghiên cứu hợp lý theo từ khóa chuyên môn
    if (selectedNorm.contains('tri tue nhan tao')) {
      return specNorm.contains('tri tue nhan tao') ||
          specNorm.contains('deep learning') ||
          specNorm.contains('machine learning') ||
          specNorm.contains('hoc may') ||
          specNorm.contains('hoc sau') ||
          specNorm.contains('thi giac') ||
          specNorm.contains('ngon ngu tu nhien') ||
          specNorm.contains('nlp') ||
          specNorm.contains('llm') ||
          RegExp(r'\bai\b').hasMatch(specNorm);
    }
    if (selectedNorm.contains('phan mem') || selectedNorm.contains('di dong')) {
      return specNorm.contains('phan mem') ||
          specNorm.contains('di dong') ||
          specNorm.contains('mobile') ||
          specNorm.contains('web') ||
          specNorm.contains('fullstack') ||
          specNorm.contains('flutter') ||
          specNorm.contains('react') ||
          specNorm.contains('backend') ||
          specNorm.contains('he thong thong tin') ||
          specNorm.contains('agile');
    }
    if (selectedNorm.contains('an toan thong tin') || selectedNorm.contains('mang')) {
      return specNorm.contains('an toan thong tin') ||
          specNorm.contains('an ninh') ||
          specNorm.contains('bao mat') ||
          specNorm.contains('kiem thu') ||
          specNorm.contains('iot') ||
          specNorm.contains('nhung') ||
          specNorm.contains('mang');
    }
    if (selectedNorm.contains('du lieu') || selectedNorm.contains('cloud')) {
      return specNorm.contains('du lieu') ||
          specNorm.contains('big data') ||
          specNorm.contains('dam may') ||
          specNorm.contains('cloud') ||
          specNorm.contains('devops') ||
          specNorm.contains('blockchain') ||
          specNorm.contains('phan tich');
    }

    return false;
  }

  Future<void> _loadLecturers({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawList = await GovernanceApiService.instance.fetchLecturers(
        forceRefresh: forceRefresh,
      );
      final parsed = rawList.map((item) {
        final rawSpec = (item['chuyenMon'] ?? item['ChuyenMon'] ?? '').toString().trim();
        final rawDegree = (item['hocVi'] ?? item['HocVi'] ?? '').toString().trim();
        final rawPhone = (item['soDienThoai'] ?? item['SoDienThoai'] ?? item['phoneNumber'] ?? '').toString().trim();
        final rawClasses = item['soLopPhuTrach'] ?? item['SoLopPhuTrach'] ?? item['soLopHocPhan'] ?? 0;

        return LecturerModel(
          id: item['id'] ?? item['giangVienId'] ?? item['GiangVienId'] ?? 0,
          lecturerCode: (item['lecturerCode'] ?? item['maGiangVien'] ?? item['MaGiangVien'] ?? '').toString().trim(),
          fullName: (item['fullName'] ?? item['hoTen'] ?? item['HoTen'] ?? '').toString().trim(),
          email: (item['email'] ?? item['Email'] ?? '').toString().trim(),
          phoneNumber: rawPhone,
          faculty: (item['faculty'] ?? item['khoa'] ?? item['tenKhoa'] ?? 'Khoa Công nghệ thông tin').toString().trim(),
          department: (item['department'] ?? item['boMon'] ?? item['tenBoMon'] ?? '').toString().trim(),
          avatar: (item['avatar'] ?? '').toString(),
          hocVi: rawDegree.isNotEmpty ? rawDegree : 'Giảng viên',
          chuyenMon: rawSpec,
          soLopPhuTrach: rawClasses is int ? rawClasses : int.tryParse('$rawClasses') ?? 0,
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

    final queryNorm = _normalizeVi(_query);
    final filtered = _lecturers.where((lecturer) {
      final matchesQuery = queryNorm.isEmpty ||
          _normalizeVi(lecturer.lecturerCode).contains(queryNorm) ||
          _normalizeVi(lecturer.fullName).contains(queryNorm) ||
          _normalizeVi(lecturer.email).contains(queryNorm) ||
          _normalizeVi(lecturer.faculty).contains(queryNorm) ||
          _normalizeVi(lecturer.department).contains(queryNorm) ||
          _normalizeVi(lecturer.chuyenMon).contains(queryNorm) ||
          _normalizeVi(lecturer.hocVi).contains(queryNorm);

      final matchesFaculty = _facultyFilter == 'Tất cả' || lecturer.faculty == _facultyFilter;
      final matchesSpec = _matchesResearchSpec(lecturer, _selectedSpec);

      return matchesQuery && matchesFaculty && matchesSpec;
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
                  onPressed: () => _loadLecturers(forceRefresh: true),
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
                              kind: GovernanceAddKind.lecturer,
                            ),
                          ),
                        );
                        if (ok == true) _loadLecturers(forceRefresh: true);
                      },
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
                      onPressed: () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const GovernanceImportScreen(
                              initialKind: GovernanceImportKind.lecturers,
                            ),
                          ),
                        );
                        _loadLecturers(forceRefresh: true);
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
                    'Tìm theo mã GV, họ tên, hướng nghiên cứu...',
                    en: 'Search by ID, name, research topic...',
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
            // Lọc hướng nghiên cứu / chuyên môn (đã sửa logic so khớp chính xác)
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _specChip('Tất cả'),
                  _specChip('Có hướng NC'),
                  _specChip('Trí tuệ nhân tạo'),
                  _specChip('Phần mềm & Di động'),
                  _specChip('An toàn thông tin & Mạng'),
                  _specChip('Dữ liệu & Cloud'),
                  _specChip('Chưa có hướng NC'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (faculties.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Tất cả'),
                    ...faculties.map(_filterChip),
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
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tìm thấy ${filtered.length} giảng viên',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ),
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

  Widget _specChip(String value) {
    final isSelected = _selectedSpec == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(value),
        selected: isSelected,
        selectedColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF6D28D9) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (_) => setState(() => _selectedSpec = value),
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
        selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
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
                onPressed: () => _loadLecturers(forceRefresh: true),
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
        onRefresh: () => _loadLecturers(forceRefresh: true),
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
                      AppLocalizations.text(
                        'Không có giảng viên phù hợp bộ lọc',
                        en: 'No matching lecturers found',
                      ),
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
      onRefresh: () => _loadLecturers(forceRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final lecturer = list[index];
          final hasSpec = _hasMeaningfulResearchSpec(lecturer);

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
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.badge_outlined, color: Color(0xFF7C3AED), size: 24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lecturer.hocVi,
                      style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      lecturer.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A5F)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        'Mã GV: ${lecturer.lecturerCode}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${lecturer.soLopPhuTrach} LHP phụ trách',
                          style: const TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 13,
                        color: hasSpec ? const Color(0xFF7C3AED) : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hasSpec
                              ? 'Hướng NC: ${lecturer.chuyenMon}'
                              : 'Hướng NC: Chưa cập nhật',
                          style: TextStyle(
                            color: hasSpec ? const Color(0xFF7C3AED) : Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: hasSpec ? FontWeight.w600 : FontWeight.normal,
                            fontStyle: hasSpec ? FontStyle.normal : FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 13, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lecturer.email,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
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
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
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
                      '${lecturer.hocVi} · ${lecturer.lecturerCode}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 28),
                    _detailRow('Mã giảng viên', lecturer.lecturerCode),
                    _detailRow('Học vị', lecturer.hocVi),
                    _detailRow(
                      'Hướng nghiên cứu',
                      lecturer.chuyenMon.isNotEmpty ? lecturer.chuyenMon : 'Chưa cập nhật',
                    ),
                    _detailRow('Số LHP phụ trách', '${lecturer.soLopPhuTrach} lớp'),
                    _detailRow('Khoa', lecturer.faculty),
                    if (lecturer.department.isNotEmpty) _detailRow('Bộ môn', lecturer.department),
                    _detailRow('Email', lecturer.email.isNotEmpty ? lecturer.email : '—'),
                    _detailRow(
                      'Số điện thoại',
                      lecturer.phoneNumber.isNotEmpty ? lecturer.phoneNumber : 'Chưa cập nhật',
                    ),
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
