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
  List<String> _importErrors = [];

  static const List<String> _headers = [
    'Tên đăng nhập',
    'Mật khẩu',
    'Họ và tên',
    'Email',
    'Số điện thoại',
    'Vai trò',
    'Trạng thái',
  ];

  static const List<List<String>> _sampleRows = [
    [
      '22110001',
      '123456',
      'Nguyễn Văn A',
      '22110001@school.edu.vn',
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

  Future<void> _downloadTemplate() async {
    try {
      if (_selectedFormat == 'csv') {
        final records = <List<String>>[
          _headers,
          ..._sampleRows,
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
        for (var r = 0; r < _sampleRows.length; r++) {
          final sample = _sampleRows[r];
          for (var col = 0; col < sample.length; col++) {
            sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r + 1)).value =
                excel.TextCellValue(sample[col]);
          }
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
        _importErrors = [];
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

  bool _isValidHeaderCols(List<String> headerCols) {
    return headerCols.length >= 4 &&
        (headerCols[0].contains('đăng nhập') || headerCols[0].contains('tendangnhap') || headerCols[0].contains('username') || headerCols[0].contains('mssv')) &&
        (headerCols[2].contains('họ') || headerCols[2].contains('hoten') || headerCols[2].contains('name'));
  }

  void _processParsedRows(List<List<String>> dataRows, String emptyLabel) {
    final List<Map<String, dynamic>> users = [];
    final List<String> errors = [];
    final seenUsernames = <String>{};
    final seenEmails = <String>{};

    for (var i = 0; i < dataRows.length; i++) {
      final cols = dataRows[i];
      if (cols.isEmpty || cols.every((c) => c.trim().isEmpty)) continue;

      final rowNumber = i + 2; // 1-based including header row
      final tenDangNhap = cols.isNotEmpty ? cols[0].trim() : '';
      final matKhau = cols.length > 1 ? cols[1].trim() : '';
      final hoTen = cols.length > 2 ? cols[2].trim() : '';
      final email = cols.length > 3 ? cols[3].trim() : '';
      final rawPhone = cols.length > 4 ? cols[4].trim() : '';
      final soDienThoai = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final vaiTroRaw = cols.length > 5 ? cols[5].trim().toUpperCase() : '';
      final maVaiTro = vaiTroRaw.isNotEmpty ? vaiTroRaw : 'SINHVIEN';
      final trangThaiRaw = cols.length > 6 ? cols[6].trim().toLowerCase() : '';

      final bool trangThai = trangThaiRaw.isEmpty ||
          trangThaiRaw == 'true' ||
          trangThaiRaw == '1' ||
          trangThaiRaw.contains('hoạt động');

      if (tenDangNhap.isEmpty || hoTen.isEmpty) {
        errors.add('Dòng $rowNumber: Thiếu tên đăng nhập hoặc họ và tên.');
        continue;
      }

      if (maVaiTro == 'SINHVIEN' && tenDangNhap.length > 30) {
        errors.add('Dòng $rowNumber ($tenDangNhap): MSSV tối đa 30 ký tự.');
        continue;
      }

      if (email.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        errors.add('Dòng $rowNumber ($tenDangNhap): Email trống hoặc không hợp lệ.');
        continue;
      }

      if (rawPhone.isNotEmpty && !RegExp(r'^[0-9]{10,11}$').hasMatch(soDienThoai)) {
        errors.add('Dòng $rowNumber ($tenDangNhap): Số điện thoại phải gồm 10-11 chữ số.');
        continue;
      }

      final uKey = tenDangNhap.toLowerCase();
      final eKey = email.toLowerCase();
      if (!seenUsernames.add(uKey)) {
        errors.add('Dòng $rowNumber ($tenDangNhap): Trùng tên đăng nhập trong file.');
        continue;
      }
      if (!seenEmails.add(eKey)) {
        errors.add('Dòng $rowNumber ($tenDangNhap): Trùng email "$email" trong file.');
        continue;
      }

      users.add({
        'tenDangNhap': tenDangNhap,
        'matKhau': matKhau.isNotEmpty ? matKhau : '123456',
        'hoTen': hoTen,
        'email': email,
        'soDienThoai': soDienThoai,
        'maVaiTro': maVaiTro,
        'trangThai': trangThai,
      });
    }

    setState(() {
      _parsedUsers = users;
      _importErrors = errors;
      if (users.isEmpty) {
        _statusMessage = errors.isNotEmpty
            ? 'Không có dòng hợp lệ (${errors.length} dòng lỗi).'
            : emptyLabel;
      } else if (errors.isNotEmpty) {
        _statusMessage = 'Tìm thấy ${users.length} dòng hợp lệ và ${errors.length} dòng lỗi bị bỏ qua.';
      }
    });
  }

  void _parseCsv(String content) {
    try {
      final rows = csv.decode(content);
      if (rows.length <= 1) {
        setState(() => _statusMessage = 'File không có dữ liệu để nhập.');
        return;
      }

      final headerCols = rows.first.map((c) => c.toString().trim().toLowerCase()).toList();
      if (!_isValidHeaderCols(headerCols)) {
        setState(() {
          _parsedUsers = [];
          _importErrors = [];
          _statusMessage = 'Cấu trúc file không đúng định dạng. Vui lòng tải file mẫu để kiểm tra.';
        });
        return;
      }

      final dataRows = rows
          .skip(1)
          .map((row) => row.map((c) => c.toString()).toList())
          .toList();
      _processParsedRows(dataRows, 'Không tìm thấy dòng người dùng hợp lệ trong file.');
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

      final headerRow = table.rows.first;
      final headerCols = headerRow.map((c) => (c?.value?.toString() ?? '').trim().toLowerCase()).toList();
      if (!_isValidHeaderCols(headerCols)) {
        setState(() {
          _parsedUsers = [];
          _importErrors = [];
          _statusMessage = 'Cấu trúc file không đúng định dạng. Vui lòng tải file mẫu để kiểm tra.';
        });
        return;
      }

      final dataRows = table.rows
          .skip(1)
          .map((row) => row.map((cell) => cell?.value?.toString() ?? '').toList())
          .toList();
      _processParsedRows(dataRows, 'Không tìm thấy dòng người dùng hợp lệ trong file Excel.');
    } catch (e) {
      setState(() => _statusMessage = 'Lỗi phân tích file Excel: $e');
    }
  }

  Future<void> _startImport() async {
    if (_parsedUsers.isEmpty) return;

    setState(() {
      _isImporting = true;
      _importProgress = 0.0;
      _importErrors = [];
      _statusMessage = null;
    });

    int successCount = 0;
    int failCount = 0;
    final List<String> errors = [];

    try {
      setState(() => _importProgress = 0.25);
      final batchRes = await AdminApiService.instance.importUsersBatch(_parsedUsers);
      successCount = (batchRes['successCount'] as num?)?.toInt() ?? 0;
      failCount = (batchRes['failedCount'] as num?)?.toInt() ?? 0;
      final rawErrors = batchRes['errors'];
      if (rawErrors is List) {
        for (final item in rawErrors) {
          final text = item?.toString().trim() ?? '';
          if (text.isNotEmpty) errors.add(text);
        }
      }
      if (mounted) {
        setState(() => _importProgress = 1.0);
      }
    } catch (_) {
      for (var i = 0; i < _parsedUsers.length; i++) {
        final user = _parsedUsers[i];
        try {
          await AdminApiService.instance.createUser(user);
          successCount++;
        } catch (e) {
          failCount++;
          final msg = e.toString().replaceFirst('Exception: ', '').trim();
          errors.add('${user['tenDangNhap']}: $msg');
        }
        if (mounted) {
          setState(() {
            _importProgress = (i + 1) / _parsedUsers.length;
          });
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _isImporting = false;
      _importErrors = errors;
      _statusMessage = 'Hoàn tất import: $successCount thành công, $failCount thất bại.';
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kết quả nhập người dùng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thành công: $successCount/${_parsedUsers.length} | Thất bại: $failCount'),
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('Chi tiết lỗi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: errors
                          .map((err) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('• $err', style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (successCount > 0)
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
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
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
                              _importErrors = [];
                              _statusMessage = null;
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
                              _importErrors = [];
                              _statusMessage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Thứ tự cột chuẩn: Tên đăng nhập (SV dùng MSSV) | Mật khẩu | Họ và tên | Email | Số điện thoại | Vai trò | Trạng thái',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        color: (_statusMessage!.contains('Lỗi') || _importErrors.isNotEmpty)
                            ? Colors.red
                            : const Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_importErrors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._importErrors.take(8).map(
                                (err) => Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    '• $err',
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFFDC2626)),
                                  ),
                                ),
                              ),
                          if (_importErrors.length > 8)
                            Text(
                              '... và ${_importErrors.length - 8} lỗi khác',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                            ),
                        ],
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
