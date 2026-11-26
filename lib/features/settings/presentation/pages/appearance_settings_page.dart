import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/widgets/applyflow_widgets.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.colorPalette,
    required this.onColorPaletteChanged,
    required this.defaultCurrency,
    required this.onDefaultCurrencyChanged,
    required this.languageCode,
    required this.onLanguageChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final AppColorPalette colorPalette;
  final ValueChanged<AppColorPalette> onColorPaletteChanged;
  final String defaultCurrency;
  final ValueChanged<String> onDefaultCurrencyChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  late ThemeMode _themeMode;
  late AppColorPalette _colorPalette;
  late String _defaultCurrency;
  late String _languageCode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    _colorPalette = widget.colorPalette;
    _defaultCurrency = widget.defaultCurrency;
    _languageCode = widget.languageCode;
  }

  void _setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    AppMotion.selectionHaptic();
    setState(() => _themeMode = mode);
    widget.onThemeModeChanged(mode);
  }

  void _setPalette(AppColorPalette palette) {
    if (_colorPalette == palette) return;
    AppMotion.selectionHaptic();
    setState(() => _colorPalette = palette);
    widget.onColorPaletteChanged(palette);
  }

  void _setCurrency(String code) {
    if (_defaultCurrency == code) return;
    AppMotion.selectionHaptic();
    setState(() => _defaultCurrency = code);
    widget.onDefaultCurrencyChanged(code);
  }

  void _setLanguage(String code) {
    if (_languageCode == code) return;
    AppMotion.selectionHaptic();
    setState(() => _languageCode = code);
    widget.onLanguageChanged(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsAppearanceTitle, style: theme.textTheme.titleMedium),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 680,
        child: ListView(
          padding: Responsive.pagePadding(context, bottom: 32),
          children: [
            // Theme Mode & Color Palette
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.themeMode, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _ThemeOptionButton(
                          label: s.themeSystem,
                          selected: _themeMode == ThemeMode.system,
                          onTap: () => _setThemeMode(ThemeMode.system),
                        ),
                        _ThemeOptionButton(
                          label: s.themeLight,
                          selected: _themeMode == ThemeMode.light,
                          onTap: () => _setThemeMode(ThemeMode.light),
                        ),
                        _ThemeOptionButton(
                          label: s.themeDark,
                          selected: _themeMode == ThemeMode.dark,
                          onTap: () => _setThemeMode(ThemeMode.dark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(s.colorPalette, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppColorPalette.values.map((palette) {
                      final selected = _colorPalette == palette;
                      final swatch = AppColors.tokensFor(palette).swatch;
                      return Material(
                        color: selected
                            ? cs.primaryFixed
                            : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _setPalette(palette),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? swatch
                                    : cs.outlineVariant.withValues(alpha: 0.4),
                                width: selected ? 1.5 : 0.75,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: swatch,
                                    shape: BoxShape.circle,
                                  ),
                                  child: selected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 12,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  palette.label,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: selected
                                        ? cs.onPrimaryFixed
                                        : cs.onSurface,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Language & Default Currency
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _showLanguageSheet(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              s.language,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _languageCode == 'id'
                                      ? 'Bahasa Indonesia'
                                      : 'English (US)',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 18,
                                  color: cs.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          s.defaultCurrency,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ['IDR', 'USD'].map((code) {
                            final selected = _defaultCurrency == code;
                            return GestureDetector(
                              onTap: () => _setCurrency(code),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? cs.primaryContainer
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  code == 'IDR' ? 'IDR (Rp)' : 'USD (\$)',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : cs.onSurfaceVariant,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.selectLanguage, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor:
                    _languageCode == 'en' ? cs.surfaceContainerLow : null,
                title: const Text('English (US)'),
                trailing: _languageCode == 'en'
                    ? Icon(Icons.check_rounded, color: cs.primary)
                    : null,
                onTap: () {
                  _setLanguage('en');
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor:
                    _languageCode == 'id' ? cs.surfaceContainerLow : null,
                title: const Text('Bahasa Indonesia'),
                trailing: _languageCode == 'id'
                    ? Icon(Icons.check_rounded, color: cs.primary)
                    : null,
                onTap: () {
                  _setLanguage('id');
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  const _ThemeOptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? cs.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF131B2E).withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? cs.primary : cs.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
