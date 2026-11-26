/**
 * LamarLog Anonymous Bug/Crash Report Proxy (Cloudflare Worker)
 *
 * Accepts sanitized crash/bug reports from the LamarLog mobile app and
 * creates GitHub Issues on `GITHUB_OWNER/GITHUB_REPO` using a server-side
 * Fine-Grained Personal Access Token stored in `env.GITHUB_TOKEN`.
 *
 * End users do NOT need a GitHub account, and no secret ever touches the APK.
 */

const MAX_BODY_BYTES = 16 * 1024; // 16 KB max payload
const RATE_LIMIT_MAX = 5; // max 5 reports per IP
const RATE_LIMIT_WINDOW_MS = 15 * 60 * 1000; // per 15 minutes
const RELEASE_CACHE_TTL_SEC = 300; // 5 minutes edge cache for GitHub Releases

// Lightweight per-isolate rate limiter (effective against burst spam)
const ipHits = new Map();

function jsonResponse(data, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
      ...extraHeaders,
    },
  });
}

function pickApkAsset(assets, pattern) {
  if (!Array.isArray(assets)) return null;
  const match = assets.find(
    (a) =>
      typeof a?.name === 'string' &&
      typeof a?.browser_download_url === 'string' &&
      pattern.test(a.name)
  );
  return match ? match.browser_download_url : null;
}

async function handleLatestRelease(request, env, ctx) {
  if (!env.GITHUB_OWNER || !env.GITHUB_REPO) {
    return jsonResponse(
      { ok: false, error: 'Server missing GitHub configuration' },
      500
    );
  }

  const cache = caches.default;
  const cacheKey = new Request(
    `${new URL(request.url).origin}/latest-release`,
    { method: 'GET' }
  );
  const cached = await cache.match(cacheKey);
  if (cached) return cached;

  const ghUrl = `https://api.github.com/repos/${env.GITHUB_OWNER}/${env.GITHUB_REPO}/releases/latest`;
  const baseHeaders = {
    Accept: 'application/vnd.github+json',
    'User-Agent': 'LamarLog-Worker/1.1',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  let ghRes = await fetch(ghUrl, {
    method: 'GET',
    headers: env.GITHUB_TOKEN
      ? { ...baseHeaders, Authorization: `Bearer ${env.GITHUB_TOKEN}` }
      : baseHeaders,
  });

  // Fallback to unauthenticated public request if token only has Issues scope
  if (env.GITHUB_TOKEN && (ghRes.status === 401 || ghRes.status === 403)) {
    ghRes = await fetch(ghUrl, { method: 'GET', headers: baseHeaders });
  }

  if (ghRes.status === 404) {
    return jsonResponse({ ok: false, error: 'No published release found' }, 404);
  }

  if (!ghRes.ok) {
    return jsonResponse(
      { ok: false, error: `GitHub API rejected request (${ghRes.status})` },
      502
    );
  }

  const release = await ghRes.json();
  const tagName = clip(release.tag_name, 64);
  const version = tagName.replace(/^v/i, '');
  const assets = Array.isArray(release.assets) ? release.assets : [];
  const apkUrl =
    pickApkAsset(assets, /arm64-v8a.*\.apk$/i) ||
    pickApkAsset(assets, /\.apk$/i);
  const universalApkUrl = pickApkAsset(assets, /universal.*\.apk$/i);

  const response = jsonResponse(
    {
      ok: true,
      tagName,
      version,
      name: clip(release.name, 120) || tagName,
      body: clip(release.body, 2000),
      htmlUrl: clip(release.html_url, 512),
      publishedAt: clip(release.published_at, 48),
      apkUrl,
      universalApkUrl,
    },
    200,
    { 'Cache-Control': `public, max-age=${RELEASE_CACHE_TTL_SEC}` }
  );

  if (ctx && typeof ctx.waitUntil === 'function') {
    ctx.waitUntil(cache.put(cacheKey, response.clone()));
  }
  return response;
}

function isRateLimited(ip) {
  const now = Date.now();
  const recent = (ipHits.get(ip) || []).filter(
    (ts) => now - ts < RATE_LIMIT_WINDOW_MS
  );
  if (recent.length >= RATE_LIMIT_MAX) {
    ipHits.set(ip, recent);
    return true;
  }
  recent.push(now);
  ipHits.set(ip, recent);
  return false;
}

function clip(value, maxLen) {
  if (typeof value !== 'string') return '';
  const trimmed = value.trim();
  return trimmed.length > maxLen ? `${trimmed.slice(0, maxLen)}...` : trimmed;
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (request.method === 'GET' && url.pathname === '/health') {
      return jsonResponse({ ok: true, service: 'lamarlog-report-worker' });
    }

    if (request.method === 'GET' && url.pathname === '/latest-release') {
      return handleLatestRelease(request, env, ctx);
    }

    if (request.method !== 'POST' || url.pathname !== '/report') {
      return jsonResponse({ ok: false, error: 'Not found' }, 404);
    }

    if (!env.GITHUB_TOKEN || !env.GITHUB_OWNER || !env.GITHUB_REPO) {
      return jsonResponse(
        { ok: false, error: 'Server missing GitHub configuration' },
        500
      );
    }

    const clientHeader = request.headers.get('X-App-Client') || '';
    if (
      !clientHeader.startsWith('LamarLog/') &&
      !clientHeader.startsWith('ApplyFlow/')
    ) {
      return jsonResponse({ ok: false, error: 'Invalid client header' }, 400);
    }

    const clientIp =
      request.headers.get('CF-Connecting-IP') ||
      request.headers.get('X-Forwarded-For') ||
      'unknown';

    if (isRateLimited(clientIp)) {
      return jsonResponse(
        { ok: false, error: 'Too many reports. Please try again later.' },
        429
      );
    }

    const rawBody = await request.text();
    if (!rawBody || rawBody.length > MAX_BODY_BYTES) {
      return jsonResponse({ ok: false, error: 'Invalid payload size' }, 413);
    }

    let payload;
    try {
      payload = JSON.parse(rawBody);
    } catch {
      return jsonResponse({ ok: false, error: 'Malformed JSON' }, 400);
    }

    const title = clip(payload.title, 120) || '[Bug] Anonymous App Report';
    const appVersion = clip(payload.appVersion, 32) || 'unknown';
    const platform = clip(payload.platform, 32) || 'unknown';
    const osVersion = clip(payload.osVersion, 120) || 'unknown';
    const locale = clip(payload.locale, 16) || 'unknown';
    const occurredAtUtc =
      clip(payload.occurredAtUtc, 48) || new Date().toISOString();
    const userNote = clip(payload.userNote, 800);
    const errorMessage = clip(payload.errorMessage, 1000);
    const stackTrace = clip(payload.stackTrace, 3000);

    if (!errorMessage && !userNote) {
      return jsonResponse(
        { ok: false, error: 'Report must contain errorMessage or userNote' },
        400
      );
    }

    const issueBody = [
      '### User Note',
      userNote || '_No additional note provided._',
      '',
      '### Environment',
      `- **App Version:** \`v${appVersion}\``,
      `- **Platform:** \`${platform}\``,
      `- **OS:** \`${osVersion}\``,
      `- **Locale:** \`${locale}\``,
      `- **Timestamp (UTC):** \`${occurredAtUtc}\``,
      '',
      '### Error Summary',
      '```text',
      errorMessage || 'N/A',
      '```',
      ...(stackTrace
        ? ['', '### Stack Trace', '```text', stackTrace, '```']
        : []),
      '',
      '---',
      '_Submitted anonymously from LamarLog via Cloudflare Worker proxy._',
    ].join('\n');

    const ghUrl = `https://api.github.com/repos/${env.GITHUB_OWNER}/${env.GITHUB_REPO}/issues`;
    const ghRes = await fetch(ghUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        Accept: 'application/vnd.github+json',
        'Content-Type': 'application/json',
        'User-Agent': 'LamarLog-Report-Worker/1.0',
        'X-GitHub-Api-Version': '2022-11-28',
      },
      body: JSON.stringify({
        title,
        body: issueBody,
        labels: ['bug', 'user-report'],
      }),
    });

    if (!ghRes.ok) {
      return jsonResponse(
        { ok: false, error: `GitHub API rejected request (${ghRes.status})` },
        502
      );
    }

    const created = await ghRes.json();
    return jsonResponse(
      {
        ok: true,
        issueNumber: created.number,
        issueUrl: created.html_url,
      },
      201
    );
  },
};
