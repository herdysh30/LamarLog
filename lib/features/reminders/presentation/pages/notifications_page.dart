import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';
import '../../../applications/presentation/pages/application_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _showUpcoming = true;
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocaleScope.of(context);

    return Scaffold(
      appBar: ApplyFlowAppBar(subtitle: s.navNotifications),
      body: StreamBuilder<List<InterviewWithApplication>>(
        stream: db.watchAllInterviewsWithApplications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorStateCard(
              title: s.dbLoadErrorTitle,
              detail: snapshot.error.toString(),
              retryLabel: s.retry,
              onRetry: () => setState(() {}),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final nowUtc = DateTime.now().toUtc();
          final all = snapshot.data ?? const <InterviewWithApplication>[];

          final upcoming = all
              .where((e) => !e.schedule.scheduledAt.isBefore(nowUtc))
              .toList()
            ..sort((a, b) =>
                a.schedule.scheduledAt.compareTo(b.schedule.scheduledAt));

          final past = all
              .where((e) => e.schedule.scheduledAt.isBefore(nowUtc))
              .toList()
            ..sort((a, b) =>
                b.schedule.scheduledAt.compareTo(a.schedule.scheduledAt));

          final inactiveUpcoming = upcoming.where((e) {
            final diff = e.schedule.scheduledAt.difference(nowUtc);
            return diff >= const Duration(hours: 1) &&
                e.schedule.notificationId1h == null &&
                e.schedule.notificationId24h == null;
          }).toList();

          final displayed = _showUpcoming ? upcoming : past;

          return ResponsiveCenter(
            maxWidth: 740,
            child: ListView(
              padding: Responsive.pagePadding(context, bottom: 96),
            children: [
              Text(s.notificationsTitle, style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(s.notificationsSubtitle, style: theme.textTheme.bodySmall),
              const SizedBox(height: 14),

              // Upcoming / Past Segmented Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _SegmentTab(
                      label: '${s.upcoming} (${upcoming.length})',
                      selected: _showUpcoming,
                      onTap: () {
                        if (!_showUpcoming) {
                          AppMotion.selectionHaptic();
                          setState(() => _showUpcoming = true);
                        }
                      },
                    ),
                    _SegmentTab(
                      label: '${s.past} (${past.length})',
                      selected: !_showUpcoming,
                      onTap: () {
                        if (_showUpcoming) {
                          AppMotion.selectionHaptic();
                          setState(() => _showUpcoming = false);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Warning banner if upcoming reminders are inactive (permission fallback)
              if (_showUpcoming && inactiveUpcoming.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.warningBgDark
                        : AppColors.warningBgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 19,
                            color: isDark
                                ? AppColors.warningIconDark
                                : AppColors.warningIconLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.permissionInactiveBanner,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.warningFgDark
                                    : AppColors.warningFgLight,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () =>
                              _rescheduleInactive(context, db, inactiveUpcoming),
                          child: Text(s.enableReminders),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Empty State or Cards List (smooth fade-through on Upcoming/Past switch)
              AnimatedSwitcher(
                duration: AppMotion.duration(context, AppMotion.medium),
                switchInCurve: AppMotion.enterCurve,
                switchOutCurve: AppMotion.exitCurve,
                child: displayed.isEmpty
                    ? Padding(
                        key: ValueKey('empty_$_showUpcoming'),
                        padding: const EdgeInsets.symmetric(vertical: 42),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: cs.primaryFixed,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _showUpcoming
                                    ? Icons.notifications_none_rounded
                                    : Icons.history_rounded,
                                size: 30,
                                color: cs.onPrimaryFixed,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _showUpcoming
                                  ? s.noUpcomingInterviews
                                  : s.noPastInterviews,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall,
                            ),
                            if (_showUpcoming) ...[
                              const SizedBox(height: 6),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 300),
                                child: Text(
                                  s.noUpcomingSub,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              const SizedBox(height: 18),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: cs.primaryContainer,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () =>
                                    _startQuickSchedule(context, db),
                                icon: const Icon(Icons.event_available_rounded,
                                    size: 18),
                                label: Text(s.scheduleInterview),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.separated(
                        key: ValueKey('list_$_showUpcoming'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayed.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = displayed[index];
                          return _ReminderCard(
                            entry: item,
                            isPast: !_showUpcoming,
                            onOpenDetail: () {
                              Navigator.of(context).push(
                                AppMotion.sharedAxisRoute<void>(
                                  ApplicationDetailPage(
                                    application: item.application,
                                  ),
                                ),
                              );
                            },
                            onDelete: () async {
                              try {
                                await NotificationService.instance
                                    .cancelReminders(
                                  item.schedule.notificationId24h,
                                  item.schedule.notificationId1h,
                                );
                                await db
                                    .deleteInterviewSchedule(item.schedule.id);
                              } catch (_) {
                                if (context.mounted) {
                                  showErrorSnackBar(
                                      context, s.actionFailedGeneric);
                                }
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startQuickSchedule(context, db),
        icon: const Icon(Icons.event_available_rounded, size: 20),
        label: Text(
          s.schedule,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _rescheduleInactive(
    BuildContext context,
    AppDatabase db,
    List<InterviewWithApplication> items,
  ) async {
    final s = AppLocaleScope.of(context);
    int reactivated = 0;

    try {
      for (final entry in items) {
        final res =
            await NotificationService.instance.scheduleInterviewReminders(
          scheduleId: entry.schedule.id,
          companyName: entry.application.companyName,
          roundName: entry.schedule.roundName,
          scheduledAtUtc: entry.schedule.scheduledAt,
        );
        if (res.notificationId1h != null || res.notificationId24h != null) {
          await db.updateInterviewReminderIds(
            id: entry.schedule.id,
            notificationId24h: res.notificationId24h,
            notificationId1h: res.notificationId1h,
          );
          reactivated++;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reactivated > 0
                  ? (s.isId
                      ? '$reactivated pengingat berhasil diaktifkan kembali.'
                      : '$reactivated reminder(s) re-enabled.')
                  : (s.isId
                      ? 'Izin notifikasi belum diberikan di pengaturan perangkat.'
                      : 'Notification permission is still denied in device settings.'),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        showErrorSnackBar(context, s.actionFailedGeneric);
      }
    }
  }

  void _startQuickSchedule(BuildContext context, AppDatabase db) {
    final s = AppLocaleScope.of(context);
    final apps = context.read<ApplicationsBloc>().state.activeApplications;

    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noAppsToSchedule)),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.65,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.pickApplicationFirst,
                    style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: apps.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, idx) {
                      final app = apps[idx];
                      return SurfaceCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _showScheduleDialog(context, db, app);
                        },
                        child: Row(
                          children: [
                            CompanyMonogram(
                              companyName: app.companyName,
                              size: 38,
                              radius: 10,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app.companyName,
                                      style: Theme.of(ctx).textTheme.titleSmall),
                                  Text(app.roleTitle,
                                      style: Theme.of(ctx).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showScheduleDialog(
    BuildContext context,
    AppDatabase db,
    JobApplication app,
  ) async {
    final s = AppLocaleScope.of(context);
    final roundCtrl = TextEditingController(text: 'Technical Interview');
    final linkCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('${s.schedule} • ${app.companyName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roundCtrl,
                decoration: InputDecoration(
                    labelText: s.isId ? 'Tahap Interview' : 'Round Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: linkCtrl,
                decoration: InputDecoration(
                    labelText: s.isId
                        ? 'Link Meeting (opsional)'
                        : 'Meeting Link (optional)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined, size: 15),
                      label: Text(DateFormat('dd MMM').format(selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: ctx,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setDialogState(() => selectedTime = picked);
                        }
                      },
                      icon: const Icon(Icons.access_time_rounded, size: 15),
                      label: Text(selectedTime.format(ctx)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final roundName = roundCtrl.text.trim();
                if (roundName.isEmpty) {
                  showErrorSnackBar(context, s.roundNameRequired);
                  return;
                }
                final localDt = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                if (!localDt.isAfter(DateTime.now())) {
                  showErrorSnackBar(context, s.pastInterviewError);
                  return;
                }
                final utcDt = localDt.toUtc();
                final scheduleId = _uuid.v4();

                try {
                  final res = await NotificationService.instance
                      .scheduleInterviewReminders(
                    scheduleId: scheduleId,
                    companyName: app.companyName,
                    roundName: roundName,
                    scheduledAtUtc: utcDt,
                  );

                  await db.insertInterviewSchedule(
                    InterviewSchedulesCompanion.insert(
                      id: scheduleId,
                      applicationId: app.id,
                      roundName: roundName,
                      scheduledAt: utcDt,
                      meetingUrl: Value(linkCtrl.text.trim().isEmpty
                          ? null
                          : linkCtrl.text.trim()),
                      notificationId24h: Value(res.notificationId24h),
                      notificationId1h: Value(res.notificationId1h),
                    ),
                  );

                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    final msg = switch (res.status) {
                      ReminderStatus.scheduledBoth => s.remindersActiveBoth,
                      ReminderStatus.scheduledOneHourOnly => s.reminderActive1h,
                      ReminderStatus.lessThanOneHour => s.isId
                          ? 'Jadwal kurang dari 1 jam lagi. Tidak ada alarm terjadwal.'
                          : 'Scheduled under 1 hour away. No alarm scheduled.',
                      ReminderStatus.permissionDenied => s.isId
                          ? 'Jadwal disimpan, pengingat tidak aktif (izin notifikasi ditolak).'
                          : 'Saved, reminders inactive (notification permission denied).',
                      ReminderStatus.scheduleFailed => s.reminderScheduleFailed,
                    };
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  }
                } catch (_) {
                  if (context.mounted) {
                    showErrorSnackBar(context, s.scheduleSaveFailed);
                  }
                }
              },
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
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

    final hasBoth =
        sched.notificationId24h != null && sched.notificationId1h != null;
    final hasOne =
        sched.notificationId1h != null && sched.notificationId24h == null;
    final isReminderActive = hasBoth || hasOne;
    final reminderText = hasBoth
        ? s.remindersActiveBoth
        : hasOne
            ? s.reminderActive1h
            : s.remindersInactive;

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
                              ClipboardData(text: sched.meetingUrl!));
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

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
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
