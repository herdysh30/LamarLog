import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/motion/app_motion.dart';
import '../../../../../core/widgets/applyflow_widgets.dart';
import '../../pages/pdf_preview_page.dart';

class ApplicationResumeCard extends StatelessWidget {
  const ApplicationResumeCard({
    super.key,
    required this.application,
    required this.db,
    required this.onRetry,
  });

  static const int _maxPdfBytes = 10 * 1024 * 1024; // 10 MB
  static const _uuid = Uuid();

  final JobApplication application;
  final AppDatabase db;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppLocaleScope.of(context);

    return StreamBuilder<ResumeAttachment?>(
      stream: db.watchResumeForApp(application.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorStateCard(
            compact: true,
            title: s.dbLoadErrorTitle,
            retryLabel: s.retry,
            onRetry: onRetry,
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
                    onPressed: () => _pickAndSavePdf(context),
                    icon: const Icon(Icons.upload_file_rounded, size: 17),
                    label: Text(resume == null ? s.attachPdf : s.replace),
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
                      AppMotion.sharedAxisRoute<void>(
                        PdfPreviewPage(
                          filePath: resume.privateFilePath,
                          fileName: resume.originalFileName,
                        ),
                      ),
                    );
                  },
                  onReattach: () => _pickAndSavePdf(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndSavePdf(BuildContext context) async {
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
          '${application.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final destFile = await picked.copy(p.join(resumesDir.path, uniqueName));

      await db.upsertResumeAttachment(
        ResumeAttachmentsCompanion.insert(
          id: _uuid.v4(),
          applicationId: application.id,
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
                  Text(
                    s.fileNotFound,
                    style:
                        theme.textTheme.titleSmall?.copyWith(color: cs.error),
                  ),
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
