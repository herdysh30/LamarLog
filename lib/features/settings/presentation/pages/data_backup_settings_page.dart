import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/models/pipeline_stage_config.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';
import 'about_page.dart';

class StorageStats {
  const StorageStats({
    required this.bytes,
    required this.appCount,
    required this.resumeCount,
  });

  final int bytes;
  final int appCount;
  final int resumeCount;

  String get formattedSize => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB'
      : '${(bytes / 1024).toStringAsFixed(1)} KB';

  static Future<StorageStats> load(AppDatabase db) async {
    final apps = await db.getAllApplications();
    final resumes = await db.getAllResumeAttachments();
    int totalBytes = 0;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, 'lamarlog.sqlite'));
      if (dbFile.existsSync()) {
        totalBytes += dbFile.lengthSync();
      }
      final resumesDir = Directory(p.join(dir.path, 'resumes'));
      if (resumesDir.existsSync()) {
        for (final entity in resumesDir.listSync()) {
          if (entity is File) {
            totalBytes += entity.lengthSync();
          }
        }
      }
    } catch (_) {}

    return StorageStats(
      bytes: totalBytes,
      appCount: apps.length,
      resumeCount: resumes.length,
    );
  }
}

class DataBackupSettingsPage extends StatefulWidget {
  const DataBackupSettingsPage({
    super.key,
    required this.onPipelineStagesChanged,
  });

  final ValueChanged<List<PipelineStageConfig>?> onPipelineStagesChanged;

  @override
  State<DataBackupSettingsPage> createState() => _DataBackupSettingsPageState();
}

class _DataBackupSettingsPageState extends State<DataBackupSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocaleScope.of(context);

    // Refresh storage stats whenever applications change
    context.watch<ApplicationsBloc>();

    final warningBg =
        isDark ? AppColors.warningBgDark : AppColors.warningBgLight;
    final warningFg =
        isDark ? AppColors.warningFgDark : AppColors.warningFgLight;
    final warningIcon =
        isDark ? AppColors.warningIconDark : AppColors.warningIconLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.settingsDataBackupTitle,
          style: theme.textTheme.titleMedium,
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 680,
        child: ListView(
          padding: Responsive.pagePadding(context, bottom: 32),
          children: [
            // Storage Usage Summary
            SurfaceCard(
              child: FutureBuilder<StorageStats>(
                future: StorageStats.load(db),
                builder: (context, snapshot) {
                  final stats = snapshot.data ??
                      const StorageStats(bytes: 0, appCount: 0, resumeCount: 0);
                  final fillRatio =
                      (stats.bytes / (20 * 1024 * 1024)).clamp(0.03, 1.0);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.localStorageUsage,
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            stats.formattedSize,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: fillRatio,
                          minHeight: 7,
                          backgroundColor: cs.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation(cs.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.storageBreakdown(stats.appCount, stats.resumeCount),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Backup & Export Actions
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _VaultActionTile(
                    icon: Icons.file_download_outlined,
                    iconBg: cs.primaryContainer,
                    iconFg: Colors.white,
                    title: s.exportBackup,
                    subtitle: s.exportBackupSub,
                    onTap: () => _exportBackup(context),
                  ),
                  const SizedBox(height: 10),
                  _VaultActionTile(
                    icon: Icons.table_chart_outlined,
                    iconBg: cs.tertiaryContainer.withValues(alpha: 0.2),
                    iconFg: cs.tertiary,
                    title: s.exportCsv,
                    subtitle: s.exportCsvSub,
                    onTap: () => _exportCsv(context),
                  ),
                  const SizedBox(height: 10),
                  _VaultActionTile(
                    icon: Icons.upload_file_outlined,
                    iconBg: cs.surfaceContainerHigh,
                    iconFg: cs.onSurface,
                    title: s.restoreBackup,
                    subtitle: s.restoreBackupSub,
                    onTap: () => _confirmRestore(context),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: warningBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: warningIcon,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.warningPlaintextBody,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: warningFg.withValues(alpha: 0.92),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Danger Zone
            SurfaceCard(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.delete_sweep_outlined,
                          size: 18,
                          color: cs.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s.irreversibleOp,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: cs.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.clearDataDesc,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _confirmClearAll(context),
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          size: 20,
                        ),
                        label: Text(
                          s.clearAllData,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final s = AppLocaleScope.of(context);
    final db = context.read<AppDatabase>();
    final apps = await db.getAllApplications();
    final transitions = await db.getAllTransitions();
    final logs = await db.getAllTimelineLogs();
    final schedules = await db.getAllInterviewSchedules();

    final payload = {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appVersion': AboutPage.appVersion,
      'pipelineStages': s.pipelineStages.map((st) => st.toJson()).toList(),
      'applications': apps
          .map((a) => {
                'id': a.id,
                'companyName': a.companyName,
                'roleTitle': a.roleTitle,
                'location': a.location,
                'workplaceType': a.workplaceType,
                'jobType': a.jobType,
                'currentStatus': a.currentStatus,
                'priority': a.priority,
                'currency': a.currency,
                'salaryPeriod': a.salaryPeriod,
                'expectedSalary': a.expectedSalary,
                'offeredSalary': a.offeredSalary,
                'vacancyUrl': a.vacancyUrl,
                'sourcePlatform': a.sourcePlatform,
                'recruiterName': a.recruiterName,
                'recruiterContact': a.recruiterContact,
                'isArchived': a.isArchived,
                'appliedAt': a.appliedAt?.toUtc().toIso8601String(),
                'createdAt': a.createdAt.toUtc().toIso8601String(),
                'updatedAt': a.updatedAt.toUtc().toIso8601String(),
              })
          .toList(),
      'transitions': transitions
          .map((t) => {
                'id': t.id,
                'applicationId': t.applicationId,
                'fromStatus': t.fromStatus,
                'toStatus': t.toStatus,
                'transitionedAt': t.transitionedAt.toUtc().toIso8601String(),
              })
          .toList(),
      'timelineLogs': logs
          .map((l) => {
                'id': l.id,
                'applicationId': l.applicationId,
                'title': l.title,
                'note': l.note,
                'loggedAt': l.loggedAt.toUtc().toIso8601String(),
              })
          .toList(),
      'interviewSchedules': schedules
          .map((sc) => {
                'id': sc.id,
                'applicationId': sc.applicationId,
                'roundName': sc.roundName,
                'scheduledAt': sc.scheduledAt.toUtc().toIso8601String(),
                'meetingUrl': sc.meetingUrl,
                'locationNotes': sc.locationNotes,
              })
          .toList(),
    };

    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      final dateTag = DateTime.now().toIso8601String().substring(0, 10);
      final fileName = 'lamarlog_backup_$dateTag.json';

      final savedUri = await FilePicker.saveFile(
        dialogTitle: s.exportBackup,
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/json',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(savedUri != null ? s.backupSaved : s.backupCancelled),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) showErrorSnackBar(context, s.exportFailed);
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final s = AppLocaleScope.of(context);
    try {
      final db = context.read<AppDatabase>();
      final apps = await db.getAllApplications();
      if (apps.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.csvEmpty)),
          );
        }
        return;
      }

      final csvString = CsvExporter.buildApplicationsCsv(
        apps,
        customStageNames: s.stageLabelMap,
      );
      final bytes = Uint8List.fromList(utf8.encode(csvString));
      final dateTag = DateTime.now().toIso8601String().substring(0, 10);
      final fileName = 'lamarlog_applications_$dateTag.csv';

      final savedUri = await FilePicker.saveFile(
        dialogTitle: s.exportCsv,
        fileName: fileName,
        bytes: bytes,
        mimeType: 'text/csv',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(savedUri != null ? s.csvSaved : s.csvCancelled),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) showErrorSnackBar(context, s.exportFailed);
    }
  }

  void _confirmRestore(BuildContext context) {
    final s = AppLocaleScope.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.isId ? 'Pulihkan Backup?' : 'Restore Backup?'),
        content: Text(
          s.isId
              ? 'Semua data saat ini akan diganti dengan data dari file backup. Lanjutkan?'
              : 'All current data will be replaced with data from the backup file. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _restoreBackup(context);
            },
            child: Text(s.isId ? 'Timpa Semua' : 'Replace All'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final s = AppLocaleScope.of(context);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result.isEmpty || result.single.path == null) return;

      final raw = await File(result.single.path!).readAsString();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['schemaVersion'] != 1) {
        if (context.mounted) {
          showErrorSnackBar(context, s.backupUnsupportedSchema);
        }
        return;
      }

      if (!context.mounted) return;
      final restoredStagesRaw = decoded['pipelineStages'];
      if (restoredStagesRaw is List<dynamic>) {
        final restoredStages = PipelineStageConfig.decodeList(
          jsonEncode(restoredStagesRaw),
        );
        if (restoredStages != null) {
          widget.onPipelineStagesChanged(restoredStages);
        }
      }
      final db = context.read<AppDatabase>();
      await db.transaction(() async {
        await db.delete(db.jobApplications).go();

        final appsList = decoded['applications'] as List<dynamic>? ?? [];
        for (final item in appsList) {
          final m = item as Map<String, dynamic>;
          await db.into(db.jobApplications).insert(
                JobApplicationsCompanion.insert(
                  id: m['id'] as String,
                  companyName: m['companyName'] as String,
                  roleTitle: m['roleTitle'] as String,
                  location: Value((m['location'] as String?) ?? ''),
                  workplaceType:
                      Value((m['workplaceType'] as String?) ?? 'remote'),
                  jobType: Value((m['jobType'] as String?) ?? 'fullTime'),
                  currentStatus:
                      Value((m['currentStatus'] as String?) ?? 'wishlist'),
                  priority: Value((m['priority'] as String?) ?? 'medium'),
                  currency: Value((m['currency'] as String?) ?? 'IDR'),
                  salaryPeriod:
                      Value((m['salaryPeriod'] as String?) ?? 'monthly'),
                  expectedSalary:
                      Value((m['expectedSalary'] as num?)?.toDouble()),
                  offeredSalary:
                      Value((m['offeredSalary'] as num?)?.toDouble()),
                  vacancyUrl: Value(m['vacancyUrl'] as String?),
                  sourcePlatform: Value(m['sourcePlatform'] as String?),
                  recruiterName: Value(m['recruiterName'] as String?),
                  recruiterContact: Value(m['recruiterContact'] as String?),
                  isArchived: Value((m['isArchived'] as bool?) ?? false),
                  appliedAt: Value(m['appliedAt'] != null
                      ? DateTime.parse(m['appliedAt'] as String).toUtc()
                      : null),
                  createdAt: DateTime.parse(m['createdAt'] as String).toUtc(),
                  updatedAt: DateTime.parse(m['updatedAt'] as String).toUtc(),
                ),
              );
        }

        final transList = decoded['transitions'] as List<dynamic>? ?? [];
        for (final item in transList) {
          final m = item as Map<String, dynamic>;
          await db.into(db.statusTransitions).insert(
                StatusTransitionsCompanion.insert(
                  id: m['id'] as String,
                  applicationId: m['applicationId'] as String,
                  fromStatus: Value(m['fromStatus'] as String?),
                  toStatus: m['toStatus'] as String,
                  transitionedAt:
                      DateTime.parse(m['transitionedAt'] as String).toUtc(),
                ),
              );
        }

        final logsList = decoded['timelineLogs'] as List<dynamic>? ?? [];
        for (final item in logsList) {
          final m = item as Map<String, dynamic>;
          await db.into(db.timelineLogs).insert(
                TimelineLogsCompanion.insert(
                  id: m['id'] as String,
                  applicationId: m['applicationId'] as String,
                  title: m['title'] as String,
                  note: Value((m['note'] as String?) ?? ''),
                  loggedAt: DateTime.parse(m['loggedAt'] as String).toUtc(),
                ),
              );
        }

        final schedList = decoded['interviewSchedules'] as List<dynamic>? ?? [];
        for (final item in schedList) {
          final m = item as Map<String, dynamic>;
          await db.into(db.interviewSchedules).insert(
                InterviewSchedulesCompanion.insert(
                  id: m['id'] as String,
                  applicationId: m['applicationId'] as String,
                  roundName: m['roundName'] as String,
                  scheduledAt:
                      DateTime.parse(m['scheduledAt'] as String).toUtc(),
                  meetingUrl: Value(m['meetingUrl'] as String?),
                  locationNotes: Value(m['locationNotes'] as String?),
                ),
              );
        }
      });

      if (context.mounted) {
        context.read<ApplicationsBloc>().add(const LoadApplications());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.backupRestoredOk)),
        );
      }
    } catch (_) {
      if (context.mounted) showErrorSnackBar(context, s.backupInvalidFile);
    }
  }

  void _confirmClearAll(BuildContext context) {
    final s = AppLocaleScope.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${s.clearAllData}?'),
        content: Text(s.clearDataDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final db = context.read<AppDatabase>();
                await db.delete(db.jobApplications).go();

                try {
                  final dir = await getApplicationDocumentsDirectory();
                  final resumesDir = Directory(p.join(dir.path, 'resumes'));
                  if (resumesDir.existsSync()) {
                    await resumesDir.delete(recursive: true);
                  }
                } catch (_) {}

                if (context.mounted) {
                  context.read<ApplicationsBloc>().add(const LoadApplications());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        s.isId
                            ? 'Seluruh data lokal berhasil dihapus.'
                            : 'All local data cleared.',
                      ),
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  showErrorSnackBar(context, s.clearDataFailed);
                }
              }
            },
            child: Text(s.clearAllData),
          ),
        ],
      ),
    );
  }
}

class _VaultActionTile extends StatelessWidget {
  const _VaultActionTile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconFg, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 1),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
