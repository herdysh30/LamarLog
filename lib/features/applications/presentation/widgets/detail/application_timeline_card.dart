import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/widgets/applyflow_widgets.dart';

class ApplicationTimelineCard extends StatelessWidget {
  const ApplicationTimelineCard({
    super.key,
    required this.application,
    required this.db,
    required this.onRetry,
  });

  static const _uuid = Uuid();

  final JobApplication application;
  final AppDatabase db;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.history_edu_rounded,
                        size: 20, color: cs.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        s.timelineActivity,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: () => _showAddNoteDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(s.addNote),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<TimelineLog>>(
            stream: db.watchTimelineLogs(application.id),
            builder: (context, logSnap) {
              return StreamBuilder<List<StatusTransition>>(
                stream: db.watchTransitionsForApp(application.id),
                builder: (context, transSnap) {
                  if (logSnap.hasError || transSnap.hasError) {
                    return ErrorStateCard(
                      compact: true,
                      title: s.dbLoadErrorTitle,
                      retryLabel: s.retry,
                      onRetry: onRetry,
                    );
                  }
                  final entries = <_TimelineEntry>[
                    ...(logSnap.data ?? []).map(
                      (l) => _TimelineEntry(
                        title: l.title,
                        body: l.note,
                        timestamp: l.loggedAt.toLocal(),
                        isStatusEvent: false,
                        log: l,
                      ),
                    ),
                    ...(transSnap.data ?? []).map((t) {
                      final toLabel = s.statusLabelById(t.toStatus);
                      final title = t.fromStatus == null
                          ? (s.isId
                              ? 'Ditambahkan ke $toLabel'
                              : 'Added to $toLabel')
                          : (s.isId
                              ? 'Status pindah ke $toLabel'
                              : 'Status moved to $toLabel');
                      return _TimelineEntry(
                        title: title,
                        body: '',
                        timestamp: t.transitionedAt.toLocal(),
                        isStatusEvent: true,
                      );
                    }),
                  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        s.noActivityYet,
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(entries.length, (i) {
                      final item = entries[i];
                      final isLast = i == entries.length - 1;
                      final dotColor =
                          item.isStatusEvent ? cs.tertiary : cs.primary;

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 22,
                              child: Column(
                                children: [
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 11,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: cs.surface,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        color: cs.surfaceContainerHighest,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(bottom: isLast ? 0 : 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat('dd MMM, HH:mm')
                                              .format(item.timestamp),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(color: cs.secondary),
                                        ),
                                        if (!item.isStatusEvent &&
                                            item.log != null) ...[
                                          const SizedBox(width: 2),
                                          SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: PopupMenuButton<String>(
                                              padding: EdgeInsets.zero,
                                              iconSize: 17,
                                              icon: Icon(
                                                Icons.more_vert_rounded,
                                                color: cs.onSurfaceVariant,
                                              ),
                                              onSelected: (action) {
                                                if (action == 'edit') {
                                                  _showEditNoteDialog(
                                                    context,
                                                    item.log!,
                                                  );
                                                } else if (action == 'delete') {
                                                  _confirmDeleteNote(
                                                    context,
                                                    item.log!,
                                                  );
                                                }
                                              },
                                              itemBuilder: (_) => [
                                                PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.edit_outlined,
                                                          size: 17),
                                                      const SizedBox(width: 8),
                                                      Text(s.editNote),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        size: 17,
                                                        color: cs.error,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        s.delete,
                                                        style: TextStyle(
                                                          color: cs.error,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (item.body.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerLow,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item.body,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final s = AppLocaleScope.of(context);
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.addNote),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: s.isId ? 'Judul' : 'Title',
                  hintText: s.isId
                      ? 'cth. Screening HR Selesai'
                      : 'e.g. Recruiter Screen Completed',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: s.isId ? 'Catatan' : 'Details',
                  hintText: s.isId
                      ? 'Pertanyaan interview, kisaran gaji, langkah selanjutnya...'
                      : 'Questions asked, salary range, next steps...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await db.insertTimelineLog(
                TimelineLogsCompanion.insert(
                  id: _uuid.v4(),
                  applicationId: application.id,
                  title: titleCtrl.text.trim(),
                  note: Value(noteCtrl.text.trim()),
                  loggedAt: DateTime.now().toUtc(),
                ),
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, TimelineLog log) {
    final s = AppLocaleScope.of(context);
    final titleCtrl = TextEditingController(text: log.title);
    final noteCtrl = TextEditingController(text: log.note);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.editNote),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: s.isId ? 'Judul' : 'Title',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: s.isId ? 'Catatan' : 'Details',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await db.updateTimelineLog(
                id: log.id,
                title: titleCtrl.text.trim(),
                note: noteCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteNote(BuildContext context, TimelineLog log) {
    final s = AppLocaleScope.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteNoteTitle),
        content: Text(s.deleteNoteBody),
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
              await db.deleteTimelineLog(log.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isStatusEvent,
    this.log,
  });

  final String title;
  final String body;
  final DateTime timestamp;
  final bool isStatusEvent;
  final TimelineLog? log;
}
