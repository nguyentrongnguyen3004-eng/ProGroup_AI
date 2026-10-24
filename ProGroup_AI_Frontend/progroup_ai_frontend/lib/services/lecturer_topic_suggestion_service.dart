import '../data/mock/mock_lecturer_courses.dart';
import '../models/lecturer_topic_suggestion_model.dart';
import 'gemini_service.dart';

class LecturerTopicSuggestionService {
  final GeminiService _geminiService;

  const LecturerTopicSuggestionService({
    GeminiService? geminiService,
  }) : _geminiService = geminiService ?? const GeminiService();

  Future<List<LecturerTopicSuggestionModel>> suggest({
    required int courseId,
    required String field,
    required String technology,
    required String keywords,
    required String description,
    int topicCount = 3,
    bool forceAiOnly = false,
  }) async {
    final course = MockLecturerCourses.getByCourseId(courseId);
    final courseName = course?.name ?? 'Lớp học phần';
    final classCode = course?.classCode ?? 'N01';

    final apiKey = await _geminiService.getApiKey();

    // 1. Nếu đã có API Key của Google Gemini, ưu tiên gọi AI thật
    if (apiKey.isNotEmpty) {
      try {
        final aiResults = await _geminiService.generateTopicSuggestions(
          courseName: courseName,
          classCode: classCode,
          field: field,
          technology: technology,
          keywords: keywords,
          description: description,
          topicCount: topicCount,
        );
        if (aiResults.isNotEmpty) return aiResults;
      } catch (e) {
        if (forceAiOnly) rethrow;
        // Nếu AI thật gặp sự cố và không bắt buộc AI-only, chuyển xuống fallback thông minh
      }
    } else if (forceAiOnly) {
      throw const GeminiException(
        'Chưa cấu hình Google Gemini API Key. Vui lòng bấm vào biểu tượng cài đặt trên góc phải để dán API Key.',
      );
    }

    // 2. Dự phòng thuật toán sinh đề tài linh hoạt theo từ khóa
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final subject = keywords.trim().isNotEmpty
        ? keywords.trim()
        : (field.trim().isNotEmpty ? field.trim() : 'Ứng dụng di động & Trí tuệ nhân tạo');
    final stack = technology.trim().isNotEmpty
        ? technology.trim()
        : 'Flutter, ASP.NET Core, SQL Server, Gemini API';
    final context = description.trim().isNotEmpty
        ? description.trim()
        : 'Xây dựng giải pháp phần mềm hoàn chỉnh giải quyết nhu cầu thực tiễn.';

    return [
      LecturerTopicSuggestionModel(
        title: 'Hệ thống $subject thông minh tích hợp AI',
        description:
            '$context. Ứng dụng cung cấp các tính năng tự động hóa và hỗ trợ người dùng ra quyết định.',
        objective:
            'Nghiên cứu ứng dụng công nghệ hiện đại giải quyết bài toán $subject trong môi trường thực tế.',
        scope:
            'Người dùng cuối và quản trị viên trong phạm vi học phần $courseName ($classCode).',
        technology: stack,
      ),
      LecturerTopicSuggestionModel(
        title: 'Nền tảng quản lý và phân tích số liệu $subject',
        description:
            'Thu thập dữ liệu, phân loại thông minh và hiển thị bảng điều khiển trực quan theo thời gian thực.',
        objective:
            'Tối ưu hóa quy trình quản lý, tăng tính minh bạch và độ chính xác của số liệu.',
        scope:
            'Doanh nghiệp vừa và nhỏ hoặc đơn vị giáo dục áp dụng quy trình số.',
        technology: stack,
      ),
      LecturerTopicSuggestionModel(
        title: 'Ứng dụng hỗ trợ cộng tác và giám sát tiến độ $subject',
        description:
            'Cung cấp không gian làm việc số, nhắc nhở thông minh và tương tác thời gian thực giữa các thành viên.',
        objective:
            'Cải thiện hiệu suất làm việc nhóm và theo dõi tiến độ các giai đoạn dự án.',
        scope:
            'Các nhóm sinh viên và giảng viên hướng dẫn trong môn $courseName.',
        technology: stack,
      ),
    ];
  }
}
