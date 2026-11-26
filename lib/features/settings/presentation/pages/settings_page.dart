import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/models/pipeline_stage_config.dart';
import '../../../../core/models/reminder_schedule_config.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';
import '../widgets/pipeline_stages_sheet.dart';
import 'about_page.dart';
import 'appearance_settings_page.dart';
import 'data_backup_settings_page.dart';
import 'notification_settings_page.dart';

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
    this.onReminderScheduleChanged,
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
  final ValueChanged<ReminderScheduleConfig>? onReminderScheduleChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  bool? _notifEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationStatus();
    }
  }

  Future<void> _checkNotificationStatus() async {
    final enabled = await NotificationService.instance.areNotificationsEnabled();
    if (mounted) {
      setState(() => _notifEnabled = enabled);
    }
  }

  String _themeLabel(AppStrings s) => switch (widget.themeMode) {
        ThemeMode.system => s.themeSystem,
        ThemeMode.light => s.themeLight,
        ThemeMode.dark => s.themeDark,
      };

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocaleScope.of(context);

    // Keep storage summary synchronized when applications change
    context.watch<ApplicationsBloc>();

    final appearanceSummary =
        '${_themeLabel(s)} • ${widget.colorPalette.label} • ${widget.languageCode.toUpperCase()} • ${widget.defaultCurrency}';

    final notifOk = _notifEnabled ?? false;
    final notifDotColor = notifOk
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? AppColors.warningIconDark : AppColors.warningIconLight);
    final useSidebar = Responsive.isMediumOrWider(context);

    return Scaffold(
      appBar: useSidebar ? null : ApplyFlowAppBar(subtitle: s.navSettings),
      body: SafeArea(
        left: !useSidebar,
        child: ResponsiveCenter(
        maxWidth: 680,
        child: ListView(
          padding: Responsive.pagePadding(context, bottom: 32),
          children: [
            // Clean Header Row
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
                      Icon(
                        Icons.verified_user_rounded,
                        size: 14,
                        color: cs.primary,
                      ),
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
            const SizedBox(height: 18),

            // GROUP 1: Personalization & Workflow
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _SettingsHubRow(
                    icon: Icons.palette_outlined,
                    iconBg: cs.primaryFixed,
                    iconFg: cs.onPrimaryFixed,
                    title: s.settingsAppearanceTitle,
                    subtitle: appearanceSummary,
                    onTap: () {
                      AppMotion.selectionHaptic();
                      Navigator.of(context).push(
                        AppMotion.sharedAxisRoute<void>(
                          AppearanceSettingsPage(
                            themeMode: widget.themeMode,
                            onThemeModeChanged: widget.onThemeModeChanged,
                            colorPalette: widget.colorPalette,
                            onColorPaletteChanged: widget.onColorPaletteChanged,
                            defaultCurrency: widget.defaultCurrency,
                            onDefaultCurrencyChanged:
                                widget.onDefaultCurrencyChanged,
                            languageCode: widget.languageCode,
                            onLanguageChanged: widget.onLanguageChanged,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 64, endIndent: 16, height: 1),
                  _SettingsHubRow(
                    icon: Icons.view_kanban_outlined,
                    iconBg: cs.tertiaryContainer.withValues(alpha: 0.2),
                    iconFg: cs.tertiary,
                    title: s.settingsPipelineStagesTitle,
                    subtitle:
                        s.settingsActiveStagesSummary(s.pipelineStages.length),
                    onTap: () {
                      AppMotion.selectionHaptic();
                      showPipelineStagesManagerSheet(
                        context,
                        onSave: widget.onPipelineStagesChanged,
                      );
                    },
                  ),
                  const Divider(indent: 64, endIndent: 16, height: 1),
                  _SettingsHubRow(
                    icon: Icons.notifications_outlined,
                    iconBg: notifDotColor.withValues(alpha: 0.14),
                    iconFg: notifDotColor,
                    title: s.settingsNotificationsTitle,
                    subtitle: _notifEnabled == null
                        ? '...'
                        : '${notifOk ? s.notifStatusEnabled : s.notifStatusDisabled} • ${s.reminderSchedule.formatSummary(isId: s.isId, short: true)}',
                    trailing: _notifEnabled == null
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: notifDotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () async {
                      AppMotion.selectionHaptic();
                      await Navigator.of(context).push(
                        AppMotion.sharedAxisRoute<void>(
                          NotificationSettingsPage(
                            onReminderScheduleChanged:
                                widget.onReminderScheduleChanged,
                          ),
                        ),
                      );
                      _checkNotificationStatus();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // GROUP 2: Data & App Info
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  FutureBuilder<StorageStats>(
                    future: StorageStats.load(db),
                    builder: (context, snapshot) {
                      final stats = snapshot.data;
                      final summary = stats == null
                          ? '...'
                          : (s.isId
                              ? '${stats.appCount} lamaran • ${stats.formattedSize}'
                              : '${stats.appCount} apps • ${stats.formattedSize}');
                      return _SettingsHubRow(
                        icon: Icons.folder_copy_outlined,
                        iconBg: cs.surfaceContainerHigh,
                        iconFg: cs.primary,
                        title: s.settingsDataBackupTitle,
                        subtitle: summary,
                        onTap: () {
                          AppMotion.selectionHaptic();
                          Navigator.of(context).push(
                            AppMotion.sharedAxisRoute<void>(
                              DataBackupSettingsPage(
                                onPipelineStagesChanged:
                                    widget.onPipelineStagesChanged,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(indent: 64, endIndent: 16, height: 1),
                  _SettingsHubRow(
                    leadingOverride: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 40,
                          height: 40,
                          color: cs.primaryContainer,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.view_kanban_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    title: s.aboutApp,
                    subtitle: 'v${AboutPage.appVersion}',
                    onTap: () {
                      AppMotion.selectionHaptic();
                      Navigator.of(context).push(
                        AppMotion.sharedAxisRoute<void>(const AboutPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Minimal Offline Footer
            Text(
              'LamarLog v${AboutPage.appVersion} • ${s.footerStorageNote}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _SettingsHubRow extends StatelessWidget {
  const _SettingsHubRow({
    this.icon,
    this.iconBg,
    this.iconFg,
    this.leadingOverride,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData? icon;
  final Color? iconBg;
  final Color? iconFg;
  final Widget? leadingOverride;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 62),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              leadingOverride ??
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg ?? cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: iconFg ?? cs.primary,
                    ),
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ?trailing,
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
