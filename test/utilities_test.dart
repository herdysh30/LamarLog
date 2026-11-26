import 'package:applyflow/core/database/app_database.dart';
import 'package:applyflow/core/enums/application_enums.dart';
import 'package:applyflow/core/utils/contact_launcher.dart';
import 'package:applyflow/core/utils/csv_exporter.dart';
import 'package:applyflow/core/utils/stale_application_helper.dart';
import 'package:flutter_test/flutter_test.dart';

JobApplication _makeApp({
  String id = 'app-1',
  String companyName = 'Acme Corp',
  String roleTitle = 'Flutter Engineer',
  String currentStatus = 'applied',
  String? sourcePlatform = 'LinkedIn',
  DateTime? updatedAt,
}) {
  final ts = (updatedAt ?? DateTime.utc(2026, 5, 1)).toUtc();
  return JobApplication(
    id: id,
    companyName: companyName,
    roleTitle: roleTitle,
    location: 'Jakarta',
    workplaceType: WorkplaceType.remote.name,
    jobType: JobType.fullTime.name,
    currentStatus: currentStatus,
    priority: PriorityLevel.high.name,
    currency: 'IDR',
    salaryPeriod: SalaryPeriod.monthly.name,
    expectedSalary: 25000000,
    offeredSalary: null,
    vacancyUrl: 'https://example.com/jobs/1',
    sourcePlatform: sourcePlatform,
    recruiterName: 'Rina',
    recruiterContact: 'rina@acme.com',
    isArchived: false,
    appliedAt: ts,
    createdAt: ts,
    updatedAt: ts,
  );
}

void main() {
  group('ContactLauncher.parse', () {
    test('detects email addresses', () {
      final parsed = ContactLauncher.parse('hr@company.co.id');
      expect(parsed.kind, ContactKind.email);
      expect(parsed.primaryUri.toString(), 'mailto:hr@company.co.id');
    });

    test('detects full URLs and scheme-less domains', () {
      final full = ContactLauncher.parse('https://glints.com/id/job/123');
      expect(full.kind, ContactKind.url);
      expect(full.primaryUri.toString(), 'https://glints.com/id/job/123');

      final bare = ContactLauncher.parse('linkedin.com/in/recruiter');
      expect(bare.kind, ContactKind.url);
      expect(bare.primaryUri.toString(), 'https://linkedin.com/in/recruiter');
    });

    test('detects Indonesian & international phones with WhatsApp URI', () {
      final local = ContactLauncher.parse('0812-3456-7890');
      expect(local.kind, ContactKind.phone);
      expect(local.primaryUri.toString(), 'tel:081234567890');
      expect(local.whatsappUri.toString(), 'https://wa.me/6281234567890');

      final intl = ContactLauncher.parse('+62 812 3456 7890');
      expect(intl.kind, ContactKind.phone);
      expect(intl.whatsappUri.toString(), 'https://wa.me/6281234567890');
    });

    test('returns unknown for blank or plain notes', () {
      expect(ContactLauncher.parse('').kind, ContactKind.unknown);
      expect(ContactLauncher.parse('Ask John at front desk').kind,
          ContactKind.unknown);
    });
  });

  group('StaleApplicationHelper', () {
    final now = DateTime.utc(2026, 5, 20);

    test('flags Applied and Screening apps >= 14 days without update', () {
      final staleApplied = _makeApp(
        currentStatus: ApplicationStatus.applied.name,
        updatedAt: now.subtract(const Duration(days: 14)),
      );
      final staleScreening = _makeApp(
        currentStatus: ApplicationStatus.screening.name,
        updatedAt: now.subtract(const Duration(days: 18)),
      );
      final freshApplied = _makeApp(
        currentStatus: ApplicationStatus.applied.name,
        updatedAt: now.subtract(const Duration(days: 13)),
      );

      expect(StaleApplicationHelper.isStale(staleApplied, nowUtc: now), isTrue);
      expect(
          StaleApplicationHelper.isStale(staleScreening, nowUtc: now), isTrue);
      expect(
          StaleApplicationHelper.isStale(freshApplied, nowUtc: now), isFalse);
    });

    test('never flags Wishlist, Interview, Offering, or terminal outcomes', () {
      final oldDate = now.subtract(const Duration(days: 45));
      for (final status in [
        ApplicationStatus.wishlist,
        ApplicationStatus.interview,
        ApplicationStatus.offering,
        ApplicationStatus.rejected,
        ApplicationStatus.noResponse,
      ]) {
        final app = _makeApp(currentStatus: status.name, updatedAt: oldDate);
        expect(StaleApplicationHelper.isStale(app, nowUtc: now), isFalse);
      }
    });
  });

  group('CsvExporter', () {
    test('escapes commas, quotes, and newlines per RFC 4180', () {
      expect(CsvExporter.escapeCell('Plain'), 'Plain');
      expect(CsvExporter.escapeCell('Jakarta, ID'), '"Jakarta, ID"');
      expect(CsvExporter.escapeCell('Say "Hi"'), '"Say ""Hi"""');
      expect(CsvExporter.escapeCell('Line1\nLine2'), '"Line1\nLine2"');
    });

    test('builds UTF-8 BOM CSV containing Platform and custom stage label', () {
      final app = _makeApp(
        companyName: 'Tech, Inc.',
        sourcePlatform: 'Glints',
        currentStatus: ApplicationStatus.applied.name,
      );

      final csv = CsvExporter.buildApplicationsCsv(
        [app],
        customStageNames: {'applied': 'Sudah Kirim'},
      );

      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv, contains('ID,Company,Role,Platform,Status'));
      expect(csv, contains('"Tech, Inc.",Flutter Engineer,Glints,Sudah Kirim'));
    });
  });
}
