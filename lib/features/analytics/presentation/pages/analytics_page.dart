import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../applications/presentation/bloc/applications_bloc.dart';
import '../../domain/analytics_calculator.dart';
import '../widgets/analytics_cards.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  AnalyticsPeriod _period = AnalyticsPeriod.allTime;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    return Scaffold(
      appBar: ApplyFlowAppBar(subtitle: s.navAnalytics),
      body: StreamBuilder<List<StatusTransition>>(
        stream: db.watchAllTransitions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorStateCard(
              title: s.dbLoadErrorTitle,
              detail: snapshot.error.toString(),
              retryLabel: s.retry,
              onRetry: () => setState(() {}),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTransitions = snapshot.data ?? const <StatusTransition>[];
          final filtered =
              AnalyticsCalculator.filterByPeriod(allTransitions, _period);
          final metrics = AnalyticsCalculator.computeMetrics(filtered);
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
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AnalyticsPeriod.values.map((p) {
                      final selected = _period == p;
                      final label = switch (p) {
                        AnalyticsPeriod.allTime => s.allTime,
                        AnalyticsPeriod.days30 => s.past30Days,
                        AnalyticsPeriod.days90 => s.past90Days,
                      };
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: selected
                              ? cs.primaryContainer
                              : cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            onTap: () {
                              if (_period != p) {
                                AppMotion.selectionHaptic();
                                setState(() => _period = p);
                              }
                            },
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
                AnalyticsKpiGrid(metrics: metrics),
                const SizedBox(height: 16),
                AnalyticsFunnelCard(metrics: metrics),
                const SizedBox(height: 14),
                AnalyticsVelocityCard(metrics: metrics, insight: insight),
              ],
            ),
          );
        },
      ),
    );
  }

  String _buildInsight(
    List<JobApplication> apps,
    FunnelMetrics metrics,
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
