import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/models/pipeline_stage_config.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/utils/stale_application_helper.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../bloc/applications_bloc.dart';
import 'application_form_page.dart';
import 'pdf_preview_page.dart';

class ApplicationDetailPage extends StatefulWidget {
  const ApplicationDetailPage({
    super.key,
    required this.application,
  });

  final JobApplication application;

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  static const int _maxPdfBytes = 10 * 1024 * 1024; // 10 MB
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final s = AppLocaleScope.of(context);

    return BlocBuilder<ApplicationsBloc, ApplicationsState>(
      builder: (context, state) {
        final app = state.applications
                .where((a) => a.id == widget.application.id)
                .firstOrNull ??
            widget.application;

        final priority = PriorityLevel.values.firstWhere(
          (p) => p.name == app.priority,
          orElse: () => PriorityLevel.medium,
        );
        final workplace = WorkplaceType.values.firstWhere(
          (w) => w.name == app.workplaceType,
          orElse: () => WorkplaceType.remote,
        );
        final jobType = JobType.values.firstWhere(
          (j) => j.name == app.jobType,
          orElse: () => JobType.fullTime,
        );

        final (prioBg, prioFg, prioDot) =
            AppColors.priorityColors(priority, brightness);
        final (statusBg, statusFg, statusDot) =
            s.stageColorsById(app.currentStatus, brightness, cs);
        final currentStatusLabel = s.statusLabelById(app.currentStatus);

        final hasSalary =
            app.expectedSalary != null && app.expectedSalary! > 0;
        final salaryAmount =
            formatSalaryAmount(app, fallback: s.salaryUnlisted);
        final periodSuffix = salaryPeriodSuffix(app, isId: s.isId);

        return Scaffold(
          appBar: AppBar(
            title:
                Text(s.applicationDetails, style: theme.textTheme.titleMedium),
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                tooltip: s.editJobDetails,
                icon: const Icon(Icons.edit_outlined, size: 21),
                onPressed: () => _openEditForm(context, app),
              ),
              IconButton(
                tooltip: s.delete,
                icon: Icon(Icons.delete_outline_rounded,
                    size: 21, color: cs.error),
                onPressed: () => _confirmDelete(context, app),
              ),
            ],
          ),
          body: ResponsiveCenter(
            maxWidth: 740,
            child: ListView(
              padding: Responsive.pagePadding(context, bottom: 32),
            children: [
              // HERO HEADER CARD
              SurfaceCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CompanyMonogram(
                          companyName: app.companyName,
                          size: 48,
                          radius: 12,
                          filled: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.companyName,
                                style: theme.textTheme.labelMedium
                                    ?.copyWith(color: cs.secondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                app.roleTitle,
                                style: theme.textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: prioBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: prioDot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                s.priorityLabel(priority),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: prioFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quick Metrics 2-col Grid
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.compensation,
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(color: cs.secondary),
                                ),
                                const SizedBox(height: 3),
                                RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                    children: [
                                      TextSpan(text: salaryAmount),
                                      if (hasSalary)
                                        TextSpan(
                                          text: periodSuffix,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: cs.secondary,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Material(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: app.location.trim().isEmpty
                                  ? null
                                  : () => _launchUriWithFeedback(
                                        context,
                                        ContactLauncher.googleMapsUri(
                                            app.location),
                                        s,
                                      ),
                              child: Padding(
                                padding: const EdgeInsets.all(11),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          s.location,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(color: cs.secondary),
                                        ),
                                        if (app.location.trim().isNotEmpty)
                                          Icon(
                                            Icons.map_outlined,
                                            size: 14,
                                            color: cs.primary,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      app.location.isEmpty
                                          ? s.workplaceLabel(workplace)
                                          : '${app.location} (${s.workplaceLabel(workplace)})',
                                      style: theme.textTheme.titleSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (app.offeredSalary != null && app.offeredSalary! > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium_outlined,
                                    size: 16, color: cs.tertiary),
                                const SizedBox(width: 6),
                                Text(
                                  s.offeredLabel,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: cs.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '${formatCurrencyValue(app.offeredSalary!, app.currency)}$periodSuffix',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: cs.tertiary,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Applied date + Job type + Source Platform metadata
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: cs.secondary),
                            const SizedBox(width: 6),
                            Text(
                              app.appliedAt != null
                                  ? s.appliedOn(DateFormat('dd MMM yyyy')
                                      .format(app.appliedAt!.toLocal()))
                                  : s.notAppliedYet,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s.jobTypeLabel(jobType),
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                            if (app.sourcePlatform?.trim().isNotEmpty ?? false)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.secondaryContainer
                                      .withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.public_rounded,
                                        size: 12,
                                        color: cs.onSecondaryContainer),
                                    const SizedBox(width: 4),
                                    Text(
                                      app.sourcePlatform!.trim(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: cs.onSecondaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    if ((app.recruiterName?.isNotEmpty ?? false) ||
                        (app.recruiterContact?.isNotEmpty ?? false) ||
                        (app.vacancyUrl?.isNotEmpty ?? false)) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      if ((app.recruiterName?.isNotEmpty ?? false) ||
                          (app.recruiterContact?.isNotEmpty ?? false)) ...[
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 16, color: cs.secondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                [
                                  if (app.recruiterName?.isNotEmpty ?? false)
                                    app.recruiterName!,
                                  if (app.recruiterContact?.isNotEmpty ?? false)
                                    app.recruiterContact!,
                                ].join(' • '),
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurface),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (app.recruiterContact?.trim().isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          _buildRecruiterActions(
                            context,
                            app.recruiterContact!.trim(),
                            s,
                          ),
                        ],
                      ],
                      if (app.vacancyUrl?.isNotEmpty ?? false) ...[
                        if ((app.recruiterName?.isNotEmpty ?? false) ||
                            (app.recruiterContact?.isNotEmpty ?? false))
                          const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.link_rounded,
                                size: 16, color: cs.secondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () =>
                                    _openRawLink(context, app.vacancyUrl!, s),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    app.vacancyUrl!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          cs.primary.withValues(alpha: 0.5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: s.openLink,
                              icon: Icon(Icons.open_in_new_rounded,
                                  size: 17, color: cs.primary),
                              onPressed: () =>
                                  _openRawLink(context, app.vacancyUrl!, s),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: s.copy,
                              icon: const Icon(Icons.content_copy_rounded,
                                  size: 16),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: app.vacancyUrl!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(s.linkCopied)),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],

                    // Status Transition Control
                    const SizedBox(height: 16),
                    Text(
                      s.applicationState,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.secondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () =>
                            _showStatusPicker(context, app, app.currentStatus),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: statusDot,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        '$currentStatusLabel (${PipelineStageConfig.isTerminalStatusId(app.currentStatus) ? s.outcomeSuffix : s.stageSuffix})',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            theme.textTheme.titleSmall?.copyWith(
                                          color: statusFg,
                                        ),
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
                                    s.change,
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: statusFg,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.expand_more_rounded,
                                      size: 20, color: statusFg),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // STALE FOLLOW-UP CALLOUT (only when >=14 days without update in Applied/Screening)
              if (StaleApplicationHelper.isStale(app)) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: brightness == Brightness.dark
                        ? const Color(0xFF3E2C0A)
                        : const Color(0xFFFFF4D6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 18,
                            color: brightness == Brightness.dark
                                ? const Color(0xFFFCD34D)
                                : const Color(0xFF92400E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.staleDetailTitle(
                                StaleApplicationHelper.daysSinceUpdate(app),
                              ),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: brightness == Brightness.dark
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFF78350F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.staleDetailBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: brightness == Brightness.dark
                              ? const Color(0xFFFCD34D).withValues(alpha: 0.9)
                              : const Color(0xFF92400E),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.primaryContainer,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 40),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () => _logFollowUp(context, db, app, s),
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: Text(s.logFollowUpBtn),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () {
                              context.read<ApplicationsBloc>().add(
                                    MoveApplicationStatus(
                                      application: app,
                                      newStatusId:
                                          ApplicationStatus.noResponse.name,
                                    ),
                                  );
                            },
                            child: Text(s.markNoResponseBtn),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // INTERVIEW SCHEDULE CARD
              StreamBuilder<List<InterviewSchedule>>(
                stream: db.watchInterviewsForApp(app.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ErrorStateCard(
                      compact: true,
                      title: s.dbLoadErrorTitle,
                      retryLabel: s.retry,
                      onRetry: () => setState(() {}),
                    );
                  }
                  final schedules = snapshot.data ?? [];
                  return SurfaceCard(
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
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: cs.primaryFixed,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.videocam_outlined,
                                        size: 19, color: cs.onPrimaryFixed),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      s.interviewSchedule,
                                      style: theme.textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                minimumSize: const Size(0, 36),
                              ),
                              onPressed: () =>
                                  _showScheduleInterviewDialog(context, db, app),
                              icon: const Icon(Icons.event_available_rounded,
                                  size: 16),
                              label: Text(s.schedule),
                            ),
                          ],
                        ),
                        if (schedules.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              s.noInterviewsYet,
                              style: theme.textTheme.bodySmall,
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 14),
                            itemCount: schedules.length,
                            separatorBuilder: (_, _) => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            itemBuilder: (_, index) {
                              final item = schedules[index];
                              final localDt = item.scheduledAt.toLocal();
                              final hasBoth = item.notificationId24h != null &&
                                  item.notificationId1h != null;
                              final hasOne = item.notificationId1h != null &&
                                  item.notificationId24h == null;
                              final reminderLabel = hasBoth
                                  ? s.remindersActiveBoth
                                  : hasOne
                                      ? s.reminderActive1h
                                      : s.remindersInactive;
                              final isReminderActive = hasBoth || hasOne;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.roundName,
                                                style:
                                                    theme.textTheme.titleSmall),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.event_rounded,
                                                    size: 15,
                                                    color: cs.secondary),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    DateFormat(
                                                            'EEE, dd MMM yyyy • HH:mm')
                                                        .format(localDt),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: cs.onSurface,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: s.delete,
                                        visualDensity: VisualDensity.compact,
                                        icon: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 19,
                                            color: cs.error),
                                        onPressed: () async {
                                          await NotificationService.instance
                                              .cancelReminders(
                                            item.notificationId24h,
                                            item.notificationId1h,
                                          );
                                          await db.deleteInterviewSchedule(
                                              item.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  if (item.meetingUrl?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.link_rounded,
                                              size: 16, color: cs.secondary),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              item.meetingUrl!,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: cs.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          FilledButton.tonal(
                                            style: FilledButton.styleFrom(
                                              minimumSize: const Size(0, 32),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                            ),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: item.meetingUrl!));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(s.linkCopied)),
                                              );
                                            },
                                            child: Text(s.copy,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        isReminderActive
                                            ? Icons
                                                .notifications_active_outlined
                                            : Icons.notifications_off_outlined,
                                        size: 15,
                                        color: isReminderActive
                                            ? cs.tertiary
                                            : cs.error,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          reminderLabel,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: isReminderActive
                                                ? cs.tertiary
                                                : cs.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // ATTACHED RESUME (PDF) CARD
              StreamBuilder<ResumeAttachment?>(
                stream: db.watchResumeForApp(app.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ErrorStateCard(
                      compact: true,
                      title: s.dbLoadErrorTitle,
                      retryLabel: s.retry,
                      onRetry: () => setState(() {}),
                    );
                  }
                  final resume = snapshot.data;
                  return SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                s.tailoredResume,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () =>
                                  _pickAndSavePdf(context, db, app),
                              icon: const Icon(Icons.upload_file_rounded,
                                  size: 17),
                              label: Text(
                                  resume == null ? s.attachPdf : s.replace),
                            ),
                          ],
                        ),
                        if (resume == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              s.noPdfAttached,
                              style: theme.textTheme.bodySmall,
                            ),
                          )
                        else ...[
                          const SizedBox(height: 8),
                          _ResumeCardTile(
                            resume: resume,
                            onPreview: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PdfPreviewPage(
                                    filePath: resume.privateFilePath,
                                    fileName: resume.originalFileName,
                                  ),
                                ),
                              );
                            },
                            onReattach: () => _pickAndSavePdf(context, db, app),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // CHRONOLOGICAL TIMELINE & ACTIVITY CARD
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.history_edu_rounded,
                                  size: 20, color: cs.primary),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  s.timelineActivity,
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: const Size(0, 36),
                          ),
                          onPressed: () =>
                              _showAddNoteDialog(context, db, app),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: Text(s.addNote),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    StreamBuilder<List<TimelineLog>>(
                      stream: db.watchTimelineLogs(app.id),
                      builder: (context, logSnap) {
                        return StreamBuilder<List<StatusTransition>>(
                          stream: db.watchTransitionsForApp(app.id),
                          builder: (context, transSnap) {
                            if (logSnap.hasError || transSnap.hasError) {
                              return ErrorStateCard(
                                compact: true,
                                title: s.dbLoadErrorTitle,
                                retryLabel: s.retry,
                                onRetry: () => setState(() {}),
                              );
                            }
                            final entries = <_TimelineEntry>[
                              ...(logSnap.data ?? []).map(
                                (l) => _TimelineEntry(
                                  title: l.title,
                                  body: l.note,
                                  timestamp: l.loggedAt.toLocal(),
                                  isStatusEvent: false,
                                  log: l,
                                ),
                              ),
                              ...(transSnap.data ?? []).map((t) {
                                final toLabel = s.statusLabelById(t.toStatus);
                                final title = t.fromStatus == null
                                    ? (s.isId
                                        ? 'Ditambahkan ke $toLabel'
                                        : 'Added to $toLabel')
                                    : (s.isId
                                        ? 'Status pindah ke $toLabel'
                                        : 'Status moved to $toLabel');
                                return _TimelineEntry(
                                  title: title,
                                  body: '',
                                  timestamp: t.transitionedAt.toLocal(),
                                  isStatusEvent: true,
                                );
                              }),
                            ]..sort(
                                (a, b) => b.timestamp.compareTo(a.timestamp));

                            if (entries.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  s.noActivityYet,
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }

                            return Column(
                              children: List.generate(entries.length, (i) {
                                final item = entries[i];
                                final isLast = i == entries.length - 1;
                                final dotColor = item.isStatusEvent
                                    ? cs.tertiary
                                    : cs.primary;

                                return IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 4),
                                            Container(
                                              width: 11,
                                              height: 11,
                                              decoration: BoxDecoration(
                                                color: dotColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: cs.surface,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            if (!isLast)
                                              Expanded(
                                                child: Container(
                                                  width: 2,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  color:
                                                      cs.surfaceContainerHighest,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: isLast ? 0 : 14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.title,
                                                      style: theme
                                                          .textTheme.titleSmall,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    DateFormat('dd MMM, HH:mm')
                                                        .format(item.timestamp),
                                                    style: theme
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                      color: cs.secondary,
                                                    ),
                                                  ),
                                                  if (!item.isStatusEvent &&
                                                      item.log != null) ...[
                                                    const SizedBox(width: 2),
                                                    SizedBox(
                                                      width: 28,
                                                      height: 28,
                                                      child: PopupMenuButton<
                                                          String>(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        iconSize: 17,
                                                        icon: Icon(
                                                          Icons
                                                              .more_vert_rounded,
                                                          color: cs
                                                              .onSurfaceVariant,
                                                        ),
                                                        onSelected: (action) {
                                                          if (action ==
                                                              'edit') {
                                                            _showEditNoteDialog(
                                                              context,
                                                              db,
                                                              item.log!,
                                                            );
                                                          } else if (action ==
                                                              'delete') {
                                                            _confirmDeleteNote(
                                                              context,
                                                              db,
                                                              item.log!,
                                                            );
                                                          }
                                                        },
                                                        itemBuilder: (_) => [
                                                          PopupMenuItem(
                                                            value: 'edit',
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                    Icons
                                                                        .edit_outlined,
                                                                    size: 17),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(s.editNote),
                                                              ],
                                                            ),
                                                          ),
                                                          PopupMenuItem(
                                                            value: 'delete',
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .delete_outline_rounded,
                                                                    size: 17,
                                                                    color: cs
                                                                        .error),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  s.delete,
                                                                  style: TextStyle(
                                                                      color: cs
                                                                          .error),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              if (item.body.isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        cs.surfaceContainerLow,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    item.body,
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color:
                                                          cs.onSurfaceVariant,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Bottom Action Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _openEditForm(context, app),
                        icon: const Icon(Icons.edit_note_rounded, size: 20),
                        label: Text(s.editJobDetails),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor:
                            cs.errorContainer.withValues(alpha: 0.7),
                        foregroundColor: cs.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmDelete(context, app),
                      child: const Icon(Icons.delete_outline_rounded, size: 21),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  void _openEditForm(BuildContext context, JobApplication app) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ApplicationFormPage(existingApplication: app),
      ),
    );
  }

  Future<void> _showScheduleInterviewDialog(
    BuildContext context,
    AppDatabase db,
    JobApplication app,
  ) async {
    final s = AppLocaleScope.of(context);
    final roundCtrl = TextEditingController(text: 'Technical Interview');
    final linkCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(s.interviewSchedule),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roundCtrl,
                decoration: InputDecoration(
                    labelText: s.isId ? 'Tahap Interview' : 'Round Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: linkCtrl,
                decoration: InputDecoration(
                    labelText: s.isId
                        ? 'Link Meeting (opsional)'
                        : 'Meeting Link (optional)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined, size: 15),
                      label: Text(DateFormat('dd MMM').format(selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: ctx,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setDialogState(() => selectedTime = picked);
                        }
                      },
                      icon: const Icon(Icons.access_time_rounded, size: 15),
                      label: Text(selectedTime.format(ctx)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final roundName = roundCtrl.text.trim();
                if (roundName.isEmpty) {
                  showErrorSnackBar(context, s.roundNameRequired);
                  return;
                }
                final localDt = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                if (!localDt.isAfter(DateTime.now())) {
                  showErrorSnackBar(context, s.pastInterviewError);
                  return;
                }
                final utcDt = localDt.toUtc();
                final scheduleId = _uuid.v4();

                try {
                  final reminderResult = await NotificationService.instance
                      .scheduleInterviewReminders(
                    scheduleId: scheduleId,
                    companyName: app.companyName,
                    roundName: roundName,
                    scheduledAtUtc: utcDt,
                  );

                  await db.insertInterviewSchedule(
                    InterviewSchedulesCompanion.insert(
                      id: scheduleId,
                      applicationId: app.id,
                      roundName: roundName,
                      scheduledAt: utcDt,
                      meetingUrl: Value(linkCtrl.text.trim().isEmpty
                          ? null
                          : linkCtrl.text.trim()),
                      notificationId24h:
                          Value(reminderResult.notificationId24h),
                      notificationId1h: Value(reminderResult.notificationId1h),
                    ),
                  );

                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    final msg = switch (reminderResult.status) {
                      ReminderStatus.scheduledBoth => s.remindersActiveBoth,
                      ReminderStatus.scheduledOneHourOnly => s.reminderActive1h,
                      ReminderStatus.lessThanOneHour => s.isId
                          ? 'Jadwal kurang dari 1 jam lagi. Tidak ada alarm terjadwal.'
                          : 'Scheduled under 1 hour away. No alarm scheduled.',
                      ReminderStatus.permissionDenied => s.isId
                          ? 'Jadwal disimpan, pengingat tidak aktif (izin notifikasi ditolak).'
                          : 'Saved, reminders inactive (notification permission denied).',
                      ReminderStatus.scheduleFailed => s.reminderScheduleFailed,
                    };
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  }
                } catch (_) {
                  if (context.mounted) {
                    showErrorSnackBar(context, s.scheduleSaveFailed);
                  }
                }
              },
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSavePdf(
    BuildContext context,
    AppDatabase db,
    JobApplication app,
  ) async {
    final s = AppLocaleScope.of(context);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result.isEmpty || result.single.path == null) return;

      final picked = File(result.single.path!);
      final sizeBytes = await picked.length();

      if (sizeBytes > _maxPdfBytes) {
        if (context.mounted) {
          showErrorSnackBar(
            context,
            s.isId
                ? 'File melebihi batas maksimal 10 MB.'
                : 'File exceeds the 10 MB maximum limit.',
          );
        }
        return;
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final resumesDir = Directory(p.join(docsDir.path, 'resumes'));
      if (!resumesDir.existsSync()) {
        resumesDir.createSync(recursive: true);
      }

      final uniqueName =
          '${app.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final destFile = await picked.copy(p.join(resumesDir.path, uniqueName));

      await db.upsertResumeAttachment(
        ResumeAttachmentsCompanion.insert(
          id: _uuid.v4(),
          applicationId: app.id,
          originalFileName: result.single.name,
          privateFilePath: destFile.path,
          fileSizeBytes: sizeBytes,
          attachedAt: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        showErrorSnackBar(context, s.pdfAttachFailed);
      }
    }
  }

  void _showStatusPicker(
    BuildContext context,
    JobApplication app,
    String currentStatusId,
  ) {
    final brightness = Theme.of(context).brightness;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final s = AppLocaleScope.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.72,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(s.updateStateTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 14),
              Text(s.activeStagesHeader, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              ...s.pipelineStages.map((stage) {
                final isSelected = stage.id == currentStatusId;
                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: isSelected ? cs.primaryFixed : null,
                  leading: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: stage.colorKey.dotColor(brightness),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(stage.label, style: theme.textTheme.titleSmall),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: cs.primary)
                      : null,
                  onTap: () {
                    context.read<ApplicationsBloc>().add(
                          MoveApplicationStatus(
                            application: app,
                            newStatusId: stage.id,
                          ),
                        );
                    Navigator.of(ctx).pop();
                  },
                );
              }),
              const SizedBox(height: 14),
              Text(s.terminalOutcomesHeader,
                  style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              ...ApplicationStatus.terminalOutcomes.map((status) {
                final isSelected = status.name == currentStatusId;
                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: isSelected ? cs.surfaceContainerHigh : null,
                  leading: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.stageDotColor(status, brightness),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(s.defaultStatusLabel(status),
                      style: theme.textTheme.titleSmall),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: cs.primary)
                      : null,
                  onTap: () {
                    context.read<ApplicationsBloc>().add(
                          MoveApplicationStatus(
                            application: app,
                            newStatusId: status.name,
                          ),
                        );
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(
    BuildContext context,
    AppDatabase db,
    JobApplication app,
  ) {
    final s = AppLocaleScope.of(context);
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.addNote),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.isId ? 'Judul' : 'Title',
                hintText: s.isId
                    ? 'cth. Screening HR Selesai'
                    : 'e.g. Recruiter Screen Completed',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.isId ? 'Catatan' : 'Details',
                hintText: s.isId
                    ? 'Pertanyaan interview, kisaran gaji, langkah selanjutnya...'
                    : 'Questions asked, salary range, next steps...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await db.insertTimelineLog(
                TimelineLogsCompanion.insert(
                  id: _uuid.v4(),
                  applicationId: app.id,
                  title: titleCtrl.text.trim(),
                  note: Value(noteCtrl.text.trim()),
                  loggedAt: DateTime.now().toUtc(),
                ),
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(
    BuildContext context,
    AppDatabase db,
    TimelineLog log,
  ) {
    final s = AppLocaleScope.of(context);
    final titleCtrl = TextEditingController(text: log.title);
    final noteCtrl = TextEditingController(text: log.note);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.editNote),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.isId ? 'Judul' : 'Title',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.isId ? 'Catatan' : 'Details',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await db.updateTimelineLog(
                id: log.id,
                title: titleCtrl.text.trim(),
                note: noteCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteNote(
    BuildContext context,
    AppDatabase db,
    TimelineLog log,
  ) {
    final s = AppLocaleScope.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteNoteTitle),
        content: Text(s.deleteNoteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await db.deleteTimelineLog(log.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruiterActions(
    BuildContext context,
    String contact,
    AppStrings s,
  ) {
    final parsed = ContactLauncher.parse(contact);
    final cs = Theme.of(context).colorScheme;

    Widget actionPill({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool primary = false,
    }) {
      return Material(
        color: primary ? cs.primaryFixed : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: primary ? cs.onPrimaryFixed : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            primary ? cs.onPrimaryFixed : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (parsed.kind == ContactKind.email && parsed.primaryUri != null)
          actionPill(
            icon: Icons.mail_outline_rounded,
            label: s.sendEmail,
            primary: true,
            onTap: () => _launchUriWithFeedback(context, parsed.primaryUri!, s),
          ),
        if (parsed.kind == ContactKind.phone && parsed.whatsappUri != null)
          actionPill(
            icon: Icons.chat_outlined,
            label: s.chatWhatsApp,
            primary: true,
            onTap: () =>
                _launchUriWithFeedback(context, parsed.whatsappUri!, s),
          ),
        if (parsed.kind == ContactKind.phone && parsed.primaryUri != null)
          actionPill(
            icon: Icons.call_outlined,
            label: s.callPhone,
            onTap: () => _launchUriWithFeedback(context, parsed.primaryUri!, s),
          ),
        if (parsed.kind == ContactKind.url && parsed.primaryUri != null)
          actionPill(
            icon: Icons.open_in_new_rounded,
            label: s.openLink,
            primary: true,
            onTap: () => _launchUriWithFeedback(context, parsed.primaryUri!, s),
          ),
        actionPill(
          icon: Icons.content_copy_rounded,
          label: s.copyAction,
          onTap: () {
            Clipboard.setData(ClipboardData(text: contact));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.copiedToClipboard)),
            );
          },
        ),
      ],
    );
  }

  Future<void> _openRawLink(
    BuildContext context,
    String raw,
    AppStrings s,
  ) async {
    final parsed = ContactLauncher.parse(raw);
    if (parsed.primaryUri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.couldNotOpenLink)),
        );
      }
      return;
    }
    await _launchUriWithFeedback(context, parsed.primaryUri!, s);
  }

  Future<void> _launchUriWithFeedback(
    BuildContext context,
    Uri uri,
    AppStrings s,
  ) async {
    final ok = await ContactLauncher.launch(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.couldNotOpenLink)),
      );
    }
  }

  Future<void> _logFollowUp(
    BuildContext context,
    AppDatabase db,
    JobApplication app,
    AppStrings s,
  ) async {
    try {
      await db.insertTimelineLog(
        TimelineLogsCompanion.insert(
          id: _uuid.v4(),
          applicationId: app.id,
          title: s.isId ? 'Follow-up terkirim' : 'Follow-up sent',
          note: Value(
            s.isId
                ? 'Mengirim pesan follow-up terkait perkembangan lamaran.'
                : 'Sent a polite follow-up regarding application status.',
          ),
          loggedAt: DateTime.now().toUtc(),
        ),
      );
      await db.touchApplicationUpdatedAt(app.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.followUpLoggedMsg)),
        );
      }
    } catch (_) {
      if (context.mounted) showErrorSnackBar(context, s.noteSaveFailed);
    }
  }

  void _confirmDelete(BuildContext context, JobApplication app) {
    final s = AppLocaleScope.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteAppTitle),
        content: Text(s.deleteAppBody(app.companyName, app.roleTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<ApplicationsBloc>().add(DeleteApplication(app.id));
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isStatusEvent,
    this.log,
  });

  final String title;
  final String body;
  final DateTime timestamp;
  final bool isStatusEvent;
  final TimelineLog? log;
}

class _ResumeCardTile extends StatelessWidget {
  const _ResumeCardTile({
    required this.resume,
    required this.onPreview,
    required this.onReattach,
  });

  final ResumeAttachment resume;
  final VoidCallback onPreview;
  final VoidCallback onReattach;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);
    final exists = File(resume.privateFilePath).existsSync();
    final sizeKb = (resume.fileSizeBytes / 1024).round();
    final dateStr =
        DateFormat('dd MMM yyyy').format(resume.attachedAt.toLocal());

    if (!exists) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.errorContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.fileNotFound,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: cs.error)),
                  Text(
                    resume.originalFileName,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onReattach,
              child: Text(s.reattach),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.picture_as_pdf_rounded,
                color: cs.onErrorContainer, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resume.originalFileName,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$sizeKb KB • $dateStr',
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: onPreview,
            icon: const Icon(Icons.visibility_outlined, size: 17),
            label: Text(s.preview),
          ),
        ],
      ),
    );
  }
}
