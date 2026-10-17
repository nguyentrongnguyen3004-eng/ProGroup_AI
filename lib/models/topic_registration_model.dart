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

  factory TopicRegistrationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is DateTime) return d;
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    return TopicRegistrationModel(
      id: json['id'] as int? ?? json['dangKyDeTaiId'] as int? ?? 0,
      groupId: json['groupId'] as int? ?? json['nhomId'] as int? ?? 0,
      topicId: json['topicId'] as int? ?? json['deTaiId'] as int? ?? 0,
      status: json['status'] as String? ?? json['trangThai'] as String? ?? 'Chờ duyệt',
      registeredAt: parseDate(json['registeredAt'] ?? json['ngayDangKy']),
      rejectionReason: json['rejectionReason'] as String? ?? json['ghiChu'] as String?,
    );
  }

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
