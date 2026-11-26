import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/screens/common/auth/login/login_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/propose_topic_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/ai_topic_screen.dart';

void main() {
  testWidgets('TC_AUTH_006 & TC_AUTH_007 & TC_AUTH_013: Login validation messages and password toggle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    // Empty username -> 'Vui lòng nhập tên đăng nhập'
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    expect(find.text('Vui lòng nhập tên đăng nhập'), findsOneWidget);

    // Dismiss snackbar cleanly
    ScaffoldMessenger.of(tester.element(find.byType(LoginScreen))).clearSnackBars();
    await tester.pump();

    // Empty password -> 'Vui lòng nhập mật khẩu'
    await tester.enterText(find.byType(TextField).at(0), 'sv001');
    await tester.enterText(find.byType(TextField).at(1), '');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);

    // Password obscure toggle
    final passFieldBefore = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(passFieldBefore.obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined).first);
    await tester.pump();
    final passFieldAfter = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(passFieldAfter.obscureText, isFalse);

    // Drain background update check timer
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('TC_NFR_014: ProposeTopicScreen asks confirmation before discarding unsaved form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => const ProposeTopicScreen()),
                ),
                child: const Text('Open Propose'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Propose'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Đề tài đang nhập dở');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Bạn có muốn hủy bỏ thông tin đang nhập không?'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.byType(ProposeTopicScreen), findsOneWidget);
  });

  testWidgets('TC_STU_030: AiTopicScreen shows 1, 2, 3, 5, 10 topic count chips', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiTopicScreen()));
    await tester.pump();

    expect(find.text('1 đề tài'), findsOneWidget);
    expect(find.text('2 đề tài'), findsOneWidget);
    expect(find.text('3 đề tài'), findsOneWidget);
    expect(find.text('5 đề tài'), findsOneWidget);
    expect(find.text('10 đề tài'), findsOneWidget);
  });
}
