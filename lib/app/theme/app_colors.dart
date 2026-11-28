import 'package:flutter/material.dart';

import '../../core/enums/application_enums.dart';

/// Selectable color theme palettes for LamarLog, tuned for WCAG AA contrast
/// in both Light and Dark modes.
enum AppColorPalette {
  indigo('Indigo'),
  emerald('Emerald'),
  ocean('Ocean'),
  amber('Amber'),
  rose('Rose');

  const AppColorPalette(this.label);
  final String label;
}

class PaletteTokens {
  const PaletteTokens({
    required this.swatch,
    // Light
    required this.primaryLight,
    required this.primaryContainerLight,
    required this.onPrimaryContainerLight,
    required this.primaryFixedLight,
    required this.onPrimaryFixedLight,
    required this.surfaceLight,
    required this.surfaceLowLight,
    required this.surfaceContainerLight,
    required this.surfaceHighLight,
    required this.surfaceHighestLight,
    required this.outlineVariantLight,
    // Dark
    required this.primaryDark,
    required this.primaryContainerDark,
    required this.primaryFixedDark,
    required this.onPrimaryFixedDark,
    required this.surfaceDark,
    required this.surfaceLowestDark,
    required this.surfaceLowDark,
    required this.surfaceContainerDark,
    required this.surfaceHighDark,
    required this.surfaceHighestDark,
    required this.outlineVariantDark,
  });

  final Color swatch;

  final Color primaryLight;
  final Color primaryContainerLight;
  final Color onPrimaryContainerLight;
  final Color primaryFixedLight;
  final Color onPrimaryFixedLight;
  final Color surfaceLight;
  final Color surfaceLowLight;
  final Color surfaceContainerLight;
  final Color surfaceHighLight;
  final Color surfaceHighestLight;
  final Color outlineVariantLight;

  final Color primaryDark;
  final Color primaryContainerDark;
  final Color primaryFixedDark;
  final Color onPrimaryFixedDark;
  final Color surfaceDark;
  final Color surfaceLowestDark;
  final Color surfaceLowDark;
  final Color surfaceContainerDark;
  final Color surfaceHighDark;
  final Color surfaceHighestDark;
  final Color outlineVariantDark;
}

abstract final class AppColors {
  static PaletteTokens tokensFor(AppColorPalette palette) {
    return switch (palette) {
      AppColorPalette.indigo => const PaletteTokens(
          swatch: Color(0xFF4F46E5),
          primaryLight: Color(0xFF3525CD),
          primaryContainerLight: Color(0xFF4F46E5),
          onPrimaryContainerLight: Color(0xFFDAD7FF),
          primaryFixedLight: Color(0xFFE2DFFF),
          onPrimaryFixedLight: Color(0xFF0F0069),
          surfaceLight: Color(0xFFFAF8FF),
          surfaceLowLight: Color(0xFFF2F3FF),
          surfaceContainerLight: Color(0xFFEAEDFF),
          surfaceHighLight: Color(0xFFE2E7FF),
          surfaceHighestLight: Color(0xFFDAE2FD),
          outlineVariantLight: Color(0xFFC7C4D8),
          primaryDark: Color(0xFFC3C0FF),
          primaryContainerDark: Color(0xFF4F46E5),
          primaryFixedDark: Color(0xFF2B247C),
          onPrimaryFixedDark: Color(0xFFE2DFFF),
          surfaceDark: Color(0xFF0B1120),
          surfaceLowestDark: Color(0xFF111827),
          surfaceLowDark: Color(0xFF162033),
          surfaceContainerDark: Color(0xFF1E293B),
          surfaceHighDark: Color(0xFF263349),
          surfaceHighestDark: Color(0xFF31415C),
          outlineVariantDark: Color(0xFF2D3A4F),
        ),
      AppColorPalette.emerald => const PaletteTokens(
          swatch: Color(0xFF059669),
          primaryLight: Color(0xFF047857),
          primaryContainerLight: Color(0xFF059669),
          onPrimaryContainerLight: Color(0xFFD1FAE5),
          primaryFixedLight: Color(0xFFD1FAE5),
          onPrimaryFixedLight: Color(0xFF064E3B),
          surfaceLight: Color(0xFFF6FBF9),
          surfaceLowLight: Color(0xFFECF7F3),
          surfaceContainerLight: Color(0xFFE2F2EC),
          surfaceHighLight: Color(0xFFD6ECE4),
          surfaceHighestLight: Color(0xFFC9E5DB),
          outlineVariantLight: Color(0xFFBBD3CA),
          primaryDark: Color(0xFF6EE7B7),
          primaryContainerDark: Color(0xFF059669),
          primaryFixedDark: Color(0xFF064E3B),
          onPrimaryFixedDark: Color(0xFFD1FAE5),
          surfaceDark: Color(0xFF081412),
          surfaceLowestDark: Color(0xFF0D1C19),
          surfaceLowDark: Color(0xFF122522),
          surfaceContainerDark: Color(0xFF18302C),
          surfaceHighDark: Color(0xFF203D38),
          surfaceHighestDark: Color(0xFF294B45),
          outlineVariantDark: Color(0xFF28453F),
        ),
      AppColorPalette.ocean => const PaletteTokens(
          swatch: Color(0xFF0284C7),
          primaryLight: Color(0xFF0369A1),
          primaryContainerLight: Color(0xFF0284C7),
          onPrimaryContainerLight: Color(0xFFE0F2FE),
          primaryFixedLight: Color(0xFFE0F2FE),
          onPrimaryFixedLight: Color(0xFF0C4A6E),
          surfaceLight: Color(0xFFF6FAFE),
          surfaceLowLight: Color(0xFFEDF5FC),
          surfaceContainerLight: Color(0xFFE3EFFA),
          surfaceHighLight: Color(0xFFD8E8F7),
          surfaceHighestLight: Color(0xFFCDE1F4),
          outlineVariantLight: Color(0xFFBDCEE0),
          primaryDark: Color(0xFF7DD3FC),
          primaryContainerDark: Color(0xFF0284C7),
          primaryFixedDark: Color(0xFF0C4A6E),
          onPrimaryFixedDark: Color(0xFFE0F2FE),
          surfaceDark: Color(0xFF09131F),
          surfaceLowestDark: Color(0xFF0E1B2B),
          surfaceLowDark: Color(0xFF142438),
          surfaceContainerDark: Color(0xFF1B2F47),
          surfaceHighDark: Color(0xFF233B57),
          surfaceHighestDark: Color(0xFF2D4868),
          outlineVariantDark: Color(0xFF2B415C),
        ),
      AppColorPalette.amber => const PaletteTokens(
          swatch: Color(0xFFD97706),
          primaryLight: Color(0xFFB45309),
          primaryContainerLight: Color(0xFFD97706),
          onPrimaryContainerLight: Color(0xFFFEF3C7),
          primaryFixedLight: Color(0xFFFEF3C7),
          onPrimaryFixedLight: Color(0xFF78350F),
          surfaceLight: Color(0xFFFFFBF5),
          surfaceLowLight: Color(0xFFFBF4E9),
          surfaceContainerLight: Color(0xFFF6ECDD),
          surfaceHighLight: Color(0xFFEFE2CF),
          surfaceHighestLight: Color(0xFFE8D8C1),
          outlineVariantLight: Color(0xFFD9CBB8),
          primaryDark: Color(0xFFFCD34D),
          primaryContainerDark: Color(0xFFD97706),
          primaryFixedDark: Color(0xFF5C2E09),
          onPrimaryFixedDark: Color(0xFFFEF3C7),
          surfaceDark: Color(0xFF16110B),
          surfaceLowestDark: Color(0xFF1D1710),
          surfaceLowDark: Color(0xFF251E15),
          surfaceContainerDark: Color(0xFF2F261C),
          surfaceHighDark: Color(0xFF3A3024),
          surfaceHighestDark: Color(0xFF473B2D),
          outlineVariantDark: Color(0xFF463A2C),
        ),
      AppColorPalette.rose => const PaletteTokens(
          swatch: Color(0xFFE11D48),
          primaryLight: Color(0xFFBE123C),
          primaryContainerLight: Color(0xFFE11D48),
          onPrimaryContainerLight: Color(0xFFFFE4E6),
          primaryFixedLight: Color(0xFFFFE4E6),
          onPrimaryFixedLight: Color(0xFF881337),
          surfaceLight: Color(0xFFFFF8FA),
          surfaceLowLight: Color(0xFFFDF0F3),
          surfaceContainerLight: Color(0xFFFAE6EB),
          surfaceHighLight: Color(0xFFF5DCE3),
          surfaceHighestLight: Color(0xFFEFD1DA),
          outlineVariantLight: Color(0xFFDCC3CB),
          primaryDark: Color(0xFFFDA4AF),
          primaryContainerDark: Color(0xFFE11D48),
          primaryFixedDark: Color(0xFF6B112B),
          onPrimaryFixedDark: Color(0xFFFFE4E6),
          surfaceDark: Color(0xFF170D12),
          surfaceLowestDark: Color(0xFF201319),
          surfaceLowDark: Color(0xFF291920),
          surfaceContainerDark: Color(0xFF332029),
          surfaceHighDark: Color(0xFF3F2833),
          surfaceHighestDark: Color(0xFF4C313E),
          outlineVariantDark: Color(0xFF4A2E3B),
        ),
    };
  }

  // Shared Neutrals & Semantics
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF0F172A);

  static const Color secondaryLight = Color(0xFF505F76);
  static const Color secondaryContainerLight = Color(0xFFD0E1FB);
  static const Color onSecondaryContainerLight = Color(0xFF38485D);

  static const Color tertiaryLight = Color(0xFF00524B);
  static const Color tertiaryContainerLight = Color(0xFF006C63);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryFixedLight = Color(0xFF89F5E7);
  static const Color onTertiaryFixedLight = Color(0xFF00201D);

  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color errorContainerLight = Color(0xFFFFDAD6);
  static const Color onErrorContainerLight = Color(0xFF93000A);

  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF131B2E);
  static const Color onSurfaceVariantLight = Color(0xFF464555);
  static const Color mutedTextLight = Color(0xFF5A596B);
  static const Color outlineLight = Color(0xFF777587);
  static const Color inverseSurfaceLight = Color(0xFF283044);
  static const Color inverseOnSurfaceLight = Color(0xFFEEF0FF);

  static const Color secondaryDark = Color(0xFFB7C8E1);
  static const Color secondaryContainerDark = Color(0xFF28364A);
  static const Color onSecondaryContainerDark = Color(0xFFD3E4FE);

  static const Color tertiaryDark = Color(0xFF6BD8CB);
  static const Color tertiaryContainerDark = Color(0xFF005049);
  static const Color onTertiaryDark = Color(0xFF00201D);

  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color errorContainerDark = Color(0xFF5C1517);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  static const Color onSurfaceDark = Color(0xFFF1F5F9);
  static const Color onSurfaceVariantDark = Color(0xFFA0AEC0);
  static const Color mutedTextDark = Color(0xFF94A3B8);
  static const Color outlineDark = Color(0xFF64748B);

  static Color mutedText(Brightness brightness) =>
      brightness == Brightness.dark ? mutedTextDark : mutedTextLight;

  // Warning (Amber) semantic tokens
  static const Color warningBgLight = Color(0xFFFEF3C7);
  static const Color warningFgLight = Color(0xFF92400E);
  static const Color warningIconLight = Color(0xFFD97706);

  static const Color warningBgDark = Color(0xFF422006);
  static const Color warningFgDark = Color(0xFFFDE68A);
  static const Color warningIconDark = Color(0xFFF59E0B);

  static (Color bg, Color fg, Color dot) priorityColors(
    PriorityLevel priority,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    return switch (priority) {
      PriorityLevel.high => isDark
          ? (
              const Color(0xFF5C1517),
              const Color(0xFFFFDAD6),
              const Color(0xFFFF897D)
            )
          : (errorContainerLight, onErrorContainerLight, errorLight),
      PriorityLevel.medium => isDark
          ? (
              const Color(0xFF3E2D0F),
              const Color(0xFFFDE68A),
              const Color(0xFFFBBF24)
            )
          : (warningBgLight, warningFgLight, warningIconLight),
      PriorityLevel.low => isDark
          ? (
              const Color(0xFF0F3B36),
              const Color(0xFF89F5E7),
              const Color(0xFF6BD8CB)
            )
          : (tertiaryFixedLight, onTertiaryFixedLight, tertiaryContainerLight),
    };
  }

  static Color stageDotColor(ApplicationStatus status, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (status) {
      ApplicationStatus.wishlist => isDark ? secondaryDark : secondaryLight,
      ApplicationStatus.applied =>
        isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
      ApplicationStatus.screening =>
        isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
      ApplicationStatus.interview => isDark ? tertiaryDark : tertiaryLight,
      ApplicationStatus.offering =>
        isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
      ApplicationStatus.offerAccepted =>
        isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
      ApplicationStatus.offerDeclined =>
        isDark ? warningIconDark : warningIconLight,
      ApplicationStatus.rejected => isDark ? errorDark : errorLight,
      ApplicationStatus.withdrawn => isDark ? secondaryDark : secondaryLight,
      ApplicationStatus.noResponse => isDark ? outlineDark : outlineLight,
    };
  }

  static (Color bg, Color fg) statusBadgeColors(
    ApplicationStatus status,
    Brightness brightness,
    ColorScheme cs,
  ) {
    final isDark = brightness == Brightness.dark;
    return switch (status) {
      ApplicationStatus.offerAccepted => isDark
          ? (const Color(0xFF0F3B36), const Color(0xFF89F5E7))
          : (tertiaryFixedLight, onTertiaryFixedLight),
      ApplicationStatus.rejected => isDark
          ? (errorContainerDark, onErrorContainerDark)
          : (errorContainerLight, onErrorContainerLight),
      ApplicationStatus.offerDeclined => isDark
          ? (warningBgDark, warningFgDark)
          : (warningBgLight, warningFgLight),
      ApplicationStatus.withdrawn || ApplicationStatus.noResponse =>
        (cs.surfaceContainerHigh, cs.secondary),
      _ => (cs.primaryFixed, cs.onPrimaryFixed),
    };
  }
}
