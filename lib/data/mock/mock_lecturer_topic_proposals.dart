import 'package:flutter/material.dart';

import '../../models/lecturer_topic_proposal_model.dart';
import 'mock_lecturer_notifications.dart';

class MockLecturerTopicProposals extends ChangeNotifier {
  MockLecturerTopicProposals._();

  static final MockLecturerTopicProposals instance =
      MockLecturerTopicProposals._();

  final List<LecturerTopicProposalModel> _proposals = [
    LecturerTopicProposalModel(
      id: 1,
      courseId: 1,
      title: 'Ứng dụng quản lý chi tiêu sinh viên',
      description: 'Ứng dụng theo dõi thu chi và nhắc nhở ngân sách.',
      objective: 'Giúp sinh viên quản lý chi tiêu cá nhân.',
      scope: 'Sinh viên trong lớp học phần LTDD-01.',
      technology: 'Flutter, Firebase',
      proposerName: 'Nguyễn Minh Anh',
      groupName: 'Nhóm FinTrack',
      status: 'Chờ duyệt',
      createdAt: DateTime(2026, 9, 22),
    ),
    LecturerTopicProposalModel(
      id: 2,
      courseId: 3,
      title: 'Bảng điều khiển cảm biến phòng học',
      description: 'Theo dõi nhiệt độ và độ ẩm qua thiết bị IoT.',
      objective: 'Quan sát môi trường phòng học theo thời gian thực.',
      scope: 'Mô hình phòng học thông minh.',
      technology: 'ESP32, MQTT, Flutter',
      proposerName: 'Trần Quốc Bảo',
      groupName: 'IoT Makers',
      status: 'Đã từ chối',
      createdAt: DateTime(2026, 9, 20),
      decisionReason: 'Phạm vi đề tài cần thu hẹp vào một phòng học.',
    ),
  ];

  List<LecturerTopicProposalModel> get proposals =>
      List.unmodifiable(_proposals);

  LecturerTopicProposalModel? getById(int id) {
    for (final proposal in _proposals) {
      if (proposal.id == id) return proposal;
    }
    return null;
  }

  void add(LecturerTopicProposalModel proposal) {
    _proposals.insert(0, proposal);
    MockLecturerNotifications.instance.addNotification(
      type: 'Đề xuất',
      icon: Icons.lightbulb_outline,
      title: 'Có đề xuất đề tài mới',
      content: proposal.groupName + ' đã gửi đề xuất "' + proposal.title + '".',
    );
    notifyListeners();
  }

  void decide(int id, String status, {String? decisionReason}) {
    final index = _proposals.indexWhere((proposal) => proposal.id == id);
    if (index == -1) return;

    _proposals[index] = _proposals[index].copyWith(
      status: status,
      decisionReason: decisionReason,
    );
    notifyListeners();
  }
}
