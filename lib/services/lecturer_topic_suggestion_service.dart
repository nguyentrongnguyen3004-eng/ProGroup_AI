import '../models/lecturer_topic_suggestion_model.dart';

class LecturerTopicSuggestionService {
  const LecturerTopicSuggestionService();

  Future<List<LecturerTopicSuggestionModel>> suggest({
    required int courseId,
    required String field,
    required String technology,
    required String keywords,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (courseId <= 0) {
      throw ArgumentError.value(courseId, 'courseId', 'Must be positive.');
    }

    final subject = keywords.trim().isNotEmpty ? keywords.trim() : field.trim();
    if (subject.isEmpty && description.trim().isEmpty) return const [];

    final topic = subject.isEmpty ? 'học tập' : subject;
    final stack = technology.trim().isEmpty ? 'Flutter, Firebase' : technology;
    final context = description.trim().isEmpty
        ? 'Ứng dụng hỗ trợ người dùng theo dõi và xử lý công việc.'
        : description.trim();

    return [
      LecturerTopicSuggestionModel(
        title: 'Hệ thống hỗ trợ $topic thông minh',
        description: context,
        objective: 'Xây dựng giải pháp thực tế cho lĩnh vực $topic.',
        scope: field.trim().isEmpty ? 'Sinh viên đại học.' : field.trim(),
        technology: stack,
      ),
      LecturerTopicSuggestionModel(
        title: 'Ứng dụng quản lý và phân tích $topic',
        description: 'Thu thập dữ liệu, theo dõi tiến độ và trình bày kết quả.',
        objective: 'Giúp người dùng quản lý $topic dựa trên dữ liệu.',
        scope: 'Ứng dụng thử nghiệm trong một lớp học phần.',
        technology: stack,
      ),
      LecturerTopicSuggestionModel(
        title: 'Nền tảng cộng tác cho $topic',
        description:
            'Cung cấp không gian cộng tác, nhắc việc và chia sẻ thông tin.',
        objective: 'Cải thiện việc phối hợp và trao đổi trong lĩnh vực $topic.',
        scope: 'Nhóm người dùng trong phạm vi học phần.',
        technology: stack,
      ),
    ];
  }
}
