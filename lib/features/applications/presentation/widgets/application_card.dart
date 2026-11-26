import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/stale_application_helper.dart';
import '../../../../core/widgets/applyflow_widgets.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.application,
    this.upcomingInterview,
    this.showStatusChip = false,
    this.onTap,
  });

  final JobApplication application;
  final InterviewSchedule? upcomingInterview;
  final bool showStatusChip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final s = AppLocaleScope.of(context);

    final priority = PriorityLevel.values.firstWhere(
      (p) => p.name == application.priority,
      orElse: () => PriorityLevel.medium,
    );
    final workplace = WorkplaceType.values.firstWhere(
      (w) => w.name == application.workplaceType,
      orElse: () => WorkplaceType.remote,
    );
    final jobType = JobType.values.firstWhere(
      (j) => j.name == application.jobType,
      orElse: () => JobType.fullTime,
    );
    final statusLabel = s.statusLabelById(application.currentStatus);
    final statusDotColor =
        s.stageDotColorById(application.currentStatus, brightness);

    final daysInStage =
        StaleApplicationHelper.daysSinceUpdate(application).clamp(0, 999);
    final isStale = StaleApplicationHelper.isStale(application);
    final platform = application.sourcePlatform?.trim();
    final hasPlatform = platform != null && platform.isNotEmpty;

    final hasSalary =
        application.expectedSalary != null && application.expectedSalary! > 0;
    final salaryStr =
        formatSalaryAmount(application, fallback: s.salaryUnlisted);
    final periodStr = salaryPeriodSuffix(application, isId: s.isId);

    final locationDisplay = application.location.trim().isEmpty
        ? s.workplaceLabel(workplace)
        : '${s.workplaceLabel(workplace)} • ${application.location.trim()}';

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Monogram + Company & Role + Priority Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyMonogram(
                companyName: application.companyName,
                size: 42,
                radius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.companyName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      application.roleTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PriorityPill(
                priority: priority,
                brightness: brightness,
                label: s.priorityLabel(priority, compact: true),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Compensation + Workplace / Location Strip (auto-wraps cleanly on tight widths)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    children: [
                      TextSpan(
                        text: salaryStr,
                        style: hasSalary
                            ? null
                            : TextStyle(
                                color: cs.outline,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.5,
                              ),
                      ),
                      if (hasSalary)
                        TextSpan(
                          text: periodStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _workplaceIcon(workplace),
                      size: 13.5,
                      color: cs.secondary,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        locationDisplay,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Upcoming Interview Micro-Banner (only when scheduled)
          if (upcomingInterview != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primaryFixed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    size: 15,
                    color: cs.onPrimaryFixed,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${upcomingInterview!.roundName} • ${DateFormat('EEE, HH:mm').format(upcomingInterview!.scheduledAt.toLocal())}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onPrimaryFixed,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Clean Footer: Job Type or Status Chip + Platform + Dwell Time / Stale Badge
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (showStatusChip)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: statusDotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              statusLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_outline_rounded,
                            size: 13.5,
                            color: cs.outline,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            s.jobTypeLabel(jobType),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    if (hasPlatform)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          platform,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10.5,
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isStale)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: brightness == Brightness.dark
                        ? const Color(0xFF3E2C0A)
                        : const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 12,
                        color: brightness == Brightness.dark
                            ? const Color(0xFFFCD34D)
                            : const Color(0xFF92400E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.needsFollowUpBadge(daysInStage),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          color: brightness == Brightness.dark
                              ? const Color(0xFFFCD34D)
                              : const Color(0xFF92400E),
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: cs.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.daysInStage(daysInStage),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.outline,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _workplaceIcon(WorkplaceType type) {
    return switch (type) {
      WorkplaceType.remote => Icons.home_work_outlined,
      WorkplaceType.hybrid => Icons.location_city_outlined,
      WorkplaceType.onsite => Icons.apartment_outlined,
    };
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({
    required this.priority,
    required this.brightness,
    required this.label,
  });

  final PriorityLevel priority;
  final Brightness brightness;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, dot) = AppColors.priorityColors(priority, brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
