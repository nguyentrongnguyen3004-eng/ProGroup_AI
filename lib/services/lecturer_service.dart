import 'package:flutter/foundation.dart';
import '../models/lecturer_model.dart';
import 'auth_service.dart';

class LecturerService extends ChangeNotifier {
  static final LecturerService instance = LecturerService._();
  LecturerService._();

  LecturerModel _current = const LecturerModel(
    id: 1,
    lecturerCode: 'GV001',
    fullName: 'Giảng viên',
    email: 'lecturer@progroup.local',
    faculty: 'Khoa Công nghệ thông tin',
    department: 'Bộ môn Công nghệ phần mềm',
    avatar: '',
  );

  LecturerModel get current => _current;

  Future<void> loadProfile() async {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      _current = _current.copyWith(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
      );
      notifyListeners();
    }
  }

  void updateEmail(String email) {
    _current = _current.copyWith(email: email);
    notifyListeners();
  }

  void updateAvatar(String avatar) {
    _current = _current.copyWith(avatar: avatar);
    notifyListeners();
  }
}
