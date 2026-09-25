import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/models/ai_feedback_model.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/ai_topic_screen.dart';
import 'package:progroup_ai_frontend/services/ai_feedback_service.dart';

void main() {
  testWidgets('negative feedback stores its reason and chat context', (
    tester,
  ) async {
    final feedbackService = AiFeedbackService();
    await tester.pumpWidget(
      MaterialApp(
        home: AiTopicScreen(feedbackService: feedbackService),
      ),
    );

    const prompt = 'Tôi muốn làm ứng dụng Flutter quản lý chi tiêu';
    await tester.enterText(find.byType(TextField).last, prompt);
    await tester.tap(find.byTooltip('Gửi'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final dislikeButton = find.byTooltip('Chưa phù hợp');
    await tester.ensureVisible(dislikeButton);
    await tester.tap(dislikeButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Không đúng lĩnh vực'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi nhận xét'));
    await tester.pumpAndSettle();

    final feedback = feedbackService.submittedFeedback.single;
    expect(feedback, isA<AiFeedbackModel>());
    expect(feedback.helpful, isFalse);
    expect(feedback.feedbackReason, 'Không đúng lĩnh vực');
    expect(feedback.userMessage, prompt);
    expect(feedback.aiResponse, contains('đã xếp hạng'));
    expect(feedback.messageId, greaterThan(0));
    expect(feedback.conversationId, isNotEmpty);
  });
}