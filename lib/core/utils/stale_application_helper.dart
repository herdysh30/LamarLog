import '../database/app_database.dart';
import '../enums/application_enums.dart';

/// Default threshold in days before an Applied/Screening application is
/// flagged as needing a follow-up.
const int kStaleThresholdDays = 14;

class StaleApplicationHelper {
  const StaleApplicationHelper._();

  static final Set<String> _staleEligibleStages = {
    ApplicationStatus.applied.name,
    ApplicationStatus.screening.name,
  };

  /// Whole days elapsed since [application.updatedAt] in UTC.
  static int daysSinceUpdate(
    JobApplication application, {
    DateTime? nowUtc,
  }) {
    final reference = (nowUtc ?? DateTime.now().toUtc()).toUtc();
    final diff = reference.difference(application.updatedAt.toUtc()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Returns true when the application is sitting in Applied or Screening
  /// for at least [thresholdDays] days without an update.
  static bool isStale(
    JobApplication application, {
    DateTime? nowUtc,
    int thresholdDays = kStaleThresholdDays,
  }) {
    if (!_staleEligibleStages.contains(application.currentStatus)) {
      return false;
    }
    return daysSinceUpdate(application, nowUtc: nowUtc) >= thresholdDays;
  }

  /// Returns all stale applications sorted by oldest update first.
  static List<JobApplication> findStale(
    Iterable<JobApplication> applications, {
    DateTime? nowUtc,
    int thresholdDays = kStaleThresholdDays,
  }) {
    final stale = applications
        .where((a) =>
            isStale(a, nowUtc: nowUtc, thresholdDays: thresholdDays))
        .toList();
    stale.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return stale;
  }
}
