class AdminActivityModel {
  const AdminActivityModel({
    required this.id,
    required this.time,
    required this.actor,
    required this.action,
    required this.target,
    required this.description,
    required this.role,
    this.status = 'Thành công',
  });

  final int id;
  final DateTime time;
  final String actor;
  final String action;
  final String target;
  final String description;
  final String role;
  final String status;
}
