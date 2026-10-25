import 'dart:convert';
import 'package:http/http.dart' as http;

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

  static const List<String> baseUrls = [
    'https://dicke-addresses-routine-reduce.trycloudflare.com',
    'http://127.0.0.1:5094',
    'http://localhost:5094',
    'http://192.168.1.193:5094',
    'http://10.0.2.2:5094',
  ];

  static String? _workingBaseUrl;

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

    // Đưa URL đang hoạt động tốt nhất lên đầu danh sách để request nhanh tức thì
    final candidateUrls = List<String>.from(baseUrls);
    if (_workingBaseUrl != null && candidateUrls.contains(_workingBaseUrl)) {
      candidateUrls.remove(_workingBaseUrl);
      candidateUrls.insert(0, _workingBaseUrl!);
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
