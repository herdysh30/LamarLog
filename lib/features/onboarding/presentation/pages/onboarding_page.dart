import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/widgets/applyflow_widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onCompleted,
  });

  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onCompleted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    final slides = [
      _SlideData(
        icon: Icons.view_kanban_rounded,
        accentBg: cs.primaryFixed,
        accentFg: cs.onPrimaryFixed,
        title: s.onboard1Title,
        body: s.onboard1Body,
        preview: _KanbanMiniPreview(cs: cs),
      ),
      _SlideData(
        icon: Icons.notifications_active_rounded,
        accentBg: cs.secondaryContainer,
        accentFg: cs.onSecondaryContainer,
        title: s.onboard2Title,
        body: s.onboard2Body,
        preview: _ScheduleMiniPreview(cs: cs),
      ),
      _SlideData(
        icon: Icons.insights_rounded,
        accentBg: cs.tertiaryContainer.withValues(alpha: 0.16),
        accentFg: cs.tertiary,
        title: s.onboard3Title,
        body: s.onboard3Body,
        preview: _AnalyticsMiniPreview(cs: cs),
      ),
    ];

    final isLast = _currentPage == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 520,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              // Top bar: Brand + Language Switcher + Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const LamarLogLogoMark(size: 32, radius: 9, iconSize: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'LamarLog',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Quick EN / ID switcher
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ['en', 'id'].map((code) {
                            final selected = widget.languageCode == code;
                            return GestureDetector(
                              onTap: () => widget.onLanguageChanged(code),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? cs.primaryContainer
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  code.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 4),
                        TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                          ),
                          onPressed: widget.onCompleted,
                          child: Text(s.skip),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Slides PageView (scrollable inside LayoutBuilder for landscape phones)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                slide.preview,
                                const SizedBox(height: 24),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: slide.accentBg,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(slide.icon,
                                      color: slide.accentFg, size: 24),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 320),
                                  child: Text(
                                    slide.body,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (index) {
                  final active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? cs.primaryContainer : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),

              // Primary CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (isLast) {
                      widget.onCompleted();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? s.getStarted : s.next,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isLast
                            ? Icons.check_circle_outline_rounded
                            : Icons.arrow_forward_rounded,
                        size: 19,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.accentBg,
    required this.accentFg,
    required this.title,
    required this.body,
    required this.preview,
  });

  final IconData icon;
  final Color accentBg;
  final Color accentFg;
  final String title;
  final String body;
  final Widget preview;
}

class _KanbanMiniPreview extends StatelessWidget {
  const _KanbanMiniPreview({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _MiniStageColumn(
              label: 'Applied',
              dotColor: cs.primaryContainer,
              items: const ['Stripe', 'Figma'],
              cs: cs,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStageColumn(
              label: 'Interview',
              dotColor: cs.tertiary,
              items: const ['Traveloka'],
              cs: cs,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStageColumn extends StatelessWidget {
  const _MiniStageColumn({
    required this.label,
    required this.dotColor,
    required this.items,
    required this.cs,
  });

  final String label;
  final Color dotColor;
  final List<String> items;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (name) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(name, style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleMiniPreview extends StatelessWidget {
  const _ScheduleMiniPreview({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cs.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.videocam_outlined,
                    color: cs.onPrimaryFixed, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Technical Interview',
                        style: theme.textTheme.titleSmall),
                    Text('Thu • 14:00 • 24h & 1h alerts',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf_rounded, size: 18, color: cs.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('CV_Flutter_Senior_2026.pdf',
                      style: theme.textTheme.labelMedium),
                ),
                Icon(Icons.check_circle_rounded, size: 16, color: cs.tertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsMiniPreview extends StatelessWidget {
  const _AnalyticsMiniPreview({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interview Rate', style: theme.textTheme.labelMedium),
              Text(
                '41.7%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.72,
              minHeight: 8,
              backgroundColor: cs.surfaceContainer,
              valueColor: AlwaysStoppedAnimation(cs.primaryContainer),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.42,
              minHeight: 8,
              backgroundColor: cs.surfaceContainer,
              valueColor: AlwaysStoppedAnimation(cs.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}
