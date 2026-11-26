import 'package:lamarlog/core/services/crash_report_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrashReportService', () {
    setUp(() {
      CrashReportService.instance.clearRecordedErrors();
    });

    test('redacts local usernames and private resume paths from errors', () {
      const rawWin = r'FileSystemException at C:\Users\Herdy\Documents\cv.pdf';
      const rawAndroid =
          'Missing /data/user/0/com.lamarlog.lamarlog/app_flutter/resumes/secret_cv.pdf';

      expect(
        CrashReportService.sanitizeText(rawWin),
        contains(r'C:\Users\<redacted>\Documents\cv.pdf'),
      );
      expect(
        CrashReportService.sanitizeText(rawAndroid),
        contains('<redacted_resume_path>'),
      );
      expect(
        CrashReportService.sanitizeText(rawAndroid),
        isNot(contains('secret_cv.pdf')),
      );
    });

    test('retains only the latest 5 recorded errors in memory', () {
      for (var i = 1; i <= 7; i++) {
        CrashReportService.instance.recordError('Error #$i', null);
      }

      final recent = CrashReportService.instance.recentErrors;
      expect(recent.length, 5);
      expect(recent.first.message, 'Error #3');
      expect(recent.last.message, 'Error #7');
    });

    test('builds valid pre-filled GitHub Issue fallback URI', () {
      final payload = CrashReportService.instance.buildPayload(
        locale: 'id',
        errorMessageOverride: 'DatabaseException: disk full',
        userNote: 'Saving new interview schedule',
      );

      final uri = CrashReportService.buildPrefilledGitHubIssueUri(payload);
      expect(uri.host, 'github.com');
      expect(uri.path, '/herdysh30/LamarLog/issues/new');
      expect(uri.queryParameters['labels'], 'bug,user-report');
      expect(uri.queryParameters['title'], contains('Saving new interview'));
      expect(uri.queryParameters['body'], contains('DatabaseException: disk full'));
    });

    test('returns notConfigured when no endpoint is supplied', () async {
      final payload = CrashReportService.instance.buildPayload(
        locale: 'en',
        errorMessageOverride: 'Test error',
      );

      final result = await CrashReportService.instance.sendReport(
        payload,
        endpointOverride: '',
      );
      expect(result.status, CrashReportSendStatus.notConfigured);
      expect(result.isSuccess, isFalse);
    });
  });
}
