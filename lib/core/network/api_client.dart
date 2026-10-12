import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException("Kết nối đến máy chủ bị quá hạn.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Lỗi kết nối: ${e.toString()}");
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException("Kết nối đến máy chủ bị quá hạn.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Lỗi kết nối: ${e.toString()}");
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException("Kết nối đến máy chủ bị quá hạn.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Lỗi kết nối: ${e.toString()}");
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException("Kết nối đến máy chủ bị quá hạn.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Lỗi kết nối: ${e.toString()}");
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body; 
      }
    } else if (response.statusCode == 401) {
      // Token háº¿t háº¡n hoáº·c khÃ´ng há»£p lá»‡
      throw ApiException("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw ApiException(errorBody['message'] ?? errorBody['Message'] ?? "Lỗi máy chủ (${response.statusCode})");
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException("Lỗi máy chủ (${response.statusCode})");
      }
    }
  }
}
