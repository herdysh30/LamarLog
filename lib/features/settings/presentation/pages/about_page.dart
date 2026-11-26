import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../../../../core/widgets/send_report_dialog.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String appVersion = '1.1.0';
  static final Uri _repoUri =
      Uri.parse('https://github.com/herdysh30/LamarLog');
  static final Uri _releasesUri =
      Uri.parse('https://github.com/herdysh30/LamarLog/releases');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocaleScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.aboutApp, style: theme.textTheme.titleMedium),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 680,
        child: ListView(
          padding: Responsive.pagePadding(context, bottom: 36),
          children: [
            // Hero Brand Card
            SurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: cs.primaryContainer,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.view_kanban_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LamarLog',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primaryFixed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'v$appVersion',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onPrimaryFixed,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      s.aboutTagline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Core Principles & Highlights
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                s.aboutHighlightsTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            SurfaceCard(
              child: Column(
                children: [
                  _AboutFeatureRow(
                    icon: Icons.lock_outline_rounded,
                    iconBg: cs.primaryFixed,
                    iconFg: cs.onPrimaryFixed,
                    title: s.aboutStorageTitle,
                    subtitle: s.aboutStorageDesc,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  _AboutFeatureRow(
                    icon: Icons.view_kanban_outlined,
                    iconBg: cs.secondaryContainer,
                    iconFg: cs.onSecondaryContainer,
                    title: s.aboutKanbanTitle,
                    subtitle: s.aboutKanbanDesc,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  _AboutFeatureRow(
                    icon: Icons.pin_drop_outlined,
                    iconBg: cs.tertiaryContainer.withValues(alpha: 0.2),
                    iconFg: cs.tertiary,
                    title: s.aboutRegionsTitle,
                    subtitle: s.aboutRegionsDesc,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Links & Licenses
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                s.aboutResourcesTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                children: [
                  _AboutLinkTile(
                    icon: Icons.bug_report_outlined,
                    title: s.aboutReportBug,
                    subtitle: s.aboutReportBugSub,
                    trailingIcon: Icons.chevron_right_rounded,
                    onTap: () {
                      AppMotion.selectionHaptic();
                      showSendReportDialog(context);
                    },
                  ),
                  const Divider(indent: 14, endIndent: 14),
                  _AboutLinkTile(
                    icon: Icons.code_rounded,
                    title: s.aboutGithubRepo,
                    subtitle: 'github.com/herdysh30/LamarLog',
                    trailingIcon: Icons.open_in_new_rounded,
                    onTap: () => _openUri(context, _repoUri, s),
                  ),
                  const Divider(indent: 14, endIndent: 14),
                  _AboutLinkTile(
                    icon: Icons.new_releases_outlined,
                    title: s.aboutReleases,
                    subtitle: 'github.com/herdysh30/LamarLog/releases',
                    trailingIcon: Icons.open_in_new_rounded,
                    onTap: () => _openUri(context, _releasesUri, s),
                  ),
                  const Divider(indent: 14, endIndent: 14),
                  _AboutLinkTile(
                    icon: Icons.description_outlined,
                    title: s.aboutOpenSourceLicenses,
                    subtitle: s.aboutOpenSourceSub,
                    trailingIcon: Icons.chevron_right_rounded,
                    onTap: () {
                      AppMotion.selectionHaptic();
                      showLicensePage(
                        context: context,
                        applicationName: 'LamarLog',
                        applicationVersion: 'v$appVersion',
                        applicationIcon: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Footer Note
            Column(
              children: [
                Text(
                  s.aboutBuiltWith,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.footerStorageNote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUri(BuildContext context, Uri uri, AppStrings s) async {
    AppMotion.selectionHaptic();
    final ok = await ContactLauncher.launch(uri);
    if (!ok && context.mounted) {
      showErrorSnackBar(context, s.couldNotOpenLink);
    }
  }
}

class _AboutFeatureRow extends StatelessWidget {
  const _AboutFeatureRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconFg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutLinkTile extends StatelessWidget {
  const _AboutLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 19, color: cs.primary),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(trailingIcon, size: 18, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
