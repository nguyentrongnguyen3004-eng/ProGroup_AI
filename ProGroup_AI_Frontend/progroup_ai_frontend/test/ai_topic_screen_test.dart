import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/ai_topic_screen.dart';

void main() {
  testWidgets('AiTopicScreen renders form inputs, topic count chips, and generate button', (
    tester,
  ) async {
    const initialCourse = CourseModel(
      id: 12,
      code: 'SE104',
      name: 'Đồ án chuyên ngành',
      classCode: 'SE104.O21',
      semester: 'HK1 2026-2027',
      lecturer: 'TS. Nguyễn Văn A',
      status: 'Đang mở',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AiTopicScreen(initialCourse: initialCourse),
      ),
    );
    await tester.pump();

    expect(find.text('Cố vấn Đề tài AI Sinh viên'), findsOneWidget);
    expect(find.text('1 đề tài'), findsOneWidget);
    expect(find.text('3 đề tài'), findsOneWidget);
    expect(find.text('10 đề tài'), findsOneWidget);
    expect(find.text('Tạo 3 gợi ý đề tài với AI'), findsOneWidget);

    await tester.ensureVisible(find.text('5 đề tài'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 đề tài'));
    await tester.pump();
    expect(find.text('Tạo 5 gợi ý đề tài với AI'), findsOneWidget);
  });
}
