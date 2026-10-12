import '../core/network/api_client.dart';

class AdminService {
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await ApiClient.get('/admin/users');
      final List<dynamic> data = response is List ? response : [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách người dùng: $e');
    }
  }

  Future<void> updateUserStatus(int id, bool status) async {
    try {
      await ApiClient.put('/admin/users/$id/status', {
        'trangThai': status,
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái người dùng: $e');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await ApiClient.get('/admin/stats');
      return response is Map<String, dynamic> ? response : {};
    } catch (e) {
      throw Exception('Lỗi khi lấy thống kê hệ thống: $e');
    }
  }
}
