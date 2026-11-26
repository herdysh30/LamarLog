import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../../../core/l10n/app_strings.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  final String filePath;
  final String fileName;

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context);
    final fileExists = File(widget.filePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('${_currentPage + 1} / $_totalPages'),
              ),
            ),
        ],
      ),
      body: !fileExists
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.pdfFileNotFoundTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.pdfFileNotFoundBody,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      s.pdfLoadError(_errorMessage!),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : PDFView(
                  filePath: widget.filePath,
                  enableSwipe: true,
                  autoSpacing: true,
                  pageFling: true,
                  onRender: (pages) {
                    if (mounted) setState(() => _totalPages = pages ?? 0);
                  },
                  onPageChanged: (page, total) {
                    if (mounted) {
                      setState(() {
                        _currentPage = page ?? 0;
                        _totalPages = total ?? _totalPages;
                      });
                    }
                  },
                  onError: (error) {
                    if (mounted) {
                      setState(() => _errorMessage = error.toString());
                    }
                  },
                ),
    );
  }
}
