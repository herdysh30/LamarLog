import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/models/pipeline_stage_config.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';

/// Shows a full interactive bottom sheet to add, rename, recolor, reorder,
/// delete (with safe application reassignment), or reset active Kanban stages.
Future<void> showPipelineStagesManagerSheet(
  BuildContext context, {
  required ValueChanged<List<PipelineStageConfig>?> onSave,
}) async {
  final s = AppLocaleScope.of(context);
  final bloc = context.read<ApplicationsBloc>();
  final currentApps = bloc.state.applications;

  final persisted = List<PipelineStageConfig>.from(s.pipelineStages);
  final working = List<PipelineStageConfig>.from(s.pipelineStages);
  final deletedStagesToReassign = <String>[];

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final brightness = theme.brightness;

        int countInStage(String stageId) =>
            currentApps.where((a) => a.currentStatus == stageId).length;

        Future<void> openAddOrEditDialog({int? editIndex}) async {
          final isEditing = editIndex != null;
          final existing = isEditing ? working[editIndex] : null;
          final ctrl = TextEditingController(text: existing?.label ?? '');
          var selectedColor = existing?.colorKey ??
              StageColorKey.values[working.length % StageColorKey.values.length];

          await showDialog<void>(
            context: ctx,
            builder: (dCtx) => StatefulBuilder(
              builder: (dCtx, setDialogState) => AlertDialog(
                title: Text(
                  isEditing
                      ? (s.isId ? 'Ubah Tahap' : 'Edit Stage')
                      : s.addStageTitle,
                ),
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
                          hintText: s.stageNameHint,
                          labelText: s.isId ? 'Nama Tahap' : 'Stage Name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.stageColorLabel,
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: StageColorKey.values.map((key) {
                          final dot = key.dotColor(brightness);
                          final isSel = selectedColor == key;
                          return InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () =>
                                setDialogState(() => selectedColor = key),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: dot,
                                shape: BoxShape.circle,
                                border: isSel
                                    ? Border.all(
                                        color: cs.onSurface,
                                        width: 2.5,
                                      )
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
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dCtx).pop(),
                    child: Text(s.cancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      final name = ctrl.text.trim();
                      if (name.isEmpty) return;
                      if (isEditing) {
                        setSheetState(() {
                          working[editIndex] = working[editIndex].copyWith(
                            label: name,
                            colorKey: selectedColor,
                          );
                        });
                      } else {
                        final newId = PipelineStageConfig.generateCustomId(
                          name,
                          {
                            ...working.map((e) => e.id),
                            ...persisted.map((e) => e.id),
                          },
                        );
                        final newStage = PipelineStageConfig(
                          id: newId,
                          label: name,
                          colorKey: selectedColor,
                        );
                        persisted.add(newStage);
                        setSheetState(() => working.add(newStage));
                        onSave(List<PipelineStageConfig>.from(persisted));
                      }
                      Navigator.of(dCtx).pop();
                    },
                    child: Text(s.save),
                  ),
                ],
              ),
            ),
          );
        }

        Future<void> confirmDeleteStage(int index) async {
          if (working.length <= 1) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(s.cannotDeleteLastStage)),
            );
            return;
          }
          final stage = working[index];
          final affectedCount = countInStage(stage.id);
          final fallbackStage = working[index > 0 ? index - 1 : 1];

          final confirmed = await showDialog<bool>(
            context: ctx,
            builder: (dCtx) => AlertDialog(
              title: Text(s.deleteStageTitle(stage.label)),
              content: Text(
                affectedCount > 0
                    ? s.deleteStageReassignNote(
                        affectedCount,
                        fallbackStage.label,
                      )
                    : s.deleteStageBody,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dCtx).pop(false),
                  child: Text(s.cancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(dCtx).pop(true),
                  child: Text(s.delete),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            setSheetState(() {
              deletedStagesToReassign.add(stage.id);
              working.removeAt(index);
            });
          }
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.84,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.managePipelineStages,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.stageCountBadge(working.length),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          setSheetState(() {
                            working
                              ..clear()
                              ..addAll(
                                PipelineStageConfig.defaults(isId: s.isId),
                              );
                          });
                        },
                        child: Text(s.resetDefault),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.reorderOrEditHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: working.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, idx) {
                        final stage = working[idx];
                        final count = countInStage(stage.id);
                        final dot = stage.colorKey.dotColor(brightness);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: dot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () =>
                                      openAddOrEditDialog(editIndex: idx),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stage.label,
                                          style: theme.textTheme.titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (count > 0)
                                          Text(
                                            s.isId
                                                ? '$count lamaran'
                                                : '$count applications',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: s.moveUp,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.arrow_upward_rounded,
                                    size: 18),
                                onPressed: idx > 0
                                    ? () {
                                        setSheetState(() {
                                          final item = working.removeAt(idx);
                                          working.insert(idx - 1, item);
                                        });
                                      }
                                    : null,
                              ),
                              IconButton(
                                tooltip: s.moveDown,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.arrow_downward_rounded,
                                    size: 18),
                                onPressed: idx < working.length - 1
                                    ? () {
                                        setSheetState(() {
                                          final item = working.removeAt(idx);
                                          working.insert(idx + 1, item);
                                        });
                                      }
                                    : null,
                              ),
                              IconButton(
                                tooltip: s.isId ? 'Ubah' : 'Edit',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () =>
                                    openAddOrEditDialog(editIndex: idx),
                              ),
                              IconButton(
                                tooltip: s.delete,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: working.length > 1
                                      ? cs.error
                                      : cs.outline,
                                ),
                                onPressed: working.length > 1
                                    ? () => confirmDeleteStage(idx)
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: working.length >= 12
                                ? null
                                : () => openAddOrEditDialog(),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(s.addStage),
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
                              final fallbackId = working.first.id;
                              final activeIds =
                                  working.map((e) => e.id).toSet();
                              // Reassign any applications in deleted or removed stages safely
                              final removedIds = <String>{
                                ...deletedStagesToReassign,
                                for (final app in currentApps)
                                  if (!PipelineStageConfig.isTerminalStatusId(
                                          app.currentStatus) &&
                                      !activeIds.contains(app.currentStatus))
                                    app.currentStatus,
                              };
                              for (final oldId in removedIds) {
                                bloc.add(
                                  ReassignStageApplications(
                                    fromStageId: oldId,
                                    toStageId: fallbackId,
                                  ),
                                );
                              }
                              onSave(List<PipelineStageConfig>.from(working));
                              Navigator.of(ctx).pop();
                            },
                            child: Text(s.save),
                          ),
                        ),
                      ),
                    ],
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
