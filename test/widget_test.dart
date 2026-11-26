import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:applyflow/core/database/app_database.dart';
import 'package:applyflow/main.dart';

void main() {
  testWidgets('ApplyFlowApp renders Pipeline shell', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ApplyFlowApp(database: db));
    await tester.pumpAndSettle();

    expect(find.text('ApplyFlow'), findsOneWidget);
    expect(find.text('Pipeline'), findsWidgets);
    expect(find.text('Track Job'), findsOneWidget);
  });
}
