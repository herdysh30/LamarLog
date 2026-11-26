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

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

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
        // Android suppresses the system dialog after prior denial — guide user
        // directly to OS App Notification Settings so they are never stuck.
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

  Future<void> _syncInactiveReminders({bool silentIfNone = false}) async {
    final db = context.read<AppDatabase>();
    final s = AppLocaleScope.of(context);
    final nowUtc = DateTime.now().toUtc();
    final all = await db.watchAllInterviewsWithApplications().first;
    final inactive = all.where((e) {
      final diff = e.schedule.scheduledAt.difference(nowUtc);
      return diff >= const Duration(hours: 1) &&
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
                          enabled ? s.notifStatusEnabled : s.notifStatusDisabled,
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

            // Pending Inactive Reminders Sync Banner (only shown if needed)
            StreamBuilder<List<InterviewWithApplication>>(
              stream: db.watchAllInterviewsWithApplications(),
              builder: (context, snapshot) {
                final nowUtc = DateTime.now().toUtc();
                final inactive = (snapshot.data ?? const [])
                    .where((e) {
                      final diff = e.schedule.scheduledAt.difference(nowUtc);
                      return diff >= const Duration(hours: 1) &&
                          e.schedule.notificationId1h == null &&
                          e.schedule.notificationId24h == null;
                    })
                    .toList();

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

            // Automatic Schedule Info (concise, scannable)
            SurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.reminderRulesTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  _RuleRow(
                    icon: Icons.schedule_rounded,
                    label: s.reminderRule24h,
                  ),
                  const SizedBox(height: 8),
                  _RuleRow(
                    icon: Icons.alarm_rounded,
                    label: s.reminderRule1h,
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

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
