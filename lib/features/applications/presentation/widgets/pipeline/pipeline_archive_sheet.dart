import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/enums/application_enums.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/widgets/applyflow_widgets.dart';

void showTerminalArchiveSheet({
  required BuildContext context,
  required List<JobApplication> terminalApps,
  required ValueChanged<JobApplication> onOpenDetail,
}) {
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
            .where((a) => a.currentStatus == ApplicationStatus.offerAccepted.name)
            .length;
        final rejectedCount = terminalApps
            .where((a) => a.currentStatus == ApplicationStatus.rejected.name)
            .length;
        final otherCount = terminalApps.length - acceptedCount - rejectedCount;

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
                          onTap: () => setSheetState(() => filterKey = 'other'),
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
                              onOpenDetail(app);
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
                                    style: theme.textTheme.labelSmall?.copyWith(
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
