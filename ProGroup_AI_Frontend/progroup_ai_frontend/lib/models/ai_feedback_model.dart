import 'ai_topic_request_model.dart';

class AiFeedbackModel {
  final String conversationId;
  final int messageId;
  final String userMessage;
  final String aiResponse;
  final AiTopicRequestModel request;
  final bool helpful;
  final String? feedbackReason;
  final String? comment;
  final DateTime createdAt;

  const AiFeedbackModel({
    required this.conversationId,
    required this.messageId,
    required this.userMessage,
    required this.aiResponse,
    required this.request,
    required this.helpful,
    this.feedbackReason,
    this.comment,
    required this.createdAt,
  });
}