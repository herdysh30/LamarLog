import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../bloc/applications_bloc.dart';
import '../widgets/application_card.dart';
import 'application_detail_page.dart';
import 'application_form_page.dart';

class PipelinePage extends StatefulWidget {
  const PipelinePage({
    super.key,
    this.defaultCurrency = 'IDR',
    this.onRenameStage,
  });

  final String defaultCurrency;
  final void Function(ApplicationStatus stage, String? newName)? onRenameStage;

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

    return Scaffold(
      appBar: ApplyFlowAppBar(subtitle: s.navPipeline),
      body: StreamBuilder<List<InterviewSchedule>>(
        stream: db.watchUpcomingInterviews(),
        builder: (context, interviewSnap) {
          final nextInterviewByApp = <String, InterviewSchedule>{};
          for (final item in interviewSnap.data ?? const <InterviewSchedule>[]) {
            nextInterviewByApp.putIfAbsent(item.applicationId, () => item);
          }

          return BlocBuilder<ApplicationsBloc, ApplicationsState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Search + Filter + View Switcher Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  context
                                      .read<ApplicationsBloc>()
                                      .add(SearchQueryChanged(val));
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  hintText: s.searchHint,
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: cs.secondary,
                                    size: 20,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          tooltip: 'Clear',
                                          icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            context
                                                .read<ApplicationsBloc>()
                                                .add(
                                                    const SearchQueryChanged(''));
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: Material(
                                color: cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () => _showFilterSheet(context, state),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        color: state.hasActiveFilters
                                            ? cs.primary
                                            : cs.secondary,
                                        size: 21,
                                      ),
                                      if (state.hasActiveFilters)
                                        Positioned(
                                          top: 10,
                                          right: 10,
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
                              // Custom View Switcher Pill
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ViewModeButton(
                                      selected: _isKanbanView,
                                      icon: Icons.view_kanban_outlined,
                                      label: s.kanban,
                                      onTap: () =>
                                          setState(() => _isKanbanView = true),
                                    ),
                                    _ViewModeButton(
                                      selected: !_isKanbanView,
                                      icon: Icons.format_list_bulleted_rounded,
                                      label: s.list,
                                      onTap: () =>
                                          setState(() => _isKanbanView = false),
                                    ),
                                  ],
                                ),
                              ),

                              // Terminal Archive Outcome Pill
                              Material(
                                color: cs.surfaceContainer,
                                borderRadius: BorderRadius.circular(999),
                                child: InkWell(
                                  onTap: () => _showArchiveSheet(
                                    context,
                                    state.terminalApplications,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 38),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 16,
                                          color: cs.secondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          s.archiveCount(
                                              state.terminalApplications.length),
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: cs.onSecondaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active Pipeline Content
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _isKanbanView
                            ? _KanbanBoard(
                                state: state,
                                nextInterviewByApp: nextInterviewByApp,
                                onAddToStage: (stage) => _openForm(
                                  context,
                                  initialStatus: stage,
                                ),
                                onRenameStage: widget.onRenameStage == null
                                    ? null
                                    : (stage) =>
                                        _showRenameStageDialog(context, stage),
                                onOpenDetail: (app) =>
                                    _openDetail(context, app),
                              )
                            : _ListViewBody(
                                applications: state.activeApplications,
                                nextInterviewByApp: nextInterviewByApp,
                                onOpenDetail: (app) =>
                                    _openDetail(context, app),
                                onAddFirst: () => _openForm(context),
                              ),
                  ),

                  // Compact Pipeline Summary Strip (no redundant offline label)
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
                                      ApplicationStatus.activeStages.length,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text(
            s.trackJob,
            style: const TextStyle(
                fontWeight: FontWeight.w600, letterSpacing: 0.2),
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {ApplicationStatus? initialStatus}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ApplicationFormPage(
          initialStatus: initialStatus,
          defaultCurrency: widget.defaultCurrency,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, JobApplication app) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ApplicationDetailPage(application: app),
      ),
    );
  }

  void _showRenameStageDialog(BuildContext context, ApplicationStatus stage) {
    final s = AppLocaleScope.of(context);
    final ctrl = TextEditingController(text: s.statusLabel(stage));

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.renameColumn),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: s.columnNameHint,
            helperText:
                '${s.resetDefault}: ${s.defaultStatusLabel(stage)}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onRenameStage?.call(stage, null);
              Navigator.of(ctx).pop();
            },
            child: Text(s.resetDefault),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = ctrl.text.trim();
              widget.onRenameStage?.call(stage, value.isEmpty ? null : value);
              Navigator.of(ctx).pop();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ApplicationsState state) {
    WorkplaceType? selectedWorkplace = state.workplaceFilter;
    PriorityLevel? selectedPriority = state.priorityFilter;
    PipelineSortOption selectedSort = state.sortOption;
    final s = AppLocaleScope.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          final cs = theme.colorScheme;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.pipelineFilter,
                        style: theme.textTheme.headlineSmall),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(s.workplaceStyle, style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: s.all,
                      selected: selectedWorkplace == null,
                      onTap: () =>
                          setSheetState(() => selectedWorkplace = null),
                    ),
                    ...WorkplaceType.values.map(
                      (w) => _FilterPill(
                        label: s.workplaceLabel(w),
                        selected: selectedWorkplace == w,
                        onTap: () =>
                            setSheetState(() => selectedWorkplace = w),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(s.priorityLevel, style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: s.all,
                      selected: selectedPriority == null,
                      onTap: () =>
                          setSheetState(() => selectedPriority = null),
                    ),
                    ...PriorityLevel.values.map(
                      (p) => _FilterPill(
                        label: s.priorityLabel(p),
                        selected: selectedPriority == p,
                        onTap: () =>
                            setSheetState(() => selectedPriority = p),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(s.sorting, style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PipelineSortOption.values.map((opt) {
                    final label = opt == PipelineSortOption.latestMove
                        ? s.sortLatest
                        : s.sortSalary;
                    return _FilterPill(
                      label: label,
                      selected: selectedSort == opt,
                      onTap: () => setSheetState(() => selectedSort = opt),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<ApplicationsBloc>()
                                .add(const ResetFilters());
                            Navigator.of(ctx).pop();
                          },
                          child: Text(s.reset),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primaryContainer,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.read<ApplicationsBloc>().add(
                                  UpdateFilters(
                                    workplaceFilter: selectedWorkplace,
                                    priorityFilter: selectedPriority,
                                    sortOption: selectedSort,
                                  ),
                                );
                            Navigator.of(ctx).pop();
                          },
                          child: Text(s.applyFilters),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showArchiveSheet(
    BuildContext context,
    List<JobApplication> terminalApps,
  ) {
    String filterKey = 'all';
    final s = AppLocaleScope.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          final cs = theme.colorScheme;
          final brightness = theme.brightness;

          final acceptedCount = terminalApps
              .where(
                  (a) => a.currentStatus == ApplicationStatus.offerAccepted.name)
              .length;
          final rejectedCount = terminalApps
              .where((a) => a.currentStatus == ApplicationStatus.rejected.name)
              .length;
          final otherCount =
              terminalApps.length - acceptedCount - rejectedCount;

          final visible = terminalApps.where((a) {
            return switch (filterKey) {
              'accepted' =>
                a.currentStatus == ApplicationStatus.offerAccepted.name,
              'rejected' => a.currentStatus == ApplicationStatus.rejected.name,
              'other' =>
                a.currentStatus != ApplicationStatus.offerAccepted.name &&
                    a.currentStatus != ApplicationStatus.rejected.name,
              _ => true,
            };
          }).toList();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.72,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                color: cs.secondary, size: 22),
                            const SizedBox(width: 8),
                            Text(s.terminalArchive,
                                style: theme.textTheme.headlineSmall),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${terminalApps.length}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _ArchiveFilterTab(
                            label: s.all,
                            selected: filterKey == 'all',
                            onTap: () => setSheetState(() => filterKey = 'all'),
                          ),
                          _ArchiveFilterTab(
                            label: s.acceptedCount(acceptedCount),
                            selected: filterKey == 'accepted',
                            onTap: () =>
                                setSheetState(() => filterKey = 'accepted'),
                          ),
                          _ArchiveFilterTab(
                            label: s.rejectedCount(rejectedCount),
                            selected: filterKey == 'rejected',
                            onTap: () =>
                                setSheetState(() => filterKey = 'rejected'),
                          ),
                          _ArchiveFilterTab(
                            label: s.otherCount(otherCount),
                            selected: filterKey == 'other',
                            onTap: () =>
                                setSheetState(() => filterKey = 'other'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 36, color: cs.outline),
                            const SizedBox(height: 8),
                            Text(
                              s.noArchivedInCategory,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: visible.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final app = visible[index];
                            final status = ApplicationStatus.values.firstWhere(
                              (st) => st.name == app.currentStatus,
                              orElse: () => ApplicationStatus.rejected,
                            );
                            final (bg, fg) = AppColors.statusBadgeColors(
                                status, brightness, cs);

                            return SurfaceCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () {
                                Navigator.of(ctx).pop();
                                _openDetail(context, app);
                              },
                              child: Row(
                                children: [
                                  CompanyMonogram(
                                    companyName: app.companyName,
                                    size: 36,
                                    radius: 9,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.companyName,
                                          style: theme.textTheme.titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          app.roleTitle,
                                          style: theme.textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      s.statusLabel(status),
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: fg,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(s.done),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? cs.primary : cs.secondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected ? cs.primary : cs.secondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  const _KanbanBoard({
    required this.state,
    required this.nextInterviewByApp,
    required this.onAddToStage,
    required this.onOpenDetail,
    this.onRenameStage,
  });

  final ApplicationsState state;
  final Map<String, InterviewSchedule> nextInterviewByApp;
  final ValueChanged<ApplicationStatus> onAddToStage;
  final ValueChanged<JobApplication> onOpenDetail;
  final ValueChanged<ApplicationStatus>? onRenameStage;

  @override
  Widget build(BuildContext context) {
    final stages = ApplicationStatus.activeStages;
    final brightness = Theme.of(context).brightness;
    final s = AppLocaleScope.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = Responsive.kanbanColumnWidth(constraints.maxWidth);

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          itemCount: stages.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final stage = stages[index];
            final stageTitle = s.statusLabel(stage);
            final apps = state.byStatus(stage);
            final stageDot = AppColors.stageDotColor(stage, brightness);

            return DragTarget<JobApplication>(
              onAcceptWithDetails: (details) {
                context.read<ApplicationsBloc>().add(
                      MoveApplicationStatus(
                        application: details.data,
                        newStatus: stage,
                      ),
                    );
              },
              builder: (context, candidateData, rejectedData) {
                final isHighlighted = candidateData.isNotEmpty;
                final cs = Theme.of(context).colorScheme;
                final theme = Theme.of(context);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: colWidth,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? cs.primaryContainer.withValues(alpha: 0.1)
                    : cs.surfaceContainerLow.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isHighlighted
                      ? cs.primaryContainer
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stage Column Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: onRenameStage == null
                                ? null
                                : () => onRenameStage!(stage),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 2),
                              child: Row(
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: stageDot,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      stageTitle,
                                      style: theme.textTheme.titleSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${apps.length}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(color: cs.secondary),
                                    ),
                                  ),
                                  if (onRenameStage != null) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit_outlined,
                                        size: 13.5, color: cs.outline),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: s.addToStage(stageTitle),
                            icon: Icon(Icons.add_rounded,
                                size: 20, color: cs.secondary),
                            onPressed: () => onAddToStage(stage),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Cards List or Dropzone Empty State
                  Expanded(
                    child: apps.isEmpty
                        ? Center(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 24),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLowest
                                    .withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      cs.outlineVariant.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.drag_indicator_rounded,
                                    size: 24,
                                    color: cs.outline,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.noJobsInStage(stageTitle),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.dropOrAddHint,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton.icon(
                                    onPressed: () => onAddToStage(stage),
                                    icon:
                                        const Icon(Icons.add_rounded, size: 16),
                                    label: Text(s.addToStage(stageTitle)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 72),
                            itemCount: apps.length + 1,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, cardIdx) {
                              if (cardIdx == apps.length) {
                                return Material(
                                  color: cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () => onAddToStage(stage),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 11),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_rounded,
                                              size: 16, color: cs.secondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            s.addToStage(stageTitle),
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(color: cs.secondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final app = apps[cardIdx];
                              final interview = nextInterviewByApp[app.id];
                              return LongPressDraggable<JobApplication>(
                                data: app,
                                feedback: SizedBox(
                                  width: colWidth - 20,
                                  child: Material(
                                    elevation: 10,
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: ApplicationCard(
                                      application: app,
                                      upcomingInterview: interview,
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.35,
                                  child: ApplicationCard(
                                    application: app,
                                    upcomingInterview: interview,
                                  ),
                                ),
                                child: ApplicationCard(
                                  application: app,
                                  upcomingInterview: interview,
                                  onTap: () => onOpenDetail(app),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
      },
    );
  }
}

class _ListViewBody extends StatelessWidget {
  const _ListViewBody({
    required this.applications,
    required this.nextInterviewByApp,
    required this.onOpenDetail,
    required this.onAddFirst,
  });

  final List<JobApplication> applications;
  final Map<String, InterviewSchedule> nextInterviewByApp;
  final ValueChanged<JobApplication> onOpenDetail;
  final VoidCallback onAddFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    if (applications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: cs.primaryFixed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.work_outline_rounded,
                      size: 30, color: cs.onPrimaryFixed),
                ),
                const SizedBox(height: 16),
                Text(
                  s.emptyPipelineTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  s.emptyPipelineSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onAddFirst,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(s.trackFirstJob),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = Responsive.cardGridColumns(constraints.maxWidth);
        if (cols == 1) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
            itemCount: applications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final app = applications[index];
              return ApplicationCard(
                application: app,
                upcomingInterview: nextInterviewByApp[app.id],
                showStatusChip: true,
                onTap: () => onOpenDetail(app),
              );
            },
          );
        }

        // Responsive 2-column grid for tablets & landscape
        final rowCount = (applications.length / 2).ceil();
        return ResponsiveCenter(
          maxWidth: 960,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 92),
            itemCount: rowCount,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, rowIdx) {
              final left = applications[rowIdx * 2];
              final rightIdx = rowIdx * 2 + 1;
              final right =
                  rightIdx < applications.length ? applications[rightIdx] : null;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ApplicationCard(
                      application: left,
                      upcomingInterview: nextInterviewByApp[left.id],
                      showStatusChip: true,
                      onTap: () => onOpenDetail(left),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: right != null
                        ? ApplicationCard(
                            application: right,
                            upcomingInterview: nextInterviewByApp[right.id],
                            showStatusChip: true,
                            onTap: () => onOpenDetail(right),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
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
    return Material(
      color: selected ? cs.primaryContainer : cs.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveFilterTab extends StatelessWidget {
  const _ArchiveFilterTab({
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? cs.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? cs.primary : cs.secondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
