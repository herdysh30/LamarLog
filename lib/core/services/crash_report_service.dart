import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class RecordedAppError {
  const RecordedAppError({
    required this.source,
    required this.message,
    required this.stackTrace,
    required this.occurredAtUtc,
  });

  final String source;
  final String message;
  final String stackTrace;
  final DateTime occurredAtUtc;
}

class CrashReportPayload {
  const CrashReportPayload({
    required this.title,
    required this.appVersion,
    required this.platform,
    required this.osVersion,
    required this.locale,
    required this.occurredAtUtc,
    required this.errorMessage,
    required this.stackTrace,
    this.userNote = '',
  });

  final String title;
  final String appVersion;
  final String platform;
  final String osVersion;
  final String locale;
  final DateTime occurredAtUtc;
  final String errorMessage;
  final String stackTrace;
  final String userNote;

  Map<String, dynamic> toJson() => {
        'title': title,
        'appVersion': appVersion,
        'platform': platform,
        'osVersion': osVersion,
        'locale': locale,
        'occurredAtUtc': occurredAtUtc.toUtc().toIso8601String(),
        'userNote': userNote,
        'errorMessage': errorMessage,
        'stackTrace': stackTrace,
      };
}

enum CrashReportSendStatus {
  sent,
  notConfigured,
  networkError,
  rateLimited,
  serverError,
}

class CrashReportSendResult {
  const CrashReportSendResult({
    required this.status,
    this.issueNumber,
    this.issueUrl,
    this.errorDetail,
  });

  final CrashReportSendStatus status;
  final int? issueNumber;
  final String? issueUrl;
  final String? errorDetail;

  bool get isSuccess => status == CrashReportSendStatus.sent;
}

/// Captures sanitized runtime errors and submits anonymous bug reports to
/// the LamarLog Cloudflare Worker proxy (which creates GitHub Issues safely
/// without requiring end users to have a GitHub account or embedding tokens).
class CrashReportService {
  CrashReportService._();

  static final CrashReportService instance = CrashReportService._();

  static const String appVersion = '1.2.0';
  static const String githubOwner = 'herdysh30';
  static const String githubRepo = 'LamarLog';

  /// Configure via `--dart-define=REPORT_ENDPOINT=https://lamarlog-report-worker.<subdomain>.workers.dev/report`
  /// or set directly after deploying `tools/report-worker`.
  static const String configuredEndpoint = String.fromEnvironment(
    'REPORT_ENDPOINT',
    defaultValue: '',
  );

  static const int _maxStoredErrors = 5;
  final List<RecordedAppError> _recentErrors = [];

  List<RecordedAppError> get recentErrors => List.unmodifiable(_recentErrors);

  RecordedAppError? get latestError =>
      _recentErrors.isEmpty ? null : _recentErrors.last;

  bool get hasEndpointConfigured => configuredEndpoint.trim().isNotEmpty;

  /// Records a sanitized error in memory (never persists user job data).
  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String source = 'runtime',
  }) {
    final sanitizedMsg = sanitizeText(error.toString(), maxLength: 600);
    final sanitizedStack = sanitizeStackTrace(stackTrace?.toString() ?? '');

    _recentErrors.add(
      RecordedAppError(
        source: source,
        message: sanitizedMsg,
        stackTrace: sanitizedStack,
        occurredAtUtc: DateTime.now().toUtc(),
      ),
    );
    if (_recentErrors.length > _maxStoredErrors) {
      _recentErrors.removeAt(0);
    }
  }

  void clearRecordedErrors() => _recentErrors.clear();

  /// Removes potentially sensitive local OS usernames / file paths from error strings.
  static String sanitizeText(String raw, {int maxLength = 800}) {
    var cleaned = raw.trim();
    // Redact Windows / macOS / Linux home directory usernames
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'([A-Za-z]:\\Users\\|/Users/|/home/)[^\\/\s]+'),
      (m) => '${m.group(1)}<redacted>',
    );
    // Redact Android app private document file paths (e.g., resume PDF filenames)
    cleaned = cleaned.replaceAll(
      RegExp(r'/data/user/\d+/[^\s]+/app_flutter/resumes/[^\s]+'),
      '<redacted_resume_path>',
    );
    if (cleaned.length > maxLength) {
      cleaned = '${cleaned.substring(0, maxLength)}...';
    }
    return cleaned;
  }

  /// Keeps only the top 20 sanitized stack frames to stay compact and readable.
  static String sanitizeStackTrace(String raw) {
    if (raw.trim().isEmpty) return '';
    final lines = raw
        .split('\n')
        .map((l) => l.trimRight())
        .where((l) => l.isNotEmpty)
        .take(20)
        .join('\n');
    return sanitizeText(lines, maxLength: 2200);
  }

  CrashReportPayload buildPayload({
    required String locale,
    String? titleOverride,
    String? errorMessageOverride,
    String? stackTraceOverride,
    String userNote = '',
  }) {
    final latest = latestError;
    final rawError = errorMessageOverride?.trim().isNotEmpty == true
        ? sanitizeText(errorMessageOverride!, maxLength: 600)
        : (latest?.message ?? 'User-initiated bug report');
    final rawStack = stackTraceOverride?.trim().isNotEmpty == true
        ? sanitizeStackTrace(stackTraceOverride!)
        : (latest?.stackTrace ?? '');

    final computedTitle = titleOverride?.trim().isNotEmpty == true
        ? sanitizeText(titleOverride!, maxLength: 100)
        : _deriveTitle(rawError, userNote);

    return CrashReportPayload(
      title: computedTitle,
      appVersion: appVersion,
      platform: kIsWeb ? 'web' : Platform.operatingSystem,
      osVersion: kIsWeb ? 'web' : sanitizeText(Platform.operatingSystemVersion, maxLength: 120),
      locale: locale,
      occurredAtUtc: latest?.occurredAtUtc ?? DateTime.now().toUtc(),
      errorMessage: rawError,
      stackTrace: rawStack,
      userNote: sanitizeText(userNote, maxLength: 600),
    );
  }

  static String _deriveTitle(String errorMessage, String userNote) {
    final noteFirst = userNote.trim().split('\n').first.trim();
    if (noteFirst.isNotEmpty) {
      final clipped =
          noteFirst.length > 72 ? '${noteFirst.substring(0, 72)}...' : noteFirst;
      return '[Bug] $clipped';
    }
    final errFirst = errorMessage.trim().split('\n').first.trim();
    final clipped =
        errFirst.length > 72 ? '${errFirst.substring(0, 72)}...' : errFirst;
    return '[Crash] $clipped';
  }

  /// Plain-text diagnostic preview shown transparently to the user before sending.
  static String formatPlainText(CrashReportPayload payload) {
    final buf = StringBuffer()
      ..writeln('Title: ${payload.title}')
      ..writeln('App Version: v${payload.appVersion}')
      ..writeln('Platform: ${payload.platform} (${payload.osVersion})')
      ..writeln('Locale: ${payload.locale}')
      ..writeln('Timestamp (UTC): ${payload.occurredAtUtc.toUtc().toIso8601String()}');
    if (payload.userNote.trim().isNotEmpty) {
      buf
        ..writeln()
        ..writeln('User Note:')
        ..writeln(payload.userNote.trim());
    }
    buf
      ..writeln()
      ..writeln('Error:')
      ..writeln(payload.errorMessage);
    if (payload.stackTrace.trim().isNotEmpty) {
      buf
        ..writeln()
        ..writeln('Stack Trace:')
        ..writeln(payload.stackTrace);
    }
    return buf.toString().trim();
  }

  /// Fallback pre-filled GitHub Issue URL (for offline/unconfigured fallback).
  static Uri buildPrefilledGitHubIssueUri(CrashReportPayload payload) {
    final body = '''
### Description
${payload.userNote.trim().isEmpty ? '_No additional notes provided._' : payload.userNote.trim()}

### Environment
- **App Version:** `v${payload.appVersion}`
- **Platform:** `${payload.platform}`
- **OS:** `${payload.osVersion}`
- **Locale:** `${payload.locale}`
- **Timestamp (UTC):** `${payload.occurredAtUtc.toUtc().toIso8601String()}`

### Error Summary
```text
${payload.errorMessage}
```
${payload.stackTrace.trim().isNotEmpty ? '\n### Stack Trace\n```text\n${payload.stackTrace}\n```' : ''}
''';
    return Uri.https(
      'github.com',
      '/$githubOwner/$githubRepo/issues/new',
      {
        'title': payload.title,
        'body': body.length > 3500 ? '${body.substring(0, 3500)}\n...' : body,
        'labels': 'bug,user-report',
      },
    );
  }

  /// Sends the sanitized payload to the Cloudflare Worker proxy to create a
  /// GitHub Issue automatically (no GitHub login needed on the user's phone).
  Future<CrashReportSendResult> sendReport(
    CrashReportPayload payload, {
    String? endpointOverride,
  }) async {
    final endpoint = (endpointOverride ?? configuredEndpoint).trim();
    if (endpoint.isEmpty) {
      return const CrashReportSendResult(
        status: CrashReportSendStatus.notConfigured,
      );
    }

    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme) {
      return const CrashReportSendResult(
        status: CrashReportSendStatus.notConfigured,
      );
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      req.headers.set('X-App-Client', 'LamarLog/$appVersion');
      final bodyBytes = utf8.encode(jsonEncode(payload.toJson()));
      req.add(bodyBytes);

      final res = await req.close().timeout(const Duration(seconds: 12));
      final resBody = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200 || res.statusCode == 201) {
        try {
          final json = jsonDecode(resBody) as Map<String, dynamic>;
          return CrashReportSendResult(
            status: CrashReportSendStatus.sent,
            issueNumber: (json['issueNumber'] as num?)?.toInt(),
            issueUrl: json['issueUrl'] as String?,
          );
        } catch (_) {
          return const CrashReportSendResult(
            status: CrashReportSendStatus.sent,
          );
        }
      }

      if (res.statusCode == 429) {
        return const CrashReportSendResult(
          status: CrashReportSendStatus.rateLimited,
        );
      }

      return CrashReportSendResult(
        status: CrashReportSendStatus.serverError,
        errorDetail: 'HTTP ${res.statusCode}',
      );
    } on SocketException catch (e) {
      return CrashReportSendResult(
        status: CrashReportSendStatus.networkError,
        errorDetail: e.message,
      );
    } catch (e) {
      return CrashReportSendResult(
        status: CrashReportSendStatus.networkError,
        errorDetail: e.toString(),
      );
    } finally {
      client.close(force: true);
    }
  }
}
