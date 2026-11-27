import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:progroup_ai_frontend/data/mock/mock_user.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/models/topic_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/group_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/propose_topic_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/topic_detail_screen.dart';
import 'package:progroup_ai_frontend/services/api_service.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';
import 'package:progroup_ai_frontend/services/data_cache_service.dart';

void main() {
  const testCourse = CourseModel(
    id: 10,
    code: 'SE104',
    name: 'Đồ án Chuyên ngành',
    classCode: 'SE104.O21',
    semester: 'HK1 2026-2027',
    lecturer: 'TS. Nguyễn Văn A',
    status: 'Đang mở',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DataCacheService.instance.invalidateAll();
    ApiService.setWorkingBaseUrl('http://127.0.0.1:5094');
    AuthService.currentToken = 'test-jwt-token';
    AuthService.currentUser = MockUser.student;
  });

  tearDown(() {
    ApiService.resetClient();
    DataCacheService.instance.invalidateAll();
  });

  testWidgets('TopicDetailScreen blocks registration when group has fewer than minMembers', (tester) async {
    bool registerCalled = false;

    ApiService.setTestClient(
      MockClient((request) async {
        final path = request.url.path;
        if (path == '/api/student/groups') {
          return http.Response(
            jsonEncode([
              {
                'nhomId': 5,
                'lopHocPhanId': 10,
                'tenNhom': 'Nhóm Thiếu Thành Viên',
                'truongNhom': MockUser.student.fullName,
                'soThanhVien': 1,
                'minMembers': 2,
                'maxMembers': 5,
                'trangThai': 'Đang hoạt động',
                'thanhViens': [
                  {'hoTen': MockUser.student.fullName}
                ],
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path == '/api/de-tai/101') {
          return http.Response(
            jsonEncode({
              'deTaiId': 101,
              'lopHocPhanId': 10,
              'tenDeTai': 'Đề tài khả dụng',
              'trangThai': 'Chưa sử dụng',
              'trangThaiDuyet': 'Đã duyệt',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path == '/api/dang-ky-de-tai/cua-nhom/5') {
          return http.Response('[]', 200);
        }
        if (path == '/api/dang-ky-de-tai') {
          registerCalled = true;
          return http.Response('{}', 200);
        }
        return http.Response('{}', 200);
      }),
    );

    const topic = TopicModel(
      id: 101,
      courseId: 10,
      lopHocPhanId: 10,
      title: 'Đề tài khả dụng',
      description: 'Mô tả',
      objective: 'Mục tiêu',
      scope: 'Phạm vi',
      technology: 'Flutter',
      source: 'Giảng viên',
      status: 'Chưa sử dụng',
      approvalStatus: 'Đã duyệt',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: TopicDetailScreen(topic: topic, course: testCourse),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('chưa đủ số thành viên tối thiểu'),
      findsOneWidget,
    );
    expect(find.text('Chưa đủ thành viên tối thiểu'), findsOneWidget);

    final minMemberBtn = find.text('Chưa đủ thành viên tối thiểu');
    await tester.ensureVisible(minMemberBtn);
    await tester.pumpAndSettle();
    await tester.tap(minMemberBtn);
    await tester.pump();
    expect(registerCalled, isFalse);
  });

  testWidgets('TopicDetailScreen blocks registration on UI when topic is already taken (Đã đăng ký)', (tester) async {
    ApiService.setTestClient(
      MockClient((request) async {
        final path = request.url.path;
        if (path == '/api/student/groups') {
          return http.Response(
            jsonEncode([
              {
                'nhomId': 5,
                'lopHocPhanId': 10,
                'tenNhom': 'Nhóm Đủ Thành Viên',
                'truongNhom': MockUser.student.fullName,
                'soThanhVien': 3,
                'minMembers': 2,
                'maxMembers': 5,
                'trangThai': 'Đang hoạt động',
                'thanhViens': [
                  {'hoTen': MockUser.student.fullName},
                  {'hoTen': 'Trần B'},
                  {'hoTen': 'Lê C'},
                ],
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path == '/api/de-tai/102') {
          return http.Response(
            jsonEncode({
              'deTaiId': 102,
              'lopHocPhanId': 10,
              'tenDeTai': 'Đề tài đã hết slot',
              'trangThai': 'Đã đăng ký',
              'trangThaiDuyet': 'Đã duyệt',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path == '/api/dang-ky-de-tai/cua-nhom/5') {
          return http.Response('[]', 200);
        }
        return http.Response('{}', 200);
      }),
    );

    const topic = TopicModel(
      id: 102,
      courseId: 10,
      lopHocPhanId: 10,
      title: 'Đề tài đã hết slot',
      description: 'Mô tả',
      objective: 'Mục tiêu',
      scope: 'Phạm vi',
      technology: 'Flutter',
      source: 'Giảng viên',
      status: 'Đã đăng ký',
      approvalStatus: 'Đã duyệt',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: TopicDetailScreen(topic: topic, course: testCourse),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đề tài đã hết slot (Đã đủ số nhóm)'), findsOneWidget);
    expect(find.text('Gửi yêu cầu đăng ký'), findsNothing);
  });

  testWidgets('GroupDetailScreen resets topic registration immediately after cancelling', (tester) async {
    bool isCancelled = false;

    ApiService.setTestClient(
      MockClient((request) async {
        final path = request.url.path;
        if (path == '/api/dang-ky-de-tai/cua-nhom/5') {
          if (isCancelled) {
            return http.Response('[]', 200);
          }
          return http.Response(
            jsonEncode([
              {
                'dangKyDeTaiId': 88,
                'nhomId': 5,
                'deTaiId': 101,
                'tenDeTai': 'Hệ thống AI',
                'trangThai': 'Chờ duyệt',
                'ngayDangKy': '2026-11-27T10:00:00',
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.method == 'DELETE' && path == '/api/dang-ky-de-tai/88') {
          isCancelled = true;
          return http.Response(
            jsonEncode({'success': true, 'message': 'Đã hủy đăng ký đề tài.'}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path == '/api/de-tai/101') {
          return http.Response(
            jsonEncode({
              'deTaiId': 101,
              'lopHocPhanId': 10,
              'tenDeTai': 'Hệ thống AI',
              'trangThai': isCancelled ? 'Chưa sử dụng' : 'Đã đăng ký',
              'trangThaiDuyet': 'Đã duyệt',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path == '/api/student/courses') {
          return http.Response(
            jsonEncode([
              {
                'lopHocPhanId': 10,
                'maHocPhan': 'SE104',
                'tenHocPhan': 'Đồ án Chuyên ngành',
                'maLopHocPhan': 'SE104.O21',
                'tenHocKy': 'HK1',
                'namHoc': '2026-2027',
                'giangVienPhuTrach': 'TS. Nguyễn Văn A',
                'trangThai': 'Đang mở',
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('[]', 200);
      }),
    );

    final group = GroupModel(
      id: 5,
      courseId: 10,
      name: 'Nhóm ProGroup',
      leader: MockUser.student.fullName,
      memberCount: 3,
      minMembers: 2,
      maxMembers: 5,
      status: 'Đang hoạt động',
      members: [MockUser.student.fullName, 'Trần B', 'Lê C'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: GroupDetailScreen(group: group),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hệ thống AI'), findsOneWidget);
    final cancelBtn = find.text('Hủy đăng ký đề tài này');
    await tester.scrollUntilVisible(cancelBtn, 200);
    await tester.pumpAndSettle();
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hủy đăng ký'));
    await tester.pumpAndSettle();

    expect(isCancelled, isTrue);
    expect(
      find.text('Nhóm chưa đăng ký đề tài nào trong học phần này.'),
      findsOneWidget,
    );
    expect(find.text('Khám phá & Đăng ký đề tài'), findsOneWidget);
    expect(find.text('Hủy đăng ký đề tài này'), findsNothing);
  });

  testWidgets('ProposeTopicScreen forwards lopHocPhanId to POST /api/de-tai/de-xuat', (tester) async {
    Map<String, dynamic>? sentPayload;

    ApiService.setTestClient(
      MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/api/de-tai/de-xuat') {
          sentPayload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'deTaiId': 999, 'tenDeTai': sentPayload!['tenDeTai']}),
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{}', 200);
      }),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ProposeTopicScreen(
          initialValues: {
            'dotDangKyId': 0,
            'lopHocPhanId': 10,
            'title': 'Ứng dụng AI gợi ý đề tài',
            'description': 'Mô tả đề tài AI',
            'objective': 'Mục tiêu đề tài AI',
            'scope': 'Phạm vi hệ thống',
            'technology': 'Flutter, Gemini',
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final submitBtn = find.text('GỬI ĐỀ XUẤT ĐỀ TÀI');
    await tester.scrollUntilVisible(
      submitBtn,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(sentPayload, isNotNull);
    expect(sentPayload!['lopHocPhanId'], 10);
    expect(sentPayload!['dotDangKyId'], 0);
    expect(sentPayload!['tenDeTai'], 'Ứng dụng AI gợi ý đề tài');
  });
}
