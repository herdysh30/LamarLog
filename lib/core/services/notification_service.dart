import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../database/app_database.dart';
import '../models/reminder_schedule_config.dart';

enum ReminderStatus {
  scheduledAll,
  scheduledPartial,
  tooClose,
  disabled,
  permissionDenied,
  scheduleFailed,
}

class ReminderScheduleResult {
  const ReminderScheduleResult({
    required this.status,
    this.notificationId24h,
    this.notificationId1h,
    this.scheduledOffsetsMinutes = const [],
    this.minLeadMinutes,
  });

  final ReminderStatus status;

  /// Primary (earlier) scheduled notification ID.
  final int? notificationId24h;

  /// Secondary (closer) scheduled notification ID.
  final int? notificationId1h;

  /// Lead-time offsets (in minutes) actually scheduled.
  final List<int> scheduledOffsetsMinutes;

  /// Shortest enabled lead time when [status] is [ReminderStatus.tooClose].
  final int? minLeadMinutes;
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const MethodChannel _systemChannel =
      MethodChannel('com.lamarlog.lamarlog/system');

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Active automatic reminder configuration synced from [PreferencesService].
  ReminderScheduleConfig reminderSchedule = ReminderScheduleConfig.defaults;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidInit,
          iOS: darwinInit,
        ),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('[LamarLog NotificationInitError] $e');
    }
  }

  /// Checks whether OS notifications are currently enabled without prompting.
  Future<bool> areNotificationsEnabled() async {
    try {
      await init();
      if (!_initialized) return false;
      if (Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final enabled = await androidImpl?.areNotificationsEnabled();
        return enabled ?? false;
      }
      if (Platform.isIOS) {
        final iosImpl = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final perms = await iosImpl?.checkPermissions();
        return perms?.isEnabled ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('[LamarLog NotificationCheckError] $e');
      return false;
    }
  }

  /// Requests OS notification permission. Note that on Android 13+, once the
  /// user denies permission, Android suppresses subsequent system dialogs and
  /// returns `false` immediately — callers should then offer
  /// [openNotificationSettings].
  Future<bool> requestPermission() async {
    try {
      await init();
      if (!_initialized) return false;
      if (Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final alreadyEnabled = await androidImpl?.areNotificationsEnabled();
        if (alreadyEnabled == true) return true;
        final granted = await androidImpl?.requestNotificationsPermission();
        return granted ?? false;
      }
      if (Platform.isIOS) {
        final iosImpl = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('[LamarLog NotificationPermissionError] $e');
      return false;
    }
  }

  /// Opens the OS App Notification Settings screen directly so users can
  /// re-enable notifications after Android/iOS suppresses the runtime dialog.
  Future<bool> openNotificationSettings() async {
    try {
      if (Platform.isAndroid) {
        final opened = await _systemChannel
            .invokeMethod<bool>('openNotificationSettings');
        return opened ?? false;
      }
      if (Platform.isIOS) {
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          return launchUrl(uri);
        }
      }
      return false;
    } catch (e) {
      debugPrint('[LamarLog OpenNotifSettingsError] $e');
      return false;
    }
  }

  Future<ReminderScheduleResult> scheduleInterviewReminders({
    required String scheduleId,
    required String companyName,
    required String roundName,
    required DateTime scheduledAtUtc,
    ReminderScheduleConfig? config,
    bool skipPermissionPrompt = false,
  }) async {
    try {
      final activeConfig = (config ?? reminderSchedule).normalized();
      if (activeConfig.isEmpty) {
        return const ReminderScheduleResult(status: ReminderStatus.disabled);
      }

      final hasPermission = skipPermissionPrompt
          ? await areNotificationsEnabled()
          : await requestPermission();
      if (!hasPermission) {
        return const ReminderScheduleResult(
          status: ReminderStatus.permissionDenied,
        );
      }

      final nowUtc = DateTime.now().toUtc();
      final diff = scheduledAtUtc.difference(nowUtc);
      final pMin = activeConfig.primaryMinutes;
      final sMin = activeConfig.secondaryMinutes;

      final canPrimary = pMin != null && diff >= Duration(minutes: pMin);
      final canSecondary = sMin != null && diff >= Duration(minutes: sMin);

      if (!canPrimary && !canSecondary) {
        return ReminderScheduleResult(
          status: ReminderStatus.tooClose,
          minLeadMinutes: activeConfig.minActiveMinutes,
        );
      }

      final baseId = scheduleId.hashCode.abs() % 100000000;
      final idSecondary = baseId * 10 + 1;
      final idPrimary = baseId * 10 + 2;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'interview_reminders',
          'Interview Reminders',
          channelDescription:
              'Customizable reminders before scheduled interviews',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      int? scheduledPrimaryId;
      int? scheduledSecondaryId;
      final scheduledOffsets = <int>[];

      if (canPrimary) {
        final triggerTime = tz.TZDateTime.from(
          scheduledAtUtc.subtract(Duration(minutes: pMin)),
          tz.UTC,
        );
        await _plugin.zonedSchedule(
          id: idPrimary,
          title: _notificationTitle(pMin, companyName),
          body: roundName,
          scheduledDate: triggerTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        scheduledPrimaryId = idPrimary;
        scheduledOffsets.add(pMin);
      }

      if (canSecondary) {
        final triggerTime = tz.TZDateTime.from(
          scheduledAtUtc.subtract(Duration(minutes: sMin)),
          tz.UTC,
        );
        await _plugin.zonedSchedule(
          id: idSecondary,
          title: _notificationTitle(sMin, companyName),
          body: roundName,
          scheduledDate: triggerTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        scheduledSecondaryId = idSecondary;
        scheduledOffsets.add(sMin);
      }

      final expectedCount = activeConfig.activeOffsetsDesc.length;
      return ReminderScheduleResult(
        status: scheduledOffsets.length == expectedCount
            ? ReminderStatus.scheduledAll
            : ReminderStatus.scheduledPartial,
        notificationId24h: scheduledPrimaryId,
        notificationId1h: scheduledSecondaryId,
        scheduledOffsetsMinutes: scheduledOffsets,
      );
    } catch (e) {
      debugPrint('[LamarLog NotificationScheduleError] $e');
      return const ReminderScheduleResult(
        status: ReminderStatus.scheduleFailed,
      );
    }
  }

  /// Cancels existing alarms and reschedules all upcoming interviews using
  /// [config] (or current [reminderSchedule]). Returns number of updated rows.
  Future<int> rescheduleAllUpcoming(
    AppDatabase db, {
    ReminderScheduleConfig? config,
  }) async {
    final activeConfig = (config ?? reminderSchedule).normalized();
    final nowUtc = DateTime.now().toUtc();
    final all = await db.watchAllInterviewsWithApplications().first;
    final upcoming = all
        .where((e) => !e.schedule.scheduledAt.isBefore(nowUtc))
        .toList();

    int updated = 0;
    for (final entry in upcoming) {
      await cancelReminders(
        entry.schedule.notificationId24h,
        entry.schedule.notificationId1h,
      );

      if (activeConfig.isEmpty) {
        if (entry.schedule.notificationId24h != null ||
            entry.schedule.notificationId1h != null) {
          await db.updateInterviewReminderIds(
            id: entry.schedule.id,
            notificationId24h: null,
            notificationId1h: null,
          );
          updated++;
        }
        continue;
      }

      final res = await scheduleInterviewReminders(
        scheduleId: entry.schedule.id,
        companyName: entry.application.companyName,
        roundName: entry.schedule.roundName,
        scheduledAtUtc: entry.schedule.scheduledAt,
        config: activeConfig,
        skipPermissionPrompt: true,
      );
      await db.updateInterviewReminderIds(
        id: entry.schedule.id,
        notificationId24h: res.notificationId24h,
        notificationId1h: res.notificationId1h,
      );
      if (res.notificationId24h != null || res.notificationId1h != null) {
        updated++;
      }
    }
    return updated;
  }

  String _notificationTitle(int minutes, String companyName) {
    if (minutes == 1440) return 'Interview tomorrow: $companyName';
    final lead = ReminderScheduleConfig.formatDuration(minutes, isId: false);
    return 'Interview in $lead: $companyName';
  }

  Future<void> cancelReminders(int? id24h, int? id1h) async {
    try {
      await init();
      if (!_initialized) return;
      if (id24h != null) await _plugin.cancel(id: id24h);
      if (id1h != null) await _plugin.cancel(id: id1h);
    } catch (e) {
      debugPrint('[LamarLog NotificationCancelError] $e');
    }
  }
}
