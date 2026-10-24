import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/data/mock/mock_admin_data.dart';
import 'package:progroup_ai_frontend/models/admin_account_model.dart';
import 'package:progroup_ai_frontend/models/user_model.dart';
import 'package:progroup_ai_frontend/screens/admin/main/admin_main_screen.dart';
import 'package:progroup_ai_frontend/services/auth_service.dart';

void main() {
  final data = MockAdminData.instance;

  test('demo Admin credentials use the shared mock account collection', () {
    final admin = data.findAdminCredentials('admin', '123456');
    expect(admin, isNotNull);
    expect(admin!.role, 'Admin');
    expect(admin.fullName, 'Quản trị viên hệ thống');
    expect(data.findAdminCredentials('admin', 'wrong'), isNull);
  });

  test(
    'AuthService routes the requested demo credentials to the Admin role',
    () async {
      final user = await AuthService().login('admin', '123456');
      expect(user, isNotNull);
      expect(user!.role, 'ADMIN');
      expect(user.roleName, 'Admin');
    },
  );

  test(
    'account validation rejects duplicate values and allows the edited record',
    () {
      expect(
        data.validateAccount(
          userCode: '22110001',
          username: 'new-user',
          fullName: 'Người dùng mới',
          email: 'new@example.com',
          role: 'Sinh viên',
          password: '123456',
          confirmPassword: '123456',
        ),
        'Mã người dùng đã tồn tại.',
      );
      expect(
        data.validateAccount(
          userCode: 'SYS001',
          username: 'admin',
          fullName: 'Quản trị viên hệ thống',
          email: 'admin@progroup.local',
          role: 'Admin',
          password: '123456',
          confirmPassword: '123456',
          editingId: 2,
          requirePassword: false,
        ),
        isNull,
      );
    },
  );

  test('search, role/status filters and account CRUD update local state', () {
    var notifications = 0;
    void listener() => notifications++;
    data.addListener(listener);

    final added = data.addAccount(
      AdminAccountModel(
        id: 0,
        userCode: 'TEST-ADMIN-01',
        username: 'admin-test-user',
        fullName: 'Người dùng kiểm thử',
        email: 'admin-test-user@example.com',
        role: 'Sinh viên',
        status: MockAdminData.activeStatus,
        password: '123456',
      ),
    );
    expect(added, isTrue);
    final account = data.accounts.singleWhere(
      (item) => item.username == 'admin-test-user',
    );
    expect(data.filterAccounts(query: 'kiểm thử'), contains(account));
    expect(
      data.filterAccounts(
        role: 'Sinh viên',
        status: MockAdminData.activeStatus,
      ),
      contains(account),
    );

    final updated = account.copyWith(
      role: 'Giảng viên',
      email: 'updated-admin-test@example.com',
    );
    expect(data.updateAccount(updated), isTrue);
    expect(data.accountById(account.id)?.role, 'Giảng viên');
    expect(data.activities.first.action, 'Thay đổi role');

    expect(
      data.setAccountLocked(account.id, locked: true, currentAdminId: 2),
      isTrue,
    );
    expect(data.accountById(account.id)?.status, MockAdminData.lockedStatus);
    expect(
      data.setAccountLocked(account.id, locked: false, currentAdminId: 2),
      isTrue,
    );
    expect(data.accountById(account.id)?.status, MockAdminData.activeStatus);

    expect(data.setAccountLocked(2, locked: true, currentAdminId: 2), isFalse);
    expect(data.deleteAccount(2, currentAdminId: 2), isFalse);
    expect(data.deleteAccount(account.id, currentAdminId: 2), isTrue);
    expect(data.accountById(account.id), isNull);
    expect(notifications, greaterThanOrEqualTo(5));
    data.removeListener(listener);
  });

  test('role permissions and notification read state are available', () {
    expect(MockAdminData.permissions.keys, containsAll(MockAdminData.roles));
    expect(data.unreadCount, greaterThan(0));
    final notification = data.notifications.firstWhere((item) => !item.isRead);
    data.markNotificationRead(notification.id);
    expect(
      data.notifications
          .firstWhere((item) => item.id == notification.id)
          .isRead,
      isTrue,
    );
    data.markAllNotificationsRead();
    expect(data.unreadCount, 0);
  });

  testWidgets('Admin main navigation opens its account management screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminMainScreen(
          user: UserModel(
            id: 2,
            username: 'admin',
            fullName: 'Quản trị viên hệ thống',
            email: 'admin@progroup.local',
            role: 'ADMIN',
            roleName: 'Admin',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tổng quan hệ thống'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.people_outline).last);
    await tester.pumpAndSettle();
    expect(find.text('Quản lý người dùng'), findsOneWidget);
    expect(find.textContaining('admin@progroup.local'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
