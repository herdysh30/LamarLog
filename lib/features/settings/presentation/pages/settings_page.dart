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
import '../../../../core/motion/app_motion.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';
import '../widgets/pipeline_stages_sheet.dart';
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.colorPalette,
    required this.onColorPaletteChanged,
    required this.defaultCurrency,
    required this.onDefaultCurrencyChanged,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onPipelineStagesChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final AppColorPalette colorPalette;
  final ValueChanged<AppColorPalette> onColorPaletteChanged;
  final String defaultCurrency;
  final ValueChanged<String> onDefaultCurrencyChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<List<PipelineStageConfig>?> onPipelineStagesChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<_StorageStats> _loadStorageStats(AppDatabase db) async {
    final apps = await db.getAllApplications();
    final resumes = await db.getAllResumeAttachments();
    int totalBytes = 0;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, 'applyflow.sqlite'));
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

    return _StorageStats(
      bytes: totalBytes,
      appCount: apps.length,
      resumeCount: resumes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocaleScope.of(context);

    // Refresh storage stats when applications update
    context.watch<ApplicationsBloc>();

    final warningBg =
        isDark ? AppColors.warningBgDark : AppColors.warningBgLight;
    final warningFg =
        isDark ? AppColors.warningFgDark : AppColors.warningFgLight;
    final warningIcon =
        isDark ? AppColors.warningIconDark : AppColors.warningIconLight;

    return Scaffold(
      appBar: ApplyFlowAppBar(subtitle: s.navSettings),
      body: ResponsiveCenter(
        maxWidth: 680,
        child: ListView(
          padding: Responsive.pagePadding(context, bottom: 32),
          children: [
            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s.navSettings,
                    style: theme.textTheme.headlineLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded,
                        size: 15, color: cs.primary),
                    const SizedBox(width: 5),
                    Text(
                      s.localVault,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            s.settingsSubtitle,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // SECTION 1: Appearance & Preferences
          _SettingsSectionTitle(
            icon: Icons.palette_outlined,
            color: cs.primary,
            title: s.appearancePreferences,
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Mode
                Text(s.themeMode, style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _ThemeOptionButton(
                        label: s.themeSystem,
                        selected: widget.themeMode == ThemeMode.system,
                        onTap: () => widget.onThemeModeChanged(ThemeMode.system),
                      ),
                      _ThemeOptionButton(
                        label: s.themeLight,
                        selected: widget.themeMode == ThemeMode.light,
                        onTap: () => widget.onThemeModeChanged(ThemeMode.light),
                      ),
                      _ThemeOptionButton(
                        label: s.themeDark,
                        selected: widget.themeMode == ThemeMode.dark,
                        onTap: () => widget.onThemeModeChanged(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Color Palette Selector
                Text(s.colorPalette, style: theme.textTheme.labelMedium),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppColorPalette.values.map((palette) {
                      final selected = widget.colorPalette == palette;
                      final swatch = AppColors.tokensFor(palette).swatch;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: selected
                              ? cs.primaryFixed
                              : cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => widget.onColorPaletteChanged(palette),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? swatch
                                      : cs.outlineVariant.withValues(alpha: 0.4),
                                  width: selected ? 1.5 : 0.75,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: swatch,
                                      shape: BoxShape.circle,
                                    ),
                                    child: selected
                                        ? const Icon(Icons.check_rounded,
                                            size: 12, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    palette.label,
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: selected
                                          ? cs.onPrimaryFixed
                                          : cs.onSurface,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),

                // Language selector
                InkWell(
                  onTap: () => _showLanguageSheet(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.language,
                                  style: theme.textTheme.titleSmall),
                              Text(s.languageSubtitle,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.languageCode == 'id'
                                    ? 'Indonesia'
                                    : 'English (US)',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.expand_more_rounded,
                                  size: 18, color: cs.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Default currency selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.defaultCurrency,
                              style: theme.textTheme.titleSmall),
                          Text(s.defaultCurrencySubtitle,
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['IDR', 'USD'].map((code) {
                          final selected = widget.defaultCurrency == code;
                          return GestureDetector(
                            onTap: () => widget.onDefaultCurrencyChanged(code),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? cs.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                code == 'IDR' ? 'IDR (Rp)' : 'USD (\$)',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : cs.onSurfaceVariant,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Customize Pipeline Stages (Add / Rename / Color / Reorder / Delete)
                InkWell(
                  onTap: () => showPipelineStagesManagerSheet(
                    context,
                    onSave: widget.onPipelineStagesChanged,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.managePipelineStages,
                                  style: theme.textTheme.titleSmall),
                              Text(s.managePipelineStagesSub,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.view_kanban_outlined,
                                  size: 15, color: cs.primary),
                              const SizedBox(width: 5),
                              Text(
                                '${s.pipelineStages.length}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // SECTION 2: Data Vault & Backup
          _SettingsSectionTitle(
            icon: Icons.folder_copy_outlined,
            color: cs.primary,
            title: s.dataVaultBackup,
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_reset_rounded,
                          size: 20, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.privacyAssurance,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Export Action Tile
                _VaultActionTile(
                  icon: Icons.file_download_outlined,
                  iconBg: cs.primaryContainer,
                  iconFg: Colors.white,
                  title: s.exportBackup,
                  subtitle: s.exportBackupSub,
                  onTap: () => _exportBackup(context),
                ),
                const SizedBox(height: 10),

                // Export CSV Action Tile
                _VaultActionTile(
                  icon: Icons.table_chart_outlined,
                  iconBg: cs.tertiaryContainer.withValues(alpha: 0.2),
                  iconFg: cs.tertiary,
                  title: s.exportCsv,
                  subtitle: s.exportCsvSub,
                  onTap: () => _exportCsv(context),
                ),
                const SizedBox(height: 10),

                // Restore Action Tile
                _VaultActionTile(
                  icon: Icons.upload_file_outlined,
                  iconBg: cs.surfaceContainerHigh,
                  iconFg: cs.onSurface,
                  title: s.restoreBackup,
                  subtitle: s.restoreBackupSub,
                  onTap: () => _confirmRestore(context),
                ),
                const SizedBox(height: 14),

                // Plaintext Warning Callout
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: warningBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: warningIcon, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.warningPlaintext,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: warningFg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.warningPlaintextBody,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: warningFg.withValues(alpha: 0.9),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // SECTION 3: Storage & Danger Zone
          _SettingsSectionTitle(
            icon: Icons.storage_rounded,
            color: cs.error,
            title: s.storageDangerZone,
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<_StorageStats>(
                  future: _loadStorageStats(db),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ??
                        const _StorageStats(
                            bytes: 0, appCount: 0, resumeCount: 0);
                    final sizeLabel = stats.bytes >= 1024 * 1024
                        ? '${(stats.bytes / (1024 * 1024)).toStringAsFixed(2)} MB'
                        : '${(stats.bytes / 1024).toStringAsFixed(1)} KB';
                    final fillRatio =
                        (stats.bytes / (20 * 1024 * 1024)).clamp(0.03, 1.0);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.localStorageUsage,
                                style: theme.textTheme.titleSmall),
                            Text(
                              sizeLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: fillRatio,
                            minHeight: 7,
                            backgroundColor: cs.surfaceContainer,
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.storageBreakdown(stats.appCount, stats.resumeCount),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Danger Box
                Container(
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
                          Icon(Icons.delete_sweep_outlined,
                              size: 18, color: cs.error),
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
                          icon: const Icon(Icons.delete_forever_rounded,
                              size: 20),
                          label: Text(
                            s.clearAllData,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // SECTION 4: About
          _SettingsSectionTitle(
            icon: Icons.info_outline_rounded,
            color: cs.primary,
            title: s.aboutApp,
          ),
          const SizedBox(height: 10),
          PressableScale(
            child: SurfaceCard(
              padding: const EdgeInsets.all(14),
              onTap: () {
                AppMotion.selectionHaptic();
                Navigator.of(context).push(
                  AppMotion.sharedAxisRoute<void>(const AboutPage()),
                );
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 42,
                        height: 42,
                        color: cs.primaryContainer,
                        alignment: Alignment.center,
                        child: const Icon(Icons.view_kanban_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.aboutApp,
                                style: theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'v${AboutPage.appVersion}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10.5,
                                  color: cs.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.aboutAppSub,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // App Version Footer
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal_rounded,
                      size: 15, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('ApplyFlow v${AboutPage.appVersion}',
                      style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                s.footerStorageNote,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.selectLanguage, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor:
                    widget.languageCode == 'en' ? cs.surfaceContainerLow : null,
                title: const Text('English (US)'),
                trailing: widget.languageCode == 'en'
                    ? Icon(Icons.check_rounded, color: cs.primary)
                    : null,
                onTap: () {
                  widget.onLanguageChanged('en');
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor:
                    widget.languageCode == 'id' ? cs.surfaceContainerLow : null,
                title: const Text('Bahasa Indonesia'),
                trailing: widget.languageCode == 'id'
                    ? Icon(Icons.check_rounded, color: cs.primary)
                    : null,
                onTap: () {
                  widget.onLanguageChanged('id');
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
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
      'appVersion': '1.0.0',
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
      final fileName = 'applyflow_backup_$dateTag.json';

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
      final fileName = 'applyflow_applications_$dateTag.csv';

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
              try {
                final db = context.read<AppDatabase>();
                await db.delete(db.jobApplications).go();
                try {
                  final dir = await getApplicationDocumentsDirectory();
                  final resumesDir = Directory(p.join(dir.path, 'resumes'));
                  if (resumesDir.existsSync()) {
                    resumesDir.deleteSync(recursive: true);
                  }
                } catch (_) {}

                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  context.read<ApplicationsBloc>().add(const LoadApplications());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.isId
                          ? 'Seluruh data lokal berhasil dihapus.'
                          : 'All local data cleared.'),
                    ),
                  );
                }
              } catch (_) {
                if (ctx.mounted) Navigator.of(ctx).pop();
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

class _StorageStats {
  const _StorageStats({
    required this.bytes,
    required this.appCount,
    required this.resumeCount,
  });

  final int bytes;
  final int appCount;
  final int resumeCount;
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({
    required this.icon,
    required this.color,
    required this.title,
  });

  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  const _ThemeOptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? cs.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
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
          padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
