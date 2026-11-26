import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/enums/application_enums.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/models/pipeline_stage_config.dart';
import '../../../../settings/presentation/widgets/pipeline_stages_sheet.dart';
import '../../bloc/applications_bloc.dart';

void showPipelineFilterSheet(BuildContext context, ApplicationsState state) {
  WorkplaceType? selectedWorkplace = state.workplaceFilter;
  PriorityLevel? selectedPriority = state.priorityFilter;
  bool selectedStaleOnly = state.staleOnlyFilter;
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
                  Text(s.pipelineFilter, style: theme.textTheme.headlineSmall),
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
                    onTap: () => setSheetState(() => selectedWorkplace = null),
                  ),
                  ...WorkplaceType.values.map(
                    (w) => _FilterPill(
                      label: s.workplaceLabel(w),
                      selected: selectedWorkplace == w,
                      onTap: () => setSheetState(() => selectedWorkplace = w),
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
                    onTap: () => setSheetState(() => selectedPriority = null),
                  ),
                  ...PriorityLevel.values.map(
                    (p) => _FilterPill(
                      label: s.priorityLabel(p),
                      selected: selectedPriority == p,
                      onTap: () => setSheetState(() => selectedPriority = p),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(s.staleOnlyFilter,
                    style: theme.textTheme.labelLarge),
                value: selectedStaleOnly,
                onChanged: (v) => setSheetState(() => selectedStaleOnly = v),
              ),
              const SizedBox(height: 8),
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
                                  staleOnlyFilter: selectedStaleOnly,
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

void showRenameStageDialog({
  required BuildContext context,
  required PipelineStageConfig stage,
  void Function(String stageId, String? newName)? onRenameStage,
  ValueChanged<List<PipelineStageConfig>?>? onPipelineStagesChanged,
}) {
  final s = AppLocaleScope.of(context);
  final ctrl = TextEditingController(text: stage.label);
  var selectedColor = stage.colorKey;

  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final brightness = theme.brightness;

        return AlertDialog(
          title: Text(s.isId ? 'Ubah Tahap' : 'Edit Stage'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: s.columnNameHint,
                    labelText: s.isId ? 'Nama Tahap' : 'Stage Name',
                  ),
                ),
                if (onPipelineStagesChanged != null) ...[
                  const SizedBox(height: 16),
                  Text(s.stageColorLabel, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: StageColorKey.values.map((key) {
                      final dot = key.dotColor(brightness);
                      final isSel = selectedColor == key;
                      return InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setDialogState(() => selectedColor = key),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: dot,
                            shape: BoxShape.circle,
                            border: isSel
                                ? Border.all(color: cs.onSurface, width: 2.5)
                                : null,
                          ),
                          child: isSel
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (onPipelineStagesChanged != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  showPipelineStagesManagerSheet(
                    context,
                    onSave: onPipelineStagesChanged,
                  );
                },
                child: Text(s.isId ? 'Kelola Semua' : 'Manage All'),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s.cancel),
            ),
            FilledButton(
              onPressed: () {
                final value = ctrl.text.trim();
                if (value.isNotEmpty) {
                  if (onPipelineStagesChanged != null) {
                    final updated = s.pipelineStages
                        .map((st) => st.id == stage.id
                            ? st.copyWith(
                                label: value,
                                colorKey: selectedColor,
                              )
                            : st)
                        .toList();
                    onPipelineStagesChanged(updated);
                  } else {
                    onRenameStage?.call(stage.id, value);
                  }
                }
                Navigator.of(ctx).pop();
              },
              child: Text(s.save),
            ),
          ],
        );
      },
    ),
  );
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
