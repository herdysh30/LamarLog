import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/utils/stale_application_helper.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../bloc/applications_bloc.dart';
import '../widgets/detail/application_hero_card.dart';
import '../widgets/detail/application_interview_card.dart';
import '../widgets/detail/application_resume_card.dart';
import '../widgets/detail/application_status_picker_sheet.dart';
import '../widgets/detail/application_timeline_card.dart';
import 'application_form_page.dart';

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
                ApplicationHeroCard(
                  application: app,
                  onTapStatus: () => showApplicationStatusPickerSheet(
                    context: context,
                    app: app,
                    currentStatusId: app.currentStatus,
                  ),
                ),
                const SizedBox(height: 14),
                if (StaleApplicationHelper.isStale(app)) ...[
                  _StaleFollowUpCallout(
                    application: app,
                    brightness: brightness,
                    onLogFollowUp: () => _logFollowUp(context, db, app, s),
                    onMarkNoResponse: () {
                      context.read<ApplicationsBloc>().add(
                            MoveApplicationStatus(
                              application: app,
                              newStatusId: ApplicationStatus.noResponse.name,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 14),
                ],
                ApplicationInterviewCard(
                  application: app,
                  db: db,
                  onRetry: () => setState(() {}),
                ),
                const SizedBox(height: 14),
                ApplicationResumeCard(
                  application: app,
                  db: db,
                  onRetry: () => setState(() {}),
                ),
                const SizedBox(height: 14),
                ApplicationTimelineCard(
                  application: app,
                  db: db,
                  onRetry: () => setState(() {}),
                ),
                const SizedBox(height: 16),
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
                        child:
                            const Icon(Icons.delete_outline_rounded, size: 21),
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
      AppMotion.slideUpRoute<void>(
        ApplicationFormPage(existingApplication: app),
      ),
    );
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

class _StaleFollowUpCallout extends StatelessWidget {
  const _StaleFollowUpCallout({
    required this.application,
    required this.brightness,
    required this.onLogFollowUp,
    required this.onMarkNoResponse,
  });

  final JobApplication application;
  final Brightness brightness;
  final VoidCallback onLogFollowUp;
  final VoidCallback onMarkNoResponse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    return Container(
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
                    StaleApplicationHelper.daysSinceUpdate(application),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: onLogFollowUp,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(s.logFollowUpBtn),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: onMarkNoResponse,
                child: Text(s.markNoResponseBtn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
