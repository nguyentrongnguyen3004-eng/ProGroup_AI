class TopicRegistrationModel {
  final int id;
  final int groupId;
  final int topicId;
  final String status;
  final DateTime registeredAt;
  final String? rejectionReason;

  const TopicRegistrationModel({
    required this.id,
    required this.groupId,
    required this.topicId,
    required this.status,
    required this.registeredAt,
    this.rejectionReason,
  });

  TopicRegistrationModel copyWith({
    int? id,
    int? groupId,
    int? topicId,
    String? status,
    DateTime? registeredAt,
    String? rejectionReason,
  }) {
    return TopicRegistrationModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      topicId: topicId ?? this.topicId,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
