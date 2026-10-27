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

  static const String currentCloudflareUrl =
      'https://platforms-interaction-alcohol-share.trycloudflare.com';
  static const String currentLanIpUrl = 'http://192.168.1.109:5094';

  static const List<String> baseUrls = [
    currentCloudflareUrl,
    currentLanIpUrl,
    'http://192.168.1.193:5094',
    'http://127.0.0.1:5094',
    'http://localhost:5094',
    'http://10.0.2.2:5094',
  ];

  static String? _workingBaseUrl;
  static String? _customBaseUrl;

  static String? get workingBaseUrl => _workingBaseUrl ?? _customBaseUrl;
  static String? get customBaseUrl => _customBaseUrl;

  static void setWorkingBaseUrl(String url) {
    _workingBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
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
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      return res.statusCode >= 200 && res.statusCode < 300;
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
  ]) async {
    ApiException? lastError;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    // Xây dựng danh sách ưu tiên kết nối: Custom -> Working -> Defaults
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
            response = await http
                .post(uri, headers: headers, body: bodyStr)
                .timeout(const Duration(seconds: 5));
            break;
          case 'PUT':
            response = await http
                .put(uri, headers: headers, body: bodyStr)
                .timeout(const Duration(seconds: 5));
            break;
          case 'DELETE':
            response = await http
                .delete(uri, headers: headers, body: bodyStr)
                .timeout(const Duration(seconds: 5));
            break;
          case 'GET':
          default:
            response = await http
                .get(uri, headers: headers)
                .timeout(const Duration(seconds: 5));
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

        // Lấy thông báo lỗi chi tiết từ phản hồi nếu có
        String errorMessage = 'Yêu cầu thất bại (${response.statusCode})';
        if (responseBody.isNotEmpty) {
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
        lastError = ApiException('Lỗi kết nối: ${e.toString()}', null);
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
