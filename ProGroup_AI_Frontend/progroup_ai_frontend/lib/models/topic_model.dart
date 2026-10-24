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
  final String? approvalStatus;
  final String? lecturerName;

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
    this.approvalStatus,
    this.lecturerName,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? json['deTaiId'] as int? ?? 0;
    final courseId = json['courseId'] as int? ??
        json['dotDangKyId'] as int? ??
        0;
    final title = json['title'] as String? ??
        json['tenDeTai'] as String? ??
        '';
    final description = json['description'] as String? ??
        json['moTa'] as String? ??
        '';
    final objective = json['objective'] as String? ??
        json['mucTieu'] as String? ??
        '';
    final scope = json['scope'] as String? ??
        json['phamVi'] as String? ??
        '';
    final technology = json['technology'] as String? ??
        json['congNgheDuKien'] as String? ??
        '';
    final source = json['source'] as String? ??
        json['nguonDeTai'] as String? ??
        'Giảng viên đề xuất';
    final status = json['status'] as String? ??
        json['trangThai'] as String? ??
        'Chưa sử dụng';
    final approvalStatus = json['approvalStatus'] as String? ??
        json['trangThaiDuyet'] as String?;
    final lecturerName = json['lecturerName'] as String? ??
        json['giangVien'] as String?;

    return TopicModel(
      id: id,
      courseId: courseId,
      title: title,
      description: description,
      objective: objective,
      scope: scope,
      technology: technology,
      source: source,
      status: status,
      approvalStatus: approvalStatus,
      lecturerName: lecturerName,
    );
  }

  TopicModel copyWith({
    int? id,
    int? courseId,
    String? title,
    String? description,
    String? objective,
    String? scope,
    String? technology,
    String? source,
    String? status,
    String? approvalStatus,
    String? lecturerName,
  }) {
    return TopicModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      objective: objective ?? this.objective,
      scope: scope ?? this.scope,
      technology: technology ?? this.technology,
      source: source ?? this.source,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      lecturerName: lecturerName ?? this.lecturerName,
    );
  }
}
