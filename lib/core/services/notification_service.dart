import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum ReminderStatus {
  scheduledBoth,
  scheduledOneHourOnly,
  lessThanOneHour,
  permissionDenied,
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

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
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
  }

  Future<bool> requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
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
  }

  Future<ReminderScheduleResult> scheduleInterviewReminders({
    required String scheduleId,
    required String companyName,
    required String roundName,
    required DateTime scheduledAtUtc,
  }) async {
    final hasPermission = await requestPermission();
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
        channelDescription: '24h and 1h reminders before scheduled interviews',
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
  }

  Future<void> cancelReminders(int? id24h, int? id1h) async {
    await init();
    if (id24h != null) await _plugin.cancel(id: id24h);
    if (id1h != null) await _plugin.cancel(id: id1h);
  }
}
