class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String roleName;
  final String? mssv;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    required this.roleName,
    this.mssv,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      roleName: json['roleName'] ?? '',
      mssv: json['mssv'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'role': role,
      'roleName': roleName,
      'mssv': mssv,
      'avatarUrl': avatarUrl,
    };
  }
}
