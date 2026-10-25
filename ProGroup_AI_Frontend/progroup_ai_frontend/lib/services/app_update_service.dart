import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

import 'api_service.dart';

/// Thông tin phiên bản ứng dụng trả về từ Backend
class AppUpdateInfo {
  final String version;
  final int versionCode;
  final String minSupportedVersion;
  final String changelog;
  final String downloadUrl;
  final String fileSize;
  final bool isForceUpdate;
  final String releaseDate;

  const AppUpdateInfo({
    required this.version,
    required this.versionCode,
    this.minSupportedVersion = '1.0.0',
    required this.changelog,
    required this.downloadUrl,
    this.fileSize = '',
    this.isForceUpdate = false,
    this.releaseDate = '',
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version']?.toString() ?? '1.0.0',
      versionCode: json['versionCode'] is int
          ? json['versionCode'] as int
          : int.tryParse(json['versionCode']?.toString() ?? '1') ?? 1,
      minSupportedVersion: json['minSupportedVersion']?.toString() ?? '1.0.0',
      changelog: json['changelog']?.toString() ?? '',
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      fileSize: json['fileSize']?.toString() ?? '',
      isForceUpdate: json['isForceUpdate'] == true,
      releaseDate: json['releaseDate']?.toString() ?? '',
    );
  }
}

/// Dịch vụ quản lý kiểm tra và cập nhật ứng dụng tự động trong app (OTA In-App Update)
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  /// Phiên bản hiện tại của app (đồng bộ với pubspec.yaml)
  static const String currentVersion = '1.0.2';
  static const int currentVersionCode = 2;

  bool _hasAutoCheckedThisSession = false;
  bool _isChecking = false;

  /// Chuẩn hóa URL tải APK phù hợp với baseUrl đang kết nối
  String resolveDownloadUrl(String rawUrl) {
    if (rawUrl.isEmpty) return rawUrl;

    // Nếu đường dẫn tương đối (vd: /downloads/app-latest.apk)
    if (rawUrl.startsWith('/')) {
      final base = ApiService.workingBaseUrl ?? ApiService.baseUrls.first;
      return '$base$rawUrl';
    }

    // Nếu qua Cloudflare Tunnel, bắt buộc sử dụng HTTPS
    if (rawUrl.contains('trycloudflare.com') && rawUrl.startsWith('http://')) {
      return rawUrl.replaceFirst('http://', 'https://');
    }

    // Nếu đã có workingBaseUrl từ ApiService (kết nối thành công), đồng bộ host & port
    final workingBase = ApiService.workingBaseUrl;
    if (workingBase != null && workingBase.isNotEmpty) {
      final workingUri = Uri.tryParse(workingBase);
      final rawUri = Uri.tryParse(rawUrl);
      if (workingUri != null && rawUri != null) {
        return rawUri
            .replace(
              scheme: workingUri.scheme,
              host: workingUri.host,
              port: workingUri.hasPort ? workingUri.port : null,
            )
            .toString();
      }
    }

    return rawUrl;
  }

  /// Kiểm tra có bản cập nhật mới từ server không
  Future<AppUpdateInfo?> checkUpdate() async {
    if (_isChecking) return null;
    _isChecking = true;

    try {
      final res = await ApiService.instance.get('/api/app/version');
      if (res is Map<String, dynamic>) {
        final info = AppUpdateInfo.fromJson(res);
        final normalizedUrl = resolveDownloadUrl(info.downloadUrl);
        final resolvedInfo = AppUpdateInfo(
          version: info.version,
          versionCode: info.versionCode,
          minSupportedVersion: info.minSupportedVersion,
          changelog: info.changelog,
          downloadUrl: normalizedUrl,
          fileSize: info.fileSize,
          isForceUpdate: info.isForceUpdate,
          releaseDate: info.releaseDate,
        );

        if (resolvedInfo.versionCode > currentVersionCode) {
          return resolvedInfo;
        }
      }
    } catch (e) {
      debugPrint('[AppUpdateService] Lỗi kiểm tra phiên bản: $e');
    } finally {
      _isChecking = false;
    }

    return null;
  }

  /// Tự động kiểm tra 1 lần mỗi khi mở app
  Future<void> autoCheckAndPrompt(BuildContext context) async {
    if (_hasAutoCheckedThisSession) return;
    _hasAutoCheckedThisSession = true;

    // Đợi UI render xong
    await Future.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) return;

    final updateInfo = await checkUpdate();
    if (updateInfo != null && context.mounted) {
      showUpdateDialog(context, updateInfo);
    }
  }

  /// Kiểm tra thủ công (người dùng bấm vào mục 'Kiểm tra bản cập nhật' trong Profile)
  Future<void> manualCheckAndPrompt(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Đang kiểm tra bản cập nhật...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final updateInfo = await checkUpdate();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (updateInfo != null) {
      showUpdateDialog(context, updateInfo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bạn đang dùng phiên bản mới nhất (v$currentVersion).',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// Hiển thị hộp thoại cập nhật ứng dụng
  void showUpdateDialog(BuildContext context, AppUpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: !info.isForceUpdate,
      builder: (dialogCtx) => _AppUpdateDialog(info: info),
    );
  }
}

/// Widget Hộp thoại cập nhật ứng dụng với thanh tiến trình tải OTA
class _AppUpdateDialog extends StatefulWidget {
  final AppUpdateInfo info;

  const _AppUpdateDialog({required this.info});

  @override
  State<_AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<_AppUpdateDialog> {
  StreamSubscription<OtaEvent>? _otaSubscription;
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusMessage = '';
  String? _errorMessage;

  @override
  void dispose() {
    _otaSubscription?.cancel();
    super.dispose();
  }

  void _startOtaDownload() {
    if (!kIsWeb && !Platform.isAndroid) {
      setState(() {
        _errorMessage = 'Tính năng cập nhật tự động chỉ hỗ trợ trên thiết bị Android.';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _errorMessage = null;
      _statusMessage = 'Đang kết nối máy chủ...';
    });

    try {
      _otaSubscription = OtaUpdate()
          .execute(
            widget.info.downloadUrl,
            destinationFilename: 'app-latest.apk',
          )
          .listen(
            (OtaEvent event) {
              if (!mounted) return;
              switch (event.status) {
                case OtaStatus.DOWNLOADING:
                  final percent = int.tryParse(event.value ?? '0') ?? 0;
                  setState(() {
                    _progress = percent / 100.0;
                    _statusMessage = 'Đang tải xuống: $percent%';
                  });
                  break;
                case OtaStatus.INSTALLING:
                  setState(() {
                    _progress = 1.0;
                    _statusMessage = 'Tải xong! Đang mở trình cài đặt...';
                  });
                  break;
                case OtaStatus.INSTALLATION_DONE:
                  setState(() {
                    _statusMessage = 'Cài đặt hoàn tất!';
                    _isDownloading = false;
                  });
                  break;
                case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                  setState(() {
                    _isDownloading = false;
                    _errorMessage =
                        'Vui lòng bật quyền "Cài đặt ứng dụng không rõ nguồn gốc" cho ProGroup AI trong Cài đặt thiết bị.';
                  });
                  break;
                case OtaStatus.DOWNLOAD_ERROR:
                  setState(() {
                    _isDownloading = false;
                    _errorMessage = 'Lỗi tải file APK (${event.value ?? "Kiểm tra mạng"}).';
                  });
                  break;
                case OtaStatus.INTERNAL_ERROR:
                case OtaStatus.INSTALLATION_ERROR:
                case OtaStatus.CHECKSUM_ERROR:
                  setState(() {
                    _isDownloading = false;
                    _errorMessage = 'Lỗi: ${event.status.name} (${event.value ?? ""})';
                  });
                  break;
                case OtaStatus.ALREADY_RUNNING_ERROR:
                  setState(() {
                    _statusMessage = 'Đang tiến hành tải trong nền...';
                  });
                  break;
                case OtaStatus.CANCELED:
                  setState(() {
                    _isDownloading = false;
                    _statusMessage = 'Đã hủy tải.';
                  });
                  break;
              }
            },
            onError: (dynamic error) {
              if (!mounted) return;
              setState(() {
                _isDownloading = false;
                _errorMessage = 'Lỗi không xác định: $error';
              });
            },
          );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _errorMessage = 'Không thể khởi động tải cập nhật: $e';
      });
    }
  }

  void _cancelDownload() {
    _otaSubscription?.cancel();
    OtaUpdate().cancel();
    setState(() {
      _isDownloading = false;
      _statusMessage = 'Đã hủy tải.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isForce = widget.info.isForceUpdate;

    return PopScope(
      canPop: !isForce && !_isDownloading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 12,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon & Title
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cập nhật ứng dụng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'v${widget.info.version}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ),
                            if (widget.info.fileSize.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                widget.info.fileSize,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Changelog container
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 15,
                            color: Color(0xFF2563EB),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Điểm mới trong bản này:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A5F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.info.changelog.isNotEmpty
                            ? widget.info.changelog
                            : '• Cập nhật tính năng và sửa lỗi hệ thống.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Downloading progress view
              if (_isDownloading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    if (_progress > 0)
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Error display
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade800,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Action Buttons
              if (!_isDownloading)
                Row(
                  children: [
                    if (!isForce) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Để sau',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: isForce ? 1 : 1,
                      child: ElevatedButton.icon(
                        onPressed: _startOtaDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: Text(
                          _errorMessage != null ? 'Thử lại' : 'Cập nhật ngay',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _cancelDownload,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: Colors.red.shade200),
                    foregroundColor: Colors.red.shade600,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text(
                    'Hủy tải xuống',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
