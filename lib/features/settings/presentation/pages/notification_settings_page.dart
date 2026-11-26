import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/models/reminder_schedule_config.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../../core/widgets/notification_permission_dialog.dart';
import '../widgets/reminder_duration_sheet.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({
    super.key,
    this.onReminderScheduleChanged,
  });

  final ValueChanged<ReminderScheduleConfig>? onReminderScheduleChanged;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>
    with WidgetsBindingObserver {
  bool? _isEnabled;
  bool _busy = false;
  bool _awaitingSettingsReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final wasWaiting = _awaitingSettingsReturn;
      _awaitingSettingsReturn = false;
      _refreshStatus(autoSyncIfNowEnabled: wasWaiting);
    }
  }

  Future<void> _refreshStatus({bool autoSyncIfNowEnabled = false}) async {
    final enabled = await NotificationService.instance.areNotificationsEnabled();
    if (!mounted) return;
    setState(() => _isEnabled = enabled);
    if (autoSyncIfNowEnabled && enabled) {
      await _syncInactiveReminders(silentIfNone: true);
    }
  }

  Future<void> _handleRequestPermission() async {
    if (_busy) return;
    AppMotion.selectionHaptic();
    setState(() => _busy = true);
    try {
      final granted = await NotificationService.instance.requestPermission();
      if (!mounted) return;
      setState(() => _isEnabled = granted);

      if (granted) {
        await _syncInactiveReminders(silentIfNone: true);
        if (mounted) {
          final s = AppLocaleScope.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                s.isId
                    ? 'Notifikasi aktif! Pengingat interview siap berjalan.'
                    : 'Notifications enabled! Interview reminders are active.',
              ),
            ),
          );
        }
      } else {
        final openedSettings = await showNotificationPermissionDialog(context);
        if (openedSettings) {
          _awaitingSettingsReturn = true;
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleOpenSystemSettings() async {
    AppMotion.selectionHaptic();
    _awaitingSettingsReturn = true;
    await NotificationService.instance.openNotificationSettings();
  }

  Future<void> _applyReminderSchedule(ReminderScheduleConfig next) async {
    final db = context.read<AppDatabase>();
    final s = AppLocaleScope.of(context);
    final normalized = next.normalized();

    NotificationService.instance.reminderSchedule = normalized;
    widget.onReminderScheduleChanged?.call(normalized);

    int rescheduled = 0;
    try {
      rescheduled = await NotificationService.instance.rescheduleAllUpcoming(
        db,
        config: normalized,
      );
    } catch (_) {}

    if (mounted) {
      final summary = normalized.formatSummary(isId: s.isId, short: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.reminderScheduleUpdatedMsg(summary, rescheduled)),
        ),
      );
    }
  }

  Future<void> _editSlot({
    required ReminderScheduleConfig current,
    required bool isPrimary,
  }) async {
    final currentMinutes =
        isPrimary ? current.primaryMinutes : current.secondaryMinutes;
    final otherMinutes =
        isPrimary ? current.secondaryMinutes : current.primaryMinutes;
    final fallbackMinutes = isPrimary ? 1440 : 60;

    final picked = await showReminderDurationSheet(
      context: context,
      initialMinutes: currentMinutes ?? fallbackMinutes,
      otherSlotMinutes: otherMinutes,
    );
    if (picked == null || !mounted) return;

    final updated = isPrimary
        ? current.copyWith(primaryMinutes: picked)
        : current.copyWith(secondaryMinutes: picked);
    await _applyReminderSchedule(updated);
  }

  Future<void> _toggleSlot({
    required ReminderScheduleConfig current,
    required bool isPrimary,
    required bool enabled,
  }) async {
    AppMotion.selectionHaptic();
    if (!enabled) {
      final updated = isPrimary
          ? current.copyWith(clearPrimary: true)
          : current.copyWith(clearSecondary: true);
      await _applyReminderSchedule(updated);
      return;
    }

    final other = isPrimary ? current.secondaryMinutes : current.primaryMinutes;
    int defaultMins = isPrimary ? 1440 : 60;
    if (other == defaultMins) {
      defaultMins = other == 60 ? 30 : 60;
    }
    final updated = isPrimary
        ? current.copyWith(primaryMinutes: defaultMins)
        : current.copyWith(secondaryMinutes: defaultMins);
    await _applyReminderSchedule(updated);
  }

  Future<void> _syncInactiveReminders({bool silentIfNone = false}) async {
    final db = context.read<AppDatabase>();
    final s = AppLocaleScope.of(context);
    final config = s.reminderSchedule;
    final nowUtc = DateTime.now().toUtc();
    final all = await db.watchAllInterviewsWithApplications().first;
    final inactive = all.where((e) {
      return config.isEligibleForReminder(e.schedule.scheduledAt, nowUtc) &&
          e.schedule.notificationId1h == null &&
          e.schedule.notificationId24h == null;
    }).toList();

    if (inactive.isEmpty) {
      if (!silentIfNone && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              s.isId
                  ? 'Semua jadwal mendatang sudah memiliki alarm aktif.'
                  : 'All upcoming schedules already have active alarms.',
            ),
          ),
        );
      }
      return;
    }

    int reactivated = 0;
    for (final entry in inactive) {
      final res = await NotificationService.instance.scheduleInterviewReminders(
        scheduleId: entry.schedule.id,
        companyName: entry.application.companyName,
        roundName: entry.schedule.roundName,
        scheduledAtUtc: entry.schedule.scheduledAt,
        config: config,
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

    if (mounted && reactivated > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.isId
                ? '$reactivated pengingat berhasil diaktifkan kembali.'
                : '$reactivated reminder(s) re-enabled.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocaleScope.of(context);
    final enabled = _isEnabled ?? false;
    final config = s.reminderSchedule.normalized();

    final statusColor = enabled
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? AppColors.warningIconDark : AppColors.warningIconLight);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.settingsNotificationsTitle,
          style: theme.textTheme.titleMedium,
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 680,
        child: ListView(
          padding: Responsive.pagePadding(context, bottom: 32),
          children: [
            // Permission Status Card
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          enabled
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_outlined,
                          color: statusColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.notifPermissionCardTitle,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isEnabled == null
                                  ? '...'
                                  : (enabled
                                      ? s.notifPermissionEnabledDesc
                                      : s.notifPermissionDisabledDesc),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          enabled
                              ? s.notifStatusEnabled
                              : s.notifStatusDisabled,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!enabled)
                    FilledButton.icon(
                      onPressed: _busy ? null : _handleRequestPermission,
                      icon: const Icon(Icons.notifications_rounded, size: 18),
                      label: Text(s.requestPermissionNow),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _handleOpenSystemSettings,
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: Text(s.deviceNotificationSettings),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pending Inactive Reminders Sync Banner
            StreamBuilder<List<InterviewWithApplication>>(
              stream: db.watchAllInterviewsWithApplications(),
              builder: (context, snapshot) {
                final nowUtc = DateTime.now().toUtc();
                final inactive = (snapshot.data ?? const []).where((e) {
                  return config.isEligibleForReminder(
                          e.schedule.scheduledAt, nowUtc) &&
                      e.schedule.notificationId1h == null &&
                      e.schedule.notificationId24h == null;
                }).toList();

                if (inactive.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SurfaceCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          color: cs.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.pendingRemindersCount(inactive.length),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () async {
                            if (!enabled) {
                              await _handleRequestPermission();
                            } else {
                              await _syncInactiveReminders();
                            }
                          },
                          child: Text(s.syncPendingReminders),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Customizable Automatic Reminder Schedule Card
            SurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          s.reminderRulesTitle,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (!config.isDefault)
                        TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: () => _applyReminderSchedule(
                            ReminderScheduleConfig.defaults,
                          ),
                          child: Text(s.reminderResetDefault),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.reminderRulesSubtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _ReminderSlotRow(
                    icon: Icons.schedule_rounded,
                    title: s.reminderFirstSlot,
                    subtitle: config.primaryMinutes != null
                        ? s.reminderBeforeInterview(config.primaryMinutes!)
                        : s.reminderSlotOff,
                    enabled: config.primaryMinutes != null,
                    onTapTime: () => _editSlot(
                      current: config,
                      isPrimary: true,
                    ),
                    onToggle: (v) => _toggleSlot(
                      current: config,
                      isPrimary: true,
                      enabled: v,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ReminderSlotRow(
                    icon: Icons.alarm_rounded,
                    title: s.reminderSecondSlot,
                    subtitle: config.secondaryMinutes != null
                        ? s.reminderBeforeInterview(config.secondaryMinutes!)
                        : s.reminderSlotOff,
                    enabled: config.secondaryMinutes != null,
                    onTapTime: () => _editSlot(
                      current: config,
                      isPrimary: false,
                    ),
                    onToggle: (v) => _toggleSlot(
                      current: config,
                      isPrimary: false,
                      enabled: v,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  InkWell(
                    onTap: _handleOpenSystemSettings,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 19,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.deviceNotificationSettings,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 17,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderSlotRow extends StatelessWidget {
  const _ReminderSlotRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTapTime,
    required this.onToggle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTapTime;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTapTime,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: enabled ? cs.primaryFixed : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: enabled ? cs.onPrimaryFixed : cs.outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: enabled ? cs.onSurface : cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: enabled ? cs.primary : cs.outline,
                              fontWeight:
                                  enabled ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (enabled) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: cs.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
