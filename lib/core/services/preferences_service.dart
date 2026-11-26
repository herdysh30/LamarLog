import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/app_colors.dart';

class PreferencesService {
  PreferencesService(this._prefs) : _fallbackOnboardingDone = false;

  final SharedPreferences? _prefs;
  final bool _fallbackOnboardingDone;

  static const _kThemeMode = 'applyflow_theme_mode';
  static const _kColorPalette = 'applyflow_color_palette';
  static const _kDefaultCurrency = 'applyflow_default_currency';
  static const _kLanguageCode = 'applyflow_language_code';
  static const _kOnboardingDone = 'applyflow_onboarding_done';
  static const _kCustomStageNames = 'applyflow_custom_stage_names';

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  /// In-memory fallback for widget tests that do not initialize SharedPreferences.
  const PreferencesService.inMemory({bool onboardingDone = true})
      : _prefs = null,
        _fallbackOnboardingDone = onboardingDone;

  ThemeMode get themeMode {
    final raw = _prefs?.getString(_kThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs?.setString(_kThemeMode, mode.name);
  }

  AppColorPalette get colorPalette {
    final raw = _prefs?.getString(_kColorPalette);
    return AppColorPalette.values.firstWhere(
      (p) => p.name == raw,
      orElse: () => AppColorPalette.indigo,
    );
  }

  Future<void> setColorPalette(AppColorPalette palette) async {
    await _prefs?.setString(_kColorPalette, palette.name);
  }

  String get defaultCurrency => _prefs?.getString(_kDefaultCurrency) ?? 'IDR';

  Future<void> setDefaultCurrency(String currency) async {
    await _prefs?.setString(_kDefaultCurrency, currency);
  }

  String get languageCode => _prefs?.getString(_kLanguageCode) ?? 'en';

  Future<void> setLanguageCode(String code) async {
    await _prefs?.setString(_kLanguageCode, code);
  }

  bool get hasCompletedOnboarding =>
      _prefs?.getBool(_kOnboardingDone) ?? _fallbackOnboardingDone;

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs?.setBool(_kOnboardingDone, value);
  }

  Map<String, String> get customStageNames {
    final raw = _prefs?.getString(_kCustomStageNames);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return const {};
    }
  }

  Future<void> setCustomStageNames(Map<String, String> names) async {
    await _prefs?.setString(_kCustomStageNames, jsonEncode(names));
  }
}
