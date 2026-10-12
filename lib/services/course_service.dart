import '../core/network/api_client.dart';
import '../models/course_model.dart';

class CourseService {
  Future<List<CourseModel>> getMyClasses() async {
    try {
      final response = await ApiClient.get('/lop-hoc-phan/me');
      final List<dynamic> data = response.data;
      return data.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách lớp giảng dạy: ');
    }
  }

  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await ApiClient.get('/lop-hoc-phan');
      
      List<dynamic> list = [];
      if (response is List) {
        list = response;
      } else if (response is Map && response.containsKey('data')) {
        list = response['data'] ?? [];
      } else if (response is Map && response.containsKey('items')) {
        list = response['items'] ?? [];
      }

      return list.map((json) => CourseModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getRegistrationPeriod(int classId) async {
    try {
      final response = await ApiClient.get('/lop-hoc-phan/$classId/dot-dang-ky');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsInClass(int classId) async {
    try {
      final response = await ApiClient.get('/lop-hoc-phan/$classId/sinh-vien');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}


