import 'package:flutter/material.dart';

import '../../models/topic_registration_model.dart';
import 'mock_lecturer_notifications.dart';

class MockLecturerTopicRegistrations {
  static final List<TopicRegistrationModel> registrations = [
    TopicRegistrationModel(
      id: 1,
      groupId: 101,
      topicId: 1,
      status: 'Chờ duyệt',
      registeredAt: DateTime(2026, 9, 20),
    ),
    TopicRegistrationModel(
      id: 2,
      groupId: 102,
      topicId: 2,
      status: 'Đã duyệt',
      registeredAt: DateTime(2026, 9, 19),
    ),
    TopicRegistrationModel(
      id: 3,
      groupId: 104,
      topicId: 3,
      status: 'Từ chối',
      registeredAt: DateTime(2026, 9, 18),
      rejectionReason: 'Đề tài đã khóa do nhóm gửi đăng ký sau thời hạn.',
    ),
  ];

  static List<TopicRegistrationModel> getAll() {
    return List.unmodifiable(registrations);
  }

  static List<TopicRegistrationModel> getPending() {
    return registrations.where((item) => item.status == 'Chờ duyệt').toList();
  }

  static void add(TopicRegistrationModel registration) {
    registrations.add(registration);
    MockLecturerNotifications.instance.addNotification(
      type: 'Đăng ký',
      icon: Icons.assignment_outlined,
      title: 'Có đăng ký đề tài mới',
      content: 'Có đăng ký đề tài mới đang chờ giảng viên xử lý.',
    );
  }

  static void updateStatus(
    int registrationId,
    String status, {
    String? rejectionReason,
  }) {
    final index = registrations.indexWhere((item) => item.id == registrationId);

    if (index == -1) return;

    registrations[index] = registrations[index].copyWith(
      status: status,
      rejectionReason: rejectionReason,
    );
    MockLecturerNotifications.instance.addNotification(
      type: 'Đăng ký',
      icon: status == 'Đã duyệt'
          ? Icons.check_circle_outline
          : Icons.cancel_outlined,
      title: status == 'Đã duyệt'
          ? 'Đã duyệt đăng ký đề tài'
          : 'Đã từ chối đăng ký đề tài',
      content: 'Trạng thái một đăng ký đề tài đã được cập nhật.',
    );
  }
}
