import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/database/app_database.dart';
import '../core/l10n/app_strings.dart';
import '../core/layout/responsive.dart';
import '../core/models/pipeline_stage_config.dart';
import '../core/models/reminder_schedule_config.dart';
import '../core/motion/app_motion.dart';
import '../core/widgets/applyflow_widgets.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/applications/presentation/bloc/applications_bloc.dart';
import '../features/applications/presentation/pages/pipeline_page.dart';
import '../features/reminders/presentation/pages/notifications_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.colorPalette,
    required this.onColorPaletteChanged,
    required this.defaultCurrency,
    required this.onDefaultCurrencyChanged,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onRenameStage,
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
  final void Function(String stageId, String? newName) onRenameStage;
  final ValueChanged<List<PipelineStageConfig>?> onPipelineStagesChanged;
  final ValueChanged<ReminderScheduleConfig>? onReminderScheduleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final s = AppLocaleScope.of(context);
    final db = context.read<AppDatabase>();
    final useRail = Responsive.isMediumOrWider(context);
    final isCompactHeight = Responsive.isCompactHeight(context);
    final extendRail = Responsive.isExpanded(context) && !isCompactHeight;

    final pages = [
      PipelinePage(
        defaultCurrency: widget.defaultCurrency,
        onRenameStage: widget.onRenameStage,
        onPipelineStagesChanged: widget.onPipelineStagesChanged,
      ),
      const NotificationsPage(),
      const AnalyticsPage(),
      SettingsPage(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        colorPalette: widget.colorPalette,
        onColorPaletteChanged: widget.onColorPaletteChanged,
        defaultCurrency: widget.defaultCurrency,
        onDefaultCurrencyChanged: widget.onDefaultCurrencyChanged,
        languageCode: widget.languageCode,
        onLanguageChanged: widget.onLanguageChanged,
        onPipelineStagesChanged: widget.onPipelineStagesChanged,
        onReminderScheduleChanged: widget.onReminderScheduleChanged,
      ),
    ];

    return BlocListener<ApplicationsBloc, ApplicationsState>(
      listenWhen: (prev, curr) =>
          curr.actionErrorId != prev.actionErrorId &&
          curr.actionErrorMessage != null,
      listener: (context, state) {
        showErrorSnackBar(context, state.actionErrorMessage!);
      },
      child: StreamBuilder<List<InterviewSchedule>>(
      stream: db.watchUpcomingInterviews(),
      builder: (context, snapshot) {
        final upcomingCount = snapshot.data?.length ?? 0;

        Widget buildNotifIcon({required bool selected}) {
          final icon = Icon(
            selected
                ? Icons.notifications_rounded
                : Icons.notifications_outlined,
          );
          if (upcomingCount == 0) return icon;
          return Badge(
            label: Text('$upcomingCount'),
            child: icon,
          );
        }

        if (useRail) {
          final theme = Theme.of(context);
          final railLeading = Padding(
            padding: EdgeInsets.fromLTRB(
              extendRail ? 12 : 6,
              isCompactHeight ? 6 : 12,
              extendRail ? 12 : 6,
              isCompactHeight ? 6 : 12,
            ),
            child: extendRail
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LamarLogLogoMark(size: 34, radius: 9, iconSize: 18),
                      const SizedBox(width: 10),
                      Text(
                        'LamarLog',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LamarLogLogoMark(
                        size: isCompactHeight ? 30 : 34,
                        radius: 9,
                        iconSize: isCompactHeight ? 16 : 18,
                      ),
                      if (!isCompactHeight) ...[
                        const SizedBox(height: 4),
                        Text(
                          'LamarLog',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
          );

          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  right: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              selectedIndex: _selectedIndex,
                              extended: extendRail,
                              minWidth: isCompactHeight ? 64 : 72,
                              groupAlignment: -1.0,
                              leading: railLeading,
                              labelType: extendRail
                                  ? NavigationRailLabelType.none
                                  : (isCompactHeight
                                      ? NavigationRailLabelType.selected
                                      : NavigationRailLabelType.all),
                              backgroundColor: cs.surfaceContainerLowest,
                              indicatorColor: cs.primaryContainer,
                              selectedIconTheme: const IconThemeData(
                                  color: Colors.white, size: 21),
                              unselectedIconTheme:
                                  IconThemeData(color: cs.secondary, size: 21),
                              selectedLabelTextStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                              unselectedLabelTextStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: cs.secondary,
                              ),
                              onDestinationSelected: (index) {
                                if (index != _selectedIndex) {
                                  AppMotion.selectionHaptic();
                                  setState(() => _selectedIndex = index);
                                }
                              },
                              destinations: [
                                NavigationRailDestination(
                                  icon: const Icon(Icons.view_column_outlined),
                                  selectedIcon:
                                      const Icon(Icons.view_column_rounded),
                                  label: Text(s.navPipeline),
                                ),
                                NavigationRailDestination(
                                  icon: buildNotifIcon(selected: false),
                                  selectedIcon: buildNotifIcon(selected: true),
                                  label: Text(s.navNotifications),
                                ),
                                NavigationRailDestination(
                                  icon: const Icon(Icons.bar_chart_outlined),
                                  selectedIcon:
                                      const Icon(Icons.bar_chart_rounded),
                                  label: Text(s.navAnalytics),
                                ),
                                NavigationRailDestination(
                                  icon: const Icon(Icons.tune_outlined),
                                  selectedIcon: const Icon(Icons.tune_rounded),
                                  label: Text(s.navSettings),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 0.75,
                  color: cs.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.35),
                ),
                Expanded(
                  child: FadeThroughIndexedStack(
                    index: _selectedIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: FadeThroughIndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color:
                      cs.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.35),
                  width: 0.75,
                ),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFF131B2E).withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, -2),
                      ),
                    ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                if (index != _selectedIndex) {
                  AppMotion.selectionHaptic();
                  setState(() => _selectedIndex = index);
                }
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.view_column_outlined),
                  selectedIcon: const Icon(Icons.view_column_rounded),
                  label: s.navPipeline,
                ),
                NavigationDestination(
                  icon: buildNotifIcon(selected: false),
                  selectedIcon: buildNotifIcon(selected: true),
                  label: s.navNotifications,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart_rounded),
                  label: s.navAnalytics,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.tune_outlined),
                  selectedIcon: const Icon(Icons.tune_rounded),
                  label: s.navSettings,
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}
