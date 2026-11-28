import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamarlog/app/app_shell.dart';
import 'package:lamarlog/app/theme/app_colors.dart';
import 'package:lamarlog/app/theme/app_theme.dart';
import 'package:lamarlog/core/database/app_database.dart';
import 'package:lamarlog/core/l10n/app_strings.dart';
import 'package:lamarlog/core/widgets/schedule_interview_dialog.dart';
import 'package:lamarlog/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:lamarlog/features/applications/presentation/pages/application_detail_page.dart';
import 'package:lamarlog/features/applications/presentation/pages/application_form_page.dart';
import 'package:lamarlog/features/applications/presentation/widgets/pipeline/pipeline_archive_sheet.dart';
import 'package:lamarlog/features/applications/presentation/widgets/pipeline/pipeline_filter_sheet.dart';
import 'package:lamarlog/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:lamarlog/features/settings/presentation/pages/about_page.dart';
import 'package:lamarlog/features/settings/presentation/pages/appearance_settings_page.dart';
import 'package:lamarlog/features/settings/presentation/pages/data_backup_settings_page.dart';
import 'package:lamarlog/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:lamarlog/features/settings/presentation/widgets/pipeline_stages_sheet.dart';
import 'package:lamarlog/features/settings/presentation/widgets/reminder_duration_sheet.dart';

class _ViewportCase {
  const _ViewportCase(this.name, this.size, {this.textScale = 1.0});
  final String name;
  final Size size;
  final double textScale;
}

const _viewports = [
  _ViewportCase('phone-small-portrait 320x568', Size(320, 568)),
  _ViewportCase('phone-portrait 360x640', Size(360, 640)),
  _ViewportCase('phone-portrait-bigfont 360x640@1.3x', Size(360, 640),
      textScale: 1.3),
  _ViewportCase('phone-small-landscape 568x320', Size(568, 320)),
  _ViewportCase('phone-landscape 640x360', Size(640, 360)),
  _ViewportCase('phone-landscape-bigfont 640x360@1.25x', Size(640, 360),
      textScale: 1.25),
  _ViewportCase('phone-wide-landscape 844x390', Size(844, 390)),
  _ViewportCase('tablet-portrait 768x1024', Size(768, 1024)),
  _ViewportCase('tablet-landscape 1024x768', Size(1024, 768)),
];

Future<(AppDatabase, JobApplication, JobApplication)> _seedDb() async {
  final db = AppDatabase(NativeDatabase.memory());
  final now = DateTime.now().toUtc();
  final staleDate = now.subtract(const Duration(days: 20));

  await db.insertApplicationWithTransition(
    JobApplicationsCompanion.insert(
      id: 'app-1',
      companyName: 'PT Teknologi Nusantara Digital Indonesia',
      roleTitle: 'Senior Mobile Flutter Engineer (Platform & Core)',
      location: const Value('Setiabudi, Jakarta Selatan, DKI Jakarta'),
      workplaceType: const Value('hybrid'),
      jobType: const Value('fullTime'),
      currentStatus: const Value('applied'),
      priority: const Value('high'),
      currency: const Value('IDR'),
      salaryPeriod: const Value('monthly'),
      expectedSalary: const Value(32000000),
      offeredSalary: const Value(35000000),
      vacancyUrl: const Value(
        'https://careers.teknologinusantara.co.id/jobs/senior-flutter-engineer-2026',
      ),
      sourcePlatform: const Value('LinkedIn'),
      recruiterName: const Value('Siti Rahmawati Putri'),
      recruiterContact: const Value('siti.rahmawati@teknologinusantara.co.id'),
      appliedAt: Value(staleDate),
      createdAt: staleDate,
      updatedAt: staleDate,
    ),
    StatusTransitionsCompanion.insert(
      id: 'tx-1',
      applicationId: 'app-1',
      toStatus: 'applied',
      transitionedAt: staleDate,
    ),
  );

  await db.insertApplicationWithTransition(
    JobApplicationsCompanion.insert(
      id: 'app-2',
      companyName: 'Global Fintech Corp',
      roleTitle: 'Staff Software Engineer',
      location: const Value('Singapore'),
      workplaceType: const Value('remote'),
      jobType: const Value('contract'),
      currentStatus: const Value('interview'),
      priority: const Value('medium'),
      currency: const Value('USD'),
      salaryPeriod: const Value('yearly'),
      expectedSalary: const Value(140000),
      appliedAt: Value(now.subtract(const Duration(days: 5))),
      createdAt: now.subtract(const Duration(days: 6)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    StatusTransitionsCompanion.insert(
      id: 'tx-2',
      applicationId: 'app-2',
      toStatus: 'interview',
      transitionedAt: now.subtract(const Duration(days: 1)),
    ),
  );

  await db.insertApplicationWithTransition(
    JobApplicationsCompanion.insert(
      id: 'app-3',
      companyName: 'Archived Startup Tbk',
      roleTitle: 'Product Engineer',
      currentStatus: const Value('rejected'),
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    StatusTransitionsCompanion.insert(
      id: 'tx-3',
      applicationId: 'app-3',
      toStatus: 'rejected',
      transitionedAt: now.subtract(const Duration(days: 2)),
    ),
  );

  await db.insertInterviewSchedule(
    InterviewSchedulesCompanion.insert(
      id: 'sched-1',
      applicationId: 'app-1',
      roundName: 'Technical Architecture & Live Coding Round',
      scheduledAt: now.add(const Duration(days: 2)),
      meetingUrl: const Value('https://meet.google.com/abc-defg-hij'),
    ),
  );

  await db.insertTimelineLog(
    TimelineLogsCompanion.insert(
      id: 'log-1',
      applicationId: 'app-1',
      title: 'HR Screening selesai dengan hasil sangat positif',
      note: const Value('Lanjut ke tahap technical interview minggu depan.'),
      loggedAt: now.subtract(const Duration(days: 3)),
    ),
  );

  final apps = await db.getAllApplications();
  final app1 = apps.firstWhere((a) => a.id == 'app-1');
  final app3 = apps.firstWhere((a) => a.id == 'app-3');
  return (db, app1, app3);
}

Widget _wrap({
  required AppDatabase db,
  required Widget child,
  required double textScale,
}) {
  return RepositoryProvider<AppDatabase>.value(
    value: db,
    child: BlocProvider<ApplicationsBloc>(
      create: (_) => ApplicationsBloc(db)..add(const LoadApplications()),
      child: AppLocaleScope(
        strings: const AppStrings('id'),
        child: MaterialApp(
          key: UniqueKey(),
          theme: AppTheme.light(AppColorPalette.indigo),
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: widget!,
          ),
          home: child,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('zero RenderFlex/layout overflows across all screens & viewports',
      (tester) async {
    final (db, app1, app3) = await _seedDb();
    final errors = <String>[];
    final allFailures = <String>[];
    final prevOnError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      final full = details.toString().split('\n').take(14).join('\n');
      errors.add(full);
    };

    try {
      for (final vp in _viewports) {
        tester.view.physicalSize = vp.size;
        tester.view.devicePixelRatio = 1.0;

        void record(String label) {
          if (errors.isNotEmpty) {
            allFailures.add(
              '=== [$label] @ ${vp.name} ===\n${errors.join('\n---\n')}',
            );
            errors.clear();
          }
        }

        Future<void> checkScreen(String label, Widget page) async {
          errors.clear();
          await tester.pumpWidget(
            _wrap(db: db, child: page, textScale: vp.textScale),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 250));
          record(label);
        }

        // 1. AppShell tabs (Pipeline Kanban, Pipeline List, Notifications, Analytics, Settings)
        await checkScreen(
          'AppShell/Pipeline(Kanban)',
          AppShell(
            themeMode: ThemeMode.light,
            onThemeModeChanged: (_) {},
            colorPalette: AppColorPalette.indigo,
            onColorPaletteChanged: (_) {},
            defaultCurrency: 'IDR',
            onDefaultCurrencyChanged: (_) {},
            languageCode: 'id',
            onLanguageChanged: (_) {},
            onRenameStage: (_, _) {},
            onPipelineStagesChanged: (_) {},
          ),
        );

        // Switch to List view (supports both icon-only tooltip on mobile & labeled button on wide)
        final textListBtn = find.text('Daftar');
        final listBtn = textListBtn.evaluate().isNotEmpty
            ? textListBtn
            : find.byTooltip('Daftar');
        if (listBtn.evaluate().isNotEmpty) {
          errors.clear();
          await tester.tap(listBtn.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 250));
          record('Pipeline(List)');
        }

        // Tap through Alerts, Analytics, Settings tabs
        for (final tabName in ['Notifikasi', 'Analitik', 'Pengaturan']) {
          final finder = find.text(tabName);
          if (finder.evaluate().isNotEmpty) {
            errors.clear();
            await tester.tap(finder.last);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 250));
            record('AppShell/$tabName');
          }
        }

        // 2. Sub-pages
        await checkScreen(
          'ApplicationDetailPage',
          ApplicationDetailPage(application: app1),
        );
        await checkScreen(
          'ApplicationFormPage(Edit)',
          ApplicationFormPage(existingApplication: app1),
        );
        await checkScreen(
          'AppearanceSettingsPage',
          AppearanceSettingsPage(
            themeMode: ThemeMode.light,
            onThemeModeChanged: (_) {},
            colorPalette: AppColorPalette.indigo,
            onColorPaletteChanged: (_) {},
            defaultCurrency: 'IDR',
            onDefaultCurrencyChanged: (_) {},
            languageCode: 'id',
            onLanguageChanged: (_) {},
          ),
        );
        await checkScreen(
          'NotificationSettingsPage',
          const NotificationSettingsPage(),
        );
        await checkScreen(
          'DataBackupSettingsPage',
          DataBackupSettingsPage(onPipelineStagesChanged: (_) {}),
        );
        await checkScreen('AboutPage', const AboutPage());
        await checkScreen(
          'OnboardingPage',
          OnboardingPage(
            languageCode: 'id',
            onLanguageChanged: (_) {},
            onCompleted: () {},
          ),
        );

        // 3. Key Bottom Sheets & Dialogs
        Future<void> checkModal(
          String label,
          void Function(BuildContext ctx) opener,
        ) async {
          errors.clear();
          await tester.pumpWidget(
            _wrap(
              db: db,
              textScale: vp.textScale,
              child: Builder(
                builder: (ctx) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => opener(ctx),
                      child: const Text('OpenModal'),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.text('OpenModal'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          record('Modal/$label');
        }

        await checkModal(
          'PipelineStagesManagerSheet',
          (ctx) => showPipelineStagesManagerSheet(ctx, onSave: (_) {}),
        );
        await checkModal(
          'PipelineFilterSheet',
          (ctx) => showPipelineFilterSheet(ctx, const ApplicationsState()),
        );
        await checkModal(
          'TerminalArchiveSheet',
          (ctx) => showTerminalArchiveSheet(
            context: ctx,
            terminalApps: [app3],
            onOpenDetail: (_) {},
          ),
        );
        await checkModal(
          'ScheduleInterviewDialog',
          (ctx) => showScheduleInterviewDialog(
            context: ctx,
            db: db,
            app: app1,
          ),
        );
        await checkModal(
          'ReminderDurationSheet',
          (ctx) => showReminderDurationSheet(
            context: ctx,
            initialMinutes: 60,
          ),
        );
      }

      expect(
        allFailures,
        isEmpty,
        reason: 'Found ${allFailures.length} overflow/layout failure(s):\n'
            '${allFailures.join('\n\n')}',
      );
    } finally {
      FlutterError.onError = prevOnError;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() => db.close());
    }
  });
}
