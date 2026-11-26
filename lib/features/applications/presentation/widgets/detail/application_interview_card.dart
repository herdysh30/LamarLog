import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/widgets/applyflow_widgets.dart';
import '../../../../../core/widgets/schedule_interview_dialog.dart';

class ApplicationInterviewCard extends StatelessWidget {
  const ApplicationInterviewCard({
    super.key,
    required this.application,
    required this.db,
    required this.onRetry,
  });

  final JobApplication application;
  final AppDatabase db;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    return StreamBuilder<List<InterviewSchedule>>(
      stream: db.watchInterviewsForApp(application.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorStateCard(
            compact: true,
            title: s.dbLoadErrorTitle,
            retryLabel: s.retry,
            onRetry: onRetry,
          );
        }
        final schedules = snapshot.data ?? [];
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
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: cs.primaryFixed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.videocam_outlined,
                              size: 19, color: cs.onPrimaryFixed),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            s.interviewSchedule,
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
                    onPressed: () => showScheduleInterviewDialog(
                      context: context,
                      db: db,
                      app: application,
                    ),
                    icon: const Icon(Icons.event_available_rounded, size: 16),
                    label: Text(s.schedule),
                  ),
                ],
              ),
              if (schedules.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    s.noInterviewsYet,
                    style: theme.textTheme.bodySmall,
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 14),
                  itemCount: schedules.length,
                  separatorBuilder: (_, _) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  itemBuilder: (_, index) {
                    final item = schedules[index];
                    final localDt = item.scheduledAt.toLocal();
                    final hasPrimary = item.notificationId24h != null;
                    final hasSecondary = item.notificationId1h != null;
                    final isReminderActive = hasPrimary || hasSecondary;
                    final reminderLabel = s.reminderStatusLabel(
                      hasPrimary: hasPrimary,
                      hasSecondary: hasSecondary,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.roundName,
                                      style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.event_rounded,
                                          size: 15, color: cs.secondary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          DateFormat('EEE, dd MMM yyyy • HH:mm')
                                              .format(localDt),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(color: cs.onSurface),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: s.delete,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.delete_outline_rounded,
                                  size: 19, color: cs.error),
                              onPressed: () async {
                                await NotificationService.instance
                                    .cancelReminders(
                                  item.notificationId24h,
                                  item.notificationId1h,
                                );
                                await db.deleteInterviewSchedule(item.id);
                              },
                            ),
                          ],
                        ),
                        if (item.meetingUrl?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.link_rounded,
                                    size: 16, color: cs.secondary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.meetingUrl!,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: cs.onSurface),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 32),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: item.meetingUrl!),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(s.linkCopied)),
                                    );
                                  },
                                  child: Text(s.copy,
                                      style: const TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              isReminderActive
                                  ? Icons.notifications_active_outlined
                                  : Icons.notifications_off_outlined,
                              size: 15,
                              color: isReminderActive ? cs.tertiary : cs.error,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                reminderLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color:
                                      isReminderActive ? cs.tertiary : cs.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
