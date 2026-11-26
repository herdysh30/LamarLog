import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/enums/application_enums.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/models/pipeline_stage_config.dart';
import '../../../../../core/widgets/applyflow_widgets.dart';
import 'form_core_section.dart';

class FormWorkArrangementSection extends StatelessWidget {
  const FormWorkArrangementSection({
    super.key,
    required this.workplaceType,
    required this.jobType,
    required this.onWorkplaceChanged,
    required this.onJobTypeChanged,
  });

  final WorkplaceType workplaceType;
  final JobType jobType;
  final ValueChanged<WorkplaceType> onWorkplaceChanged;
  final ValueChanged<JobType> onJobTypeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            icon: Icons.tune_rounded,
            iconBg: cs.secondaryContainer,
            iconFg: cs.onSecondaryContainer,
            title: s.workArrangement,
          ),
          const SizedBox(height: 14),
          Text(s.workplaceSetting, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: WorkplaceType.values.map((type) {
              final selected = workplaceType == type;
              final icon = switch (type) {
                WorkplaceType.remote => Icons.public_outlined,
                WorkplaceType.hybrid => Icons.apartment_outlined,
                WorkplaceType.onsite => Icons.location_city_outlined,
              };
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: type != WorkplaceType.values.last ? 8 : 0,
                  ),
                  child: _SelectableChipTile(
                    selected: selected,
                    icon: icon,
                    label: s.workplaceLabel(type),
                    onTap: () => onWorkplaceChanged(type),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(s.employmentContract, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: JobType.values.map((type) {
              final selected = jobType == type;
              return ChoiceChip(
                label: Text(s.jobTypeLabel(type)),
                selected: selected,
                showCheckmark: true,
                selectedColor: cs.primaryContainer,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                backgroundColor: cs.surfaceContainer,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                onSelected: (_) => onJobTypeChanged(type),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class FormPipelineStatusSection extends StatelessWidget {
  const FormPipelineStatusSection({
    super.key,
    required this.activeStages,
    required this.statusId,
    required this.priority,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  final List<PipelineStageConfig> activeStages;
  final String statusId;
  final PriorityLevel priority;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<PriorityLevel> onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final s = AppLocaleScope.of(context);
    final stageIdx = activeStages.indexWhere((st) => st.id == statusId);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            icon: Icons.flag_outlined,
            iconBg: cs.tertiaryContainer.withValues(alpha: 0.16),
            iconFg: cs.tertiary,
            title: s.pipelineStatusPriority,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.pipelineStage, style: theme.textTheme.labelMedium),
              if (stageIdx >= 0)
                Text(
                  s.stageOf(stageIdx + 1, activeStages.length),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: activeStages.map((stage) {
                final selected = statusId == stage.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color:
                        selected ? cs.primaryContainer : cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: () => onStatusChanged(stage.id),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.tertiaryFixedLight
                                    : stage.colorKey.dotColor(brightness),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              stage.label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: selected
                                    ? Colors.white
                                    : cs.onSurfaceVariant,
                                fontWeight: selected
                                    ? FontWeight.w600
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
          Text(s.applicationUrgency, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: PriorityLevel.values.map((level) {
              final selected = priority == level;
              final (bg, fg, dot) = AppColors.priorityColors(level, brightness);
              final sub = switch (level) {
                PriorityLevel.high => s.topFocus,
                PriorityLevel.medium => s.standard,
                PriorityLevel.low => s.backburner,
              };
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: level != PriorityLevel.values.last ? 8 : 0,
                  ),
                  child: Material(
                    color: selected ? bg : cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => onPriorityChanged(level),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 54),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: dot,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  s.priorityLabel(level),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: selected ? fg : cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sub,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: selected
                                    ? fg.withValues(alpha: 0.85)
                                    : cs.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SelectableChipTile extends StatelessWidget {
  const _SelectableChipTile({
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
    return Material(
      color: selected ? cs.primaryContainer : cs.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selected ? Colors.white : cs.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
