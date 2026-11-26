# AGENTS.md — LamarLog (Flutter Job Application Tracker)

## 1. Project Overview
* **App Name:** LamarLog
* **Source of Truth:** [PRD.md](PRD.md) (v2.0.0) & [DESIGN.md](DESIGN.md)
* **Stack:** Flutter 3.24+ / Dart 3.5+, `flutter_bloc` (v8.x), `drift` (SQLite), `flutter_local_notifications`, `flutter_pdfview`, `file_picker`.
* **Architecture:** Clean Architecture + Feature-First (`lib/app/`, `lib/core/`, `lib/features/`).

---

## 2. Skill Utilization Guidelines

Maximize the installed skills according to the phase of work:

### A. `superpowers` (Engineering Workflow & Quality)
Use `superpowers` discipline for all non-trivial feature work:
* **Before coding:** Clarify requirements against `PRD.md`, design the module/schema, and break work into small, testable tasks.
* **During implementation:** Follow TDD where applicable (write unit tests for BLoC, Drift DAOs, and metric calculations before or alongside implementation).
* **Debugging:** Use systematic root-cause analysis—never guess-and-patch.
* **Before claiming done:** Run `flutter analyze` and `flutter test` to verify zero errors and passing tests.

### B. `impeccable` (UI Craft, UX & Accessibility)
Use `impeccable` principles whenever building or refining screens and widgets:
* **Visual Hierarchy & Polish:** Ensure clean spacing, clear typography, and purposeful use of color for status badges and priority tags (`High`, `Medium`, `Low`).
* **States & Edge Cases:** Always design and implement **empty states** (with clear CTAs), **loading states**, **error states**, and **destructive action confirmations** (e.g., delete application, restore overwrite).
* **Accessibility & Responsiveness:** Enforce minimum `48x48 dp` touch targets, semantic labels, WCAG AA contrast in both **Light & Dark Mode**, and test layouts from `360dp` width phones up to tablets.

### C. `ui-ux-pro-max-skill` (Design System & Mobile Patterns)
Use `ui-ux-pro-max-skill` when establishing or auditing the app's design system:
* Maintain consistent Material 3 tokens (color scheme, typography scale, elevation, border radius).
* Optimize mobile-first interactions: smooth `LongPressDraggable` / `DragTarget` Kanban board, non-drag status-change fallback in detail view, and thumb-friendly bottom sheets/navigation.

---

## 3. Non-Negotiable Architecture & Data Rules
1. **Pipeline Separation:** Keep active stages (`wishlist`, `applied`, `screening`, `interview`, `offering`) strictly separate from terminal outcomes (`offer_accepted`, `offer_declined`, `rejected`, `withdrawn`, `no_response`).
2. **Metrics via History:** Never compute analytics from `currentStatus` alone. Always record and query `STATUS_TRANSITION` rows.
3. **Timestamps:** Store all `DateTime` values in **UTC** in Drift; convert to local timezone only in the presentation layer.
4. **PDF Attachments:** Copy picked PDFs into `getApplicationDocumentsDirectory()/resumes/` (max 10 MB, 1 active PDF per application in MVP) and handle missing-file states gracefully.
5. **Notifications:** Implement all fallback rules (scheduled < 24h, < 1h, permission denied, cancel old IDs on edit/delete).
6. **Privacy:** Keep `android:allowBackup="false"` and warn users before exporting/restoring plain JSON backups.

---

## 4. Verification Checklist
Before finishing any task:
- [ ] `flutter analyze` passes with 0 issues.
- [ ] `flutter test` passes for all unit/widget tests.
- [ ] Both Light and Dark themes render with proper contrast.
- [ ] Changes align with MVP v1.0 scope in `PRD.md`.
