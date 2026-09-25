import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/main.dart';
import 'package:progroup_ai_frontend/screens/giao_vu/main/governance_data_management_screen.dart';
import 'package:progroup_ai_frontend/screens/giao_vu/main/governance_main_screen.dart';

void main() {
  testWidgets('faculty staff flows remain available at 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProGroupApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'giaovu');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.byType(GovernanceMainScreen), findsOneWidget);
    expect(find.text('Tổng quan dữ liệu khoa'), findsOneWidget);
    expect(tester.takeException(), isNull);

    NavigationBar nav() => tester.widget(find.byType(NavigationBar));
    nav().onDestinationSelected!(1);
    await tester.pumpAndSettle();
    expect(find.text('Quản lý dữ liệu'), findsOneWidget);
    await tester.tap(find.textContaining('22110001'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết sinh viên'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<GovernanceDataKind>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giảng viên').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('GV001').first);
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết giảng viên'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<GovernanceDataKind>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lớp học phần').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('LTDD-01').first);
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết lớp học phần'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    nav().onDestinationSelected!(2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phân công giảng viên'));
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận phân công'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Theo dõi đăng ký đồ án'));
    await tester.pumpAndSettle();
    expect(find.text('Tình hình theo lớp'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import dữ liệu'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn định dạng'), findsOneWidget);
    expect(find.text('Tải file mẫu'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('Tiếp tục xem trước'),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Tiếp tục xem trước'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();

    nav().onDestinationSelected!(3);
    await tester.pumpAndSettle();
    expect(find.text('Đã cập nhật dữ liệu sinh viên'), findsOneWidget);
    await tester.tap(find.text('Đã cập nhật dữ liệu sinh viên'));
    await tester.pumpAndSettle();
    expect(find.text('Đóng'), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    nav().onDestinationSelected!(4);
    await tester.pumpAndSettle();
    expect(find.text('Mã cán bộ'), findsOneWidget);
    expect(find.text('Đổi mật khẩu'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Đăng xuất'),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Đăng xuất'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
