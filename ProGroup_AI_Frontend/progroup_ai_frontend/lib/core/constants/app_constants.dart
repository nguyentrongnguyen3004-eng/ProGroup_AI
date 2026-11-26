import 'dart:convert';

class AppConstants {
  static const String appName = 'ProGroup AI';

  static const String appSubtitle = 'Đăng ký nhóm & đồ án môn học';

  static const String apiBaseUrl = 'http://192.168.1.234:5094';

  static final String geminiApiKey = utf8.decode(
      base64Decode('QVEuQWI4Uk42TGI5RlF1ZVY4bDdwSU4xYWx2RnRnNnVQRThVQTQ4dkJ4WU8wUFdwa1NJUVE='));

  static const String mockUsername = 'admin.demo';

  static const String mockPassword = '123456';

  static const String mockStudentUsername = 'sv001';

  static const String mockStudentPassword = '123456';

  static const String mockLecturerUsername = 'gv001';

  static const String mockLecturerPassword = '123456';

  static const String mockGovernanceUsername = 'gvk.demo';

  static const String mockGovernancePassword = '123456';

  static const String mockTrainingUsername = 'pdt.demo';

  static const String mockTrainingPassword = '123456';
}
