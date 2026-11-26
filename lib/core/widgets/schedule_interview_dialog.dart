import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../l10n/app_strings.dart';
import '../services/notification_service.dart';
import 'applyflow_widgets.dart';
import 'notification_permission_dialog.dart';

/// Shared interview scheduling dialog used by both ApplicationDetailPage and
/// NotificationsPage.
Future<void> showScheduleInterviewDialog({
  required BuildContext context,
  required AppDatabase db,
  required JobApplication app,
  String? title,
  VoidCallback? onPermissionSettingsOpened,
  bool useSnackBarForPermissionDenied = false,
}) async {
  final s = AppLocaleScope.of(context);
  const uuid = Uuid();
  final roundCtrl = TextEditingController(text: 'Technical Interview');
  final linkCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(title ?? s.interviewSchedule),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roundCtrl,
                decoration: InputDecoration(
                  labelText: s.isId ? 'Tahap Interview' : 'Round Name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: linkCtrl,
                decoration: InputDecoration(
                  labelText: s.isId
                      ? 'Link Meeting (opsional)'
                      : 'Meeting Link (optional)',
                ),
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
                      label: Text(
                        DateFormat('dd MMM').format(selectedDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                      label: Text(
                        selectedTime.format(ctx),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    s.reminderSchedule.isEmpty
                        ? Icons.notifications_off_outlined
                        : Icons.notifications_active_outlined,
                    size: 15,
                    color: Theme.of(ctx).colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${s.reminderAutoPreviewPrefix}: ${s.reminderSchedule.formatSummary(isId: s.isId, short: true)}',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
                ],
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
              final scheduleId = uuid.v4();

              try {
                final reminderResult = await NotificationService.instance
                    .scheduleInterviewReminders(
                  scheduleId: scheduleId,
                  companyName: app.companyName,
                  roundName: roundName,
                  scheduledAtUtc: utcDt,
                  config: s.reminderSchedule,
                );

                await db.insertInterviewSchedule(
                  InterviewSchedulesCompanion.insert(
                    id: scheduleId,
                    applicationId: app.id,
                    roundName: roundName,
                    scheduledAt: utcDt,
                    meetingUrl: Value(
                      linkCtrl.text.trim().isEmpty
                          ? null
                          : linkCtrl.text.trim(),
                    ),
                    notificationId24h:
                        Value(reminderResult.notificationId24h),
                    notificationId1h: Value(reminderResult.notificationId1h),
                  ),
                );

                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  final msg = switch (reminderResult.status) {
                    ReminderStatus.scheduledAll ||
                    ReminderStatus.scheduledPartial =>
                      s.reminderActiveSummary(
                        reminderResult.scheduledOffsetsMinutes,
                      ),
                    ReminderStatus.tooClose => s.reminderTooCloseMessage(
                        reminderResult.minLeadMinutes,
                      ),
                    ReminderStatus.disabled => s.remindersDisabledSaved,
                    ReminderStatus.permissionDenied => s.isId
                        ? 'Jadwal disimpan, pengingat tidak aktif (izin notifikasi ditolak).'
                        : 'Saved, reminders inactive (notification permission denied).',
                    ReminderStatus.scheduleFailed => s.reminderScheduleFailed,
                  };
                  if (reminderResult.status ==
                          ReminderStatus.permissionDenied &&
                      !useSnackBarForPermissionDenied) {
                    await showNotificationPermissionDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        action: reminderResult.status ==
                                ReminderStatus.permissionDenied
                            ? SnackBarAction(
                                label: s.openNotificationSettings,
                                onPressed: () async {
                                  final opened =
                                      await showNotificationPermissionDialog(
                                    context,
                                  );
                                  if (opened) {
                                    onPermissionSettingsOpened?.call();
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  }
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
