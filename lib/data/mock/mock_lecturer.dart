import 'package:flutter/foundation.dart';

import '../../models/lecturer_model.dart';

class MockLecturer extends ChangeNotifier {
  MockLecturer._();

  static final MockLecturer instance = MockLecturer._();

  static LecturerModel _current = const LecturerModel(
    id: 1,
    lecturerCode: 'GV001',
    fullName: 'Nguyễn Văn Bình',
    email: 'binh.nguyen@example.com',
    faculty: 'Khoa Công nghệ thông tin',
    department: 'Bộ môn Công nghệ phần mềm',
    avatar: '',
  );

  static LecturerModel get current => _current;

  static void updateEmail(String email) {
    _current = _current.copyWith(email: email);
    instance.notifyListeners();
  }

  static void updateAvatar(String avatar) {
    _current = _current.copyWith(avatar: avatar);
    instance.notifyListeners();
  }
}
