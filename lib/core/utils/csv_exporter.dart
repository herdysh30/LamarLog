import 'package:intl/intl.dart';

import '../database/app_database.dart';
import '../enums/application_enums.dart';

class CsvExporter {
  const CsvExporter._();

  static const List<String> headers = [
    'ID',
    'Company',
    'Role',
    'Platform',
    'Status',
    'Priority',
    'Workplace',
    'Job Type',
    'Location',
    'Expected Salary',
    'Offered Salary',
    'Currency',
    'Salary Period',
    'Applied Date',
    'Last Updated',
    'Recruiter Name',
    'Recruiter Contact',
    'Vacancy URL',
  ];

  /// Escapes a single CSV field according to RFC 4180.
  static String escapeCell(String? value) {
    final text = value ?? '';
    final needsQuotes = text.contains(',') ||
        text.contains('"') ||
        text.contains('\n') ||
        text.contains('\r');
    if (!needsQuotes) return text;
    return '"${text.replaceAll('"', '""')}"';
  }

  /// Builds a UTF-8 BOM-prefixed CSV spreadsheet of [applications].
  static String buildApplicationsCsv(
    List<JobApplication> applications, {
    Map<String, String> customStageNames = const {},
    bool includeBom = true,
  }) {
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final buffer = StringBuffer();
    if (includeBom) {
      buffer.write('\uFEFF');
    }
    buffer.writeln(headers.map(escapeCell).join(','));

    for (final app in applications) {
      final statusEnum = ApplicationStatus.values.firstWhere(
        (s) => s.name == app.currentStatus,
        orElse: () => ApplicationStatus.wishlist,
      );
      final statusLabel = customStageNames[statusEnum.name]?.trim();
      final resolvedStatus = (statusLabel != null && statusLabel.isNotEmpty)
          ? statusLabel
          : statusEnum.label;

      final priorityEnum = PriorityLevel.values.firstWhere(
        (p) => p.name == app.priority,
        orElse: () => PriorityLevel.medium,
      );
      final workplaceEnum = WorkplaceType.values.firstWhere(
        (w) => w.name == app.workplaceType,
        orElse: () => WorkplaceType.remote,
      );
      final jobTypeEnum = JobType.values.firstWhere(
        (j) => j.name == app.jobType,
        orElse: () => JobType.fullTime,
      );

      final row = [
        app.id,
        app.companyName,
        app.roleTitle,
        app.sourcePlatform ?? '',
        resolvedStatus,
        priorityEnum.label,
        workplaceEnum.label,
        jobTypeEnum.label,
        app.location,
        app.expectedSalary != null ? app.expectedSalary!.toStringAsFixed(0) : '',
        app.offeredSalary != null ? app.offeredSalary!.toStringAsFixed(0) : '',
        app.currency,
        app.salaryPeriod,
        app.appliedAt != null ? dateFmt.format(app.appliedAt!.toLocal()) : '',
        dateFmt.format(app.updatedAt.toLocal()),
        app.recruiterName ?? '',
        app.recruiterContact ?? '',
        app.vacancyUrl ?? '',
      ];
      buffer.writeln(row.map(escapeCell).join(','));
    }
    return buffer.toString();
  }
}
