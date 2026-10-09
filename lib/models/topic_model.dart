class TopicModel {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final String objective;
  final String scope;
  final String technology;
  final String source;
  final String status;

  const TopicModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.objective,
    required this.scope,
    required this.technology,
    required this.source,
    required this.status,
  });
}
