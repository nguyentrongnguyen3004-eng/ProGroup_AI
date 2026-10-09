import 'topic_model.dart';

class AiTopicRecommendationModel {
  final TopicModel topic;
  final double weightedScore;
  final double cosineSimilarity;
  final double finalScore;

  const AiTopicRecommendationModel({
    required this.topic,
    required this.weightedScore,
    required this.cosineSimilarity,
    required this.finalScore,
  });
}