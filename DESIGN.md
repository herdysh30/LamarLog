---
name: ApplyFlow
description: Calm, high-clarity Material 3 mobile design system for an offline-first career pipeline and job application tracker.
colors:
  primary: "#3525cd"
  primary-container: "#4f46e5"
  on-primary: "#ffffff"
  primary-fixed: "#e2dfff"
  on-primary-fixed: "#0f0069"
  secondary: "#505f76"
  secondary-container: "#d0e1fb"
  on-secondary-container: "#38485d"
  tertiary: "#00524b"
  tertiary-container: "#006c63"
  tertiary-fixed: "#89f5e7"
  on-tertiary-fixed: "#00201d"
  error: "#ba1a1a"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  warning: "#d97706"
  warning-container: "#fef3c7"
  on-warning-container: "#92400e"
  surface: "#faf8ff"
  surface-container-lowest: "#ffffff"
  surface-container-low: "#f2f3ff"
  surface-container: "#eaedff"
  surface-container-high: "#e2e7ff"
  surface-container-highest: "#dae2fd"
  on-surface: "#131b2e"
  on-surface-variant: "#464555"
  outline: "#777587"
  outline-variant: "#c7c4d8"
  dark-surface: "#0b1120"
  dark-surface-container-low: "#162033"
  dark-surface-container: "#1e293b"
  dark-surface-container-high: "#263349"
  dark-primary: "#c3c0ff"
  dark-tertiary: "#6bd8cb"
  dark-on-surface: "#f1f5f9"
  dark-on-surface-variant: "#a0aec0"
typography:
  headline-large:
    fontFamily: "Plus Jakarta Sans, Inter, sans-serif"
    fontSize: "26px"
    fontWeight: 700
    lineHeight: 1.31
    letterSpacing: "-0.015em"
  headline-medium:
    fontFamily: "Plus Jakarta Sans, Inter, sans-serif"
    fontSize: "22px"
    fontWeight: 600
    lineHeight: 1.27
    letterSpacing: "-0.012em"
  headline-small:
    fontFamily: "Plus Jakarta Sans, Inter, sans-serif"
    fontSize: "18px"
    fontWeight: 600
    lineHeight: 1.33
    letterSpacing: "-0.01em"
  title-medium:
    fontFamily: "Inter, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.38
  title-small:
    fontFamily: "Inter, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.43
  metric-md:
    fontFamily: "Inter, sans-serif"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: 1.33
    fontFeature: "tnum"
  body-medium:
    fontFamily: "Inter, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.43
  body-small:
    fontFamily: "Inter, sans-serif"
    fontSize: "12px"
    fontWeight: 400
    lineHeight: 1.33
  label-medium:
    fontFamily: "Inter, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    lineHeight: 1.33
  label-small:
    fontFamily: "Inter, sans-serif"
    fontSize: "11px"
    fontWeight: 600
    lineHeight: 1.27
rounded:
  xs: "6px"
  sm: "8px"
  md: "10px"
  lg: "12px"
  xl: "14px"
  column: "18px"
  sheet: "24px"
  full: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary}"
    typography: "{typography.title-small}"
    rounded: "{rounded.xl}"
    height: "52px"
    padding: "0 20px"
  button-tonal:
    backgroundColor: "{colors.primary-fixed}"
    textColor: "{colors.on-primary-fixed}"
    typography: "{typography.label-medium}"
    rounded: "{rounded.lg}"
    height: "48px"
    padding: "0 16px"
  card-surface:
    backgroundColor: "{colors.surface-container-lowest}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.xl}"
    padding: "16px"
  input-field:
    backgroundColor: "{colors.surface-container-low}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-medium}"
    rounded: "{rounded.lg}"
    height: "50px"
    padding: "14px 14px"
  pill-offline:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.tertiary}"
    typography: "{typography.label-small}"
    rounded: "{rounded.full}"
    padding: "6px 10px"
  nav-bar:
    backgroundColor: "{colors.surface-container-lowest}"
    textColor: "{colors.secondary}"
    height: "68px"
---

# Design System: ApplyFlow

## Overview

**Creative North Star: "The Focused Career Desk"**

ApplyFlow is an Operate-mode productivity tool built for active job hunters managing dozens of applications, interviews, resumes, and offers offline. The interface stays calm, legible, and fast so the user's attention stays on company names, compensation numbers, upcoming interview dates, and stage progress rather than ornamental UI chrome.

The visual world pairs cool lavender-tinted paper surfaces in Light Mode (and deep slate in Dark Mode) with disciplined indigo primary actions and grounded teal trust signals for offline persistence and positive interview states. Every screen follows one consistent component vocabulary across Pipeline, Application Form, Application Detail, Analytics, and Settings—no competing button shapes, no decorative glassmorphism, and no cluttered card nesting.

**Key Characteristics:**
- Tonal surface layering instead of heavy dividers or harsh gray borders.
- Crisp tabular numerals on all salary figures, conversion percentages, and dwell-time counters.
- Purposeful semantic color reserved for active stages, priority urgency, offline trust, and destructive actions.
- Touch-first ergonomics with minimum 48dp interactive targets and non-drag accessibility fallbacks.

## Colors

A restrained cool-neutral surface ladder anchored by deep indigo for primary actions, muted slate for supporting metadata, and deep teal for offline readiness and interview progress.

### Primary
- **Electric Indigo** (`primary`): Core interactive text, selected view toggles, active navigation labels, and primary monogram accents.
- **Indigo Container** (`primary-container`): Filled primary actions (`Save Application`, `Track Job` FAB, selected chips, and active navigation pill indicator).
- **Indigo Mist** (`primary-fixed` / `on-primary-fixed`): Tonal action surfaces, status transition selector, and upcoming interview micro-banners.
- **Dark Indigo Glow** (`dark-primary`): High-contrast primary accent adapted for Dark Mode surfaces.

### Secondary
- **Slate Steel** (`secondary`): Inactive navigation icons, secondary labels, Wishlist stage indicator dot, and metadata icons.
- **Ice Slate** (`secondary-container` / `on-secondary-container`): Medium priority badges, Archive pill accents, and offline-first assurance banners.

### Tertiary
- **Deep Teal** (`tertiary` / `dark-tertiary`): Offline-ready status indicators, saved-locally pins, active reminder confirmations, and Interview/Offering stage momentum.
- **Mint Glass** (`tertiary-fixed` / `on-tertiary-fixed`): Low priority tags and `Offer Accepted` terminal outcome pills.

### Neutral
- **Lavender Paper** (`surface`): Main Light Mode canvas background; keeps pure white cards visually distinct without heavy borders.
- **Pure White** (`surface-container-lowest`): Primary elevated cards (`SurfaceCard`), top-level form sections, and active segmented toggle pills.
- **Soft Mist & Periwinkle Ladder** (`surface-container-low` → `surface-container-highest`): Nested input fields, Kanban column wells, quick metric tiles, and timeline note bubbles.
- **Ink Navy & Graphite** (`on-surface`, `on-surface-variant`, `outline`): High-contrast primary text, secondary subtitles, and muted hints meeting WCAG AA (≥ 4.5:1).
- **Deep Slate Dark Ladder** (`dark-surface` → `dark-surface-container-high` with `dark-on-surface`): Adaptive Dark Mode surfaces preserving clear elevation separation under low ambient light.
- **Semantic Alert Pairings** (`error` / `error-container`, `warning` / `warning-container`): High priority tags, `Rejected` outcomes, destructive `Clear All Data` actions, and plaintext JSON backup warnings.

### Named Rules
**The Semantic Restraint Rule.** Accent colors (`primary-container`, `error`, `tertiary`) appear only on primary CTAs, active selections, stage dots, and semantic status pills—never as decorative full-card fills or inactive chrome.

**The Adaptive Contrast Rule.** Every status badge, priority pill, and warning box uses paired background and foreground tokens per brightness mode (`AppColors.priorityColors`, `AppColors.statusBadgeColors`) so text stays ≥ 4.5:1 in both Light and Dark themes.

**The Multi-Palette Rule.** Users can switch between five curated tonal palettes (`Indigo`, `Emerald`, `Ocean`, `Amber`, `Rose`) in Settings; each palette harmonizes primary accents and subtle surface tints across both Light and Dark modes without breaking semantic priority or stage indicators.

**The Quiet Offline Rule.** Never show "Offline Ready" pills or toggle-like "Offline-First Enabled" banners; explain local offline storage once as plain factual copy inside Settings → Data Vault & Backup.

## Typography

**Display / Headline Font:** Plus Jakarta Sans (fallback: Inter, system sans-serif)
**Body & UI Font:** Inter (fallback: system sans-serif)

**Character:** Geometric warmth in headlines (`Plus Jakarta Sans`) paired with neutral, high-legibility UI copy and crisp aligned numerals (`Inter`).

### Hierarchy
- **Headline Large** (700, 26px, 1.31 line-height, -0.4px tracking): Screen-level titles (`Analytics & Insights`, `Settings`).
- **Headline Medium** (600, 22px, 1.27 line-height): KPI hero figures and prominent modal headers.
- **Headline Small** (600, 18px, 1.33 line-height): App brand title (`ApplyFlow`), bottom sheet headers, and empty-state titles.
- **Title Medium** (600, 16px, 1.38 line-height): Card section headers (`Application Funnel`, `Interview Schedule`, `Timeline & Activity`) and stack AppBar titles.
- **Title Small** (600, 14px, 1.43 line-height): Company names on cards, Kanban stage headers, timeline event titles, and primary button labels.
- **Metric Medium** (600, 15px, tabular figures): Compensation readouts (`Rp 28.000.000`, `$160,000`), funnel percentages, and stage velocity days.
- **Body Medium** (400, 14px, 1.43 line-height): Form inputs, notes, and primary descriptions.
- **Body Small** (400, 12px, 1.33 line-height): Role subtitles, secondary descriptions, timestamps, and helper captions.
- **Label Medium / Small** (500–600, 12px / 11px): Chips, priority pills, stage counters, and bottom navigation labels.

### Named Rules
**The Tabular Numerals Rule.** Every salary figure, funnel percentage, storage size, and day counter must enable `FontFeature.tabularFigures()` so numeric columns align cleanly when scanning cards and analytics.

## Layout

ApplyFlow uses a single-column mobile-first layout tuned from `360dp` compact phones up to tablets, built on a `4px` base unit (`8px`, `12px`, `16px`, `24px` rhythm):

- **Screen Margins:** `16px` horizontal padding on all scroll views, form sections, and bottom sheets.
- **Section Rhythm:** `14px` to `16px` gap between sibling `SurfaceCard` blocks; `20px` to `22px` gap before new major section headings.
- **Kanban Columns:** Horizontally scrollable `300px`-wide column wells separated by `14px` gutters with `10px` inner padding and `10px` card spacing.
- **Touch Ergonomics:** All buttons, chips, filter triggers, and navigation destinations enforce a minimum `48dp` interactive height/width (or `44dp+` inside compact horizontal pill rows).
- **Safe Areas:** Top `ApplyFlowAppBar` (`64px` height) and bottom `NavigationBar` (`68px` height) respect system insets; primary FAB sits clear of the bottom pipeline summary bar.

## Elevation & Depth

ApplyFlow uses a **tonal-first hybrid elevation model** implemented via `SurfaceCard`:

- **Light Mode:** White cards (`surface-container-lowest`) rest on the lavender canvas (`surface`) or soft column wells (`surface-container-low`), reinforced by a hairline outline (`outline-variant` at 35% opacity) and a soft downward ambient shadow (`0 2px 10px rgba(19, 27, 46, 0.045)`).
- **Dark Mode:** Shadows are omitted; depth is communicated strictly through stepped slate surface brightness (`dark-surface` → `dark-surface-container-low` → `dark-surface-container`) plus crisp `0.75px` `outline-variant` hairlines.
- **Interactive Lift:** Only the floating `Track Job` FAB, dragged Kanban cards (`elevation: 10`), and modal bottom sheets carry higher elevation.

### Named Rules
**The No-Left-Stripe Rule.** Never place thick colored `border-left` accent strips on cards, interview callouts, or alerts. Signal category and emphasis through tinted icon containers (`30–38px` rounded squares) and semantic status pills.

**The No-Nested-Cards Rule.** Inside a `SurfaceCard`, inner groupings (quick metrics, meeting link bars, timeline note bubbles, warning callouts) use flat borderless tonal fills (`surface-container-low` or semantic container tints) rather than bordered nested cards.

## Shapes

Rounded, friendly-yet-precise geometry scales proportionally with container size:

- **Small Chips & Tags** (`6px–8px`): Workplace badges, job type tags, cadence toggle segments.
- **Interactive Controls & Inputs** (`10px–12px`): Form fields, filter pills, monogram avatars, inner metric tiles, action tiles.
- **Primary Cards & CTA Buttons** (`14px`): `SurfaceCard`, Kanban cards, full-width primary buttons.
- **Kanban Column Wells** (`18px`): Soft containers grouping active stage cards.
- **Modal Bottom Sheets** (`24px` top corners): Filter sheet, Terminal Archive drawer, status picker, language sheet.
- **Pills & Indicators** (`9999px`): Offline status pill, stage count badges, priority pills, stage filter pills, FAB, and active navigation indicator.

## Components

Every screen pulls from the shared vocabulary in `lib/core/widgets/applyflow_widgets.dart` and `lib/app/theme/app_theme.dart`.

### Buttons
- **Shape:** `14px` radius for primary full-width form CTAs (`52px` height); `12px` radius for dialog/sheet buttons (`48px` height); stadium pill for the `Track Job` FAB.
- **Primary:** `primary-container` background with pure white label (`600–700` weight).
- **Tonal / Secondary:** `primary-fixed` or `surface-container-high` fill for non-destructive secondary actions (`Schedule`, `Add Note`, `Edit Job Details`, `Reset`).
- **Destructive:** `error` fill with white label inside explicit confirmation dialogs and the Settings Danger Zone (`Delete`, `Clear All Data`).

### Chips & Pills
- **Style:** Borderless tonal fills (`surface-container` when unselected; `primary-container` with white text when selected).
- **Semantic Badges:** Priority (`High`, `Med`, `Low`) and Terminal Outcomes (`Offer Accepted`, `Rejected`, `Withdrawn`, `No Response`) use rounded pill geometry with paired semantic container/foreground tokens.

### Cards (`SurfaceCard`)
- **Corner Style:** `14px` radius.
- **Background:** `surface-container-lowest` (Light) / `dark-surface-container` (Dark).
- **Shadow Strategy:** Soft ambient offset shadow in Light Mode; tonal step + hairline border in Dark Mode.
- **Internal Padding:** `14px` on dense Kanban cards, `16px–18px` on Detail, Form, Analytics, and Settings cards.

### Inputs & Form Controls
- **Style:** Borderless filled container (`surface-container-low`, `12px` radius, `50px` height) with leading semantic outline icons.
- **Focus:** Transitions smoothly to `1.5px` `primary-container` (Light) or `dark-primary` (Dark) outline.
- **Error:** `1.2px–1.5px` `error` outline with inline validation copy naming the missing field.

### Navigation (`ApplyFlowAppBar` & `AppShell`)
- **Top Bar:** `64px` height, gradient primary ApplyFlow monogram (`36x36`, `10px` radius), brand title + localized screen subtitle on left; `OfflineStatusPill` appears only on the Settings tab.
- **Bottom Bar:** `68px` Material 3 `NavigationBar` with stadium `primary-container` indicator pill, white active icon, `primary` active label, and `secondary` inactive items (`Pipeline`, `Analytics`/`Analitik`, `Settings`/`Pengaturan`).

### Signature Components
- **Kanban Column & Drag Target:** `300px` column well with semantic stage dot, count pill, quick `+` button, `LongPressDraggable` cards with 35% opacity ghost placeholder, and highlighted `primary-container` border when receiving a dragged card.
- **Vertical Timeline Rail:** Chronological activity stream combining manual `TimelineLog` notes and automatic `StatusTransition` milestones along a `2px` vertical track (`surface-container-highest`) with `11px` bordered nodes (`primary` for notes, `tertiary` for stage moves).

## Do's and Don'ts

### Do:
- **Do** use `SurfaceCard`, `ApplyFlowAppBar`, `OfflineStatusPill`, and `CompanyMonogram` for all new screens to keep elevation, typography, and chrome unified.
- **Do** enable `FontFeature.tabularFigures()` on every monetary figure, percentage, counter, and storage metric.
- **Do** provide clear empty states with direct CTAs (e.g., `Track First Job`, `Add to <Stage>`) and destructive confirmation dialogs before deleting data or overwriting backups.
- **Do** keep active pipeline stages strictly separate from terminal outcomes in both Kanban columns and status pickers.
- **Do** verify every new screen in both Light Mode (`#FAF8FF` canvas) and Dark Mode (`#0B1120` canvas) from `360dp` width upward.

### Don't:
- **Don't** add colored `border-left` strips above `1px` on cards, interview alerts, or warning callouts.
- **Don't** nest bordered cards inside other cards; use flat tonal fills (`surface-container-low`) for inner groupings.
- **Don't** place decorative uppercase eyebrow/kicker labels above headings.
- **Don't** hardcode raw `Colors.red`, `Colors.grey`, or `Colors.white` text/backgrounds where theme `ColorScheme` or `AppColors` semantic helpers belong.
- **Don't** rely solely on drag-and-drop for status transitions; always maintain the accessible `Change` status selector in `ApplicationDetailPage`.
