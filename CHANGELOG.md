# Changelog

All notable changes to **ApplyFlow** are documented in this file.

## [1.1.0] - 2026-11-26

### Added
- **Offline Indonesia Regions Autocomplete (up to Kecamatan):** Bundled Kemendagri dataset covering all 38 provinces, 514 cities/regencies, and 7,285 districts + 16 global hubs (~103 KB, 100% offline), with one-tap Google Maps navigation from Application Detail.
- **Customizable Pipeline Stages (1–12 stages):** Add, rename, recolor (8 indicator colors), reorder, delete (with safe card migration + transition logging), or reset Kanban stages from Settings or directly from the Pipeline board.
- **Inline Stage Color Picker:** Tap any Kanban column header to edit both the stage title and indicator color directly.
- **About ApplyFlow Page:** Accessible from Settings with app branding, core privacy highlights, GitHub links, and Open-Source Licenses viewer.
- **Anonymous Bug / Crash Reporting (Auto GitHub Issues):** Global error capture (`CrashReportService`), privacy-first preview dialog (`SendReportDialog`), Cloudflare Worker proxy (`tools/report-worker/`) so users can submit reports without a GitHub account, plus GitHub URL & Copy fallbacks.
- **Comprehensive Error Handling:** Global `FlutterError`/`PlatformDispatcher` boundaries, `ErrorStateCard` with Retry + Send Report across Pipeline, Notifications, Analytics, and Detail, BLoC CRUD `try/catch` with centralized SnackBar listener, OEM-safe notification scheduling (`ReminderStatus.scheduleFailed`), and past-date interview validation.
- **Material 3 Motion & Tactile Polish:** Shared `AppMotion` system respecting system Reduce Motion, `FadeThroughIndexedStack` tab transitions, `Hero` monogram continuity, `PressableScale` card feedback, `AnimatedSwitcher` view switches, `PredictiveBackPageTransitionsBuilder`, and tactile haptics.

### Fixed
- Resolved missing native `libsqlite3.so` in incremental debug builds and prevented infinite loading on database stream errors.
- Pinned Flutter `3.41.9` in CI & Release workflows for deterministic builds.

## [1.0.0] - 2026-11-26

### Added
- Initial offline-first ApplyFlow release with Kanban/List Pipeline, Application Platform tracking, clickable recruiter contacts (Email/Phone/WhatsApp/URL), stale follow-up alerts (≥14 days), private PDF resume attachments, interview reminders (24h/1h), `StatusTransition` funnel analytics, JSON backup/restore, CSV export, Light/Dark mode + 5 color palettes, EN/ID localization, and responsive phone/tablet layouts.
