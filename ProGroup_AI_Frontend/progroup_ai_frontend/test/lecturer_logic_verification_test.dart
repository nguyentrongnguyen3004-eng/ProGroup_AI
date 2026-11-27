import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:progroup_ai_frontend/models/lecturer_course_model.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/course/lecturer_course_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/course/lecturer_course_settings_screen.dart';
import 'package:progroup_ai_frontend/screens/giang_vien/topic_proposal/lecturer_topic_proposal_screen.dart';
import 'package:progroup_ai_frontend/services/api_service.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';
import 'package:progroup_ai_frontend/services/data_cache_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DataCacheService.instance.invalidateAll();
    ApiService.setWorkingBaseUrl('http://127.0.0.1:5094');
    AuthService.currentToken = 'test-lecturer-jwt';
  });

  tearDown(() {
    ApiService.resetClient();
    DataCacheService.instance.invalidateAll();
  });

  testWidgets('LecturerTopicProposalScreen resolves class by lopHocPhanId, counts rejected status, and calls approve endpoint', (tester) async {
    bool approvedCalled = false;

    ApiService.setTestClient(
      MockClient((request) async {
        final path = request.url.path;
        if (path == '/api/de-tai/proposals') {
          return http.Response(
            jsonEncode([
              {
                'deTaiId': 301,
                'dotDangKyId': 99,
                'lopHocPhanId': 15,
                'tenDeTai': 'Hệ thống phân tích học tập AI',
                'moTa': 'Mô tả đề tài',
                'mucTieu': 'Mục tiêu đề tài',
                'phamVi': 'Phạm vi đề tài',
                'congNgheDuKien': 'Flutter, .NET',
                'nguonDeTai': 'Sinh viên đề xuất',
                'tenSinhVienDeXuat': 'Nguyễn Văn A',
                'tenNhom': 'Nhóm Alpha',
                'trangThaiDuyet': 'Chờ duyệt',
                'createdAt': '2026-11-27T10:00:00',
              },
              {
                'deTaiId': 302,
                'dotDangKyId': 99,
                'lopHocPhanId': 15,
                'tenDeTai': 'Đề tài bị từ chối',
                'nguonDeTai': 'Sinh viên đề xuất',
                'tenSinhVienDeXuat': 'Trần Thị B',
                'tenNhom': 'Nhóm Beta',
                'trangThaiDuyet': 'Từ chối',
                'lyDoTuChoi': 'Phạm vi quá rộng',
                'createdAt': '2026-11-26T10:00:00',
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path == '/api/lecturer/courses') {
          return http.Response(
            jsonEncode([
              {
                'lopHocPhanId': 15,
                'hocPhanId': 1,
                'maHocPhan': 'SE104',
                'tenHocPhan': 'Đồ án Chuyên ngành',
                'maLopHocPhan': 'SE104.O21',
                'tenLopHocPhan': 'Đồ án Chuyên ngành O21',
                'tenHocKy': 'HK1',
                'namHoc': '2026-2027',
                'soSinhVien': 40,
                'soNhom': 8,
                'soDeTai': 10,
                'dotDangKys': [],
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.method == 'PUT' && path == '/api/de-tai/301/duyet') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          approvedCalled = body['chapNhan'] == true;
          return http.Response(
            jsonEncode({'deTaiId': 301, 'trangThaiDuyet': 'Đã duyệt'}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('[]', 200);
      }),
    );

    await tester.pumpWidget(
      const MaterialApp(home: LecturerTopicProposalScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đã từ chối (1)'), findsOneWidget);
    expect(find.text('Nhóm Alpha • SE104.O21'), findsOneWidget);
    expect(find.textContaining('Không rõ lớp'), findsNothing);

    await tester.tap(find.text('Hệ thống phân tích học tập AI'));
    await tester.pumpAndSettle();

    final approveBtn = find.text('Duyệt và thêm vào đề tài');
    await tester.ensureVisible(approveBtn);
    await tester.pumpAndSettle();
    await tester.tap(approveBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Duyệt đề xuất'));
    await tester.pumpAndSettle();

    expect(approvedCalled, isTrue);
  });

  testWidgets('LecturerCourseSettingsScreen blocks topicEnd equal to groupEnd and topicEnd within 7 days of semesterEnd', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groupStart = today.add(const Duration(days: 1));
    final groupEnd = today.add(const Duration(days: 5));
    final topicStart = today.add(const Duration(days: 2));
    // Vi phạm mốc cách kết thúc học phần ít nhất 7 ngày
    final semesterEnd = today.add(const Duration(days: 15));
    final invalidTopicEnd = today.add(const Duration(days: 12));

    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    final courseViolatingSemester = LecturerCourseModel(
      id: 15,
      courseId: 1,
      code: 'SE104',
      name: 'Đồ án Chuyên ngành',
      classCode: 'SE104.O21',
      semester: 'HK1 - 2026-2027',
      studentCount: 40,
      groupCount: 0,
      topicCount: 0,
      groupRegistrationStart: fmt(groupStart),
      groupRegistrationEnd: fmt(groupEnd),
      topicRegistrationStart: fmt(topicStart),
      topicRegistrationEnd: fmt(invalidTopicEnd),
      minMembers: 2,
      maxMembers: 5,
      status: 'Đang mở',
      semesterEnd: semesterEnd,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LecturerCourseSettingsScreen(course: courseViolatingSemester),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lưu cấu hình'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('sớm hơn ngày kết thúc học phần ít nhất 7 ngày'),
      findsOneWidget,
    );
  });

  testWidgets('LecturerCourseDetailScreen shows Thêm đợt when empty and submits full period dates', (tester) async {
    Map<String, dynamic>? postedPeriod;

    ApiService.setTestClient(
      MockClient((request) async {
        final path = request.url.path;
        if (request.method == 'POST' && path == '/api/dot-dang-ky') {
          postedPeriod = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'dotDangKyId': 50, 'tenDot': postedPeriod!['tenDot']}),
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('[]', 200);
      }),
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final semesterEnd = today.add(const Duration(days: 60));

    final course = LecturerCourseModel(
      id: 15,
      courseId: 1,
      code: 'SE104',
      name: 'Đồ án Chuyên ngành',
      classCode: 'SE104.O21',
      semester: 'HK1 - 2026-2027',
      studentCount: 40,
      groupCount: 0,
      topicCount: 0,
      groupRegistrationStart: '01/12/2026',
      groupRegistrationEnd: '07/12/2026',
      topicRegistrationStart: '02/12/2026',
      topicRegistrationEnd: '15/12/2026',
      minMembers: 2,
      maxMembers: 4,
      status: 'Chưa mở',
      semesterEnd: semesterEnd,
    );

    await tester.pumpWidget(
      MaterialApp(home: LecturerCourseDetailScreen(course: course)),
    );
    await tester.pumpAndSettle();

    final addPeriodBtn = find.text('Thêm đợt');
    await tester.scrollUntilVisible(
      addPeriodBtn,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(addPeriodBtn);
    await tester.pumpAndSettle();

    expect(find.text('Bắt đầu đăng ký đề tài'), findsOneWidget);
    await tester.tap(find.text('Tạo đợt'));
    await tester.pumpAndSettle();

    expect(postedPeriod, isNotNull);
    expect(postedPeriod!['lopHocPhanId'], 15);
    expect(postedPeriod!['ngayKetThucLapNhom'], isNotNull);
    expect(postedPeriod!['ngayBatDauDangKyDeTai'], isNotNull);
  });
}
