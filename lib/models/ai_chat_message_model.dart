import 'ai_topic_recommendation_model.dart';
import 'ai_topic_request_model.dart';

class AiChatMessageModel {
  final int id;
  final String text;
  final bool isUser;
  final List<AiTopicRecommendationModel> recommendations;
  final AiTopicRequestModel? request;
  final bool? helpful;
  final String? feedbackReason;

  const AiChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    this.recommendations = const [],
    this.request,
    this.helpful,
    this.feedbackReason,
  });

  AiChatMessageModel copyWith({
    bool? helpful,
    String? feedbackReason,
    bool clearFeedbackReason = false,
  }) {
    return AiChatMessageModel(
      id: id,
      text: text,
      isUser: isUser,
      recommendations: recommendations,
      request: request,
      helpful: helpful ?? this.helpful,
      feedbackReason: clearFeedbackReason
          ? null
          : feedbackReason ?? this.feedbackReason,
    );
  }
}