import 'package:lamarlog/core/database/app_database.dart';
import 'package:lamarlog/core/enums/application_enums.dart';
import 'package:lamarlog/features/analytics/domain/analytics_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

StatusTransition _tx({
  required String id,
  required String appId,
  String? from,
  required ApplicationStatus to,
  required DateTime at,
}) {
  return StatusTransition(
    id: id,
    applicationId: appId,
    fromStatus: from,
    toStatus: to.name,
    transitionedAt: at.toUtc(),
  );
}

void main() {
  group('AnalyticsCalculator', () {
    test('returns zeroes when there are no transitions', () {
      final metrics = AnalyticsCalculator.computeMetrics(const []);

      expect(metrics.totalTracked, 0);
      expect(metrics.totalApplied, 0);
      expect(metrics.interviewCount, 0);
      expect(metrics.offerCount, 0);
      expect(metrics.interviewRate, 0.0);
      expect(metrics.offerRate, 0.0);
      expect(metrics.avgResponseDays, isNull);
      expect(metrics.appliedToScreenDays, isNull);
      expect(metrics.screenToInterviewDays, isNull);
      expect(metrics.interviewToOfferDays, isNull);
    });

    test('computes funnel conversion and stage velocity from history rows', () {
      final day0 = DateTime.utc(2026, 1, 1);

      final transitions = <StatusTransition>[
        // App 1: Wishlist only (should be tracked, not counted as applied)
        _tx(id: '1', appId: 'app-1', to: ApplicationStatus.wishlist, at: day0),

        // App 2: Applied -> Screening (+2d) -> Interview (+5d) -> Offering (+9d)
        _tx(id: '2', appId: 'app-2', to: ApplicationStatus.applied, at: day0),
        _tx(
          id: '3',
          appId: 'app-2',
          from: 'applied',
          to: ApplicationStatus.screening,
          at: day0.add(const Duration(days: 2)),
        ),
        _tx(
          id: '4',
          appId: 'app-2',
          from: 'screening',
          to: ApplicationStatus.interview,
          at: day0.add(const Duration(days: 5)),
        ),
        _tx(
          id: '5',
          appId: 'app-2',
          from: 'interview',
          to: ApplicationStatus.offering,
          at: day0.add(const Duration(days: 9)),
        ),

        // App 3: Applied -> Rejected (+4d)
        _tx(id: '6', appId: 'app-3', to: ApplicationStatus.applied, at: day0),
        _tx(
          id: '7',
          appId: 'app-3',
          from: 'applied',
          to: ApplicationStatus.rejected,
          at: day0.add(const Duration(days: 4)),
        ),
      ];

      final metrics = AnalyticsCalculator.computeMetrics(transitions);

      expect(metrics.totalTracked, 3);
      expect(metrics.totalApplied, 2);
      expect(metrics.interviewCount, 1);
      expect(metrics.offerCount, 1);
      expect(metrics.interviewRate, closeTo(50.0, 0.01));
      expect(metrics.offerRate, closeTo(50.0, 0.01));

      // Average response days: (2d for app-2 + 4d for app-3) / 2 = 3.0d
      expect(metrics.avgResponseDays, closeTo(3.0, 0.01));
      expect(metrics.appliedToScreenDays, closeTo(2.0, 0.01));
      expect(metrics.screenToInterviewDays, closeTo(3.0, 0.01));
      expect(metrics.interviewToOfferDays, closeTo(4.0, 0.01));

      expect(metrics.stageCounts[ApplicationStatus.wishlist.name], 1);
      expect(metrics.stageCounts[ApplicationStatus.applied.name], 2);
      expect(metrics.stageCounts[ApplicationStatus.screening.name], 1);
      expect(metrics.stageCounts[ApplicationStatus.interview.name], 1);
      expect(metrics.stageCounts[ApplicationStatus.offering.name], 1);
    });

    test('filters transitions accurately by 30-day and 90-day periods', () {
      final now = DateTime.utc(2026, 6, 1);
      final transitions = [
        _tx(
          id: 'recent',
          appId: 'a1',
          to: ApplicationStatus.applied,
          at: now.subtract(const Duration(days: 10)),
        ),
        _tx(
          id: 'mid',
          appId: 'a2',
          to: ApplicationStatus.applied,
          at: now.subtract(const Duration(days: 60)),
        ),
        _tx(
          id: 'old',
          appId: 'a3',
          to: ApplicationStatus.applied,
          at: now.subtract(const Duration(days: 120)),
        ),
      ];

      expect(
        AnalyticsCalculator.filterByPeriod(
          transitions,
          AnalyticsPeriod.allTime,
          nowUtc: now,
        ).length,
        3,
      );
      expect(
        AnalyticsCalculator.filterByPeriod(
          transitions,
          AnalyticsPeriod.days90,
          nowUtc: now,
        ).length,
        2,
      );
      expect(
        AnalyticsCalculator.filterByPeriod(
          transitions,
          AnalyticsPeriod.days30,
          nowUtc: now,
        ).length,
        1,
      );
    });

    test('reverts applied count when app moves wishlist -> applied -> wishlist',
        () {
      final t0 = DateTime.utc(2026, 2, 1, 9, 0);
      final transitions = <StatusTransition>[
        _tx(id: '1', appId: 'a1', to: ApplicationStatus.wishlist, at: t0),
        _tx(
          id: '2',
          appId: 'a1',
          from: 'wishlist',
          to: ApplicationStatus.applied,
          at: t0.add(const Duration(minutes: 5)),
        ),
        _tx(
          id: '3',
          appId: 'a1',
          from: 'applied',
          to: ApplicationStatus.wishlist,
          at: t0.add(const Duration(minutes: 6)),
        ),
      ];

      final metrics = AnalyticsCalculator.computeMetrics(transitions);
      expect(metrics.totalTracked, 1);
      expect(metrics.totalApplied, 0);
      expect(metrics.stageCounts[ApplicationStatus.wishlist.name], 1);
      expect(metrics.stageCounts[ApplicationStatus.applied.name], 0);
    });

    test(
        'counts applied again after wishlist -> applied -> wishlist -> applied',
        () {
      final t0 = DateTime.utc(2026, 2, 1, 9, 0);
      final transitions = <StatusTransition>[
        _tx(id: '1', appId: 'a1', to: ApplicationStatus.wishlist, at: t0),
        _tx(
          id: '2',
          appId: 'a1',
          from: 'wishlist',
          to: ApplicationStatus.applied,
          at: t0.add(const Duration(hours: 1)),
        ),
        _tx(
          id: '3',
          appId: 'a1',
          from: 'applied',
          to: ApplicationStatus.wishlist,
          at: t0.add(const Duration(hours: 2)),
        ),
        _tx(
          id: '4',
          appId: 'a1',
          from: 'wishlist',
          to: ApplicationStatus.applied,
          at: t0.add(const Duration(days: 5)),
        ),
        _tx(
          id: '5',
          appId: 'a1',
          from: 'applied',
          to: ApplicationStatus.screening,
          at: t0.add(const Duration(days: 7)),
        ),
      ];

      final metrics = AnalyticsCalculator.computeMetrics(transitions);
      expect(metrics.totalTracked, 1);
      expect(metrics.totalApplied, 1);
      expect(metrics.stageCounts[ApplicationStatus.applied.name], 1);
      expect(metrics.stageCounts[ApplicationStatus.screening.name], 1);
      // Velocity uses the second (effective) applied timestamp: 7d - 5d = 2.0d
      expect(metrics.appliedToScreenDays, closeTo(2.0, 0.01));
    });
  });
}
