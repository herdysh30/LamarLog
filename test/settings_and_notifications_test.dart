import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamarlog/app/theme/app_colors.dart';
import 'package:lamarlog/core/database/app_database.dart';
import 'package:lamarlog/core/l10n/app_strings.dart';
import 'package:lamarlog/core/models/reminder_schedule_config.dart';
import 'package:lamarlog/core/widgets/notification_permission_dialog.dart';
import 'package:lamarlog/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:lamarlog/features/settings/presentation/pages/notification_settings_page.dart';
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

  group('Customizable Automatic Reminder Schedule', () {
    test('normalizes order, clamps bounds, deduplicates, and round-trips JSON',
        () {
      const unordered = ReminderScheduleConfig(
        primaryMinutes: 30,
        secondaryMinutes: 180,
      );
      final norm = unordered.normalized();
      expect(norm.primaryMinutes, 180);
      expect(norm.secondaryMinutes, 30);
      expect(norm.minActiveMinutes, 30);

      final dup = const ReminderScheduleConfig(
        primaryMinutes: 60,
        secondaryMinutes: 60,
      ).normalized();
      expect(dup.primaryMinutes, 60);
      expect(dup.secondaryMinutes, isNull);

      final clamped = const ReminderScheduleConfig(
        primaryMinutes: 99999,
        secondaryMinutes: 1,
      ).normalized();
      expect(clamped.primaryMinutes, ReminderScheduleConfig.maxMinutes);
      expect(clamped.secondaryMinutes, ReminderScheduleConfig.minMinutes);

      final decoded = ReminderScheduleConfig.decode(norm.encode());
      expect(decoded, norm);
      expect(
        ReminderScheduleConfig.decode('invalid-json'),
        ReminderScheduleConfig.defaults,
      );
    });

    test('formats durations and eligibility checks in EN and ID', () {
      const custom = ReminderScheduleConfig(
        primaryMinutes: 2880, // 2 days
        secondaryMinutes: 30,
      );
      expect(custom.formatSummary(isId: false, short: true), '2d & 30m');
      expect(custom.formatSummary(isId: true, short: true), '2 hr & 30 mnt');

      final now = DateTime.utc(2026, 6, 1, 10, 0);
      expect(
        custom.isEligibleForReminder(
          now.add(const Duration(minutes: 45)),
          now,
        ),
        isTrue,
      );
      expect(
        custom.isEligibleForReminder(
          now.add(const Duration(minutes: 20)),
          now,
        ),
        isFalse,
      );
      expect(
        const ReminderScheduleConfig(
          primaryMinutes: null,
          secondaryMinutes: null,
        ).isEligibleForReminder(now.add(const Duration(days: 3)), now),
        isFalse,
      );
    });

    testWidgets(
        'NotificationSettingsPage allows picking preset and toggling slots',
        (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      var currentConfig = ReminderScheduleConfig.defaults;

      await tester.pumpWidget(
        RepositoryProvider<AppDatabase>.value(
          value: db,
          child: StatefulBuilder(
            builder: (context, setHostState) => AppLocaleScope(
              strings: AppStrings('en', reminderSchedule: currentConfig),
              child: MaterialApp(
                home: NotificationSettingsPage(
                  onReminderScheduleChanged: (next) {
                    setHostState(() => currentConfig = next);
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('24 hours before interview'), findsOneWidget);
      expect(find.text('1 hour before interview'), findsOneWidget);

      // Tap second slot to open duration picker and select 30m preset
      await tester.tap(find.text('1 hour before interview'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('30m'));
      await tester.pumpAndSettle();

      expect(currentConfig.primaryMinutes, 1440);
      expect(currentConfig.secondaryMinutes, 30);
      expect(find.text('30 minutes before interview'), findsOneWidget);
      expect(find.text('Reset Default'), findsOneWidget);

      // Reset back to default (24h & 1h)
      await tester.tap(find.text('Reset Default'));
      await tester.pumpAndSettle();
      expect(currentConfig, ReminderScheduleConfig.defaults);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() => db.close());
    });
  });
}
