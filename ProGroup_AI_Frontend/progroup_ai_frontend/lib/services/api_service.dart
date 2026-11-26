import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static http.Client _client = http.Client();
  static http.Client get client => _client;

  static void resetClient() {
    try {
      _client.close();
    } catch (_) {}
    _client = http.Client();
  }

  static const String currentLanIpUrl = 'http://192.168.1.234:5094';
  static const String currentLanIpUrlOld = 'http://192.168.1.229:5094';
  static const String usbUrl = 'http://127.0.0.1:5094';
  static const String emulatorUrl = 'http://10.0.2.2:5094';
  static const String currentCloudflareUrl =
      'https://platforms-interaction-alcohol-share.trycloudflare.com';

  /// Danh sách địa chỉ máy chủ theo thứ tự ưu tiên tốc độ cao nhất:
  /// 1. usbUrl (127.0.0.1:5094): Cực nhanh qua ADB Reverse (dùng cho cả máy thật cắm USB lẫn máy ảo Android).
  /// 2. emulatorUrl (10.0.2.2:5094): Dự phòng cho Android Emulator nếu chưa chạy reverse ADB.
  /// 3. localhost:5094: Dành cho Windows / Web Desktop.
  /// 4. Wi-Fi LAN IPs: Dành cho điện thoại kết nối cùng mạng Wi-Fi.
  static const List<String> baseUrls = [
    usbUrl,
    emulatorUrl,
    'http://localhost:5094',
    currentLanIpUrl,
    currentLanIpUrlOld,
  ];

  static String? _workingBaseUrl;
  static String? _customBaseUrl;

  static String? get workingBaseUrl => _workingBaseUrl ?? _customBaseUrl;
  static String? get customBaseUrl => _customBaseUrl;

  static void setWorkingBaseUrl(String url) {
    _workingBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  /// Tự động dò tìm máy chủ Backend khả dụng (USB hoặc Wi-Fi) trong nền
  static Future<String?> autoDetectServer() async {
    // Nếu người dùng đã cài đặt URL thủ công và kết nối được thì dùng luôn
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      if (await testConnection(_customBaseUrl!)) {
        _workingBaseUrl = _customBaseUrl;
        return _customBaseUrl;
      }
    }

    // Ping nhanh các địa chỉ ứng cử viên
    for (final url in baseUrls) {
      if (await testConnection(url)) {
        _workingBaseUrl = url;
        debugPrint('[ApiService] Tự động kết nối máy chủ thành công: $url');
        return url;
      }
    }
    return null;
  }

  /// Khởi tạo và đọc URL máy chủ người dùng đã cấu hình trước đó (nếu có)
  static Future<void> initCustomUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('custom_backend_url');
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _customBaseUrl = savedUrl.trim().replaceAll(RegExp(r'/+$'), '');
        _workingBaseUrl = _customBaseUrl;
        debugPrint('[ApiService] Đã tải URL máy chủ tùy chỉnh: $_customBaseUrl');
      }
    } catch (_) {}
  }

  /// Lưu URL máy chủ tùy chỉnh mới
  static Future<void> saveCustomBaseUrl(String url) async {
    final cleanUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    _customBaseUrl = cleanUrl;
    _workingBaseUrl = cleanUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_backend_url', cleanUrl);
    } catch (_) {}
  }

  /// Xóa URL tùy chỉnh, quay về danh sách mặc định
  static Future<void> clearCustomBaseUrl() async {
    _customBaseUrl = null;
    _workingBaseUrl = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_backend_url');
    } catch (_) {}
  }

  /// Kiểm tra xem một URL có kết nối được tới Backend hay không (/api/health)
  static Future<bool> testConnection(String url) async {
    try {
      final cleanUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$cleanUrl/api/health');
      final res = await _client.get(uri).timeout(const Duration(seconds: 3));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = utf8.decode(res.bodyBytes).toLowerCase();
        return body.contains('healthy');
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    final token = AuthService.currentToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
    bool isRetry = false,
  ]) async {
    ApiException? lastError;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    // Xây dựng danh sách ưu tiên kết nối: Custom -> Working -> Defaults
    if (_workingBaseUrl == null) {
      await autoDetectServer();
    }

    // Đảm bảo có token nếu tài khoản đã đăng nhập
    if (AuthService.currentToken == null || AuthService.currentToken!.isEmpty) {
      await AuthService.ensureValidToken();
    }

    final candidateUrls = <String>[];
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      candidateUrls.add(_customBaseUrl!);
    }
    if (_workingBaseUrl != null &&
        _workingBaseUrl!.isNotEmpty &&
        !candidateUrls.contains(_workingBaseUrl)) {
      candidateUrls.add(_workingBaseUrl!);
    }
    for (final u in baseUrls) {
      if (!candidateUrls.contains(u)) {
        candidateUrls.add(u);
      }
    }

    for (final baseUrl in candidateUrls) {
      try {
        final uri = Uri.parse('$baseUrl$normalizedPath');
        final headers = _headers();
        final bodyStr = body != null ? jsonEncode(body) : null;

        final http.Response response;
        switch (method.toUpperCase()) {
          case 'POST':
            response = await _client
                .post(uri, headers: headers, body: bodyStr)
                .timeout(const Duration(seconds: 25));
            break;
          case 'PUT':
            response = await _client
                .put(uri, headers: headers, body: bodyStr)
                .timeout(const Duration(seconds: 25));
            break;
          case 'DELETE':
            response = await _client
                .delete(uri, headers: headers, body: bodyStr)
                .timeout(const Duration(seconds: 25));
            break;
          case 'GET':
          default:
            response = await _client
                .get(uri, headers: headers)
                .timeout(const Duration(seconds: 25));
            break;
        }

        final responseBody = utf8.decode(response.bodyBytes);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Lưu lại URL thành công để các request tiếp theo không mất thời gian thử lại
          _workingBaseUrl = baseUrl;

          if (responseBody.trim().isEmpty) return null;
          try {
            return jsonDecode(responseBody);
          } catch (_) {
            return responseBody;
          }
        }

        // Tự động cấp lại token và thử lại nếu nhận 401 hoặc 403 do token cũ hoặc hết hạn
        if ((response.statusCode == 401 || response.statusCode == 403) && !isRetry) {
          final reAuthed = await AuthService.reAuthenticate();
          if (reAuthed) {
            _workingBaseUrl = baseUrl;
            return _send(method, path, body, true);
          }
        }

        // Nếu nhận 403/404 từ router hoặc thiết bị mạng lạ không mang cấu trúc JSON của Backend API, bỏ qua để thử URL tiếp theo
        if ((response.statusCode == 403 || response.statusCode == 404) &&
            !responseBody.contains('message') &&
            !responseBody.contains('title') &&
            !responseBody.contains('status')) {
          debugPrint('[ApiService] Bỏ qua $baseUrl do phản hồi ${response.statusCode} từ thiết bị mạng không phải Backend API');
          continue;
        }

        // Lấy thông báo lỗi chi tiết từ phản hồi nếu có
        String errorMessage = response.statusCode == 401
            ? 'Phiên đăng nhập đã hết hạn (401). Vui lòng đăng xuất và đăng nhập lại.'
            : 'Yêu cầu thất bại (${response.statusCode})';
        if (responseBody.isNotEmpty && response.statusCode != 401) {
          try {
            final errorJson = jsonDecode(responseBody);
            if (errorJson is Map) {
              errorMessage = errorJson['message'] ??
                  errorJson['title'] ??
                  errorJson['error'] ??
                  errorMessage;
            }
          } catch (_) {
            errorMessage = responseBody;
          }
        }

        lastError = ApiException(errorMessage, response.statusCode);
        // Nếu máy chủ đã phản hồi mã lỗi HTTP, nghĩa là đã kết nối thành công tới API
        _workingBaseUrl = baseUrl;
        throw lastError;
      } on ApiException {
        rethrow;
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('TimeoutException')) {
          lastError = ApiException(
            'Hết thời gian chờ kết nối máy chủ (Timeout). Vui lòng thử lại.',
            null,
          );
        } else if (errStr.contains('SocketException')) {
          lastError = ApiException(
            'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
            null,
          );
        } else {
          lastError = ApiException('Lỗi kết nối: $errStr', null);
        }
      }
    }

    throw lastError ??
        ApiException(
          'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',
        );
  }

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send('POST', path, body);

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) =>
      _send('PUT', path, body);

  Future<dynamic> delete(String path, [Map<String, dynamic>? body]) =>
      _send('DELETE', path, body);
}
