import 'dart:convert';

/// User-customizable automatic reminder lead times (in minutes before interview).
///
/// ponytail: Capped at 2 active slots (`primaryMinutes` -> `notificationId24h`,
/// `secondaryMinutes` -> `notificationId1h`) to reuse the existing SQLite
/// columns without a Drift migration. Add a JSON/join table column only if
/// users need >2 simultaneous alarms per interview.
class ReminderScheduleConfig {
  const ReminderScheduleConfig({
    this.primaryMinutes = 1440,
    this.secondaryMinutes = 60,
  });

  static const int minMinutes = 5;
  static const int maxMinutes = 10080; // 7 days

  static const ReminderScheduleConfig defaults = ReminderScheduleConfig(
    primaryMinutes: 1440,
    secondaryMinutes: 60,
  );

  static const List<int> presetMinutes = [
    15,
    30,
    60,
    120,
    180,
    360,
    720,
    1440,
    2880,
    4320,
    10080,
  ];

  /// Earlier reminder offset in minutes, or `null` when disabled.
  final int? primaryMinutes;

  /// Closer reminder offset in minutes, or `null` when disabled.
  final int? secondaryMinutes;

  bool get isEmpty => primaryMinutes == null && secondaryMinutes == null;

  bool get isDefault => primaryMinutes == 1440 && secondaryMinutes == 60;

  /// Active offsets sorted descending (earliest reminder first).
  List<int> get activeOffsetsDesc {
    final norm = normalized();
    return [
      if (norm.primaryMinutes != null) norm.primaryMinutes!,
      if (norm.secondaryMinutes != null) norm.secondaryMinutes!,
    ];
  }

  /// Shortest enabled reminder offset, used to check whether an upcoming
  /// interview still has enough lead time for at least one alarm.
  int? get minActiveMinutes {
    final offsets = activeOffsetsDesc;
    return offsets.isEmpty ? null : offsets.last;
  }

  /// Returns `true` when [scheduledAtUtc] is far enough in the future to
  /// schedule at least one configured reminder.
  bool isEligibleForReminder(DateTime scheduledAtUtc, DateTime nowUtc) {
    final minMin = minActiveMinutes;
    if (minMin == null) return false;
    return scheduledAtUtc.difference(nowUtc) >= Duration(minutes: minMin);
  }

  /// Clamps offsets to `[minMinutes, maxMinutes]`, deduplicates equal values,
  /// and orders descending (`primaryMinutes >= secondaryMinutes`).
  ReminderScheduleConfig normalized() {
    int? clampOpt(int? v) => v?.clamp(minMinutes, maxMinutes);

    final a = clampOpt(primaryMinutes);
    final b = clampOpt(secondaryMinutes);

    if (a == null && b == null) {
      return const ReminderScheduleConfig(
        primaryMinutes: null,
        secondaryMinutes: null,
      );
    }
    if (a == null) {
      return ReminderScheduleConfig(primaryMinutes: b, secondaryMinutes: null);
    }
    if (b == null || a == b) {
      return ReminderScheduleConfig(primaryMinutes: a, secondaryMinutes: null);
    }
    return a > b
        ? ReminderScheduleConfig(primaryMinutes: a, secondaryMinutes: b)
        : ReminderScheduleConfig(primaryMinutes: b, secondaryMinutes: a);
  }

  ReminderScheduleConfig copyWith({
    int? primaryMinutes,
    bool clearPrimary = false,
    int? secondaryMinutes,
    bool clearSecondary = false,
  }) {
    return ReminderScheduleConfig(
      primaryMinutes:
          clearPrimary ? null : (primaryMinutes ?? this.primaryMinutes),
      secondaryMinutes:
          clearSecondary ? null : (secondaryMinutes ?? this.secondaryMinutes),
    );
  }

  String formatSummary({required bool isId, bool short = false}) {
    final offsets = activeOffsetsDesc;
    if (offsets.isEmpty) return isId ? 'Nonaktif' : 'Off';
    return offsets
        .map((m) => formatDuration(m, isId: isId, short: short))
        .join(' & ');
  }

  static String formatDuration(
    int minutes, {
    required bool isId,
    bool short = false,
  }) {
    if (minutes == 1440) {
      if (short) return isId ? '24 jam' : '24h';
      return isId ? '24 jam' : '24 hours';
    }
    if (minutes >= 1440 && minutes % 1440 == 0) {
      final days = minutes ~/ 1440;
      if (short) return isId ? '$days hr' : '${days}d';
      return isId ? '$days hari' : '$days ${days == 1 ? 'day' : 'days'}';
    }
    if (minutes >= 60 && minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      if (short) return isId ? '$hours jam' : '${hours}h';
      return isId ? '$hours jam' : '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    if (minutes > 60) {
      final hours = minutes ~/ 60;
      final rem = minutes % 60;
      if (short) return isId ? '${hours}j ${rem}m' : '${hours}h ${rem}m';
      return isId ? '$hours jam $rem menit' : '${hours}h ${rem}m';
    }
    if (short) return isId ? '$minutes mnt' : '${minutes}m';
    return isId
        ? '$minutes menit'
        : '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
  }

  String encode() => jsonEncode({
        'primaryMinutes': primaryMinutes,
        'secondaryMinutes': secondaryMinutes,
      });

  static ReminderScheduleConfig decode(String? raw) {
    if (raw == null || raw.isEmpty) return defaults;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final p = (map['primaryMinutes'] as num?)?.toInt();
      final s = (map['secondaryMinutes'] as num?)?.toInt();
      return ReminderScheduleConfig(
        primaryMinutes: p,
        secondaryMinutes: s,
      ).normalized();
    } catch (_) {
      return defaults;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderScheduleConfig &&
          other.primaryMinutes == primaryMinutes &&
          other.secondaryMinutes == secondaryMinutes;

  @override
  int get hashCode => Object.hash(primaryMinutes, secondaryMinutes);
}
