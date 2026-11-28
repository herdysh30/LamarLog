---
trigger: model_decision
description: LamarLog v2.1 UI/UX design tokens, WCAG AA contrast rules, mobile screen layout specs, and FigCraft MCP conventions. Activate when designing, editing, or auditing LamarLog screens in FigCraft or syncing FigCraft specs to Flutter.
---

# LamarLog UI/UX & FigCraft Rules (v2.1)

## 1. Canvas & Frame Grid
- **Mobile frame:** `390×844` (`cornerRadius: 28`, `clip: true`), spaced horizontally by `440px` (`x = 0, 440, 880, 1320, 1760, 2200`), vertical row gap `900px` (`y = 56, 956`).
- **Screen titles:** `Inter` `15px` Bold `#131B2E`, placed `34px` above frame (`y = 22` / `y = 922`).
- **Touch targets:** Minimum `48dp` height on every interactive control (`52px` primary CTA, `48px` secondary buttons / status selector bars / sheet rows, `42–48px` search/filter actions with `48dp` hit area).

## 2. Color Tokens (WCAG AA Verified)
### Light Mode (`02 · Core Screens (Light)`)
- **Surfaces:** Canvas `#FAF8FF`, Card `#FFFFFF`, Surface Low `#F2F3FF`, Container `#EAEDFF`, Container High `#E2E7FF`, Hairline `#E2E7FF` / `#C7C4D8` (borders only).
- **Text:** Primary `#131B2E` (17.16:1), Secondary `#464555` (9.36:1), **Muted AA `#5A596B` (6.83:1 on `#FFFFFF`, 6.19:1 on `#F2F3FF`)** — never use `outline` `#777587` for readable text.
- **Brand & Semantic:** Primary `#3525CD`, CTA `#4F46E5`, Primary Fixed `#E2DFFF` / `#0F0069`, Secondary `#505F76` / `#D0E1FB` / `#38485D`, Tertiary Teal `#00524B` / `#89F5E7` / `#00201D`, Warning `#FEF3C7` / `#92400E` / `#D97706`, Error `#BA1A1A` / `#FFDAD6` / `#93000A`.

### Dark Mode (`03 · Dark Mode & Sub-Screens`)
- **Surfaces (Zero Shadow + 1px Hairline):** Canvas `#0B1120`, Sheet `#111827`, Surface Low / Nav / Column `#162033`, Card `#1E293B`, Hairline `#2D3A4F`.
- **Text:** Primary `#F1F5F9` (13.35:1), Secondary `#A0AEC0` (6.49:1), **Muted AA `#94A3B8` (5.71:1 on `#1E293B`, 6.36:1 on `#162033`)** — never use `#64748B` for readable text.
- **Brand & Semantic:** Primary `#C3C0FF`, CTA `#4F46E5`, Active Row `#2B247C` / `#E2DFFF`, Priority High `#5C1517` / `#FFDAD6` / `#FF897D`, Medium `#3E2D0F` / `#FDE68A` / `#FBBF24`, Low `#0F3B36` / `#89F5E7` / `#6BD8CB`, Warning `#422006` / `#FDE68A` / `#F59E0B`.

### Theme Palettes (`Tampilan & Tema`)
`Indigo #4F46E5` (default), `Emerald #059669`, `Ocean #0284C7`, `Amber #D97706`, `Rose #E11D48`.

## 3. Domain Rules & Stage Semantics
- **Pipeline Separation:** Strictly separate **5 Active Stages** (`Wishlist`, `Applied`, `Screening`, `Interview`, `Offering`) from **5 Terminal Outcomes** (`Offer Accepted`, `Offer Declined`, `Rejected`, `Withdrawn`, `No Response` in Arsip Terminal).
- **Stage Dot Colors (Light / Dark):**
  - `Wishlist`: `#505F76` / `#B7C8E1`
  - `Applied`: `#4F46E5` / `#818CF8`
  - `Screening`: `#7C3AED` / `#C084FC`
  - `Interview`: `#00524B` / `#6BD8CB`
  - `Offering`: `#059669` / `#34D399`
- **No-Left-Stripe & No-Nested-Cards:** Use tinted pill boxes (`#F2F3FF` / `#162033`) instead of decorative left accent bars or stacked white-in-white bordered boxes.

## 4. Typography & Mobile Text Capacity
- **Flutter Target:** `Plus Jakarta Sans` (Headlines, KPIs + `FontFeature.tabularFigures()`) paired with `Inter` (UI controls, cards, body).
- **FigCraft (Windows):** Render headings and body with `Inter` (`Regular`, `Medium`, `SemiBold`, `Bold`) because FigCraft desktop cleanly maps all `Inter` weights.
- **Mobile Font-Size Floor (`360–390dp`):** Minimum `12px` for all informative text, subtitles, sub-KPIs, field labels, and card metadata (`14–15px` body); reserve `11px` strictly for compact pills/badges and bottom nav tab labels; never place readable text `< 11px`.
- **Full-Width Card Titles:** On Kanban cards, place `Monogram + Company + Priority` on row 1 and move `Role Title` onto its own full-width row below (`maxLines: 2`) so long role names do not truncate.
- **Icon-Only Toolbar Switchers:** Use an icon-only `Board / List` toggle (`~72px`) so the Pipeline search bar retains comfortable typing width down to `360dp`.
- **Readable Metric Lists:** Replace cramped multi-column abbreviated tiles (such as 3-column stage velocity) with full-width rows (`Stage A -> Stage B | 3.2 hari`) to support natural Indonesian copy and `1.2x` text scaling.

## 5. UX Polish Patterns (v2.1)
1. **Compact Pipeline Header:** Put `Arsip (N)` pill in `ApplyFlowAppBar`, combine Search + Filter icon + `Board/List` toggle in one `42px` row, embed total count in `Semua N` stage chip, and omit redundant bottom summary strips.
2. **Zero-Overlap FAB Clearance:** Reserve dedicated bottom gutter above `Bottom NavigationBar` (`h=70`) so the FAB (`y=710`, `h=48`) never covers card actions.
3. **Single-Tap Quick Move (WCAG 2.2 AA):** Include `Pindah ⌄` on cards alongside long-press drag & drop.
4. **Sticky Form Footer:** Pin `Batal` (`48px`) + `Simpan Lamaran` (`52px`) at the bottom of form sheets; keep optional recruiter/source fields collapsible.
5. **Empty State Card:** Center icon badge, clear headline, `#5A596B` helper copy, and `+ Catat Lamaran Pertama` CTA.

## 6. FigCraft MCP Conventions
- Always pass `"fill": null` on transparent wrapper / auto-layout `frame`s (omitting `fill` creates opaque `#FFFFFF`).
- Batch edits per screen or card with `batch` (atomic undo step).
- Switch active page with `run_command` (`command: "page.select"`, `params: {"id": <pageId>}`) before page screenshots.
- Reuse Master Components from `01 · Design System` (`component.list`) instead of rebuilding buttons, cards, or navigation bars from scratch.
- Draw icons with SVG `vector` paths rather than emoji characters. Avoid `backgroundBlur` and multi-layer shadows during drafting.
- Save updates to `d:\Project\New folder\lamarlog_design.figcraft` via `save_file`.
