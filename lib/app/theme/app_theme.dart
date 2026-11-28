import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light(AppColorPalette palette) {
    final p = AppColors.tokensFor(palette);
    final baseTextTheme = GoogleFonts.interTextTheme();
    final headlineFont = GoogleFonts.plusJakartaSans();

    final colorScheme = ColorScheme.light(
      primary: p.primaryLight,
      primaryContainer: p.primaryContainerLight,
      onPrimary: AppColors.onPrimaryLight,
      onPrimaryContainer: p.onPrimaryContainerLight,
      primaryFixed: p.primaryFixedLight,
      onPrimaryFixed: p.onPrimaryFixedLight,
      secondary: AppColors.secondaryLight,
      secondaryContainer: AppColors.secondaryContainerLight,
      onSecondaryContainer: AppColors.onSecondaryContainerLight,
      tertiary: AppColors.tertiaryLight,
      tertiaryContainer: AppColors.tertiaryContainerLight,
      onTertiary: AppColors.onTertiaryLight,
      tertiaryFixed: AppColors.tertiaryFixedLight,
      onTertiaryFixed: AppColors.onTertiaryFixedLight,
      error: AppColors.errorLight,
      errorContainer: AppColors.errorContainerLight,
      onErrorContainer: AppColors.onErrorContainerLight,
      surface: p.surfaceLight,
      surfaceContainerLowest: AppColors.surfaceContainerLowestLight,
      surfaceContainerLow: p.surfaceLowLight,
      surfaceContainer: p.surfaceContainerLight,
      surfaceContainerHigh: p.surfaceHighLight,
      surfaceContainerHighest: p.surfaceHighestLight,
      onSurface: AppColors.onSurfaceLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      outline: AppColors.outlineLight,
      outlineVariant: p.outlineVariantLight,
      inverseSurface: AppColors.inverseSurfaceLight,
      onInverseSurface: AppColors.inverseOnSurfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.surfaceLight,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: const Color(0x14131B2E),
        centerTitle: false,
      ),
      textTheme: _buildTextTheme(
        baseTextTheme,
        headlineFont,
        AppColors.onSurfaceLight,
        AppColors.onSurfaceVariantLight,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceContainerLowestLight,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: p.outlineVariantLight.withValues(alpha: 0.45),
            width: 0.75,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceLowLight,
        hintStyle:
            const TextStyle(color: AppColors.mutedTextLight, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.primaryContainerLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: AppColors.surfaceContainerLowestLight,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primaryContainerLight,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.onPrimaryLight,
              size: 22,
            );
          }
          return const IconThemeData(
            color: AppColors.secondaryLight,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: p.primaryLight,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryLight,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primaryContainerLight,
        foregroundColor: AppColors.onPrimaryLight,
        elevation: 4,
        shape: const StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurfaceLight,
        contentTextStyle: const TextStyle(
          color: AppColors.inverseOnSurfaceLight,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceLight,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.outlineVariantLight.withValues(alpha: 0.4),
        thickness: 0.75,
        space: 1,
      ),
    );
  }

  static ThemeData dark(AppColorPalette palette) {
    final p = AppColors.tokensFor(palette);
    final baseTextTheme =
        GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final headlineFont = GoogleFonts.plusJakartaSans();

    final colorScheme = ColorScheme.dark(
      primary: p.primaryDark,
      primaryContainer: p.primaryContainerDark,
      onPrimary: AppColors.onPrimaryDark,
      onPrimaryContainer: Colors.white,
      primaryFixed: p.primaryFixedDark,
      onPrimaryFixed: p.onPrimaryFixedDark,
      secondary: AppColors.secondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.tertiaryDark,
      tertiaryContainer: AppColors.tertiaryContainerDark,
      onTertiary: AppColors.onTertiaryDark,
      error: AppColors.errorDark,
      errorContainer: AppColors.errorContainerDark,
      onErrorContainer: AppColors.onErrorContainerDark,
      surface: p.surfaceDark,
      surfaceContainerLowest: p.surfaceLowestDark,
      surfaceContainerLow: p.surfaceLowDark,
      surfaceContainer: p.surfaceContainerDark,
      surfaceContainerHigh: p.surfaceHighDark,
      surfaceContainerHighest: p.surfaceHighestDark,
      onSurface: AppColors.onSurfaceDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
      outlineVariant: p.outlineVariantDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.surfaceDark,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      textTheme: _buildTextTheme(
        baseTextTheme,
        headlineFont,
        AppColors.onSurfaceDark,
        AppColors.onSurfaceVariantDark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surfaceContainerDark,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.outlineVariantDark, width: 0.75),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceLowDark,
        hintStyle:
            const TextStyle(color: AppColors.mutedTextDark, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outlineVariantDark, width: 0.75),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.primaryDark, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: p.surfaceLowestDark,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primaryContainerDark,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white, size: 22);
          }
          return const IconThemeData(
            color: AppColors.onSurfaceVariantDark,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: p.primaryDark,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariantDark,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primaryContainerDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.surfaceHighDark,
        contentTextStyle: const TextStyle(
          color: AppColors.onSurfaceDark,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceLowestDark,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.outlineVariantDark,
        thickness: 0.75,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base,
    TextStyle headlineFont,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    return base.copyWith(
      headlineLarge: headlineFont.copyWith(
        fontSize: 26,
        height: 34 / 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: onSurface,
      ),
      headlineMedium: headlineFont.copyWith(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      headlineSmall: headlineFont.copyWith(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        height: 22 / 15,
        color: onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        color: onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        color: onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 13,
        height: 16 / 13,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        color: onSurfaceVariant,
      ),
    );
  }
}
