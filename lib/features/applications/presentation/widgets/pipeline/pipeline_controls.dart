import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/models/pipeline_stage_config.dart';
import '../../../../../core/motion/app_motion.dart';
import '../../bloc/applications_bloc.dart';

class PipelineViewModeButton extends StatelessWidget {
  const PipelineViewModeButton({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
    this.iconOnly = false,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final child = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: iconOnly ? 8 : (compact ? 9 : 12),
          vertical: compact ? 5 : 7,
        ),
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
            if (!iconOnly) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? cs.primary : cs.secondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return iconOnly ? Tooltip(message: label, child: child) : child;
  }
}

class PipelineStageFilterBar extends StatelessWidget {
  const PipelineStageFilterBar({
    super.key,
    required this.stages,
    required this.state,
    required this.onSelectAll,
    required this.onToggleStage,
    this.compact = false,
  });

  final List<PipelineStageConfig> stages;
  final ApplicationsState state;
  final VoidCallback onSelectAll;
  final ValueChanged<String> onToggleStage;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context);
    final allCount = state.activeApplicationsAllStages.length;
    final effectiveFilterActive =
        stages.any((st) => state.stageFilter.contains(st.id));

    return Semantics(
      container: true,
      label: s.filterByStage,
      child: SizedBox(
        height: compact ? 38 : 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stages.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _StageChip(
                label: s.allStages,
                count: allCount,
                selected: !effectiveFilterActive,
                stage: null,
                compact: compact,
                onTap: onSelectAll,
              );
            }
            final stage = stages[index - 1];
            return _StageChip(
              label: stage.label,
              count: state.byStatusId(stage.id).length,
              selected: state.stageFilter.contains(stage.id),
              stage: stage,
              compact: compact,
              onTap: () => onToggleStage(stage.id),
            );
          },
        ),
      ),
    );
  }
}

class PipelineStaleBanner extends StatelessWidget {
  const PipelineStaleBanner({
    super.key,
    required this.staleCount,
    required this.staleOnlyFilter,
    required this.onTap,
    this.compact = false,
  });

  final int staleCount;
  final bool staleOnlyFilter;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocaleScope.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 2, 16, compact ? 4 : 10),
      child: Material(
        color: staleOnlyFilter
            ? cs.primaryContainer
            : (isDark ? const Color(0xFF3E2C0A) : const Color(0xFFFFF4D6)),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: compact ? 6 : 10,
            ),
            child: Row(
              children: [
                Icon(
                  staleOnlyFilter
                      ? Icons.filter_alt_rounded
                      : Icons.notifications_active_outlined,
                  size: compact ? 16 : 18,
                  color: staleOnlyFilter
                      ? Colors.white
                      : (isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFF92400E)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.staleBannerTitle(staleCount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: staleOnlyFilter
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFF78350F)),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!compact)
                        Text(
                          s.staleBannerSub,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: staleOnlyFilter
                                ? Colors.white.withValues(alpha: 0.85)
                                : (isDark
                                    ? const Color(0xFFFCD34D)
                                        .withValues(alpha: 0.85)
                                    : const Color(0xFF92400E)
                                        .withValues(alpha: 0.85)),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  staleOnlyFilter
                      ? Icons.close_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: staleOnlyFilter
                      ? Colors.white
                      : (isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFF92400E)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.stage,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final int count;
  final bool selected;
  final PipelineStageConfig? stage;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;

    final Color bg;
    final Color fg;
    final Color borderColor;
    if (stage == null) {
      bg = selected ? cs.primaryContainer : cs.surfaceContainerLow;
      fg = selected ? Colors.white : cs.onSurfaceVariant;
      borderColor = selected ? cs.primaryContainer : cs.outlineVariant;
    } else {
      final (chipBg, chipFg) = stage!.colorKey.chipColors(brightness);
      bg = selected ? chipBg : cs.surfaceContainerLow;
      fg = selected ? chipFg : cs.onSurfaceVariant;
      borderColor = selected
          ? stage!.colorKey.dotColor(brightness)
          : cs.outlineVariant.withValues(alpha: 0.6);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $count',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
          child: AnimatedContainer(
            duration: AppMotion.duration(context, AppMotion.fast),
            curve: AppMotion.standardCurve,
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  Icon(Icons.check_rounded, size: 15, color: fg)
                else if (stage != null)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: stage!.colorKey.dotColor(brightness),
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Icon(Icons.layers_outlined, size: 15, color: fg),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected
                        ? fg.withValues(alpha: 0.14)
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? fg : cs.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
