import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/applyflow_widgets.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.entry,
    required this.isPast,
    required this.onOpenDetail,
    required this.onDelete,
  });

  final InterviewWithApplication entry;
  final bool isPast;
  final VoidCallback onOpenDetail;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);
    final sched = entry.schedule;
    final app = entry.application;

    final localDt = sched.scheduledAt.toLocal();
    final diff = sched.scheduledAt.difference(DateTime.now().toUtc());

    final String countdownLabel;
    if (isPast || diff.isNegative) {
      countdownLabel = s.completedLabel;
    } else if (diff.inHours < 1) {
      countdownLabel = s.startingSoon;
    } else if (diff.inHours < 24) {
      countdownLabel = s.inHours(diff.inHours);
    } else if (diff.inDays == 1) {
      countdownLabel = s.tomorrow;
    } else {
      countdownLabel = s.inDays(diff.inDays);
    }

    final hasPrimary = sched.notificationId24h != null;
    final hasSecondary = sched.notificationId1h != null;
    final isReminderActive = hasPrimary || hasSecondary;
    final reminderText = s.reminderStatusLabel(
      hasPrimary: hasPrimary,
      hasSecondary: hasSecondary,
    );

    return SurfaceCard(
      onTap: onOpenDetail,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyMonogram(
                companyName: app.companyName,
                size: 40,
                radius: 11,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isPast ? cs.surfaceContainerHigh : cs.primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countdownLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPast ? cs.onSurfaceVariant : cs.onPrimaryFixed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Session Detail Container
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.videocam_outlined, size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        sched.roundName,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event_rounded, size: 15, color: cs.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        DateFormat('EEE, dd MMM yyyy • HH:mm').format(localDt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurface),
                      ),
                    ),
                  ],
                ),
                if (sched.meetingUrl?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.link_rounded, size: 15, color: cs.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sched.meetingUrl!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: sched.meetingUrl!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.linkCopied)),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          child: Text(
                            s.copy,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Footer: Reminder alarm status + delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isPast
                          ? Icons.check_circle_outline_rounded
                          : (isReminderActive
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined),
                      size: 15,
                      color: isPast
                          ? cs.outline
                          : (isReminderActive ? cs.tertiary : cs.error),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        isPast ? s.completedLabel : reminderText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isPast
                              ? cs.outline
                              : (isReminderActive ? cs.tertiary : cs.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: s.delete,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 18, color: cs.error),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReminderSegmentTab extends StatelessWidget {
  const ReminderSegmentTab({
    super.key,
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
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
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
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
