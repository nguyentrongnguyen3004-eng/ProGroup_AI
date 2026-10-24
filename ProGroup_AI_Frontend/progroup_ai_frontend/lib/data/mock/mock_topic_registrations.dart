import '../../models/topic_registration_model.dart';

class MockTopicRegistrations {
  static final List<TopicRegistrationModel> registrations = [];

  static TopicRegistrationModel? getByGroupId(int groupId) {
    try {
      return registrations.firstWhere(
        (registration) => registration.groupId == groupId,
      );
    } catch (_) {
      return null;
    }
  }

  static TopicRegistrationModel? getByGroupAndTopic(int groupId, int topicId) {
    try {
      return registrations.firstWhere(
        (registration) =>
            registration.groupId == groupId && registration.topicId == topicId,
      );
    } catch (_) {
      return null;
    }
  }

  static bool hasRegistrationForGroup(int groupId) {
    return registrations.any((registration) => registration.groupId == groupId);
  }

  static void add(TopicRegistrationModel registration) {
    registrations.add(registration);
  }

  static void update(TopicRegistrationModel registration) {
    final index = registrations.indexWhere(
      (item) => item.id == registration.id,
    );

    if (index == -1) {
      registrations.add(registration);
      return;
    }

    registrations[index] = registration;
  }

  static void clear() {
    registrations.clear();
  }
}
