# LamarLog

**LamarLog** is an offline-first mobile job application tracker built with Flutter. Manage your career pipeline on a Kanban board or list view, log interview schedules with local reminders, attach tailored PDF resumes privately on-device, and track conversion analytics from full status history.

## Features

- **Customizable Kanban & List Pipeline:** Drag-and-drop Kanban board (`LongPressDraggable` / `DragTarget`) where you can add, rename, recolor, reorder, or remove active stages (1–12 stages), plus a responsive list/grid view, search (including application platform), filters, sorting, and a dedicated Terminal Archive for completed outcomes (`Offer Accepted`, `Offer Declined`, `Rejected`, `Withdrawn`, `No Response`).
- **Offline Indonesia Region Autocomplete & Maps:** Bundled Kemendagri dataset covering all 38 provinces, 514 cities/regencies, and 7,285 districts (Kecamatan) + global remote hubs (~103 KB, 100% offline), with one-tap Google Maps navigation from the detail screen.
- **Application Detail & Timeline:** Full status picker, quick metrics (expected/offered compensation, location, recruiter contact with direct actions), private PDF resume attachment (max 10 MB with built-in preview), and a chronological vertical timeline with manual notes.
- **Interview Reminders:** Schedule local notifications with automatic 24-hour and 1-hour reminders (including smart fallback rules when scheduled <24h or <1h away) and a dedicated Reminders tab with countdown badges.
- **Funnel Analytics:** Real-time conversion rates, active pipeline breakdown, stage velocity, and actionable insights calculated directly from immutable `StatusTransition` history records.
- **Offline-First & Private by Design:** All applications, notes, schedules, and PDF files are stored locally on your device (`android:allowBackup="false"`). Export/import full JSON backups or export CSV spreadsheets anytime.
- **Personalization & Responsive UI:** Material 3 Light & Dark themes, 5 color palettes (`Indigo`, `Emerald`, `Ocean`, `Amber`, `Rose`), bilingual UI (`English` & `Bahasa Indonesia`), IDR/USD currency formatting, and adaptive phone/tablet navigation (`NavigationBar` / `NavigationRail`).

## Tech Stack

- **Framework:** Flutter 3.24+ / Dart 3.5+
- **State Management:** `flutter_bloc` + `equatable`
- **Local Database:** `drift` (SQLite)
- **Preferences:** `shared_preferences`
- **Notifications:** `flutter_local_notifications` + `timezone`
- **Files & PDF:** `file_picker` + `flutter_pdfview` + `path_provider`
- **Typography:** `google_fonts` (`Plus Jakarta Sans` & `Inter`)

## Architecture

Feature-first Clean Architecture:

```text
lib/
├── app/            # App shell, adaptive navigation, Material 3 theme & palettes
├── core/           # Drift database, enums, l10n, responsive layout, services, shared widgets
└── features/
    ├── analytics/      # StatusTransition-based funnel & velocity metrics
    ├── applications/   # Pipeline (Kanban/List), Form, Detail, PDF preview, BLoC
    ├── onboarding/     # First-run onboarding flow
    ├── reminders/      # Upcoming & past interview schedules
    └── settings/       # Appearance, language, currency, Kanban customization, backup/export
```

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

## Documentation

- [PRD.md](PRD.md) — Product Requirements Document (v2.0.0)
- [DESIGN.md](DESIGN.md) — Design system tokens, typography, and component guidelines
