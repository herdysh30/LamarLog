import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lamarlog/core/database/app_database.dart';
import 'package:lamarlog/core/widgets/applyflow_widgets.dart';
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

  testWidgets(
      'Landscape mode puts logo in sidebar and shows Kanban items without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(NativeDatabase.memory());
    final now = DateTime.now().toUtc();
    await db.insertApplicationWithTransition(
      JobApplicationsCompanion.insert(
        id: 'app-land-1',
        companyName: 'Acme Landscape',
        roleTitle: 'Flutter Engineer',
        currentStatus: const Value('wishlist'),
        createdAt: now,
        updatedAt: now,
      ),
      StatusTransitionsCompanion.insert(
        id: 'tx-land-1',
        applicationId: 'app-land-1',
        toStatus: 'wishlist',
        transitionedAt: now,
      ),
    );

    await tester.pumpWidget(LamarLogApp(database: db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Sidebar displays the brand logo mark and hides the duplicate top AppBar
    expect(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byType(LamarLogLogoMark),
      ),
      findsOneWidget,
    );
    expect(find.byType(ApplyFlowAppBar), findsNothing);

    // Kanban item renders cleanly with zero RenderFlex overflow
    expect(find.text('Acme Landscape'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() => db.close());
  });

  testWidgets('Pushing a route from AppShell has no duplicate Hero tag error',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final captured = <String>[];
    final prevErr = FlutterError.onError;
    FlutterError.onError = (details) {
      captured.add(details.toString());
    };

    final db = AppDatabase(NativeDatabase.memory());
    try {
      await tester.pumpWidget(LamarLogApp(database: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Track Job'));
      await tester.pumpAndSettle();

      FlutterError.onError = prevErr;
      expect(captured, isEmpty);
      expect(find.byType(TextFormField), findsWidgets);
      expect(tester.getSize(find.byType(ListView)).height, greaterThan(400));
      expect(tester.getTopLeft(find.byType(FilledButton)).dy, greaterThan(650));
    } finally {
      FlutterError.onError = prevErr;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() => db.close());
    }
  });
}
