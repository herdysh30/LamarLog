import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';
import '../enums/application_enums.dart';

/// Shared ApplyFlow brand top bar used across primary tabs.
/// Clean by default (no redundant offline badge unless explicitly provided, e.g. in Settings).
class ApplyFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ApplyFlowAppBar({
    super.key,
    required this.subtitle,
    this.trailing,
  });

  final String subtitle;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      toolbarHeight: 64,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer,
                  cs.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: cs.primaryContainer.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.layers_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ApplyFlow',
                  style: theme.textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: trailing!,
          ),
      ],
    );
  }
}

/// Compact status pill used exclusively in Settings to communicate local offline storage.
class OfflineStatusPill extends StatelessWidget {
  const OfflineStatusPill({
    super.key,
    this.label = 'Offline Ready',
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 13, color: cs.tertiary)
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: cs.tertiary,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.tertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Consistent soft-elevated surface card wrapper aligned with ApplyFlow design tokens.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final cardColor =
        color ?? (isDark ? cs.surfaceContainer : cs.surfaceContainerLowest);

    final decoration = BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? cs.outlineVariant.withValues(alpha: 0.75)
            : cs.outlineVariant.withValues(alpha: 0.4),
        width: 0.8,
      ),
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: const Color(0xFF131B2E).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
    );

    if (onTap == null) {
      return Container(
        decoration: decoration,
        padding: padding,
        child: child,
      );
    }

    return Container(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Consistent company monogram avatar with palette-harmonized tint.
class CompanyMonogram extends StatelessWidget {
  const CompanyMonogram({
    super.key,
    required this.companyName,
    this.size = 42,
    this.radius = 12,
    this.filled = false,
  });

  final String companyName;
  final double size;
  final double radius;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final initial =
        companyName.trim().isNotEmpty ? companyName.trim()[0].toUpperCase() : '?';

    final hash = companyName.codeUnits.fold<int>(0, (acc, c) => acc + c);
    final palette = [
      (cs.primaryFixed, cs.onPrimaryFixed),
      (cs.secondaryContainer, cs.onSecondaryContainer),
      (cs.surfaceContainerHigh, cs.primary),
      (cs.tertiaryContainer.withValues(alpha: 0.16), cs.tertiary),
    ];
    final (bg, fg) = filled
        ? (cs.primaryContainer, Colors.white)
        : palette[hash % palette.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: (size >= 48
                ? theme.textTheme.headlineMedium
                : theme.textTheme.titleMedium)
            ?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Shared currency + cadence salary formatter with tabular numeral support.
String formatCurrencyValue(double amount, String currency) {
  if (currency == 'IDR') {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  ).format(amount);
}

String formatSalaryAmount(JobApplication app,
    {String fallback = 'Salary unlisted'}) {
  final salary = app.expectedSalary;
  if (salary == null || salary <= 0) return fallback;
  return formatCurrencyValue(salary, app.currency);
}

String salaryPeriodSuffix(JobApplication app, {bool isId = false}) {
  if (app.salaryPeriod == SalaryPeriod.yearly.name) {
    return isId ? '/thn' : '/yr';
  }
  return isId ? '/bln' : '/mo';
}
