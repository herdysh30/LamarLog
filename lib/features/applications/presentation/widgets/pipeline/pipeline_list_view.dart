import 'package:flutter/material.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/layout/responsive.dart';
import '../application_card.dart';

class PipelineListView extends StatelessWidget {
  const PipelineListView({
    super.key,
    required this.applications,
    required this.nextInterviewByApp,
    required this.onOpenDetail,
    required this.onAddFirst,
    required this.isFiltered,
    required this.onResetFilters,
  });

  final List<JobApplication> applications;
  final Map<String, InterviewSchedule> nextInterviewByApp;
  final ValueChanged<JobApplication> onOpenDetail;
  final VoidCallback onAddFirst;
  final bool isFiltered;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    if (applications.isEmpty && isFiltered) {
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
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.filter_alt_off_outlined,
                      size: 28, color: cs.secondary),
                ),
                const SizedBox(height: 16),
                Text(
                  s.noFilterMatchTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  s.noFilterMatchSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: FilledButton.tonalIcon(
                    onPressed: onResetFilters,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(s.resetFilters),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
