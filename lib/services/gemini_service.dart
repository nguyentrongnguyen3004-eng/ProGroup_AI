import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/lecturer_topic_suggestion_model.dart';

class GeminiService {
  static const String _prefKey = 'progroup_gemini_api_key';
  static const String _defaultModel = 'gemini-3.8-flash';
  static const String _fallbackModel = 'gemini-2.5-flash';

  const GeminiService();

  /// Lấy Gemini API Key. Ưu tiên key người dùng lưu, nếu chưa có thì dùng key tích hợp sẵn trong AppConstants.
  Future<String> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefKey)?.trim();
      if (savedKey != null && savedKey.isNotEmpty) {
        return savedKey;
      }
    } catch (_) {}
    return AppConstants.geminiApiKey;
  }

  /// Lưu Gemini API Key tùy chỉnh
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, key.trim());
  }

  /// Khôi phục API Key về mặc định
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Chat tư vấn đồ án / môn học dành cho Sinh viên
  Future<String> chatConsult({
    required String message,
    String? learningModules,
    String? applicationFields,
    String? platform,
    String? technology,
    String? level,
  }) async {
    final apiKey = await getApiKey();

    final prompt = '''
Bạn là "ProGroup AI Assistant" - Trợ lý Trí tuệ Nhân tạo hỗ trợ sinh viên đại học trong việc chọn đề tài, xây dựng giải pháp công nghệ và định hướng đồ án/khóa luận.

Thông tin bối cảnh của sinh viên:
- Môn học / Học phần: ${learningModules ?? 'Công nghệ thông tin'}
- Lĩnh vực quan tâm: ${applicationFields ?? 'Ứng dụng thực tế'}
- Nền tảng mong muốn: ${platform ?? 'Mobile / Web'}
- Công nghệ dự kiến: ${technology ?? 'Flutter, .NET, AI'}
- Độ khó: ${level ?? 'Trung bình'}

Câu hỏi hoặc yêu cầu của sinh viên:
"$message"

YÊU CẦU PHẢN HỒI:
- Trả lời bằng tiếng Việt, giọng điệu chuyên nghiệp, nhiệt tình, khích lệ và mang tính định hướng học thuật cao.
- Đưa ra lời khuyên cụ thể, phân tích tính khả thi và gợi ý 1-2 hướng tiếp cận hoặc tính năng nổi bật.
- Ngắn gọn, súc tích (khoảng 3-5 đoạn ngắn hoặc các gạch đầu dòng rõ ràng), dễ đọc trên điện thoại.
''';

    try {
      return await _rawCallGemini(
        model: _defaultModel,
        apiKey: apiKey,
        prompt: prompt,
      );
    } catch (e) {
      try {
        return await _rawCallGemini(
          model: _fallbackModel,
          apiKey: apiKey,
          prompt: prompt,
        );
      } catch (fallbackError) {
        throw GeminiException(
          'Không thể kết nối đến Google Gemini: ${fallbackError.toString().replaceAll('Exception:', '').trim()}',
        );
      }
    }
  }

  /// Sinh gợi ý đề tài sử dụng Gemini REST API dành cho Giảng viên & Sinh viên
  Future<List<LecturerTopicSuggestionModel>> generateTopicSuggestions({
    required String courseName,
    required String classCode,
    required String field,
    required String technology,
    required String keywords,
    required String description,
    int topicCount = 3,
  }) async {
    final apiKey = await getApiKey();

    final prompt = _buildPrompt(
      courseName: courseName,
      classCode: classCode,
      field: field,
      technology: technology,
      keywords: keywords,
      description: description,
      topicCount: topicCount,
    );

    try {
      final rawText = await _rawCallGemini(
        model: _defaultModel,
        apiKey: apiKey,
        prompt: prompt,
      );
      return _parseSuggestionsJson(rawText);
    } catch (e) {
      // Nếu _defaultModel gặp sự cố (ví dụ quá tải mạng), thử lại với timeout ngắn hơn hoặc báo lỗi chính xác
      throw GeminiException(
        'Lỗi từ Google Gemini: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  Future<String> _rawCallGemini({
    required String model,
    required String apiKey,
    required String prompt,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
      },
    });

    final client = HttpClient();
    try {
      final request = await client.postUrl(url).timeout(const Duration(seconds: 25));
      request.headers.contentType = ContentType.json;
      request.write(requestBody);
      final response = await request.close().timeout(const Duration(seconds: 25));
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != HttpStatus.ok) {
        final dynamic errorJson = jsonDecode(responseBody);
        final message = (errorJson is Map)
            ? (errorJson['error']?['message'] ?? 'Mã lỗi HTTP ${response.statusCode}')
            : 'Mã lỗi HTTP ${response.statusCode}';
        throw GeminiException('Gemini API báo lỗi: $message');
      }

      final dynamic data = jsonDecode(responseBody);
      final parts = data['candidates']?[0]?['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw const GeminiException('Mô hình Gemini không phản hồi nội dung.');
      }

      final buffer = StringBuffer();
      for (final p in parts) {
        if (p is Map && p['text'] != null) {
          buffer.write(p['text']);
        }
      }

      final rawText = buffer.toString().trim();
      if (rawText.isEmpty) {
        throw const GeminiException('Mô hình Gemini không phản hồi nội dung.');
      }

      return rawText;
    } finally {
      client.close();
    }
  }

  List<LecturerTopicSuggestionModel> _parseSuggestionsJson(String rawText) {
    String cleanJson = rawText.trim();
    if (cleanJson.startsWith('```')) {
      final firstNewline = cleanJson.indexOf('\n');
      if (firstNewline != -1) {
        cleanJson = cleanJson.substring(firstNewline + 1);
      }
      final lastBacktick = cleanJson.lastIndexOf('```');
      if (lastBacktick != -1) {
        cleanJson = cleanJson.substring(0, lastBacktick);
      }
      cleanJson = cleanJson.trim();
    }

    final startIdx = cleanJson.indexOf('[');
    final endIdx = cleanJson.lastIndexOf(']');
    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      cleanJson = cleanJson.substring(startIdx, endIdx + 1);
    }

    final dynamic parsed = jsonDecode(cleanJson);
    if (parsed is! List) {
      throw const GeminiException('Dữ liệu trả về từ Gemini không đúng định dạng danh sách đề tài.');
    }

    final results = <LecturerTopicSuggestionModel>[];
    for (final item in parsed) {
      if (item is Map) {
        results.add(
          LecturerTopicSuggestionModel(
            title: (item['title'] ?? 'Đề tài đề xuất').toString().trim(),
            description: (item['description'] ?? '').toString().trim(),
            objective: (item['objective'] ?? '').toString().trim(),
            scope: (item['scope'] ?? 'Sinh viên trong lớp học phần').toString().trim(),
            technology: (item['technology'] ?? 'Công nghệ hiện đại').toString().trim(),
          ),
        );
      }
    }

    return results;
  }

  String _buildPrompt({
    required String courseName,
    required String classCode,
    required String field,
    required String technology,
    required String keywords,
    required String description,
    int topicCount = 3,
  }) {
    return '''
Bạn là một Giảng viên Cố vấn Đồ án Đại học và Chuyên gia Công nghệ Thông tin giàu kinh nghiệm.
Hãy gợi ý chính xác $topicCount đề tài đồ án/khóa luận thực tế, có tính ứng dụng cao và phù hợp với thông tin cung cấp dưới đây:

- Lớp học phần: $courseName (Mã lớp: $classCode)
- Lĩnh vực nghiên cứu/ứng dụng: ${field.isEmpty ? 'Công nghệ phần mềm & Hệ thống thông tin' : field}
- Công nghệ định hướng: ${technology.isEmpty ? 'Flutter, Node.js, Spring Boot, AI, Cloud' : technology}
- Từ khóa chính: ${keywords.isEmpty ? 'Ứng dụng thực tế' : keywords}
- Nhu cầu/mô tả bổ sung của giảng viên: ${description.isEmpty ? 'Đề tài đáp ứng tính khả thi trong học kỳ, có sản phẩm demo cụ thể.' : description}

QUY ĐỊNH BẮT BUỘC VỀ ĐỊNH DẠNG ĐẦU RA:
- Chỉ trả về DUY NHẤT một chuỗi JSON chuẩn (Array of Objects), KHÔNG kèm bất kỳ lời chào, lời dẫn hay văn bản giải thích nào khác.
- Mỗi phần tử trong mảng có cấu trúc đúng chuẩn:
[
  {
    "title": "Tên đề tài ngắn gọn, súc tích, thực tế",
    "description": "Mô tả bài toán thực tế và giải pháp của đề tài",
    "objective": "Mục tiêu cụ thể sinh viên cần đạt được",
    "scope": "Phạm vi hệ thống và đối tượng người dùng",
    "technology": "Danh sách công nghệ chính (ngăn cách bởi dấu phẩy)"
  }
]
''';
  }

  /// Phân tích tải học phần và phân công giảng viên bằng Gemini AI (Giáo vụ)
  Future<String> analyzeAcademicWorkload({
    required int totalCourses,
    required int totalLecturers,
    required int totalGroups,
    required int totalStudents,
  }) async {
    final apiKey = await getApiKey();
    final prompt = '''
Bạn là "ProGroup Academic AI" - Chuyên gia cố vấn quản lý đào tạo & phân bổ tải học phần đại học.
Dữ liệu hiện tại của khoa:
- Tổng số lớp học phần đang mở: $totalCourses
- Tổng số giảng viên cơ hữu: $totalLecturers
- Tổng số sinh viên: $totalStudents
- Tổng số nhóm đồ án sinh viên đã thành lập: $totalGroups

YÊU CẦU PHÂN TÍCH TỪ GEMINI AI:
1. Đánh giá tỷ lệ sinh viên / giảng viên và số nhóm trung bình mỗi giảng viên phải hướng dẫn.
2. Cảnh báo những điểm nghẽn tiềm ẩn (ví dụ quá tải giảng viên, thiếu lớp học phần hoặc số nhóm quá đông).
3. Đề xuất 3 hành động cụ thể cho Giáo vụ khoa để tối ưu hóa việc phân công và tiến độ học kỳ.
Định dạng: Trình bày súc tích, chuyên nghiệp bằng tiếng Việt, có các gạch đầu dòng rõ ràng.
''';

    try {
      return await _rawCallGemini(model: _defaultModel, apiKey: apiKey, prompt: prompt);
    } catch (_) {
      return await _rawCallGemini(model: _fallbackModel, apiKey: apiKey, prompt: prompt);
    }
  }

  /// Dự báo xu hướng và phân tích dữ liệu đào tạo bằng Gemini AI (Phòng Đào Tạo & Admin)
  Future<String> analyzeTrainingForecast({
    required int totalCourses,
    required int totalStudents,
    required int totalLecturers,
    required int totalGroups,
    String roleName = 'Phòng Đào Tạo',
  }) async {
    final apiKey = await getApiKey();
    final prompt = '''
Bạn là "ProGroup Enterprise AI" - Cố vấn phân tích chiến lược đào tạo và quản trị dữ liệu cấp trường.
Dữ liệu đào tạo tổng quan:
- Lớp học phần: $totalCourses
- Sinh viên: $totalStudents
- Giảng viên: $totalLecturers
- Nhóm đề tài đã đăng ký: $totalGroups

YÊU CẦU PHÂN TÍCH CHO $roleName:
1. Đánh giá tính cân đối giữa quy mô đào tạo và nguồn lực giảng dạy.
2. Dự báo xu hướng hoàn thành đồ án và chất lượng bảo vệ cuối kỳ.
3. Khuyến nghị 3 giải pháp cải tiến quy trình công nghệ cho ban quản trị.
Định dạng: Trình bày chuyên nghiệp, logic, ngắn gọn bằng tiếng Việt.
''';

    try {
      return await _rawCallGemini(model: _defaultModel, apiKey: apiKey, prompt: prompt);
    } catch (_) {
      return await _rawCallGemini(model: _fallbackModel, apiKey: apiKey, prompt: prompt);
    }
  }
}

class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);

  @override
  String toString() => message;
}
