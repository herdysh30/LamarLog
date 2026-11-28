# Changelog

All notable changes to **LamarLog** (formerly ApplyFlow) are documented in this file.

## [1.3.4] - 2026-11-28

### Fixed
- **Application Form Body Collapsed Behind Sticky Footer:** Replaced `ResponsiveCenter` (`Align` without `heightFactor`) inside `ApplicationFormPage`'s `Scaffold.bottomNavigationBar` with `Align(alignment: Alignment.topCenter, heightFactor: 1.0, ...)` so the sticky `Cancel`/`Save Application` footer keeps its intrinsic height and no longer collapses the form body.
- **Priority Tile Narrow-Screen Overflow:** Wrapped priority label text in `Flexible` inside `FormWorkAndStatusSection` to prevent a `3.9px` horizontal overflow on compact mobile screens and updated muted sublabel contrast tokens.

## [1.3.3] - 2026-11-28

### Fixed
- **Persistent Android Release Signing:** Configured `signingConfigs.release` in `android/app/build.gradle.kts` and keystore decoding from GitHub Secrets in `.github/workflows/release.yml` so future APK releases share the same signing certificate and install in-place without package signature conflicts.

## [1.3.2] - 2026-11-28

### Added
- **Single-Tap Card Quick Move (`Pindah ⌄`):** Added a non-drag status transition chip directly on active application cards (`ApplicationCard`) in Kanban and List views for WCAG 2.2 AA accessibility.
- **Collapsible Optional Form Fields:** Grouped source platform, vacancy URL, and recruiter contact inside an expandable section in `FormCompensationSection` (auto-expanded when editing or populated) to reduce initial form overwhelm.
- **FigCraft UI/UX Design Spec & Rule:** Added `lamarlog_design.figcraft` (Design System, Light/Dark core screens, and sub-screens) and `.agents/rules/lamarlog-figcraft-design.md`.

### Changed
- **Compact Pipeline Header & Clear FAB Gutter:** Moved the Terminal Archive pill (`Arsip`) to the top AppBar, switched the mobile Kanban/List toggle to an icon-only segmented control, slimmed the stale follow-up banner to a single row, removed the redundant bottom summary strip, and adjusted FAB clearance so cards are never obscured.
- **Mobile Text Capacity & Full-Width Role Titles:** Moved `roleTitle` below the company header row on `ApplicationCard` to prevent narrow Kanban column truncation, bumped readable metadata/sub-KPI text to a `12px` floor (`11px` minimum for pills/badges), and converted `AnalyticsVelocityCard` from 3 narrow tiles to full-width vertical velocity rows.
- **Sticky Form Footer & Slim Notification Banner:** Pinned `Batal` (`48dp`) and `Simpan Lamaran` (`52dp`) to `Scaffold.bottomNavigationBar` in `ApplicationFormPage`, and compacted the notification permission warning banner with a responsive layout fallback down to `320dp` and `1.3x` font scaling.
- **WCAG AA Muted Text Tokens:** Added `AppColors.mutedTextLight` (`#5A596B`) and `AppColors.mutedTextDark` (`#94A3B8`) to ensure `>= 4.5:1` contrast for secondary captions and hints across Light and Dark themes.

## [1.3.1] - 2026-11-26

### Added
- **In-App Update Checker (via Cloudflare Worker):** Added **Check for Updates** in About LamarLog (`UpdateCheckService` + `GET /latest-release` edge-cached route on `lamarlog-report-worker`) to check GitHub Releases, compare SemVer tags, preview release notes, and open direct APK downloads with GitHub fallback.

### Fixed
- **Duplicate Hero Tag Crash on Navigation:** Added unique `heroTag` values to the Pipeline and Notifications FABs inside `FadeThroughIndexedStack` so pushing routes from any tab no longer triggers a duplicate Hero tag error.
- **Analytics Wishlist Revert Accuracy:** Moving an application from Wishlist to Applied and back to Wishlist no longer counts reverted transitions as Applied, and resets `appliedAt` cleanly.
- **Landscape Kanban Overflow & Compact Sidebar Layout:** Moved the LamarLog brand mark to the top of the side `NavigationRail` in landscape/tablet layouts, removed the duplicate top AppBar, compacted the Pipeline toolbar into a single responsive row, and made Kanban columns overflow-proof across narrow, landscape, and large-font viewports.
- **Immediate Persist on Add Stage:** Saving in the Add Stage dialog now immediately persists the new stage without requiring a second Save in Manage Pipeline Stages (keeping Manage Save dedicated to rename, recolor, reorder, and delete).
- **Zero-Overflow Hardening:** Fixed layout overflows across application cards, detail/form headers, settings sub-pages, onboarding, filter/archive/reminder sheets, and interview/note dialogs (verified across 9 portrait, landscape, tablet, and large-font viewports).

## [1.3.0] - 2026-11-26

### Added
- **Customizable Automatic Interview Reminders:** Configure up to 2 automatic reminder slots (5 minutes to 7 days before interviews, presets + custom minutes/hours/days input, per-slot ON/OFF toggles, and one-tap Reset Default) in Notification Settings, with automatic rescheduling of upcoming interviews.
- **Multi-page Settings Hub & Permission Recovery:** Reorganized Settings into clean category sub-pages (Appearance & Language, Pipeline Stages, Notifications & Reminders, Data & Backup, About) and added a recovery flow when OS notification permission is denied.

### Changed
- **Codebase Modularization:** Split oversized pages and BLoC (`ApplicationDetailPage`, `PipelinePage`, `ApplicationFormPage`, `NotificationsPage`, `DataBackupSettingsPage`, `AnalyticsPage`, `ApplicationsBloc`) into cohesive feature widgets, `BackupService`, BLoC `part` files, and a shared `showScheduleInterviewDialog`.

## [1.2.0] - 2026-11-26

### Changed
- **Full Rebrand to LamarLog:** Renamed the app, launcher labels (Android & iOS), AppBar, Onboarding, About page, release APKs (`LamarLog-*.apk`), and JSON/CSV export filenames from ApplyFlow to **LamarLog**.
- **Clean Package & Storage Migration:** Migrated Dart package (`lamarlog`), Android `applicationId`/`namespace` & iOS bundle identifier (`com.lamarlog.lamarlog`), SQLite database (`lamarlog.sqlite`), and local `SharedPreferences` keys (`lamarlog_*`).
- **Repository & Bug Report Worker Update:** Updated GitHub repository links to `herdysh30/LamarLog`, updated Cloudflare Worker proxy (`lamarlog-report-worker`), and ignored `.wrangler/` local cache files.

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
