class LecturerTopicProposalModel {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final String objective;
  final String scope;
  final String technology;
  final String source;
  final String proposerName;
  final String groupName;
  final String status;
  final DateTime createdAt;
  final String? decisionReason;

  const LecturerTopicProposalModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.objective,
    required this.scope,
    required this.technology,
    this.source = 'Sinh viên đề xuất',
    required this.proposerName,
    required this.groupName,
    required this.status,
    required this.createdAt,
    this.decisionReason,
  });

  LecturerTopicProposalModel copyWith({
    String? source,
    String? status,
    String? decisionReason,
  }) {
    return LecturerTopicProposalModel(
      id: id,
      courseId: courseId,
      title: title,
      description: description,
      objective: objective,
      scope: scope,
      technology: technology,
      source: source ?? this.source,
      proposerName: proposerName,
      groupName: groupName,
      status: status ?? this.status,
      createdAt: createdAt,
      decisionReason: decisionReason ?? this.decisionReason,
    );
  }
}
