import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/data/mock/mock_courses.dart';
import 'package:progroup_ai_frontend/data/mock/mock_groups.dart';
import 'package:progroup_ai_frontend/data/mock/mock_user.dart';
import 'package:progroup_ai_frontend/data/mock/mock_lecturer_courses.dart';
import 'package:progroup_ai_frontend/data/mock/mock_lecturer_groups.dart';
import 'package:progroup_ai_frontend/data/mock/mock_lecturer_notifications.dart';
import 'package:progroup_ai_frontend/data/mock/mock_lecturer_topic_proposals.dart';
import 'package:progroup_ai_frontend/data/mock/mock_lecturer_topic_registrations.dart';
import 'package:progroup_ai_frontend/data/mock/mock_lecturer_topics.dart';
import 'package:progroup_ai_frontend/data/mock/mock_lecturer.dart';
import 'package:progroup_ai_frontend/data/mock/mock_notifications.dart';
import 'package:progroup_ai_frontend/main.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/main/lecturer_main_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/home/lecturer_statistics_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/course/lecturer_course_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/group/lecturer_group_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/profile/lecturer_profile_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/topic_proposal/lecturer_topic_proposal_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/topic_registration/topic_registration_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/group_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/create_group_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/course/course_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/home/student_main_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/topic_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/propose_topic_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/ai_topic_screen.dart';
import 'package:progroup_ai_frontend/screens/common/auth/login/login_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/topic/import_topic_preview_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/topic/import_topic_screen.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/widgets/app_bottom_nav.dart';
import 'package:progroup_ai_frontend/widgets/lecturer/lecturer_bottom_nav.dart';

void main() {
  testWidgets(
    'unsupported account role does not enter Student or Lecturer UI',
    (tester) async {
      await _openLogin(tester);
      await _submitLogin(tester, 'admin', password: 'Admin@123');

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(StudentMainScreen), findsNothing);
      expect(find.byType(LecturerMainScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('student role cannot open the lecturer named route', (
    tester,
  ) async {
    await _openLogin(tester);
    final context = tester.element(find.byType(LoginScreen));
    unawaited(
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.lecturerMain, arguments: MockUser.student),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LecturerMainScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lecturer statistics show total course and topic counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LecturerStatisticsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tổng học phần'), findsOneWidget);
    expect(find.text('Tổng đề tài'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('student demo login opens the student main screen', (
    tester,
  ) async {
    await _openLogin(tester);
    await _submitLogin(tester, 'sv001');

    expect(find.byType(StudentMainScreen), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
    final navigationBar = tester.widget<NavigationBar>(
      find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.byType(NavigationBar),
      ),
    );
    expect(navigationBar.destinations, hasLength(4));
    expect(navigationBar.selectedIndex, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lecturer demo login opens lecturer main and selects the group tab',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _openLogin(tester);
      await _submitLogin(tester, 'gv001');

      expect(find.byType(LecturerMainScreen), findsOneWidget);
      expect(find.byType(LecturerBottomNav), findsOneWidget);
      final navFinder = find.descendant(
        of: find.byType(LecturerBottomNav),
        matching: find.byType(NavigationBar),
      );
      expect(
        tester.widget<NavigationBar>(navFinder).destinations,
        hasLength(5),
      );

      await tester.tap(
        find.descendant(
          of: find.byType(LecturerBottomNav),
          matching: find.text('Nhóm'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<NavigationBar>(navFinder).selectedIndex, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('create-group route uses its typed course argument', (
    tester,
  ) async {
    await _openLogin(tester);

    final context = tester.element(find.byType(TextField).first);
    unawaited(
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.createGroup, arguments: MockCourses.courses.first),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CreateGroupScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('student course navigation preserves the selected course', (
    tester,
  ) async {
    await _openLogin(tester);
    await _submitLogin(tester, 'sv001');

    await tester.tap(find.text('Lập trình di động').first);
    await tester.pumpAndSettle();
    expect(find.byType(CourseDetailScreen), findsOneWidget);
    expect(find.text('LTDD-01'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Xem đề tài'),
      300,
      scrollable: find.descendant(
        of: find.byType(CourseDetailScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Xem đề tài'));
    await tester.pumpAndSettle();
    expect(find.text('Ứng dụng quản lý đăng ký đồ án'), findsOneWidget);
    expect(find.text('Phân tích dữ liệu sinh viên'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lecturer course detail filters groups and topics by course', (
    tester,
  ) async {
    await _openLogin(tester);
    await _submitLogin(tester, 'gv001');

    await tester.tap(
      find.descendant(
        of: find.byType(LecturerBottomNav),
        matching: find.text('Lớp học phần'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lập trình di động').first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Nhóm ProGroup'),
      300,
      scrollable: find.descendant(
        of: find.byType(LecturerCourseDetailScreen),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Nhóm ProGroup'), findsOneWidget);
    expect(find.text('Nhóm IoT Team'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Quản lý đề tài của học phần'),
      300,
      scrollable: find.descendant(
        of: find.byType(LecturerCourseDetailScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Quản lý đề tài của học phần'));
    await tester.pumpAndSettle();
    expect(find.text('Ứng dụng quản lý nhóm đồ án'), findsOneWidget);
    expect(find.text('Hệ thống cảnh báo rò rỉ gas'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'student manual and AI proposals reach lecturer review and decisions',
    (tester) async {
      const manualTitle = 'Phase 8 manual proposal verification';
      const aiTitle = 'Phân tích dữ liệu học tập sinh viên';
      final unreadBefore = MockLecturerNotifications.instance.unreadCount;

      await _openLogin(tester);
      await _submitLogin(tester, 'sv001');
      await _openStudentTopicList(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tự đề xuất đề tài'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, manualTitle);
      await tester.scrollUntilVisible(
        find.text('GỬI ĐỀ XUẤT'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ProposeTopicScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('GỬI ĐỀ XUẤT'));
      await tester.pumpAndSettle();

      final manualProposal = MockLecturerTopicProposals.instance.proposals
          .firstWhere((proposal) => proposal.title == manualTitle);
      expect(manualProposal.courseId, 1);
      expect(manualProposal.proposerName, 'Nguyễn Văn An');
      expect(manualProposal.groupName, 'Nhóm ProGroup');
      expect(manualProposal.source, 'Sinh viên đề xuất');
      expect(manualProposal.status, 'Chờ duyệt');

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('AI hỗ trợ đề xuất'));
      await tester.pumpAndSettle();
      expect(find.byType(AiTopicScreen), findsOneWidget);
      final fieldSelector = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(fieldSelector);
      await tester.tap(fieldSelector);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Big Data').last);
      await tester.pumpAndSettle();
      expect(find.text('Big Data'), findsOneWidget);
      final generateButton = find.ancestor(
        of: find.text('GỢI Ý ĐỀ TÀI'),
        matching: find.byType(ElevatedButton),
      );
      await tester.scrollUntilVisible(
        generateButton,
        300,
        scrollable: find
            .descendant(
              of: find.byType(AiTopicScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(generateButton.first);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final aiResultsScroll = find
          .descendant(
            of: find.byType(AiTopicScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text(aiTitle),
        300,
        scrollable: aiResultsScroll,
      );
      expect(find.text(aiTitle), findsOneWidget);
      final useAiTopic = find.text('Dùng đề tài này').first;
      await tester.scrollUntilVisible(
        useAiTopic,
        300,
        scrollable: aiResultsScroll,
      );
      await tester.pumpAndSettle();
      await tester.tap(useAiTopic);
      await tester.pumpAndSettle();
      expect(find.byType(AiTopicScreen), findsNothing);
      expect(find.byType(TopicScreen), findsOneWidget);

      final aiProposal = MockLecturerTopicProposals.instance.proposals
          .firstWhere((proposal) => proposal.title == aiTitle);
      expect(aiProposal.courseId, 1);
      expect(aiProposal.source, 'AI đề xuất');
      expect(aiProposal.status, 'Chờ duyệt');

      await tester.pumpWidget(
        const MaterialApp(home: LecturerTopicProposalScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text(manualTitle), findsOneWidget);
      expect(find.text(aiTitle), findsOneWidget);

      await tester.tap(find.text(manualTitle));
      await tester.pumpAndSettle();
      expect(find.text('Sinh viên đề xuất'), findsOneWidget);
      await tester.tap(find.text('Duyệt và thêm vào đề tài'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duyệt đề xuất'));
      await tester.pumpAndSettle();
      expect(
        MockLecturerTopics.topics.any(
          (topic) =>
              topic.title == manualTitle &&
              topic.courseId == 1 &&
              topic.source == 'Sinh viên đề xuất',
        ),
        isTrue,
      );

      await tester.tap(find.text(aiTitle));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Từ chối đề xuất'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Từ chối đề xuất'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).last,
        'Cần thu hẹp phạm vi.',
      );
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xác nhận từ chối'));
      await tester.pumpAndSettle();

      final rejectedAiProposal = MockLecturerTopicProposals.instance.getById(
        aiProposal.id,
      );
      expect(rejectedAiProposal?.status, 'Đã từ chối');
      expect(rejectedAiProposal?.decisionReason, 'Cần thu hẹp phạm vi.');
      expect(
        MockLecturerNotifications.instance.unreadCount,
        greaterThan(unreadBefore),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('lecturer group details read member limits from course setup', (
    tester,
  ) async {
    final original = MockLecturerCourses.getByCourseId(1)!;
    final configured = original.copyWith(minMembers: 2, maxMembers: 6);
    MockLecturerCourses.update(configured);
    addTearDown(() => MockLecturerCourses.update(original));

    await tester.pumpWidget(
      MaterialApp(
        home: LecturerGroupDetailScreen(
          course: original,
          group: MockLecturerGroups.groups.first,
        ),
      ),
    );

    expect(find.text('2 - 6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lecturer profile can update email without a disposed controller',
    (tester) async {
      final originalEmail = MockLecturer.current.email;
      addTearDown(() => MockLecturer.updateEmail(originalEmail));

      await tester.pumpWidget(const MaterialApp(home: LecturerProfileScreen()));
      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        'phase8.lecturer@example.edu',
      );
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();

      expect(MockLecturer.current.email, 'phase8.lecturer@example.edu');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'registration rejection preserves its reason and closes cleanly',
    (tester) async {
      const reason = 'Cần điều chỉnh thông tin đề tài.';
      final registration = MockLecturerTopicRegistrations.getPending().first;
      final index = MockLecturerTopicRegistrations.registrations.indexWhere(
        (item) => item.id == registration.id,
      );
      addTearDown(() {
        MockLecturerTopicRegistrations.registrations[index] = registration;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: TopicRegistrationDetailScreen(registration: registration),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Từ chối đăng ký'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(TopicRegistrationDetailScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Từ chối đăng ký'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, reason);
      await tester.tap(find.text('Xác nhận từ chối'));
      await tester.pumpAndSettle();

      final updated = MockLecturerTopicRegistrations.getAll().firstWhere(
        (item) => item.id == registration.id,
      );
      expect(updated.status, 'Từ chối');
      expect(updated.rejectionReason, reason);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('CSV preview imports valid rows and reports all-invalid rows', (
    tester,
  ) async {
    const validTitle = 'Phase 8 CSV import verification';
    final rows = TopicCsvParser.parse(
      'title,description,objective,scope,technology,source,status\n'
      '$validTitle,Desc,Goal,Scope,Flutter,Lecturer,Đang hoạt động\n'
      'Missing fields,,,,,,',
      courseScopeId: 1,
    );
    expect(rows, hasLength(2));
    expect(rows.first.isValid, isTrue);
    expect(rows.last.isValid, isFalse);

    await tester.pumpWidget(_csvPreviewHost(rows, 'valid-and-invalid.csv'));
    await tester.tap(find.text('Open CSV preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận import'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận import').last);
    await tester.pumpAndSettle();

    expect(
      MockLecturerTopics.topics.any((topic) => topic.title == validTitle),
      isTrue,
    );
    final success = MockLecturerNotifications.instance.notifications.first;
    expect(success['title'], 'Import đề tài thành công');
    expect(success['content'], contains('1 đề tài, 1 dòng lỗi'));

    final invalidRows = TopicCsvParser.parse(
      'title,description,objective,scope,technology,source,status\n'
      'Missing fields,,,,,,',
      courseScopeId: 1,
    );
    final unreadBeforeFailure = MockLecturerNotifications.instance.unreadCount;
    await tester.pumpWidget(_csvPreviewHost(invalidRows, 'all-invalid.csv'));
    await tester.tap(find.text('Open CSV preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thông báo không có dòng hợp lệ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thông báo không có dòng hợp lệ'));
    await tester.pumpAndSettle();

    final failure = MockLecturerNotifications.instance.notifications.first;
    expect(failure['title'], 'Import đề tài không thành công');
    expect(failure['content'], contains('Không có dòng hợp lệ'));
    expect(
      MockLecturerNotifications.instance.unreadCount,
      unreadBeforeFailure + 1,
    );
    expect(
      MockLecturerTopics.topics.where((topic) => topic.title == validTitle),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('group detail keeps its topic list scoped to that course', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GroupDetailScreen(group: MockGroups.groups.last),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (_) =>
              TopicScreen(course: settings.arguments as CourseModel?),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Xem danh sách đề tài'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Xem danh sách đề tài'));
    await tester.pumpAndSettle();

    expect(find.text('Hệ thống cảnh báo rò rỉ gas và cháy'), findsOneWidget);
    expect(find.text('Phân tích dữ liệu sinh viên'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'student notification badge updates when a notification is read',
    (tester) async {
      await _openLogin(tester);
      await _submitLogin(tester, 'sv001');

      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomNav),
          matching: find.text('Thông báo'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text('Bạn được mời vào nhóm'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      MockNotifications.instance.addNotification(
        type: 'Hệ thống',
        icon: Icons.info_outline,
        title: 'Test notification',
        content: 'Test notification content',
        time: 'Now',
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const ProGroupApp());
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();

  expect(find.byType(TextField), findsNWidgets(2));
}

Future<void> _openStudentTopicList(WidgetTester tester) async {
  await tester.tap(find.text('Lập trình di động').first);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Xem đề tài'),
    300,
    scrollable: find.descendant(
      of: find.byType(CourseDetailScreen),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.tap(find.text('Xem đề tài'));
  await tester.pumpAndSettle();
}

Widget _csvPreviewHost(List<TopicImportPreviewRow> rows, String fileName) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => ImportTopicPreviewScreen(
                    fileName: fileName,
                    rows: rows,
                    totalRows: rows.length,
                    courseScopeId: 1,
                  ),
                ),
              );
            },
            child: const Text('Open CSV preview'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _submitLogin(
  WidgetTester tester,
  String username, {
  String password = '123456',
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), username);
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.byType(ElevatedButton).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pumpAndSettle();
}
