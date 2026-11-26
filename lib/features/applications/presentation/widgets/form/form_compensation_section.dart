import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/enums/application_enums.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/widgets/applyflow_widgets.dart';
import 'form_core_section.dart';

class FormCompensationSection extends StatelessWidget {
  const FormCompensationSection({
    super.key,
    required this.salaryCtrl,
    required this.offeredSalaryCtrl,
    required this.platformCtrl,
    required this.urlCtrl,
    required this.recruiterNameCtrl,
    required this.recruiterContactCtrl,
    required this.currency,
    required this.salaryPeriod,
    required this.statusId,
    required this.isEditing,
    required this.onSalaryPeriodChanged,
    required this.onToggleCurrency,
    required this.onPlatformChanged,
    required this.onClearPlatform,
    required this.onSelectPlatformPreset,
  });

  final TextEditingController salaryCtrl;
  final TextEditingController offeredSalaryCtrl;
  final TextEditingController platformCtrl;
  final TextEditingController urlCtrl;
  final TextEditingController recruiterNameCtrl;
  final TextEditingController recruiterContactCtrl;
  final String currency;
  final SalaryPeriod salaryPeriod;
  final String statusId;
  final bool isEditing;
  final ValueChanged<SalaryPeriod> onSalaryPeriodChanged;
  final VoidCallback onToggleCurrency;
  final VoidCallback onPlatformChanged;
  final VoidCallback onClearPlatform;
  final ValueChanged<String> onSelectPlatformPreset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);

    final showOfferedField = statusId == ApplicationStatus.offering.name ||
        statusId == ApplicationStatus.offerAccepted.name ||
        statusId == ApplicationStatus.offerDeclined.name ||
        statusId.contains('offer') ||
        isEditing ||
        offeredSalaryCtrl.text.isNotEmpty;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            icon: Icons.payments_outlined,
            iconBg: cs.surfaceContainerHigh,
            iconFg: cs.onSurface,
            title: s.compensationRef,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  s.expectedCompensation,
                  style: theme.textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: SalaryPeriod.values.map((period) {
                    final selected = salaryPeriod == period;
                    final pLabel = period == SalaryPeriod.yearly
                        ? (s.isId ? '/thn' : '/yr')
                        : (s.isId ? '/bln' : '/mo');
                    return GestureDetector(
                      onTap: () => onSalaryPeriodChanged(period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.surfaceContainerLowest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected ? cs.primary : cs.onSurfaceVariant,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: Material(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onToggleCurrency,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(
                            currency == 'IDR' ? 'IDR (Rp)' : 'USD (\$)',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.swap_vert_rounded,
                              size: 18, color: cs.outline),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: salaryCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 15,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    hintText: currency == 'IDR' ? '25000000' : '120000',
                    suffixText: 'GROSS',
                    suffixStyle: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.outline),
                  ),
                ),
              ),
            ],
          ),
          if (showOfferedField) ...[
            const SizedBox(height: 14),
            Text(s.offeredCompensation, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            TextFormField(
              controller: offeredSalaryCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 15,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              decoration: InputDecoration(
                hintText: currency == 'IDR' ? '30000000' : '140000',
                prefixIcon:
                    const Icon(Icons.workspace_premium_outlined, size: 20),
                suffixText: currency,
                suffixStyle:
                    theme.textTheme.labelSmall?.copyWith(color: cs.outline),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(s.sourcePlatform, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: platformCtrl,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => onPlatformChanged(),
            decoration: InputDecoration(
              hintText: s.sourcePlatformHint,
              prefixIcon: const Icon(Icons.public_rounded, size: 20),
              suffixIcon: platformCtrl.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: onClearPlatform,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: s.platformPresets.map((preset) {
              final selected = platformCtrl.text.trim().toLowerCase() ==
                  preset.toLowerCase();
              return ChoiceChip(
                label: Text(preset),
                selected: selected,
                showCheckmark: false,
                selectedColor: cs.primaryContainer,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                backgroundColor: cs.surfaceContainer,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                onSelected: (isSel) =>
                    onSelectPlatformPreset(isSel ? preset : ''),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(s.jobVacancyLink, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: urlCtrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'https://careers.company.com/job/123',
              prefixIcon: Icon(Icons.link_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          Text(s.recruiterInfoOptional, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final nameField = TextFormField(
                controller: recruiterNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: s.name,
                  prefixIcon: const Icon(Icons.person_outline, size: 19),
                ),
              );
              final contactField = TextFormField(
                controller: recruiterContactCtrl,
                decoration: InputDecoration(
                  hintText: s.emailPhone,
                  prefixIcon: const Icon(
                    Icons.alternate_email_rounded,
                    size: 19,
                  ),
                ),
              );
              if (constraints.maxWidth < 360) {
                return Column(
                  children: [
                    nameField,
                    const SizedBox(height: 8),
                    contactField,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: nameField),
                  const SizedBox(width: 8),
                  Expanded(child: contactField),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
