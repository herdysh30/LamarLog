import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/models/pipeline_stage_config.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';
import '../../data/backup_service.dart';
import 'about_page.dart';

export '../../data/backup_service.dart' show StorageStats;

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

    try {
      final jsonString = await BackupService.buildBackupJson(
        db: db,
        appVersion: AboutPage.appVersion,
        pipelineStages: s.pipelineStages,
      );
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
      if (!context.mounted) return;
      final db = context.read<AppDatabase>();
      final restoredStages = await BackupService.restoreFromJson(
        db: db,
        rawJson: raw,
      );
      if (restoredStages != null) {
        widget.onPipelineStagesChanged(restoredStages);
      }

      if (context.mounted) {
        context.read<ApplicationsBloc>().add(const LoadApplications());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.backupRestoredOk)),
        );
      }
    } on UnsupportedBackupSchemaException {
      if (context.mounted) {
        showErrorSnackBar(context, s.backupUnsupportedSchema);
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
                await BackupService.clearAllLocalData(db);

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
