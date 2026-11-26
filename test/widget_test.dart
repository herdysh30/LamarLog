import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lamarlog/core/database/app_database.dart';
import 'package:lamarlog/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('LamarLogApp renders Pipeline shell',
      (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(LamarLogApp(database: db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('LamarLog'), findsOneWidget);
    expect(find.text('Pipeline'), findsWidgets);
    expect(find.text('Track Job'), findsOneWidget);

    // Unmount widget tree and flush Drift's internal stream cleanup timers
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() => db.close());
  });
}
