import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamarlog/app/theme/app_colors.dart';
import 'package:lamarlog/core/database/app_database.dart';
import 'package:lamarlog/core/l10n/app_strings.dart';
import 'package:lamarlog/core/widgets/notification_permission_dialog.dart';
import 'package:lamarlog/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:lamarlog/features/settings/presentation/pages/settings_page.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSettingsHarness({
    required AppDatabase db,
    ThemeMode themeMode = ThemeMode.system,
    ValueChanged<ThemeMode>? onThemeModeChanged,
  }) {
    return RepositoryProvider<AppDatabase>.value(
      value: db,
      child: BlocProvider<ApplicationsBloc>(
        create: (_) => ApplicationsBloc(db),
        child: AppLocaleScope(
          strings: const AppStrings('en'),
          child: MaterialApp(
            home: SettingsPage(
              themeMode: themeMode,
              onThemeModeChanged: onThemeModeChanged ?? (_) {},
              colorPalette: AppColorPalette.indigo,
              onColorPaletteChanged: (_) {},
              defaultCurrency: 'IDR',
              onDefaultCurrencyChanged: (_) {},
              languageCode: 'en',
              onLanguageChanged: (_) {},
              onPipelineStagesChanged: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  group('Multi-page Settings Hub', () {
    testWidgets('shows concise category rows without inline danger zone',
        (tester) async {
      final db = AppDatabase(NativeDatabase.memory());

      await tester.pumpWidget(buildSettingsHarness(db: db));
      await tester.pumpAndSettle();

      expect(find.text('Appearance & Language'), findsOneWidget);
      expect(find.text('Pipeline Stages'), findsOneWidget);
      expect(find.text('Notifications & Reminders'), findsOneWidget);
      expect(find.text('Data & Backup'), findsOneWidget);
      expect(find.text('About LamarLog'), findsOneWidget);

      // Heavy sub-page controls should NOT clutter the main hub
      expect(find.text('Clear All Data'), findsNothing);
      expect(find.text('Export Backup (.json)'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() => db.close());
    });

    testWidgets('navigates to Appearance sub-page and updates theme mode',
        (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      ThemeMode? selectedTheme;

      await tester.pumpWidget(
        buildSettingsHarness(
          db: db,
          onThemeModeChanged: (m) => selectedTheme = m,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Appearance & Language'));
      await tester.pumpAndSettle();

      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('Color Palette'), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(selectedTheme, ThemeMode.dark);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() => db.close());
    });

    testWidgets('navigates to Data & Backup sub-page', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());

      await tester.pumpWidget(buildSettingsHarness(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Data & Backup'));
      await tester.pumpAndSettle();

      expect(find.text('Export Backup (.json)'), findsOneWidget);
      expect(find.text('Restore Backup (.json)'), findsOneWidget);
      expect(find.text('Clear All Data'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() => db.close());
    });
  });

  group('Notification Permission Recovery Dialog', () {
    testWidgets('displays recovery message and Open Settings action',
        (tester) async {
      await tester.pumpWidget(
        AppLocaleScope(
          strings: const AppStrings('id'),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => showNotificationPermissionDialog(context),
                  child: const Text('Trigger'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Aktifkan Notifikasi di Pengaturan'), findsOneWidget);
      expect(find.text('Buka Pengaturan'), findsOneWidget);
      expect(find.text('Nanti'), findsOneWidget);

      await tester.tap(find.text('Nanti'));
      await tester.pumpAndSettle();
      expect(find.text('Aktifkan Notifikasi di Pengaturan'), findsNothing);
    });
  });
}
