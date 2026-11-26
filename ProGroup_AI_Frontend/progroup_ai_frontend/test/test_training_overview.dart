import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/screens/phong_dao_tao/home/training_overview_screen.dart';

void main() {
  testWidgets('Test TrainingOverviewScreen build', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TrainingOverviewScreen(),
        ),
      ),
    );
    await tester.pump();
    print('Pump 1 completed');
    await tester.pump(const Duration(seconds: 1));
    print('Pump 2 completed');
  });
}
