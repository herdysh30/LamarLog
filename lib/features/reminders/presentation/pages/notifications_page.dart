import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../../core/widgets/notification_permission_dialog.dart';
import '../../../../core/widgets/schedule_interview_dialog.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';
import '../../../applications/presentation/pages/application_detail_page.dart';
import '../widgets/reminder_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  bool _showUpcoming = true;
  bool _awaitingSettingsReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSettingsReturn) {
      _awaitingSettingsReturn = false;
      _autoRescheduleIfGranted();
    }
  }

  Future<void> _autoRescheduleIfGranted() async {
    if (!mounted) return;
    final enabled = await NotificationService.instance.areNotificationsEnabled();
    if (!enabled || !mounted) return;

    final db = context.read<AppDatabase>();
    final config = AppLocaleScope.of(context).reminderSchedule;
    final nowUtc = DateTime.now().toUtc();
    final all = await db.watchAllInterviewsWithApplications().first;
    final inactive = all.where((e) {
      return config.isEligibleForReminder(e.schedule.scheduledAt, nowUtc) &&
          e.schedule.notificationId1h == null &&
          e.schedule.notificationId24h == null;
    }).toList();

    if (inactive.isEmpty || !mounted) return;
    await _rescheduleInactive(context, db, inactive, skipPrompt: true);
  }

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
            return s.reminderSchedule
                    .isEligibleForReminder(e.schedule.scheduledAt, nowUtc) &&
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
                      ReminderSegmentTab(
                        label: '${s.upcoming} (${upcoming.length})',
                        selected: _showUpcoming,
                        onTap: () {
                          if (!_showUpcoming) {
                            AppMotion.selectionHaptic();
                            setState(() => _showUpcoming = true);
                          }
                        },
                      ),
                      ReminderSegmentTab(
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

                // Warning banner if upcoming reminders are inactive
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () => _rescheduleInactive(
                                context, db, inactiveUpcoming),
                            child: Text(s.enableReminders),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

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
                                  icon: const Icon(
                                      Icons.event_available_rounded,
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
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = displayed[index];
                            return ReminderCard(
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
                                  await db.deleteInterviewSchedule(
                                    item.schedule.id,
                                  );
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
    List<InterviewWithApplication> items, {
    bool skipPrompt = false,
  }) async {
    final s = AppLocaleScope.of(context);
    int reactivated = 0;

    try {
      final granted = skipPrompt
          ? await NotificationService.instance.areNotificationsEnabled()
          : await NotificationService.instance.requestPermission();

      if (!granted) {
        if (context.mounted) {
          final openedSettings =
              await showNotificationPermissionDialog(context);
          if (openedSettings) {
            _awaitingSettingsReturn = true;
          }
        }
        return;
      }

      for (final entry in items) {
        final res =
            await NotificationService.instance.scheduleInterviewReminders(
          scheduleId: entry.schedule.id,
          companyName: entry.application.companyName,
          roundName: entry.schedule.roundName,
          scheduledAtUtc: entry.schedule.scheduledAt,
          config: s.reminderSchedule,
          skipPermissionPrompt: true,
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
                  : s.reminderScheduleFailed,
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
                          showScheduleInterviewDialog(
                            context: context,
                            db: db,
                            app: app,
                            title: '${s.schedule} • ${app.companyName}',
                            useSnackBarForPermissionDenied: true,
                            onPermissionSettingsOpened: () =>
                                _awaitingSettingsReturn = true,
                          );
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
                                      style:
                                          Theme.of(ctx).textTheme.titleSmall),
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
}
