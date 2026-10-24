import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import '../../../services/admin_api_service.dart';

class AdminUserImportScreen extends StatefulWidget {
  const AdminUserImportScreen({super.key});

  @override
  State<AdminUserImportScreen> createState() => _AdminUserImportScreenState();
}

class _AdminUserImportScreenState extends State<AdminUserImportScreen> {
  String _selectedFormat = 'csv'; // 'csv' or 'xlsx'
  String? _selectedFileName;
  bool _isProcessing = false;
  bool _isImporting = false;
  double _importProgress = 0.0;
  String? _statusMessage;

  List<Map<String, dynamic>> _parsedUsers = [];

  static const List<String> _headers = [
    'Tên đăng nhập',
    'Mật khẩu',
    'Họ và tên',
    'Email',
    'Số điện thoại',
    'Vai trò',
    'Trạng thái',
  ];

  Future<void> _downloadTemplate() async {
    try {
      if (_selectedFormat == 'csv') {
        final records = <List<String>>[
          _headers,
          [
            'sv_nguyenvana',
            '123456',
            'Nguyễn Văn A',
            'vana@school.edu.vn',
            '0912345678',
            'SINHVIEN',
            'true',
          ],
          [
            'gv_tranthib',
            '123456',
            'Trần Thị B',
            'thib@school.edu.vn',
            '0987654321',
            'GIANGVIEN',
            'true',
          ],
          [
            'giaovu_cntt',
            '123456',
            'Lê Văn C',
            'giaovu@school.edu.vn',
            '0901234567',
            'GIAOVUKHOA',
            'true',
          ],
        ];

        final csvData = csv.encode(records);
        final bytes = Uint8List.fromList(utf8.encode('\uFEFF$csvData'));

        final saveToDownloads = !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
        if (saveToDownloads) {
          await FileSaver.instance.saveFile(
            name: 'mau_nhap_nguoi_dung',
            bytes: bytes,
            fileExtension: 'csv',
            mimeType: MimeType.custom,
            customMimeType: 'text/csv',
          );
        } else {
          await FileSaver.instance.saveAs(
            name: 'mau_nhap_nguoi_dung',
            bytes: bytes,
            fileExtension: 'csv',
            mimeType: MimeType.custom,
            customMimeType: 'text/csv',
          );
        }
      } else {
        final workbook = excel.Excel.createExcel();
        final defaultSheet = workbook.getDefaultSheet();
        if (defaultSheet != null && defaultSheet != 'Người dùng') {
          workbook.rename(defaultSheet, 'Người dùng');
        }
        final sheet = workbook['Người dùng'];

        // Header
        for (var col = 0; col < _headers.length; col++) {
          final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
          cell.value = excel.TextCellValue(_headers[col]);
          cell.cellStyle = excel.CellStyle(bold: true);
        }

        // Sample rows
        final sample1 = ['sv_nguyenvana', '123456', 'Nguyễn Văn A', 'vana@school.edu.vn', '0912345678', 'SINHVIEN', 'true'];
        final sample2 = ['gv_tranthib', '123456', 'Trần Thị B', 'thib@school.edu.vn', '0987654321', 'GIANGVIEN', 'true'];

        for (var col = 0; col < sample1.length; col++) {
          sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1)).value = excel.TextCellValue(sample1[col]);
          sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 2)).value = excel.TextCellValue(sample2[col]);
        }

        final encoded = workbook.encode();
        if (encoded != null) {
          final bytes = Uint8List.fromList(encoded);
          await FileSaver.instance.saveAs(
            name: 'mau_nhap_nguoi_dung',
            bytes: bytes,
            fileExtension: 'xlsx',
            mimeType: MimeType.custom,
            customMimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tải file mẫu thành công.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải file mẫu: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final allowedExtensions = _selectedFormat == 'csv' ? ['csv'] : ['xlsx'];
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty || !mounted) return;
      final file = result.files.single;

      setState(() {
        _isProcessing = true;
        _selectedFileName = file.name;
        _parsedUsers = [];
        _statusMessage = null;
      });

      if (_selectedFormat == 'csv') {
        final content = utf8.decode(file.bytes!, allowMalformed: true).replaceFirst('\uFEFF', '');
        _parseCsv(content);
      } else {
        _parseExcel(file.bytes!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Lỗi đọc file: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _parseCsv(String content) {
    try {
      final rows = csv.decode(content);
      if (rows.length <= 1) {
        setState(() => _statusMessage = 'File không có dữ liệu để nhập.');
        return;
      }

      final List<Map<String, dynamic>> users = [];
      // Bỏ qua dòng header
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

        final tenDangNhap = row.isNotEmpty ? row[0].toString().trim() : '';
        final matKhau = row.length > 1 ? row[1].toString().trim() : '123456';
        final hoTen = row.length > 2 ? row[2].toString().trim() : '';
        final email = row.length > 3 ? row[3].toString().trim() : '';
        final soDienThoai = row.length > 4 ? row[4].toString().trim() : '';
        final vaiTro = row.length > 5 ? row[5].toString().trim().toUpperCase() : 'SINHVIEN';
        final trangThaiRaw = row.length > 6 ? row[6].toString().trim().toLowerCase() : 'true';

        final bool trangThai = trangThaiRaw == 'true' || trangThaiRaw == '1' || trangThaiRaw.contains('hoạt động');

        if (tenDangNhap.isNotEmpty && hoTen.isNotEmpty) {
          users.add({
            'tenDangNhap': tenDangNhap,
            'matKhau': matKhau.isNotEmpty ? matKhau : '123456',
            'hoTen': hoTen,
            'email': email,
            'soDienThoai': soDienThoai,
            'maVaiTro': vaiTro.isNotEmpty ? vaiTro : 'SINHVIEN',
            'trangThai': trangThai,
          });
        }
      }

      setState(() {
        _parsedUsers = users;
        if (users.isEmpty) {
          _statusMessage = 'Không tìm thấy dòng người dùng hợp lệ trong file.';
        }
      });
    } catch (e) {
      setState(() => _statusMessage = 'Lỗi phân tích file CSV: $e');
    }
  }

  void _parseExcel(Uint8List bytes) {
    try {
      final workbook = excel.Excel.decodeBytes(bytes);
      final sheetName = workbook.tables.keys.first;
      final table = workbook.tables[sheetName];

      if (table == null || table.rows.length <= 1) {
        setState(() => _statusMessage = 'File Excel không có dữ liệu để nhập.');
        return;
      }

      final List<Map<String, dynamic>> users = [];
      for (var i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;

        String getVal(int index) {
          if (index < row.length && row[index] != null) {
            return row[index]!.value?.toString().trim() ?? '';
          }
          return '';
        }

        final tenDangNhap = getVal(0);
        final matKhau = getVal(1);
        final hoTen = getVal(2);
        final email = getVal(3);
        final soDienThoai = getVal(4);
        final vaiTro = getVal(5).toUpperCase();
        final trangThaiRaw = getVal(6).toLowerCase();

        final bool trangThai = trangThaiRaw == 'true' || trangThaiRaw == '1' || trangThaiRaw.contains('hoạt động');

        if (tenDangNhap.isNotEmpty && hoTen.isNotEmpty) {
          users.add({
            'tenDangNhap': tenDangNhap,
            'matKhau': matKhau.isNotEmpty ? matKhau : '123456',
            'hoTen': hoTen,
            'email': email,
            'soDienThoai': soDienThoai,
            'maVaiTro': vaiTro.isNotEmpty ? vaiTro : 'SINHVIEN',
            'trangThai': trangThai,
          });
        }
      }

      setState(() {
        _parsedUsers = users;
        if (users.isEmpty) {
          _statusMessage = 'Không tìm thấy dòng người dùng hợp lệ trong file Excel.';
        }
      });
    } catch (e) {
      setState(() => _statusMessage = 'Lỗi phân tích file Excel: $e');
    }
  }

  Future<void> _startImport() async {
    if (_parsedUsers.isEmpty) return;

    setState(() {
      _isImporting = true;
      _importProgress = 0.0;
      _statusMessage = null;
    });

    int successCount = 0;
    int failCount = 0;

    for (var i = 0; i < _parsedUsers.length; i++) {
      final user = _parsedUsers[i];
      try {
        await AdminApiService.instance.createUser(user);
        successCount++;
      } catch (_) {
        failCount++;
      }
      if (mounted) {
        setState(() {
          _importProgress = (i + 1) / _parsedUsers.length;
        });
      }
    }

    if (!mounted) return;
    setState(() {
      _isImporting = false;
      _statusMessage = 'Hoàn tất import: $successCount thành công, $failCount thất bại.';
    });

    if (successCount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Kết quả nhập người dùng', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Đã nhập thành công $successCount/${_parsedUsers.length} tài khoản người dùng.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: const Text('Đóng & Tải lại danh sách'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Import người dùng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          children: [
            // Header Hero Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nhập tài khoản hàng loạt',
                          style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Hỗ trợ file CSV và Excel (.xlsx) chuẩn cấu trúc trường dữ liệu hệ thống.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 1: Chọn định dạng
            _buildCard(
              title: '1. Chọn định dạng & Tải file mẫu',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FormatSelectTile(
                          title: 'CSV (.csv)',
                          subtitle: 'File văn bản UTF-8',
                          icon: Icons.description_rounded,
                          isSelected: _selectedFormat == 'csv',
                          onTap: () {
                            setState(() {
                              _selectedFormat = 'csv';
                              _selectedFileName = null;
                              _parsedUsers = [];
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FormatSelectTile(
                          title: 'Excel (.xlsx)',
                          subtitle: 'Bảng tính Excel',
                          icon: Icons.table_chart_rounded,
                          isSelected: _selectedFormat == 'xlsx',
                          onTap: () {
                            setState(() {
                              _selectedFormat = 'xlsx';
                              _selectedFileName = null;
                              _parsedUsers = [];
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _downloadTemplate,
                      icon: const Icon(Icons.download_rounded),
                      label: Text('Tải file mẫu ${_selectedFormat.toUpperCase()}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Step 2: Chọn file
            _buildCard(
              title: '2. Tải lên file người dùng',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _isProcessing || _isImporting ? null : _pickFile,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFileName != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                            size: 40,
                            color: _selectedFileName != null ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _selectedFileName ?? 'Nhấn để chọn file $_selectedFormat',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedFileName != null ? const Color(0xFF10B981) : colors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedFileName != null ? 'Đã tải và phân tích dữ liệu' : 'Kích thước tối đa 5MB',
                            style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _statusMessage!.contains('Lỗi') ? Colors.red : const Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Step 3: Xem trước & Xác nhận import
            if (_parsedUsers.isNotEmpty) ...[
              _buildCard(
                title: '3. Xem trước danh sách (${_parsedUsers.length} tài khoản)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._parsedUsers.take(5).map((u) {
                      final role = u['maVaiTro'].toString();
                      final Color roleColor = role.contains('GIANGVIEN')
                          ? const Color(0xFF2563EB)
                          : role.contains('ADMIN')
                              ? const Color(0xFFEF4444)
                              : role.contains('GIAOVU')
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF10B981);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.person, color: roleColor, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u['hoTen'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    '@${u['tenDangNhap']} • ${u['email']}',
                                    style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(fontSize: 10, color: roleColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_parsedUsers.length > 5) ...[
                      Center(
                        child: Text(
                          '... và còn ${_parsedUsers.length - 5} tài khoản khác',
                          style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 14),

                    if (_isImporting) ...[
                      LinearProgressIndicator(
                        value: _importProgress,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF2563EB),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Đang import: ${(_importProgress * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _startImport,
                          icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                          label: Text(
                            'Bắt đầu Import ${_parsedUsers.length} tài khoản',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FormatSelectTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatSelectTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF2563EB) : Colors.grey, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
