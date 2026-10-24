import 'package:flutter/material.dart';

import '../../../services/admin_api_service.dart';
import '../../../services/governance_api_service.dart';
import '../../admin/admin_helpers.dart';
import 'admin_data_management_screen.dart';

class AdminDataDetailScreen extends StatefulWidget {
  const AdminDataDetailScreen({
    super.key,
    required this.type,
    required this.title,
  });

  final AdminDataType type;
  final String title;

  @override
  State<AdminDataDetailScreen> createState() => _AdminDataDetailScreenState();
}

class _AdminDataDetailScreenState extends State<AdminDataDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _data = [];
  String _query = '';

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
      List<Map<String, dynamic>> list = [];
      switch (widget.type) {
        case AdminDataType.students:
          list = await GovernanceApiService.instance.fetchStudents();
        case AdminDataType.lecturers:
          list = await GovernanceApiService.instance.fetchLecturers();
        case AdminDataType.courseClasses:
        case AdminDataType.subjects:
          list = await GovernanceApiService.instance.fetchCourses();
        case AdminDataType.groups:
          list = await GovernanceApiService.instance.fetchGroups();
        case AdminDataType.accounts:
          list = await AdminApiService.instance.fetchUsers();
      }

      if (!mounted) return;
      setState(() {
        _data = list;
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
    final query = _query.trim().toLowerCase();
    final filtered = _data.where((item) {
      if (query.isEmpty) return true;
      final text = item.values.map((v) => v.toString()).join(' ').toLowerCase();
      return text.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                  hintText: adminText('Tìm kiếm...', 'Search...'),
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
                ),
              ),
            ),
            Expanded(
              child: _buildListContent(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(List<Map<String, dynamic>> list) {
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
                onPressed: _loadData,
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
        onRefresh: _loadData,
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
                    Icon(Icons.inbox_outlined, size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      adminText('Chưa có dữ liệu', 'No data available'),
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
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = list[index];
          final title = item['tenLopHocPhan'] ?? item['TenLopHocPhan'] ?? item['tenHocPhan'] ?? item['TenHocPhan'] ?? item['hoTen'] ?? item['HoTen'] ?? item['tenNhom'] ?? item['tenDangNhap'] ?? '—';
          final sub1 = item['maLopHocPhan'] ?? item['MaLopHocPhan'] ?? item['mssv'] ?? item['MSSV'] ?? item['maGiangVien'] ?? item['tenDangNhap'] ?? '';
          final sub2 = item['email'] ?? item['Email'] ?? item['giangVienTen'] ?? item['GiangVienTen'] ?? '';

          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.dataset_outlined, color: Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$title',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A5F)),
                        ),
                        if (sub1.isNotEmpty || sub2.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            '$sub1 ${sub2.isNotEmpty ? "· $sub2" : ""}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
