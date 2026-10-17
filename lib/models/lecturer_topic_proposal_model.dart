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

  factory LecturerTopicProposalModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is DateTime) return d;
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    return LecturerTopicProposalModel(
      id: json['id'] as int? ?? json['deTaiId'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? json['dotDangKyId'] as int? ?? 1,
      title: json['title'] as String? ?? json['tenDeTai'] as String? ?? '',
      description: json['description'] as String? ?? json['moTa'] as String? ?? '',
      objective: json['objective'] as String? ?? json['mucTieu'] as String? ?? '',
      scope: json['scope'] as String? ?? json['phamVi'] as String? ?? '',
      technology: json['technology'] as String? ?? json['congNgheDuKien'] as String? ?? '',
      source: json['source'] as String? ?? json['nguonDeTai'] as String? ?? 'Sinh viên đề xuất',
      proposerName: json['proposerName'] as String? ?? json['sinhVienDeXuatTen'] as String? ?? json['sinhVienTen'] as String? ?? 'Sinh viên',
      groupName: json['groupName'] as String? ?? json['tenNhom'] as String? ?? '',
      status: json['status'] as String? ?? json['trangThaiDuyet'] as String? ?? 'Chờ duyệt',
      createdAt: parseDate(json['createdAt'] ?? json['ngayTao']),
      decisionReason: json['decisionReason'] as String? ?? json['lyDo'] as String? ?? json['ghiChu'] as String?,
    );
  }

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
