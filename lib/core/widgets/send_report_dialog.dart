import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../motion/app_motion.dart';
import '../services/crash_report_service.dart';
import '../utils/contact_launcher.dart';
import 'applyflow_widgets.dart';

/// Opens a transparent, privacy-first Bug / Crash Report dialog that sends
/// sanitized diagnostics directly to the Cloudflare Worker proxy (auto GitHub
/// Issue without requiring user login), with Copy & GitHub URL fallbacks.
Future<void> showSendReportDialog(
  BuildContext context, {
  String? errorMessage,
  String? stackTrace,
}) async {
  final s = AppLocaleScope.of(context);
  final noteCtrl = TextEditingController();
  bool isSending = false;
  bool showPreview = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final payload = CrashReportService.instance.buildPayload(
          locale: s.languageCode,
          errorMessageOverride: errorMessage,
          stackTraceOverride: stackTrace,
          userNote: noteCtrl.text,
        );
        final previewText = CrashReportService.formatPlainText(payload);

        Future<void> handleAutoSend() async {
          setSheetState(() => isSending = true);
          final result = await CrashReportService.instance.sendReport(payload);
          if (!ctx.mounted) return;
          setSheetState(() => isSending = false);

          switch (result.status) {
            case CrashReportSendStatus.sent:
              AppMotion.lightHaptic();
              Navigator.of(ctx).pop();
              if (context.mounted) {
                final issueLabel = result.issueNumber != null
                    ? ' (#${result.issueNumber})'
                    : '';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.reportSentSuccess(issueLabel)),
                    action: result.issueUrl != null
                        ? SnackBarAction(
                            label: s.openLink,
                            onPressed: () {
                              final uri = Uri.tryParse(result.issueUrl!);
                              if (uri != null) ContactLauncher.launch(uri);
                            },
                          )
                        : null,
                  ),
                );
              }
            case CrashReportSendStatus.notConfigured:
              showErrorSnackBar(ctx, s.reportEndpointNotConfigured);
            case CrashReportSendStatus.networkError:
              showErrorSnackBar(ctx, s.reportNetworkFailed);
            case CrashReportSendStatus.rateLimited:
              showErrorSnackBar(ctx, s.reportRateLimited);
            case CrashReportSendStatus.serverError:
              showErrorSnackBar(ctx, s.reportServerFailed);
          }
        }

        Future<void> handleOpenGitHubFallback() async {
          AppMotion.selectionHaptic();
          final uri = CrashReportService.buildPrefilledGitHubIssueUri(payload);
          final ok = await ContactLauncher.launch(uri);
          if (!ok && ctx.mounted) {
            showErrorSnackBar(ctx, s.couldNotOpenLink);
          }
        }

        void handleCopy() {
          AppMotion.selectionHaptic();
          Clipboard.setData(ClipboardData(text: previewText));
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(s.reportCopied)),
          );
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.errorContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(Icons.bug_report_outlined,
                            color: cs.error, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.sendReportTitle,
                                style: theme.textTheme.headlineSmall),
                            Text(s.sendReportSub,
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Privacy Notice Callout
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 18, color: cs.tertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.reportPrivacyNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Optional User Description
                  Text(s.reportNoteLabel, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      hintText: s.reportNoteHint,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Collapsible Diagnostic Preview
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () =>
                        setSheetState(() => showPreview = !showPreview),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            showPreview
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 20,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.reportPreviewToggle,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: AppMotion.duration(ctx, AppMotion.medium),
                    curve: AppMotion.enterCurve,
                    child: showPreview
                        ? Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 4, bottom: 8),
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(maxHeight: 170),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                previewText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),

                  // Primary Auto-Send CTA (Worker Proxy -> Auto GitHub Issue)
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSending ? null : handleAutoSend,
                      icon: isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        isSending ? s.reportSending : s.sendReportAutoBtn,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Secondary Fallbacks (Open GitHub Issue directly / Copy)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                isSending ? null : handleOpenGitHubFallback,
                            icon: const Icon(Icons.open_in_new_rounded,
                                size: 16),
                            label: Text(
                              'GitHub',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isSending ? null : handleCopy,
                            icon: const Icon(Icons.content_copy_rounded,
                                size: 16),
                            label: Text(
                              s.copyAction,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
