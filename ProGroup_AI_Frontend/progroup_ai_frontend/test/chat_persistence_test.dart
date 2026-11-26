import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/chat/chat_screen.dart';
import 'package:progroup_ai_frontend/services/chat_storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ChatStorageService saves, loads, appends, and clears messages', () async {
    const roomId = 'group_101';
    final now = DateTime(2026, 11, 26, 14, 50);

    await ChatStorageService.instance.saveMessages(roomId, [
      {
        'id': 'm1',
        'senderId': '10',
        'type': 'text',
        'name': 'User A',
        'message': 'Chào cả nhóm',
        'me': true,
        'createdAt': now,
        'time': '14:50',
      },
    ]);

    await ChatStorageService.instance.appendMessage(roomId, {
      'id': 'm2',
      'senderId': '20',
      'type': 'text',
      'name': 'User B',
      'message': 'Chào bạn nha',
      'me': false,
      'createdAt': now.add(const Duration(minutes: 1)),
      'time': '14:51',
    });

    final loadedForUser10 = await ChatStorageService.instance.loadMessages(
      roomId,
      currentUserId: '10',
    );
    expect(loadedForUser10.length, 2);
    expect(loadedForUser10[0]['message'], 'Chào cả nhóm');
    expect(loadedForUser10[0]['me'], isTrue);
    expect(loadedForUser10[1]['message'], 'Chào bạn nha');
    expect(loadedForUser10[1]['me'], isFalse);

    final loadedForUser20 = await ChatStorageService.instance.loadMessages(
      roomId,
      currentUserId: '20',
    );
    expect(loadedForUser20[0]['me'], isFalse);
    expect(loadedForUser20[1]['me'], isTrue);

    await ChatStorageService.instance.clearRoom(roomId);
    final afterClear = await ChatStorageService.instance.loadMessages(roomId);
    expect(afterClear, isEmpty);
  });

  testWidgets('ChatScreen persists sent messages across exit and reopen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(groupName: 'Nhóm Test Persistence', groupId: 777),
      ),
    );
    await tester.pumpAndSettle();

    // Send a message
    const testMsg = 'Tin nhắn test không bị mất';
    await tester.enterText(find.byType(TextField), testMsg);
    await tester.tap(find.byTooltip('Gửi'));
    await tester.pumpAndSettle();

    expect(find.text(testMsg), findsOneWidget);

    // Simulate leaving ChatScreen
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();

    // Reopen ChatScreen for the same group
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(groupName: 'Nhóm Test Persistence', groupId: 777),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(testMsg), findsOneWidget);
  });
}
