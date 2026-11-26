import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/layout/responsive.dart';
import '../../../../../core/models/pipeline_stage_config.dart';
import '../../../../../core/motion/app_motion.dart';
import '../../bloc/applications_bloc.dart';
import '../application_card.dart';

class PipelineKanbanBoard extends StatelessWidget {
  const PipelineKanbanBoard({
    super.key,
    required this.state,
    required this.nextInterviewByApp,
    required this.onAddToStage,
    required this.onOpenDetail,
    this.onRenameStage,
    this.onManageStages,
  });

  final ApplicationsState state;
  final Map<String, InterviewSchedule> nextInterviewByApp;
  final ValueChanged<PipelineStageConfig> onAddToStage;
  final ValueChanged<JobApplication> onOpenDetail;
  final ValueChanged<PipelineStageConfig>? onRenameStage;
  final VoidCallback? onManageStages;

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context);
    final allStages = s.pipelineStages;
    final filteredStages =
        allStages.where((st) => state.isStageVisible(st.id)).toList();
    final stages = filteredStages.isEmpty ? allStages : filteredStages;
    final brightness = Theme.of(context).brightness;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeight = constraints.maxHeight < 280;
        final colWidth = Responsive.kanbanColumnWidth(
          constraints.maxWidth,
          compactHeight: compactHeight,
        );
        final extraManageCol =
            onManageStages != null && !state.hasStageFilter ? 1 : 0;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(16, 4, 16, compactHeight ? 6 : 8),
          itemCount: stages.length + extraManageCol,
          separatorBuilder: (_, _) => SizedBox(width: compactHeight ? 10 : 14),
          itemBuilder: (context, index) {
            if (index == stages.length) {
              final cs = Theme.of(context).colorScheme;
              final theme = Theme.of(context);
              return SizedBox(
                width: (colWidth * 0.72).clamp(170.0, 232.0),
                child: Material(
                  color: cs.surfaceContainerLow.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: onManageStages,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: EdgeInsets.all(compactHeight ? 12 : 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: compactHeight ? 38 : 48,
                                height: compactHeight ? 38 : 48,
                                decoration: BoxDecoration(
                                  color: cs.primaryFixed,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: cs.onPrimaryFixed,
                                  size: compactHeight ? 22 : 26,
                                ),
                              ),
                              SizedBox(height: compactHeight ? 8 : 12),
                              Text(
                                s.managePipelineStages,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.stageCountBadge(stages.length),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            final stage = stages[index];
            final stageTitle = stage.label;
            final apps = state.byStatusId(stage.id);
            final stageDot = stage.colorKey.dotColor(brightness);

            return DragTarget<JobApplication>(
              onAcceptWithDetails: (details) {
                AppMotion.lightHaptic();
                context.read<ApplicationsBloc>().add(
                      MoveApplicationStatus(
                        application: details.data,
                        newStatusId: stage.id,
                      ),
                    );
              },
              builder: (context, candidateData, rejectedData) {
                final isHighlighted = candidateData.isNotEmpty;
                final cs = Theme.of(context).colorScheme;
                final theme = Theme.of(context);

                return AnimatedContainer(
                  duration: AppMotion.duration(context, AppMotion.fast),
                  curve: AppMotion.standardCurve,
                  width: colWidth,
                  padding: EdgeInsets.all(compactHeight ? 8 : 10),
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
                                  padding: EdgeInsets.symmetric(
                                    vertical: compactHeight ? 3 : 6,
                                    horizontal: 2,
                                  ),
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
                                          borderRadius:
                                              BorderRadius.circular(999),
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
                              width: compactHeight ? 36 : 44,
                              height: compactHeight ? 36 : 44,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: s.addToStage(stageTitle),
                                icon: Icon(Icons.add_rounded,
                                    size: 20, color: cs.secondary),
                                onPressed: () {
                                  AppMotion.selectionHaptic();
                                  onAddToStage(stage);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: compactHeight ? 6 : 10),

                      // Cards List or Dropzone Empty State
                      Expanded(
                        child: apps.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: compactHeight ? 12 : 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerLowest
                                          .withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: cs.outlineVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.drag_indicator_rounded,
                                          size: compactHeight ? 20 : 24,
                                          color: cs.outline,
                                        ),
                                        SizedBox(
                                            height: compactHeight ? 4 : 8),
                                        Text(
                                          s.noJobsInStage(stageTitle),
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                        if (!compactHeight) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            s.dropOrAddHint,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                        SizedBox(
                                            height: compactHeight ? 6 : 12),
                                        TextButton.icon(
                                          style: compactHeight
                                              ? TextButton.styleFrom(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                )
                                              : null,
                                          onPressed: () => onAddToStage(stage),
                                          icon: const Icon(Icons.add_rounded,
                                              size: 16),
                                          label:
                                              Text(s.addToStage(stageTitle)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.only(
                                  bottom: compactHeight ? 56 : 72,
                                ),
                                itemCount: apps.length + 1,
                                separatorBuilder: (_, _) =>
                                    SizedBox(height: compactHeight ? 8 : 10),
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
                                                  size: 16,
                                                  color: cs.secondary),
                                              const SizedBox(width: 4),
                                              Text(
                                                s.addToStage(stageTitle),
                                                style: theme
                                                    .textTheme.labelMedium
                                                    ?.copyWith(
                                                        color: cs.secondary),
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
                                    onDragStarted: AppMotion.impactHaptic,
                                    feedback: SizedBox(
                                      width: colWidth - 20,
                                      child: Transform.scale(
                                        scale: 1.02,
                                        child: Material(
                                          elevation: 12,
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: ApplicationCard(
                                            application: app,
                                            upcomingInterview: interview,
                                            enableHero: false,
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.35,
                                      child: ApplicationCard(
                                        application: app,
                                        upcomingInterview: interview,
                                        enableHero: false,
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
