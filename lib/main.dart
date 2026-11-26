import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app_shell.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/l10n/app_strings.dart';
import 'core/models/pipeline_stage_config.dart';
import 'core/services/preferences_service.dart';
import 'features/applications/presentation/bloc/applications_bloc.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final preferences = await PreferencesService.create();
  runApp(ApplyFlowApp(database: database, preferences: preferences));
}

class ApplyFlowApp extends StatefulWidget {
  const ApplyFlowApp({
    super.key,
    required this.database,
    this.preferences = const PreferencesService.inMemory(),
  });

  final AppDatabase database;
  final PreferencesService preferences;

  @override
  State<ApplyFlowApp> createState() => _ApplyFlowAppState();
}

class _ApplyFlowAppState extends State<ApplyFlowApp> {
  late ThemeMode _themeMode;
  late AppColorPalette _colorPalette;
  late String _defaultCurrency;
  late String _languageCode;
  late bool _hasCompletedOnboarding;
  List<PipelineStageConfig>? _customPipelineStages;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.preferences.themeMode;
    _colorPalette = widget.preferences.colorPalette;
    _defaultCurrency = widget.preferences.defaultCurrency;
    _languageCode = widget.preferences.languageCode;
    _hasCompletedOnboarding = widget.preferences.hasCompletedOnboarding;
    _customPipelineStages = widget.preferences.pipelineStages;
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.preferences.setThemeMode(mode);
  }

  void _updateColorPalette(AppColorPalette palette) {
    setState(() => _colorPalette = palette);
    widget.preferences.setColorPalette(palette);
  }

  void _updateDefaultCurrency(String currency) {
    setState(() => _defaultCurrency = currency);
    widget.preferences.setDefaultCurrency(currency);
  }

  void _updateLanguage(String lang) {
    setState(() => _languageCode = lang);
    widget.preferences.setLanguageCode(lang);
  }

  void _completeOnboarding() {
    setState(() => _hasCompletedOnboarding = true);
    widget.preferences.setOnboardingCompleted(true);
  }

  void _updatePipelineStages(List<PipelineStageConfig>? stages) {
    setState(() {
      _customPipelineStages =
          stages == null ? null : List<PipelineStageConfig>.from(stages);
    });
    widget.preferences.setPipelineStages(stages);
  }

  void _renameStageById(String stageId, String? newName) {
    final current = List<PipelineStageConfig>.from(
      _customPipelineStages ??
          PipelineStageConfig.defaults(isId: _languageCode == 'id'),
    );
    final idx = current.indexWhere((s) => s.id == stageId);
    if (idx < 0) return;

    final trimmed = newName?.trim() ?? '';
    if (trimmed.isEmpty) {
      final defMatch = PipelineStageConfig.defaults(isId: _languageCode == 'id')
          .where((s) => s.id == stageId)
          .firstOrNull;
      if (defMatch != null) {
        current[idx] = current[idx].copyWith(label: defMatch.label);
      }
    } else {
      current[idx] = current[idx].copyWith(label: trimmed);
    }
    _updatePipelineStages(current);
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.database,
      child: BlocProvider(
        create: (_) =>
            ApplicationsBloc(widget.database)..add(const LoadApplications()),
        child: AppLocaleScope(
          strings: AppStrings(
            _languageCode,
            customPipelineStages: _customPipelineStages,
          ),
          child: MaterialApp(
            title: 'ApplyFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(_colorPalette),
            darkTheme: AppTheme.dark(_colorPalette),
            themeMode: _themeMode,
            home: _hasCompletedOnboarding
                ? AppShell(
                    themeMode: _themeMode,
                    onThemeModeChanged: _updateThemeMode,
                    colorPalette: _colorPalette,
                    onColorPaletteChanged: _updateColorPalette,
                    defaultCurrency: _defaultCurrency,
                    onDefaultCurrencyChanged: _updateDefaultCurrency,
                    languageCode: _languageCode,
                    onLanguageChanged: _updateLanguage,
                    onRenameStage: _renameStageById,
                    onPipelineStagesChanged: _updatePipelineStages,
                  )
                : OnboardingPage(
                    languageCode: _languageCode,
                    onLanguageChanged: _updateLanguage,
                    onCompleted: _completeOnboarding,
                  ),
          ),
        ),
      ),
    );
  }
}
