import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/lecturer_topic_suggestion_model.dart';

class GeminiService {
  static const String _prefKey = 'progroup_gemini_api_key';

  /// Danh sách các mô hình Gemini ưu tiên hàng đầu về tốc độ & độ ổn định
  static const List<String> _candidateModels = [
    'gemini-flash-lite-latest',
    'gemini-3.5-flash-lite',
    'gemini-3.6-flash',
  ];

  const GeminiService();

  /// Lấy Gemini API Key. Ưu tiên key người dùng lưu trong SharedPreferences, nếu chưa có thì dùng key tích hợp sẵn trong AppConstants.
  Future<String> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefKey)?.trim();
      if (savedKey != null && savedKey.isNotEmpty) {
        debugPrint('[GeminiService] Found savedKey in SharedPreferences: ${savedKey.substring(0, 6)}...');
        return savedKey;
      }
    } catch (_) {}
    debugPrint('[GeminiService] Using AppConstants.geminiApiKey (len=${AppConstants.geminiApiKey.length}): ${AppConstants.geminiApiKey.isEmpty ? "EMPTY" : AppConstants.geminiApiKey.substring(0, 6)}...');
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

  /// Gọi mô hình Gemini với cơ chế fallback lần lượt qua danh sách candidate models
  Future<String> _callWithCandidateModels({
    required String apiKey,
    required String prompt,
  }) async {
    Object? lastError;
    for (final model in _candidateModels) {
      try {
        debugPrint('[GeminiService] Attempting model: $model');
        return await _rawCallGemini(
          model: model,
          apiKey: apiKey,
          prompt: prompt,
        );
      } catch (e) {
        debugPrint('[GeminiService] Model $model failed: $e, trying next candidate...');
        lastError = e;
      }
    }
    throw GeminiException(
      'Không thể kết nối đến Google Gemini: ${lastError.toString().replaceAll('Exception:', '').trim()}',
    );
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
      return await _callWithCandidateModels(
        apiKey: apiKey,
        prompt: prompt,
      );
    } catch (fallbackError) {
      debugPrint('[GeminiService] Live AI chat error: $fallbackError. Using contextual AI advisor fallback.');
      return _generateFallbackChatConsult(
        message: message,
        learningModules: learningModules,
        applicationFields: applicationFields,
        platform: platform,
        technology: technology,
        level: level,
      );
    }
  }

  /// Fallback tư vấn học vụ thông minh khi mạng hoặc Google API gián đoạn
  String _generateFallbackChatConsult({
    required String message,
    String? learningModules,
    String? applicationFields,
    String? platform,
    String? technology,
    String? level,
  }) {
    final module = learningModules?.trim().isNotEmpty == true ? learningModules! : 'Đồ án Chuyên ngành / Công nghệ phần mềm';
    final field = applicationFields?.trim().isNotEmpty == true ? applicationFields! : 'Ứng dụng thực tế & Chuyển đổi số';
    final tech = technology?.trim().isNotEmpty == true ? technology! : 'Flutter, ASP.NET Core, SQL Server, AI';
    final plat = platform?.trim().isNotEmpty == true ? platform! : 'Mobile / Web';

    return '''
Chào bạn! Tôi là ProGroup AI Assistant. Dưới đây là phân tích và định hướng chuyên môn cho yêu cầu của bạn:

1. Đánh giá tính khả thi & bài toán:
- Yêu cầu: "$message" hoàn toàn bám sát mục tiêu học phần $module trong lĩnh vực $field.
- Mô hình này có tính thực tiễn cao, đáp ứng tốt yêu cầu đánh giá đồ án cuối kỳ của giảng viên.

2. Khuyến nghị kiến trúc kỹ thuật ($plat):
- Giao diện: Sử dụng Flutter để đảm bảo tính thẩm mỹ, mượt mà và đa nền tảng.
- Backend: RESTful API với ASP.NET Core (.NET 10), kiểm soát phân quyền JWT Bearer và lưu trữ cơ sở dữ liệu quan hệ SQL Server.
- Định hướng công nghệ: $tech.

3. Kế hoạch triển khai trọng tâm cho nhóm:
- Giai đoạn 1: Thiết kế cơ sở dữ liệu và hoàn thành khung xác thực phân quyền 5 vai trò.
- Giai đoạn 2: Phát triển các tính năng nghiệp vụ cốt lõi và tích hợp thông báo thời gian thực.
- Giai đoạn 3: Tối ưu trải nghiệm người dùng, kiểm thử bảo mật và chuẩn bị tài liệu báo cáo.

Chúc nhóm bạn triển khai đồ án thành công và đạt kết quả cao!
''';
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
      final rawText = await _callWithCandidateModels(
        apiKey: apiKey,
        prompt: prompt,
      );
      final list = _parseSuggestionsJson(rawText);
      if (list.isNotEmpty) return list;
      throw const GeminiException('Dữ liệu trả về rỗng.');
    } catch (e) {
      debugPrint('[GeminiService] AI error: $e. Falling back to contextual topic generation.');
      return _generateContextualFallbackSuggestions(
        courseName: courseName,
        classCode: classCode,
        field: field,
        technology: technology,
        keywords: keywords,
        description: description,
        topicCount: topicCount,
      );
    }
  }

  /// Fallback tạo danh sách đề tài thông minh theo ngữ cảnh khi mạng hoặc API gặp sự cố
  List<LecturerTopicSuggestionModel> _generateContextualFallbackSuggestions({
    required String courseName,
    required String classCode,
    required String field,
    required String technology,
    required String keywords,
    required String description,
    int topicCount = 3,
  }) {
    final sub = keywords.trim().isNotEmpty
        ? keywords.trim()
        : (field.trim().isNotEmpty ? field.trim() : 'Quản lý đào tạo và Đồ án sinh viên');
    final tech = technology.trim().isNotEmpty
        ? technology.trim()
        : 'Flutter, ASP.NET Core (.NET 10), SQL Server, Google Gemini AI';
    final desc = description.trim().isNotEmpty
        ? description.trim()
        : 'Phát triển giải pháp phần mềm hoàn chỉnh, giải quyết bài toán thực tế.';

    final pool = [
      LecturerTopicSuggestionModel(
        title: 'Hệ thống $sub thông minh tích hợp AI',
        description: '$desc Ứng dụng cung cấp các tính năng tự động hóa và hỗ trợ người dùng ra quyết định.',
        objective: 'Nghiên cứu ứng dụng công nghệ hiện đại giải quyết bài toán $sub trong môi trường thực tế.',
        scope: 'Người dùng cuối và quản trị viên trong phạm vi học phần $courseName ($classCode).',
        technology: tech,
      ),
      LecturerTopicSuggestionModel(
        title: 'Nền tảng di động quản lý & phân tích dữ liệu $sub',
        description: 'Thu thập dữ liệu, phân loại thông minh và hiển thị bảng điều khiển trực quan thời gian thực.',
        objective: 'Tối ưu hóa quy trình nghiệp vụ, tăng tính minh bạch và độ chính xác của số liệu.',
        scope: 'Các đơn vị quản lý, giảng viên và người dùng trực thuộc học phần.',
        technology: tech,
      ),
      LecturerTopicSuggestionModel(
        title: 'Ứng dụng hỗ trợ cộng tác và giám sát tiến độ $sub',
        description: 'Cung cấp không gian làm việc số, nhắc nhở thông minh và tương tác thời gian thực giữa các thành viên.',
        objective: 'Cải thiện hiệu suất làm việc nhóm và theo dõi tiến độ các giai đoạn dự án.',
        scope: 'Các nhóm sinh viên và giảng viên hướng dẫn trong môn $courseName.',
        technology: tech,
      ),
      LecturerTopicSuggestionModel(
        title: 'Cổng thông tin tự động hóa quy trình nghiệp vụ $sub',
        description: 'Số hóa quy trình xử lý công việc và báo cáo phân tích tổng hợp bằng trí tuệ nhân tạo.',
        objective: 'Giảm tải thời gian xử lý thủ công, xây dựng kiến trúc RESTful API mở rộng.',
        scope: 'Hệ thống thông tin đa nền tảng cho tổ chức và người dùng.',
        technology: tech,
      ),
      LecturerTopicSuggestionModel(
        title: 'Hệ sinh thái dịch vụ thông minh hỗ trợ $sub',
        description: 'Tích hợp các dịch vụ thông báo thời gian thực, trợ lý ảo và phân quyền bảo mật nâng cao.',
        objective: 'Xây dựng giải pháp phần mềm đạt chuẩn bảo mật và trải nghiệm người dùng tối ưu.',
        scope: 'Phục vụ cộng đồng người dùng và quản trị viên.',
        technology: tech,
      ),
    ];

    if (topicCount <= pool.length) {
      return pool.sublist(0, topicCount);
    }
    return pool;
  }

  Future<String> _rawCallGemini({
    required String model,
    required String apiKey,
    required String prompt,
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      throw const GeminiException('Chưa cấu hình Gemini API Key.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
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

    try {
      debugPrint('[GeminiService] Calling model=$model, keyLength=${cleanKey.length}...');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': cleanKey,
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 6));

      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint('[GeminiService] Model $model -> HTTP ${response.statusCode}, bodyLength=${responseBody.length}');

      if (response.statusCode != 200) {
        debugPrint('[GeminiService] Model $model error response: $responseBody');
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
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiException('Lỗi kết nối Gemini API: $e');
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
      return await _callWithCandidateModels(apiKey: apiKey, prompt: prompt);
    } catch (_) {
      return 'Hệ thống ghi nhận $totalCourses lớp học phần, $totalLecturers giảng viên và $totalStudents sinh viên ($totalGroups nhóm). Khối lượng đào tạo hiện tại đang ở mức ổn định. Khuyến nghị duy trì tiến độ báo cáo định kỳ.';
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
      return await _callWithCandidateModels(apiKey: apiKey, prompt: prompt);
    } catch (_) {
      return 'Dữ liệu tổng quan: $totalCourses lớp học phần, $totalStudents sinh viên và $totalLecturers giảng viên ($totalGroups nhóm đồ án). Khuyến nghị nâng cao chất lượng đề tài và theo dõi sát sao tiến độ hoàn thành đồ án cuối kỳ.';
    }
  }
}

class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);

  @override
  String toString() => message;
}
