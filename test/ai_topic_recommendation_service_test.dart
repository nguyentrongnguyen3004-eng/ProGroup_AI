import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/data/mock/mock_topics.dart';
import 'package:progroup_ai_frontend/models/ai_topic_request_model.dart';
import 'package:progroup_ai_frontend/services/ai_topic_recommendation_service.dart';

void main() {
  const service = AiTopicRecommendationService();

  test('ranks Big Data topics above unrelated topics', () {
    const request = AiTopicRequestModel(
      message: 'Tôi muốn phân tích dữ liệu học tập bằng Big Data',
      learningModules: {'Big Data'},
      applicationFields: {'Công nghệ thông tin'},
      platform: 'Web',
      priorities: {'Tính thực tế'},
    );

    final recommendations = service.recommend(
      request: request,
      topics: MockTopics.topics,
    );

    expect(recommendations, isNotEmpty);
    expect(recommendations.first.topic.title, 'Phân tích dữ liệu sinh viên');
    expect(
      recommendations.first.finalScore,
      greaterThanOrEqualTo(recommendations.last.finalScore),
    );
  });

  test('final score combines weighted and cosine scores at 60/40', () {
    const request = AiTopicRequestModel(
      message: 'Flutter quản lý chi tiêu',
      learningModules: {'Lập trình Mobile'},
      applicationFields: {'Tài chính'},
      platform: 'Mobile',
      technology: 'Flutter',
      priorities: {'Dễ triển khai'},
    );

    final result = service.recommend(
      request: request,
      topics: MockTopics.topics,
      limit: 1,
    ).single;

    expect(
      result.finalScore,
      closeTo(0.6 * result.weightedScore + 0.4 * result.cosineSimilarity, 1e-10),
    );
  });
}