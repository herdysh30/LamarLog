import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamarlog/core/l10n/app_strings.dart';
import 'package:lamarlog/core/services/update_check_service.dart';
import 'package:lamarlog/features/settings/presentation/pages/about_page.dart';

class _DirectHttpOverrides extends HttpOverrides {}

void main() {
  group('UpdateCheckService', () {
    test('compares SemVer tags accurately including v-prefix and prereleases', () {
      expect(UpdateCheckService.isNewerVersion('v1.4.0', '1.3.1'), isTrue);
      expect(UpdateCheckService.isNewerVersion('1.3.2', '1.3.1'), isTrue);
      expect(UpdateCheckService.isNewerVersion('2.0.0', '1.9.9'), isTrue);
      expect(UpdateCheckService.isNewerVersion('1.3.1', '1.3.1'), isFalse);
      expect(UpdateCheckService.isNewerVersion('v1.3.1+5', '1.3.1'), isFalse);
      expect(UpdateCheckService.isNewerVersion('1.3.0', '1.3.1'), isFalse);
      expect(UpdateCheckService.isNewerVersion('1.4.0', '1.4.0-beta.1'), isTrue);
      expect(
        UpdateCheckService.isNewerVersion('1.4.0-beta.1', '1.4.0'),
        isFalse,
      );
      expect(UpdateCheckService.compareVersions('1.4', '1.4.0'), 0);
    });

    test('resolves endpoint from explicit override or REPORT_ENDPOINT origin', () {
      final derived = UpdateCheckService.resolveEndpoint(
        reportEndpointOverride:
            'https://lamarlog-report-worker.example.workers.dev/report',
      );
      expect(
        derived.toString(),
        'https://lamarlog-report-worker.example.workers.dev/latest-release',
      );

      final explicit = UpdateCheckService.resolveEndpoint(
        endpointOverride: 'https://custom.workers.dev/release',
        reportEndpointOverride: 'https://ignored.workers.dev/report',
      );
      expect(explicit.toString(), 'https://custom.workers.dev/release');

      expect(
        UpdateCheckService.resolveEndpoint(endpointOverride: ''),
        isNull,
      );
    });

    test('returns notConfigured when no endpoint is supplied', () async {
      final result = await UpdateCheckService.instance.checkForUpdate(
        endpointOverride: '',
      );
      expect(result.status, UpdateCheckStatus.notConfigured);
      expect(result.hasUpdate, isFalse);
    });

    test('parses worker response for updateAvailable, upToDate, and serverError',
        () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        late int statusCode;
        late Map<String, dynamic> payload;

        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => server.close(force: true));

        server.listen((req) {
          req.response.statusCode = statusCode;
          req.response.headers.contentType = ContentType.json;
          req.response.write(jsonEncode(payload));
          req.response.close();
        });

        final endpoint = 'http://127.0.0.1:${server.port}/latest-release';

        // 1. Newer release available
        statusCode = 200;
        payload = {
          'ok': true,
          'tagName': 'v1.4.0',
          'version': '1.4.0',
          'name': 'LamarLog v1.4.0',
          'body': '- Added update checker via worker',
          'htmlUrl': 'https://github.com/herdysh30/LamarLog/releases/tag/v1.4.0',
          'publishedAt': '2026-11-27T08:00:00Z',
          'apkUrl':
              'https://github.com/herdysh30/LamarLog/releases/download/v1.4.0/LamarLog-v1.4.0-arm64-v8a.apk',
          'universalApkUrl':
              'https://github.com/herdysh30/LamarLog/releases/download/v1.4.0/LamarLog-v1.4.0-universal.apk',
        };

        final updateRes = await UpdateCheckService.instance.checkForUpdate(
          endpointOverride: endpoint,
          currentVersionOverride: '1.3.1',
        );
        expect(updateRes.status, UpdateCheckStatus.updateAvailable);
        expect(updateRes.hasUpdate, isTrue);
        expect(updateRes.release!.version, '1.4.0');
        expect(
          updateRes.release!.preferredDownloadUri.toString(),
          contains('arm64-v8a.apk'),
        );

        // 2. Already up to date
        final upToDateRes = await UpdateCheckService.instance.checkForUpdate(
          endpointOverride: endpoint,
          currentVersionOverride: '1.4.0',
        );
        expect(upToDateRes.status, UpdateCheckStatus.upToDate);
        expect(upToDateRes.hasUpdate, isFalse);

        // 3. Upstream error
        statusCode = 502;
        payload = {'ok': false, 'error': 'GitHub API error'};
        final errRes = await UpdateCheckService.instance.checkForUpdate(
          endpointOverride: endpoint,
          currentVersionOverride: '1.3.1',
        );
        expect(errRes.status, UpdateCheckStatus.serverError);
        expect(errRes.errorDetail, 'HTTP 502');
      }, _DirectHttpOverrides());
    });
  });

  group('AboutPage Check Updates UI', () {
    testWidgets('shows update sheet when newer release is returned',
        (tester) async {
      await tester.pumpWidget(
        AppLocaleScope(
          strings: const AppStrings('id'),
          child: MaterialApp(
            home: AboutPage(
              checkUpdateOverride: () async => UpdateCheckResult(
                status: UpdateCheckStatus.updateAvailable,
                currentVersion: '1.3.1',
                release: ReleaseInfo(
                  tagName: 'v1.4.0',
                  version: '1.4.0',
                  name: 'LamarLog v1.4.0',
                  body: 'Perbaikan performa dan fitur cek pembaruan.',
                  htmlUri: Uri.parse(
                    'https://github.com/herdysh30/LamarLog/releases/tag/v1.4.0',
                  ),
                  apkUri: Uri.parse(
                    'https://github.com/herdysh30/LamarLog/releases/download/v1.4.0/LamarLog-v1.4.0-arm64-v8a.apk',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final checkTile = find.text('Periksa Pembaruan');
      await tester.scrollUntilVisible(checkTile, 200);
      await tester.ensureVisible(checkTile);
      await tester.pumpAndSettle();
      await tester.tap(checkTile);
      await tester.pumpAndSettle();

      expect(find.text('Pembaruan Tersedia'), findsOneWidget);
      expect(find.text('Unduh APK'), findsOneWidget);
      expect(find.text('Lihat di GitHub'), findsOneWidget);
    });
  });
}
