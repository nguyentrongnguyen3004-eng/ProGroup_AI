import 'dart:convert';
import 'dart:io';

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
    'http://127.0.0.1:5094',
    'http://192.168.1.193:5094',
    'http://10.0.2.2:5094',
  ];

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

    for (final baseUrl in baseUrls) {
      HttpClient? client;
      try {
        client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
        final uri = Uri.parse('$baseUrl$normalizedPath');

        final HttpClientRequest request;
        switch (method.toUpperCase()) {
          case 'POST':
            request = await client.postUrl(uri);
            break;
          case 'PUT':
            request = await client.putUrl(uri);
            break;
          case 'DELETE':
            request = await client.deleteUrl(uri);
            break;
          case 'GET':
          default:
            request = await client.getUrl(uri);
            break;
        }

        _headers().forEach((k, v) => request.headers.set(k, v));

        if (body != null && (method == 'POST' || method == 'PUT')) {
          request.write(jsonEncode(body));
        }

        final response =
            await request.close().timeout(const Duration(seconds: 8));
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode >= 200 && response.statusCode < 300) {
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

        // Nếu máy chủ đã phản hồi mã lỗi HTTP (400, 401, 403, 404, 409...),
        // nghĩa là đã kết nối thành công tới API, ném lỗi ra ngay lập tức
        throw lastError;
      } on SocketException catch (_) {
        lastError = ApiException(
          'Không thể kết nối đến máy chủ tại $baseUrl. Vui lòng kiểm tra kết nối mạng.',
          null,
        );
      } on HttpException catch (e) {
        lastError = ApiException('Lỗi giao thức HTTP: ${e.message}', null);
      } on ApiException {
        rethrow;
      } catch (e) {
        lastError = ApiException('Lỗi kết nối: ${e.toString()}', null);
      } finally {
        client?.close();
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
