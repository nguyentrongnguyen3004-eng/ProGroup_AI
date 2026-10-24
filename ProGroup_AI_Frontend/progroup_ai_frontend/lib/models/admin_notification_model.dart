class AdminNotificationModel {
  const AdminNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AdminNotificationModel copyWith({bool? isRead}) => AdminNotificationModel(
    id: id,
    title: title,
    message: message,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );
}
