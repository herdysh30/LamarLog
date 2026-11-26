import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

enum ReminderStatus {
  scheduledBoth,
  scheduledOneHourOnly,
  lessThanOneHour,
  permissionDenied,
  scheduleFailed,
}

class ReminderScheduleResult {
  const ReminderScheduleResult({
    required this.status,
    this.notificationId24h,
    this.notificationId1h,
  });

  final ReminderStatus status;
  final int? notificationId24h;
  final int? notificationId1h;
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const MethodChannel _systemChannel =
      MethodChannel('com.lamarlog.lamarlog/system');

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

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
    bool skipPermissionPrompt = false,
  }) async {
    try {
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

      if (diff < const Duration(hours: 1)) {
        return const ReminderScheduleResult(
          status: ReminderStatus.lessThanOneHour,
        );
      }

      final baseId = scheduleId.hashCode.abs() % 100000000;
      final id1h = baseId * 10 + 1;
      final id24h = baseId * 10 + 2;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'interview_reminders',
          'Interview Reminders',
          channelDescription:
              '24h and 1h reminders before scheduled interviews',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      final time1h = tz.TZDateTime.from(
        scheduledAtUtc.subtract(const Duration(hours: 1)),
        tz.UTC,
      );

      await _plugin.zonedSchedule(
        id: id1h,
        title: 'Interview in 1 hour: $companyName',
        body: roundName,
        scheduledDate: time1h,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      if (diff >= const Duration(hours: 24)) {
        final time24h = tz.TZDateTime.from(
          scheduledAtUtc.subtract(const Duration(hours: 24)),
          tz.UTC,
        );
        await _plugin.zonedSchedule(
          id: id24h,
          title: 'Interview tomorrow: $companyName',
          body: roundName,
          scheduledDate: time24h,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        return ReminderScheduleResult(
          status: ReminderStatus.scheduledBoth,
          notificationId24h: id24h,
          notificationId1h: id1h,
        );
      }

      return ReminderScheduleResult(
        status: ReminderStatus.scheduledOneHourOnly,
        notificationId1h: id1h,
      );
    } catch (e) {
      debugPrint('[LamarLog NotificationScheduleError] $e');
      return const ReminderScheduleResult(
        status: ReminderStatus.scheduleFailed,
      );
    }
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
