import '../../../core/database/app_database.dart';
import '../../../core/enums/application_enums.dart';

enum AnalyticsPeriod { allTime, days30, days90 }

class FunnelMetrics {
  const FunnelMetrics({
    required this.totalTracked,
    required this.totalApplied,
    required this.interviewCount,
    required this.offerCount,
    required this.interviewRate,
    required this.offerRate,
    required this.avgResponseDays,
    required this.appliedToScreenDays,
    required this.screenToInterviewDays,
    required this.interviewToOfferDays,
    required this.stageCounts,
  });

  final int totalTracked;
  final int totalApplied;
  final int interviewCount;
  final int offerCount;
  final double interviewRate;
  final double offerRate;
  final double? avgResponseDays;
  final double? appliedToScreenDays;
  final double? screenToInterviewDays;
  final double? interviewToOfferDays;
  final Map<String, int> stageCounts;
}

class AnalyticsCalculator {
  const AnalyticsCalculator._();

  static List<StatusTransition> filterByPeriod(
    List<StatusTransition> transitions,
    AnalyticsPeriod period, {
    DateTime? nowUtc,
  }) {
    if (period == AnalyticsPeriod.allTime) return transitions;
    final ref = (nowUtc ?? DateTime.now().toUtc()).toUtc();
    final cutoff = ref.subtract(
      Duration(days: period == AnalyticsPeriod.days30 ? 30 : 90),
    );
    return transitions
        .where((t) => !t.transitionedAt.toUtc().isBefore(cutoff))
        .toList();
  }

  /// Computes conversion funnel and stage velocity strictly from
  /// [StatusTransition] history rows (never from currentStatus alone).
  static FunnelMetrics computeMetrics(List<StatusTransition> transitions) {
    final byApp = <String, List<StatusTransition>>{};
    for (final t in transitions) {
      byApp.putIfAbsent(t.applicationId, () => []).add(t);
    }

    final stageCounts = <String, int>{
      for (final s in ApplicationStatus.values) s.name: 0,
    };

    final appliedAppIds = <String>{};
    final interviewAppIds = <String>{};
    final offerAppIds = <String>{};

    final responseDaysList = <double>[];
    final appliedToScreen = <double>[];
    final screenToInterview = <double>[];
    final interviewToOffer = <double>[];

    for (final entry in byApp.entries) {
      final appId = entry.key;
      final list = List<StatusTransition>.from(entry.value)
        ..sort((a, b) => a.transitionedAt.compareTo(b.transitionedAt));

      final statusesReached = list.map((e) => e.toStatus).toSet();
      for (final s in statusesReached) {
        stageCounts[s] = (stageCounts[s] ?? 0) + 1;
      }

      final everApplied =
          statusesReached.any((s) => s != ApplicationStatus.wishlist.name);
      if (everApplied) appliedAppIds.add(appId);

      if (statusesReached.any(
        (s) =>
            s == ApplicationStatus.interview.name ||
            s.contains('interview') ||
            s.contains('wawancara'),
      )) {
        interviewAppIds.add(appId);
      }
      if (statusesReached.any(
        (s) =>
            s == ApplicationStatus.offering.name ||
            s == ApplicationStatus.offerAccepted.name ||
            s.contains('offer') ||
            s.contains('tawaran'),
      )) {
        offerAppIds.add(appId);
      }

      DateTime? firstAt(String status) => list
          .where((t) => t.toStatus == status)
          .firstOrNull
          ?.transitionedAt;

      final tApplied = firstAt(ApplicationStatus.applied.name);
      final tScreen = firstAt(ApplicationStatus.screening.name);
      final tInterview = firstAt(ApplicationStatus.interview.name);
      final tOffer = firstAt(ApplicationStatus.offering.name);

      if (tApplied != null) {
        final firstResponse = list
            .where((t) =>
                t.transitionedAt.isAfter(tApplied) &&
                (t.toStatus == ApplicationStatus.screening.name ||
                    t.toStatus == ApplicationStatus.interview.name ||
                    t.toStatus == ApplicationStatus.offering.name ||
                    t.toStatus == ApplicationStatus.rejected.name))
            .firstOrNull;
        if (firstResponse != null) {
          responseDaysList.add(
            firstResponse.transitionedAt.difference(tApplied).inHours / 24.0,
          );
        }
      }
      if (tApplied != null && tScreen != null && tScreen.isAfter(tApplied)) {
        appliedToScreen.add(tScreen.difference(tApplied).inHours / 24.0);
      }
      if (tScreen != null &&
          tInterview != null &&
          tInterview.isAfter(tScreen)) {
        screenToInterview.add(tInterview.difference(tScreen).inHours / 24.0);
      }
      if (tInterview != null && tOffer != null && tOffer.isAfter(tInterview)) {
        interviewToOffer.add(tOffer.difference(tInterview).inHours / 24.0);
      }
    }

    double? avg(List<double> values) => values.isEmpty
        ? null
        : values.reduce((a, b) => a + b) / values.length;

    final totalApplied = appliedAppIds.length;
    return FunnelMetrics(
      totalTracked: byApp.length,
      totalApplied: totalApplied,
      interviewCount: interviewAppIds.length,
      offerCount: offerAppIds.length,
      interviewRate: totalApplied == 0
          ? 0.0
          : (interviewAppIds.length / totalApplied) * 100,
      offerRate:
          totalApplied == 0 ? 0.0 : (offerAppIds.length / totalApplied) * 100,
      avgResponseDays: avg(responseDaysList),
      appliedToScreenDays: avg(appliedToScreen),
      screenToInterviewDays: avg(screenToInterview),
      interviewToOfferDays: avg(interviewToOffer),
      stageCounts: stageCounts,
    );
  }
}
