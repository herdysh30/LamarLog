import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/enums/application_enums.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/models/pipeline_stage_config.dart';
import '../../../../../core/utils/contact_launcher.dart';
import '../../../../../core/widgets/applyflow_widgets.dart';

class ApplicationHeroCard extends StatelessWidget {
  const ApplicationHeroCard({
    super.key,
    required this.application,
    required this.onTapStatus,
  });

  final JobApplication application;
  final VoidCallback onTapStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final s = AppLocaleScope.of(context);
    final app = application;

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

    final hasSalary = app.expectedSalary != null && app.expectedSalary! > 0;
    final salaryAmount = formatSalaryAmount(app, fallback: s.salaryUnlisted);
    final periodSuffix = salaryPeriodSuffix(app, isId: s.isId);

    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'app-monogram-${app.id}',
                child: CompanyMonogram(
                  companyName: app.companyName,
                  size: 48,
                  radius: 12,
                  filled: true,
                ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          children: [
                            TextSpan(text: salaryAmount),
                            if (hasSalary)
                              TextSpan(
                                text: periodSuffix,
                                style: theme.textTheme.labelSmall?.copyWith(
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
                              ContactLauncher.googleMapsUri(app.location),
                              s,
                            ),
                    child: Padding(
                      padding: const EdgeInsets.all(11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        fontFeatures: const [FontFeature.tabularFigures()],
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                        color: cs.secondaryContainer.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public_rounded,
                              size: 12, color: cs.onSecondaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            app.sourcePlatform!.trim(),
                            style: theme.textTheme.labelSmall?.copyWith(
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
                  Icon(Icons.link_rounded, size: 16, color: cs.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _openRawLink(context, app.vacancyUrl!, s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          app.vacancyUrl!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: cs.primary.withValues(alpha: 0.5),
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
                    onPressed: () => _openRawLink(context, app.vacancyUrl!, s),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: s.copy,
                    icon: const Icon(Icons.content_copy_rounded, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: app.vacancyUrl!));
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
              onTap: onTapStatus,
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
                              style: theme.textTheme.titleSmall?.copyWith(
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
                          style: theme.textTheme.labelMedium?.copyWith(
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
}
