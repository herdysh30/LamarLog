import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/motion/app_motion.dart';
import '../../../../../core/services/indonesia_regions_service.dart';
import '../../../../../core/widgets/applyflow_widgets.dart';

class FormSectionHeader extends StatelessWidget {
  const FormSectionHeader({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconFg),
            ),
            const SizedBox(width: 10),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        ?trailing,
      ],
    );
  }
}

class FormCoreSection extends StatelessWidget {
  const FormCoreSection({
    super.key,
    required this.companyCtrl,
    required this.roleCtrl,
    required this.locationCtrl,
    required this.locationFocus,
    required this.regionSuggestions,
    required this.showRegionSuggestions,
    required this.onLocationChanged,
    required this.onClearLocation,
    required this.onSelectRegion,
  });

  final TextEditingController companyCtrl;
  final TextEditingController roleCtrl;
  final TextEditingController locationCtrl;
  final FocusNode locationFocus;
  final List<RegionSuggestion> regionSuggestions;
  final bool showRegionSuggestions;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onClearLocation;
  final ValueChanged<RegionSuggestion> onSelectRegion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            icon: Icons.business_center_outlined,
            iconBg: cs.primaryFixed,
            iconFg: cs.onPrimaryFixed,
            title: s.coreDetails,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(s.requiredTag, style: theme.textTheme.labelSmall),
            ),
          ),
          const SizedBox(height: 14),
          Text(s.companyName, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: companyCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: s.companyHint,
              prefixIcon: const Icon(Icons.domain_outlined, size: 20),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? s.companyRequired : null,
          ),
          const SizedBox(height: 14),
          Text(s.roleTitle, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: roleCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: s.roleHint,
              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? s.roleRequired : null,
          ),
          const SizedBox(height: 14),
          Text(s.location, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: locationCtrl,
            focusNode: locationFocus,
            textCapitalization: TextCapitalization.words,
            onChanged: onLocationChanged,
            decoration: InputDecoration(
              hintText: s.locationAutocompleteHint,
              prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
              suffixIcon: locationCtrl.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: onClearLocation,
                    )
                  : null,
            ),
          ),
          AnimatedSize(
            duration: AppMotion.duration(context, AppMotion.medium),
            curve: AppMotion.enterCurve,
            alignment: Alignment.topCenter,
            child: (showRegionSuggestions && regionSuggestions.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 240),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shrinkWrap: true,
                        itemCount: regionSuggestions.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: cs.outlineVariant.withValues(alpha: 0.25),
                        ),
                        itemBuilder: (_, idx) {
                          final item = regionSuggestions[idx];
                          final levelTag = switch (item.level) {
                            RegionLevel.district => s.districtTag,
                            RegionLevel.regency => s.cityTag,
                            RegionLevel.province => s.provinceTag,
                            RegionLevel.globalHub => 'Global',
                          };
                          return InkWell(
                            onTap: () => onSelectRegion(item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              child: Row(
                                children: [
                                  Icon(
                                    item.level == RegionLevel.globalHub
                                        ? Icons.public_rounded
                                        : Icons.location_on_outlined,
                                    size: 17,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.primaryText,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(fontSize: 13.5),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (item.secondaryText.isNotEmpty)
                                          Text(
                                            item.secondaryText,
                                            style: theme.textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      levelTag,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        fontSize: 10,
                                        color: cs.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
