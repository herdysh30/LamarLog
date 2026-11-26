import 'dart:convert';
import 'dart:io';

import 'crash_report_service.dart';

class ReleaseInfo {
  const ReleaseInfo({
    required this.tagName,
    required this.version,
    required this.name,
    required this.body,
    required this.htmlUri,
    this.publishedAtUtc,
    this.apkUri,
    this.universalApkUri,
  });

  final String tagName;
  final String version;
  final String name;
  final String body;
  final Uri htmlUri;
  final DateTime? publishedAtUtc;
  final Uri? apkUri;
  final Uri? universalApkUri;

  /// Prefers direct APK asset download, falling back to the GitHub Release page.
  Uri get preferredDownloadUri => apkUri ?? universalApkUri ?? htmlUri;
}

enum UpdateCheckStatus {
  upToDate,
  updateAvailable,
  notConfigured,
  networkError,
  serverError,
}

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.status,
    required this.currentVersion,
    this.release,
    this.errorDetail,
  });

  final UpdateCheckStatus status;
  final String currentVersion;
  final ReleaseInfo? release;
  final String? errorDetail;

  bool get hasUpdate =>
      status == UpdateCheckStatus.updateAvailable && release != null;
}

/// Checks GitHub Releases via the LamarLog Cloudflare Worker (`/latest-release`)
/// so end-user devices stay protected from GitHub's unauthenticated rate limits.
class UpdateCheckService {
  UpdateCheckService._();

  static final UpdateCheckService instance = UpdateCheckService._();

  // ponytail: reads static app version constant; switch to package_info_plus if
  // build-time --build-name overrides ever diverge from pubspec.yaml.
  static const String currentVersion = CrashReportService.appVersion;

  static const String configuredEndpoint = String.fromEnvironment(
    'UPDATE_ENDPOINT',
    defaultValue: '',
  );

  static Uri? _parseHttpUri(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    return uri;
  }

  static Uri? _parseHttpsUri(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.host.isEmpty || uri.scheme != 'https') return null;
    return uri;
  }

  /// Resolves the Worker release endpoint in priority order:
  /// 1. Explicit [endpointOverride]
  /// 2. `--dart-define=UPDATE_ENDPOINT=...`
  /// 3. Same-origin `/latest-release` derived from `REPORT_ENDPOINT`
  static Uri? resolveEndpoint({
    String? endpointOverride,
    String? reportEndpointOverride,
  }) {
    if (endpointOverride != null) {
      return _parseHttpUri(endpointOverride);
    }

    final explicit = _parseHttpUri(configuredEndpoint);
    if (explicit != null) return explicit;

    final reportBase = _parseHttpUri(
      reportEndpointOverride ?? CrashReportService.configuredEndpoint,
    );
    if (reportBase == null) return null;

    return Uri(
      scheme: reportBase.scheme,
      host: reportBase.host,
      port: reportBase.hasPort ? reportBase.port : null,
      path: '/latest-release',
    );
  }

  /// Compares two SemVer strings (handles optional leading `v`, `+build`, and `-prerelease`).
  /// Returns positive if [a] > [b], negative if [a] < [b], and 0 if equal.
  static int compareVersions(String a, String b) {
    final pa = _ParsedSemVer.parse(a);
    final pb = _ParsedSemVer.parse(b);

    final maxCore =
        pa.core.length > pb.core.length ? pa.core.length : pb.core.length;
    for (var i = 0; i < maxCore; i++) {
      final va = i < pa.core.length ? pa.core[i] : 0;
      final vb = i < pb.core.length ? pb.core[i] : 0;
      if (va != vb) return va.compareTo(vb);
    }

    if (pa.preRelease.isEmpty && pb.preRelease.isEmpty) return 0;
    if (pa.preRelease.isEmpty) return 1; // Stable > pre-release
    if (pb.preRelease.isEmpty) return -1;

    final maxPre = pa.preRelease.length > pb.preRelease.length
        ? pa.preRelease.length
        : pb.preRelease.length;
    for (var i = 0; i < maxPre; i++) {
      if (i >= pa.preRelease.length) return -1;
      if (i >= pb.preRelease.length) return 1;
      final sa = pa.preRelease[i];
      final sb = pb.preRelease[i];
      final na = int.tryParse(sa);
      final nb = int.tryParse(sb);
      if (na != null && nb != null) {
        if (na != nb) return na.compareTo(nb);
      } else if (na != null) {
        return -1;
      } else if (nb != null) {
        return 1;
      } else {
        final cmp = sa.compareTo(sb);
        if (cmp != 0) return cmp;
      }
    }
    return 0;
  }

  static bool isNewerVersion(String remote, String current) =>
      compareVersions(remote, current) > 0;

  Future<UpdateCheckResult> checkForUpdate({
    String? endpointOverride,
    String? reportEndpointOverride,
    String? currentVersionOverride,
  }) async {
    final installed = (currentVersionOverride ?? currentVersion).trim();
    final uri = resolveEndpoint(
      endpointOverride: endpointOverride,
      reportEndpointOverride: reportEndpointOverride,
    );
    if (uri == null) {
      return UpdateCheckResult(
        status: UpdateCheckStatus.notConfigured,
        currentVersion: installed,
      );
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.set('X-App-Client', 'LamarLog/$installed');

      final res = await req.close().timeout(const Duration(seconds: 12));
      final bodyText = await res.transform(utf8.decoder).join();

      if (res.statusCode != 200) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.serverError,
          currentVersion: installed,
          errorDetail: 'HTTP ${res.statusCode}',
        );
      }

      final json = jsonDecode(bodyText);
      if (json is! Map<String, dynamic>) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.serverError,
          currentVersion: installed,
          errorDetail: 'Invalid response format',
        );
      }

      final tagName = (json['tagName'] as String? ?? '').trim();
      final version = (json['version'] as String? ?? tagName)
          .trim()
          .replaceFirst(RegExp(r'^[vV]'), '');
      final htmlUri = _parseHttpsUri(json['htmlUrl']) ??
          Uri.parse(
            'https://github.com/${CrashReportService.githubOwner}/${CrashReportService.githubRepo}/releases',
          );

      if (version.isEmpty) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.serverError,
          currentVersion: installed,
          errorDetail: 'Missing release version',
        );
      }

      final release = ReleaseInfo(
        tagName: tagName.isNotEmpty ? tagName : 'v$version',
        version: version,
        name: ((json['name'] as String?) ?? '').trim().isNotEmpty
            ? (json['name'] as String).trim()
            : 'LamarLog v$version',
        body: ((json['body'] as String?) ?? '').trim(),
        htmlUri: htmlUri,
        publishedAtUtc: json['publishedAt'] is String
            ? DateTime.tryParse(json['publishedAt'] as String)?.toUtc()
            : null,
        apkUri: _parseHttpsUri(json['apkUrl']),
        universalApkUri: _parseHttpsUri(json['universalApkUrl']),
      );

      final hasUpdate = isNewerVersion(release.version, installed);
      return UpdateCheckResult(
        status: hasUpdate
            ? UpdateCheckStatus.updateAvailable
            : UpdateCheckStatus.upToDate,
        currentVersion: installed,
        release: release,
      );
    } on SocketException catch (e) {
      return UpdateCheckResult(
        status: UpdateCheckStatus.networkError,
        currentVersion: installed,
        errorDetail: e.message,
      );
    } catch (e) {
      return UpdateCheckResult(
        status: UpdateCheckStatus.networkError,
        currentVersion: installed,
        errorDetail: e.toString(),
      );
    } finally {
      client.close(force: true);
    }
  }
}

class _ParsedSemVer {
  const _ParsedSemVer(this.core, this.preRelease);

  final List<int> core;
  final List<String> preRelease;

  static _ParsedSemVer parse(String raw) {
    var cleaned = raw.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final plusIdx = cleaned.indexOf('+');
    if (plusIdx >= 0) cleaned = cleaned.substring(0, plusIdx);

    String corePart = cleaned;
    List<String> pre = const [];
    final dashIdx = cleaned.indexOf('-');
    if (dashIdx >= 0) {
      corePart = cleaned.substring(0, dashIdx);
      final preStr = cleaned.substring(dashIdx + 1).trim();
      if (preStr.isNotEmpty) {
        pre = preStr.split('.');
      }
    }

    final coreNums = corePart
        .split('.')
        .map((seg) => int.tryParse(seg.trim()) ?? 0)
        .toList(growable: false);
    return _ParsedSemVer(coreNums, pre);
  }
}
