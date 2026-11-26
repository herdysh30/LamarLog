import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/models/pipeline_stage_config.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../settings/presentation/widgets/pipeline_stages_sheet.dart';
import '../bloc/applications_bloc.dart';
import '../widgets/pipeline/pipeline_archive_sheet.dart';
import '../widgets/pipeline/pipeline_controls.dart';
import '../widgets/pipeline/pipeline_filter_sheet.dart';
import '../widgets/pipeline/pipeline_kanban_board.dart';
import '../widgets/pipeline/pipeline_list_view.dart';
import 'application_detail_page.dart';
import 'application_form_page.dart';

class PipelinePage extends StatefulWidget {
  const PipelinePage({
    super.key,
    this.defaultCurrency = 'IDR',
    this.onRenameStage,
    this.onPipelineStagesChanged,
  });

  final String defaultCurrency;
  final void Function(String stageId, String? newName)? onRenameStage;
  final ValueChanged<List<PipelineStageConfig>?>? onPipelineStagesChanged;

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage> {
  bool _isKanbanView = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final db = context.read<AppDatabase>();
    final s = AppLocaleScope.of(context);
    final useSidebar = Responsive.isMediumOrWider(context);
    final isCompactHeight = Responsive.isCompactHeight(context);
    final singleRowToolbar = useSidebar || isCompactHeight;

    return Scaffold(
      appBar: useSidebar ? null : ApplyFlowAppBar(subtitle: s.navPipeline),
      body: SafeArea(
        left: !useSidebar,
        child: StreamBuilder<List<InterviewSchedule>>(
        stream: db.watchUpcomingInterviews(),
        builder: (context, interviewSnap) {
          final nextInterviewByApp = <String, InterviewSchedule>{};
          for (final item in interviewSnap.data ?? const <InterviewSchedule>[]) {
            nextInterviewByApp.putIfAbsent(item.applicationId, () => item);
          }

          return BlocBuilder<ApplicationsBloc, ApplicationsState>(
            builder: (context, state) {
              final allStages = s.pipelineStages;
              final validStageIds = {for (final st in allStages) st.id};
              _pruneStaleStageFilter(context, state, validStageIds);
              final filteredStageCount =
                  allStages.where((st) => state.isStageVisible(st.id)).length;
              final visibleStageCount = filteredStageCount == 0
                  ? allStages.length
                  : filteredStageCount;

              final searchField = TextField(
                controller: _searchController,
                onChanged: (val) {
                  context
                      .read<ApplicationsBloc>()
                      .add(SearchQueryChanged(val));
                  setState(() {});
                },
                decoration: InputDecoration(
                  isDense: singleRowToolbar,
                  hintText: s.searchHint,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: cs.secondary,
                    size: 19,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<ApplicationsBloc>()
                                .add(const SearchQueryChanged(''));
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: singleRowToolbar ? 9 : 12,
                  ),
                ),
              );

              final filterButton = SizedBox(
                width: singleRowToolbar ? 42 : 48,
                height: singleRowToolbar ? 42 : 48,
                child: Semantics(
                  button: true,
                  label: s.pipelineFilter,
                  child: Material(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        AppMotion.selectionHaptic();
                        showPipelineFilterSheet(context, state);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: state.hasActiveFilters
                                ? cs.primary
                                : cs.secondary,
                            size: 20,
                          ),
                          if (state.hasActiveFilters)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.surface,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              Widget buildViewSwitcher({required bool iconOnly}) => Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PipelineViewModeButton(
                      selected: _isKanbanView,
                      icon: Icons.view_kanban_outlined,
                      label: s.kanban,
                      compact: singleRowToolbar,
                      iconOnly: iconOnly,
                      onTap: () {
                        if (!_isKanbanView) {
                          AppMotion.selectionHaptic();
                          setState(() => _isKanbanView = true);
                        }
                      },
                    ),
                    PipelineViewModeButton(
                      selected: !_isKanbanView,
                      icon: Icons.format_list_bulleted_rounded,
                      label: s.list,
                      compact: singleRowToolbar,
                      iconOnly: iconOnly,
                      onTap: () {
                        if (_isKanbanView) {
                          AppMotion.selectionHaptic();
                          setState(() => _isKanbanView = false);
                        }
                      },
                    ),
                  ],
                ),
              );

              Widget buildArchivePill({required bool compactCount}) => Material(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () => showTerminalArchiveSheet(
                    context: context,
                    terminalApps: state.terminalApplications,
                    onOpenDetail: (app) => _openDetail(context, app),
                  ),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: singleRowToolbar ? 36 : 38,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: singleRowToolbar ? 10 : 12,
                      vertical: singleRowToolbar ? 6 : 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: cs.secondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          compactCount
                              ? '${state.terminalApplications.length}'
                              : s.archiveCount(
                                  state.terminalApplications.length,
                                ),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              return Column(
                children: [
                  // Search + Filter + View Switcher Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      useSidebar ? (isCompactHeight ? 6 : 10) : 4,
                      16,
                      isCompactHeight ? 2 : 4,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final textScale =
                            MediaQuery.textScalerOf(context).scale(1.0);
                        final tightSingleRow = singleRowToolbar &&
                            (constraints.maxWidth < 560 * textScale);

                        if (singleRowToolbar) {
                          return Row(
                            children: [
                              Expanded(child: searchField),
                              const SizedBox(width: 6),
                              filterButton,
                              const SizedBox(width: 6),
                              buildViewSwitcher(iconOnly: tightSingleRow),
                              const SizedBox(width: 6),
                              buildArchivePill(compactCount: tightSingleRow),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: searchField),
                                const SizedBox(width: 8),
                                filterButton,
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  buildViewSwitcher(iconOnly: false),
                                  buildArchivePill(compactCount: false),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  PipelineStageFilterBar(
                    stages: allStages,
                    state: state,
                    compact: isCompactHeight,
                    onSelectAll: () {
                      if (!state.hasStageFilter) return;
                      AppMotion.selectionHaptic();
                      context
                          .read<ApplicationsBloc>()
                          .add(const UpdateStageFilter({}));
                    },
                    onToggleStage: (stageId) {
                      AppMotion.selectionHaptic();
                      _toggleStage(context, state, validStageIds, stageId);
                    },
                  ),

                  if (state.staleApplications.isNotEmpty ||
                      state.staleOnlyFilter)
                    PipelineStaleBanner(
                      staleCount: state.staleApplications.length,
                      staleOnlyFilter: state.staleOnlyFilter,
                      compact: isCompactHeight,
                      onTap: () => context
                          .read<ApplicationsBloc>()
                          .add(const ToggleStaleFilter()),
                    ),

                  // Active Pipeline Content
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state.errorMessage != null
                            ? ErrorStateCard(
                                title: s.dbLoadErrorTitle,
                                detail: state.errorMessage,
                                retryLabel: s.retry,
                                onRetry: () => context
                                    .read<ApplicationsBloc>()
                                    .add(const LoadApplications()),
                              )
                            : AnimatedSwitcher(
                                duration: AppMotion.duration(
                                  context,
                                  AppMotion.medium,
                                ),
                                switchInCurve: AppMotion.enterCurve,
                                switchOutCurve: AppMotion.exitCurve,
                                child: _isKanbanView
                                    ? PipelineKanbanBoard(
                                        key: const ValueKey('kanban_view'),
                                        state: state,
                                        nextInterviewByApp: nextInterviewByApp,
                                        onAddToStage: (stage) => _openForm(
                                          context,
                                          initialStatusId: stage.id,
                                        ),
                                        onRenameStage:
                                            widget.onRenameStage == null
                                                ? null
                                                : (stage) =>
                                                    showRenameStageDialog(
                                                      context: context,
                                                      stage: stage,
                                                      onRenameStage:
                                                          widget.onRenameStage,
                                                      onPipelineStagesChanged:
                                                          widget
                                                              .onPipelineStagesChanged,
                                                    ),
                                        onManageStages:
                                            widget.onPipelineStagesChanged ==
                                                    null
                                                ? null
                                                : () =>
                                                    showPipelineStagesManagerSheet(
                                                      context,
                                                      onSave: widget
                                                          .onPipelineStagesChanged!,
                                                    ),
                                        onOpenDetail: (app) =>
                                            _openDetail(context, app),
                                      )
                                    : PipelineListView(
                                        key: const ValueKey('list_view'),
                                        applications: state.activeApplications,
                                        nextInterviewByApp: nextInterviewByApp,
                                        isFiltered: state.hasActiveFilters ||
                                            state.searchQuery
                                                .trim()
                                                .isNotEmpty,
                                        onOpenDetail: (app) =>
                                            _openDetail(context, app),
                                        onAddFirst: () => _openForm(context),
                                        onResetFilters: () {
                                          _searchController.clear();
                                          final bloc =
                                              context.read<ApplicationsBloc>();
                                          bloc
                                            ..add(const SearchQueryChanged(''))
                                            ..add(const ResetFilters());
                                          setState(() {});
                                        },
                                      ),
                              ),
                  ),

                  // Compact Pipeline Summary Strip (omitted on short landscape
                  // screens to maximize Kanban board height)
                  if (!isCompactHeight)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.bolt_rounded,
                                      size: 18, color: cs.primary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      s.activeSummary(
                                        visibleStageCount,
                                        state.activeApplications.length,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (state.hasActiveFilters) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => context
                                    .read<ApplicationsBloc>()
                                    .add(const ResetFilters()),
                                child: Text(
                                  s.reset,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: isCompactHeight ? 4 : 40),
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            s.trackJob,
            style: const TextStyle(
                fontWeight: FontWeight.w600, letterSpacing: 0.2),
          ),
        ),
      ),
    );
  }

  void _toggleStage(
    BuildContext context,
    ApplicationsState state,
    Set<String> validStageIds,
    String stageId,
  ) {
    final next = state.stageFilter.intersection(validStageIds).toSet();
    if (!next.remove(stageId)) next.add(stageId);
    if (next.length == validStageIds.length) next.clear();
    context.read<ApplicationsBloc>().add(UpdateStageFilter(next));
  }

  void _pruneStaleStageFilter(
    BuildContext context,
    ApplicationsState state,
    Set<String> validStageIds,
  ) {
    if (state.stageFilter.every(validStageIds.contains)) return;
    final bloc = context.read<ApplicationsBloc>();
    final pruned = state.stageFilter.intersection(validStageIds);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      bloc.add(UpdateStageFilter(pruned));
    });
  }

  void _openForm(BuildContext context, {String? initialStatusId}) {
    Navigator.of(context).push(
      AppMotion.slideUpRoute<void>(
        ApplicationFormPage(
          initialStatusId: initialStatusId,
          defaultCurrency: widget.defaultCurrency,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, JobApplication app) {
    Navigator.of(context).push(
      AppMotion.sharedAxisRoute<void>(
        ApplicationDetailPage(application: app),
      ),
    );
  }
}
