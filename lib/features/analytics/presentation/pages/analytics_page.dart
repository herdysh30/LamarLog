import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';

enum _AnalyticsPeriod { allTime, days30, days90 }

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  _AnalyticsPeriod _period = _AnalyticsPeriod.allTime;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final s = AppLocaleScope.of(context);

    return Scaffold(
      appBar: ApplyFlowAppBar(subtitle: s.navAnalytics),
      body: StreamBuilder<List<StatusTransition>>(
        stream: db.watchAllTransitions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTransitions = snapshot.data ?? const <StatusTransition>[];
          final filtered = _filterByPeriod(allTransitions, _period);
          final metrics = _computeMetrics(filtered);
          final apps = context.watch<ApplicationsBloc>().state.applications;
          final insight = _buildInsight(apps, metrics, s);

          return ResponsiveCenter(
            maxWidth: 840,
            child: ListView(
              padding: Responsive.pagePadding(context, bottom: 28),
            children: [
              Text(
                s.analyticsInsights,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                s.analyticsSubtitle,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 14),

              // Period Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _AnalyticsPeriod.values.map((p) {
                    final selected = _period == p;
                    final label = switch (p) {
                      _AnalyticsPeriod.allTime => s.allTime,
                      _AnalyticsPeriod.days30 => s.past30Days,
                      _AnalyticsPeriod.days90 => s.past90Days,
                    };
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: selected
                            ? cs.primaryContainer
                            : cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                        child: InkWell(
                          onTap: () => setState(() => _period = p),
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            child: Text(
                              label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: selected ? Colors.white : cs.secondary,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Responsive KPI Summary Grid (2 cols on phone, 4 cols on tablet)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = Responsive.kpiColumns(constraints.maxWidth);
                  final scale = MediaQuery.textScalerOf(context).scale(1.0);
                  final tileHeight = (114.0 * scale).clamp(114.0, 164.0);

                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: tileHeight,
                    ),
                    children: [
                      _KpiCard(
                        label: s.totalApplied,
                        value: '${metrics.totalApplied}',
                        subtitle: s.totalTrackedSub(metrics.totalTracked),
                        icon: Icons.send_rounded,
                        color: cs.primary,
                      ),
                      _KpiCard(
                        label: s.interviewRate,
                        value: '${metrics.interviewRate.toStringAsFixed(1)}%',
                        subtitle: s.appliedRatioSub(
                            metrics.interviewCount, metrics.totalApplied),
                        icon: Icons.forum_outlined,
                        color: cs.tertiary,
                      ),
                      _KpiCard(
                        label: s.offerRate,
                        value: '${metrics.offerRate.toStringAsFixed(1)}%',
                        subtitle: s.offersReachedSub(metrics.offerCount),
                        icon: Icons.verified_outlined,
                        color: cs.primaryContainer,
                      ),
                      _KpiCard(
                        label: s.respVelocity,
                        value: metrics.avgResponseDays == null
                            ? '—'
                            : '${metrics.avgResponseDays!.toStringAsFixed(1)}${s.isId ? 'h' : 'd'}',
                        subtitle: metrics.avgResponseDays == null
                            ? s.needResponses
                            : s.appliedToResponse,
                        icon: Icons.bolt_rounded,
                        color: cs.secondary,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Application Funnel Breakdown Card
              SurfaceCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.applicationFunnel,
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 2),
                              Text(s.funnelSubtitle,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            s.leadsCount(metrics.totalTracked),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: cs.secondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...ApplicationStatus.activeStages.map((stage) {
                      final count = metrics.stageCounts[stage.name] ?? 0;
                      final ratio = metrics.totalTracked == 0
                          ? 0.0
                          : (count / metrics.totalTracked).clamp(0.0, 1.0);
                      final pct = (ratio * 100).toStringAsFixed(0);
                      final barColor =
                          AppColors.stageDotColor(stage, brightness);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          s.statusLabel(stage),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      s.reachedCount(count),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      child: Text(
                                        '$pct%',
                                        textAlign: TextAlign.end,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontFeatures: const [
                                            FontFeature.tabularFigures()
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: ratio),
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeOutCubic,
                                builder: (_, val, _) => LinearProgressIndicator(
                                  value: val,
                                  minHeight: 8,
                                  backgroundColor: cs.surfaceContainer,
                                  valueColor: AlwaysStoppedAnimation(barColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Stage Velocity & Strategic Insight Card
              SurfaceCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timelapse_rounded,
                                size: 20, color: cs.primaryContainer),
                            const SizedBox(width: 8),
                            Text(s.stageVelocity,
                                style: theme.textTheme.titleMedium),
                          ],
                        ),
                        Text(s.pacingAvg, style: theme.textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _VelocityTile(
                            label: s.isId
                                ? 'Dilamar → Screen'
                                : 'Applied → Screen',
                            days: metrics.appliedToScreenDays,
                            unit: s.isId ? 'h' : 'd',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _VelocityTile(
                            label: 'Screen → Interview',
                            days: metrics.screenToInterviewDays,
                            unit: s.isId ? 'h' : 'd',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _VelocityTile(
                            label: 'Interview → Offer',
                            days: metrics.interviewToOfferDays,
                            unit: s.isId ? 'h' : 'd',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: cs.primaryFixed,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.lightbulb_outline_rounded,
                                size: 17, color: cs.onPrimaryFixed),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.keyFunnelInsight,
                                    style: theme.textTheme.titleSmall),
                                const SizedBox(height: 2),
                                Text(
                                  insight,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          );
        },
      ),
    );
  }

  List<StatusTransition> _filterByPeriod(
    List<StatusTransition> transitions,
    _AnalyticsPeriod period,
  ) {
    if (period == _AnalyticsPeriod.allTime) return transitions;
    final days = period == _AnalyticsPeriod.days30 ? 30 : 90;
    final cutoff = DateTime.now().toUtc().subtract(Duration(days: days));
    return transitions.where((t) => t.transitionedAt.isAfter(cutoff)).toList();
  }

  _FunnelMetrics _computeMetrics(List<StatusTransition> transitions) {
    final byApp = <String, List<StatusTransition>>{};
    for (final t in transitions) {
      byApp.putIfAbsent(t.applicationId, () => []).add(t);
    }

    final appliedAppIds = <String>{};
    final interviewAppIds = <String>{};
    final offerAppIds = <String>{};
    final stageCounts = <String, int>{};
    final responseDaysList = <double>[];
    final appliedToScreen = <double>[];
    final screenToInterview = <double>[];
    final interviewToOffer = <double>[];

    for (final entry in byApp.entries) {
      final appId = entry.key;
      final list = entry.value
        ..sort((a, b) => a.transitionedAt.compareTo(b.transitionedAt));

      final statusesReached = list.map((e) => e.toStatus).toSet();
      for (final s in statusesReached) {
        stageCounts[s] = (stageCounts[s] ?? 0) + 1;
      }

      final everApplied =
          statusesReached.any((s) => s != ApplicationStatus.wishlist.name);
      if (everApplied) appliedAppIds.add(appId);

      if (statusesReached.contains(ApplicationStatus.interview.name)) {
        interviewAppIds.add(appId);
      }
      if (statusesReached.contains(ApplicationStatus.offering.name) ||
          statusesReached.contains(ApplicationStatus.offerAccepted.name)) {
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
              firstResponse.transitionedAt.difference(tApplied).inHours / 24.0);
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
    return _FunnelMetrics(
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

  String _buildInsight(
    List<JobApplication> apps,
    _FunnelMetrics metrics,
    AppStrings s,
  ) {
    if (metrics.totalTracked == 0) {
      return s.isId
          ? 'Mulai catat lamaran di papan Pipeline untuk melihat funnel konversi dan kecepatan respon perusahaan.'
          : 'Start tracking applications on your Pipeline board to unlock conversion funnel and response pacing insights.';
    }
    if (metrics.totalApplied == 0) {
      return s.isId
          ? 'Kamu memiliki ${metrics.totalTracked} lowongan di Wishlist. Pindahkan ke Dilamar setelah mengirim lamaran.'
          : 'You have ${metrics.totalTracked} saved wishlist leads. Move them to Applied once submitted to track response speed.';
    }
    final remoteCount =
        apps.where((a) => a.workplaceType == WorkplaceType.remote.name).length;
    final pctRemote =
        apps.isEmpty ? 0 : ((remoteCount / apps.length) * 100).round();
    if (metrics.interviewRate >= 30) {
      return s.isId
          ? 'Konversi interview kuat (${metrics.interviewRate.toStringAsFixed(1)}%). $pctRemote% lamaranmu adalah Remote—pertahankan penyesuaian CV per posisi.'
          : 'Strong interview conversion (${metrics.interviewRate.toStringAsFixed(1)}%). $pctRemote% of your tracked roles are Remote—keep tailoring resumes per role.';
    }
    return s.isId
        ? 'Kamu telah melamar ${metrics.totalApplied} posisi dengan rasio interview ${metrics.interviewRate.toStringAsFixed(1)}%. Menyesuaikan CV per lowongan dapat meningkatkan lolos screening.'
        : 'You have applied to ${metrics.totalApplied} roles with a ${metrics.interviewRate.toStringAsFixed(1)}% interview rate. Attaching role-specific CVs can help lift screening conversion.';
  }
}

class _FunnelMetrics {
  const _FunnelMetrics({
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.secondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VelocityTile extends StatelessWidget {
  const _VelocityTile({
    required this.label,
    required this.days,
    required this.unit,
  });

  final String label;
  final double? days;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            days == null ? '—' : '${days!.toStringAsFixed(1)}$unit',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
