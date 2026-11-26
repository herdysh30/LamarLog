import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../domain/analytics_calculator.dart';

class AnalyticsKpiGrid extends StatelessWidget {
  const AnalyticsKpiGrid({
    super.key,
    required this.metrics,
  });

  final FunnelMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = AppLocaleScope.of(context);

    return LayoutBuilder(
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
    );
  }
}

class AnalyticsFunnelCard extends StatelessWidget {
  const AnalyticsFunnelCard({
    super.key,
    required this.metrics,
  });

  final FunnelMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final s = AppLocaleScope.of(context);

    return SurfaceCard(
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
                    Text(s.funnelSubtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  s.leadsCount(metrics.totalTracked),
                  style:
                      theme.textTheme.labelSmall?.copyWith(color: cs.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...s.pipelineStages.map((stage) {
            final count = metrics.stageCounts[stage.id] ?? 0;
            final ratio = metrics.totalTracked == 0
                ? 0.0
                : (count / metrics.totalTracked).clamp(0.0, 1.0);
            final pct = (ratio * 100).toStringAsFixed(0);
            final barColor = stage.colorKey.dotColor(brightness);

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
                                stage.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
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
                            style: theme.textTheme.labelSmall?.copyWith(
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
                              style: theme.textTheme.titleSmall?.copyWith(
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
                      duration: AppMotion.duration(
                        context,
                        const Duration(milliseconds: 380),
                      ),
                      curve: AppMotion.enterCurve,
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
    );
  }
}

class AnalyticsVelocityCard extends StatelessWidget {
  const AnalyticsVelocityCard({
    super.key,
    required this.metrics,
    required this.insight,
  });

  final FunnelMetrics metrics;
  final String insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    return SurfaceCard(
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
                  Text(s.stageVelocity, style: theme.textTheme.titleMedium),
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
                  label: s.isId ? 'Dilamar → Screen' : 'Applied → Screen',
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
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
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
  }
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
          AnimatedSwitcher(
            duration: AppMotion.duration(context, AppMotion.medium),
            switchInCurve: AppMotion.enterCurve,
            switchOutCurve: AppMotion.exitCurve,
            child: Text(
              value,
              key: ValueKey(value),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
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
