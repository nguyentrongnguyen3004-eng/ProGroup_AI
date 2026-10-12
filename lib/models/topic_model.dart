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
  final String lecturerName;

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
    this.lecturerName = '',
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['deTaiId'] ?? 0,
      courseId: json['dotDangKyId'] ?? 0,
      title: json['tenDeTai'] ?? '',
      description: json['moTa'] ?? '',
      objective: json['mucTieu'] ?? '',
      scope: json['phamVi'] ?? '',
      technology: json['congNgheDuKien'] ?? '',
      source: json['nguonDeTai'] ?? 'Giảng viên',
      status: json['trangThaiDuyet'] ?? 'Chờ duyệt',
      lecturerName: json['giangVienTen'] ?? '',
    );
  }
}
