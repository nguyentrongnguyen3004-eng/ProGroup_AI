class AiTopicRequestModel {
  final String message;
  final Set<String> learningModules;
  final Set<String> applicationFields;
  final String level;
  final String platform;
  final String technology;
  final Set<String> priorities;

  const AiTopicRequestModel({
    required this.message,
    this.learningModules = const {},
    this.applicationFields = const {},
    this.level = 'Trung bình',
    this.platform = 'Web',
    this.technology = '',
    this.priorities = const {},
  });
}