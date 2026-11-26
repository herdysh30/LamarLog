import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/widgets/applyflow_widgets.dart';
import '../bloc/applications_bloc.dart';

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({
    super.key,
    this.existingApplication,
    this.initialStatus,
    this.defaultCurrency = 'IDR',
  });

  final JobApplication? existingApplication;
  final ApplicationStatus? initialStatus;
  final String defaultCurrency;

  bool get isEditing => existingApplication != null;

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _salaryCtrl;
  late final TextEditingController _offeredSalaryCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _recruiterNameCtrl;
  late final TextEditingController _recruiterContactCtrl;

  late WorkplaceType _workplaceType;
  late JobType _jobType;
  late ApplicationStatus _status;
  late PriorityLevel _priority;
  late String _currency;
  late SalaryPeriod _salaryPeriod;

  @override
  void initState() {
    super.initState();
    final app = widget.existingApplication;

    _companyCtrl = TextEditingController(text: app?.companyName ?? '');
    _roleCtrl = TextEditingController(text: app?.roleTitle ?? '');
    _locationCtrl = TextEditingController(text: app?.location ?? '');
    _salaryCtrl = TextEditingController(
      text: app?.expectedSalary != null
          ? app!.expectedSalary!.toStringAsFixed(0)
          : '',
    );
    _offeredSalaryCtrl = TextEditingController(
      text: app?.offeredSalary != null
          ? app!.offeredSalary!.toStringAsFixed(0)
          : '',
    );
    _urlCtrl = TextEditingController(text: app?.vacancyUrl ?? '');
    _recruiterNameCtrl = TextEditingController(text: app?.recruiterName ?? '');
    _recruiterContactCtrl =
        TextEditingController(text: app?.recruiterContact ?? '');

    _workplaceType = WorkplaceType.values.firstWhere(
      (e) => e.name == app?.workplaceType,
      orElse: () => WorkplaceType.remote,
    );
    _jobType = JobType.values.firstWhere(
      (e) => e.name == app?.jobType,
      orElse: () => JobType.fullTime,
    );
    _status = app != null
        ? ApplicationStatus.values.firstWhere(
            (e) => e.name == app.currentStatus,
            orElse: () => ApplicationStatus.wishlist,
          )
        : (widget.initialStatus ?? ApplicationStatus.wishlist);
    _priority = PriorityLevel.values.firstWhere(
      (e) => e.name == app?.priority,
      orElse: () => PriorityLevel.medium,
    );
    _currency = app?.currency ?? widget.defaultCurrency;
    _salaryPeriod = SalaryPeriod.values.firstWhere(
      (e) => e.name == app?.salaryPeriod,
      orElse: () =>
          _currency == 'USD' ? SalaryPeriod.yearly : SalaryPeriod.monthly,
    );
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _offeredSalaryCtrl.dispose();
    _urlCtrl.dispose();
    _recruiterNameCtrl.dispose();
    _recruiterContactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final s = AppLocaleScope.of(context);
    final activeStages = ApplicationStatus.activeStages;
    final stageIdx = activeStages.indexOf(_status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? s.editApplication : s.addApplication,
          style: theme.textTheme.titleMedium,
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 680,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: Responsive.pagePadding(context, bottom: 32),
          children: [
            // SECTION 1: Core Details
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.business_center_outlined,
                    iconBg: cs.primaryFixed,
                    iconFg: cs.onPrimaryFixed,
                    title: s.coreDetails,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child:
                          Text(s.requiredTag, style: theme.textTheme.labelSmall),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(s.companyName, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _companyCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: s.companyHint,
                      prefixIcon: const Icon(Icons.domain_outlined, size: 20),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.companyRequired
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(s.roleTitle, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _roleCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: s.roleHint,
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.roleRequired
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(s.location, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _locationCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: s.locationHint,
                      prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // SECTION 2: Work & Job Arrangement
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.tune_rounded,
                    iconBg: cs.secondaryContainer,
                    iconFg: cs.onSecondaryContainer,
                    title: s.workArrangement,
                  ),
                  const SizedBox(height: 14),
                  Text(s.workplaceSetting, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: WorkplaceType.values.map((type) {
                      final selected = _workplaceType == type;
                      final icon = switch (type) {
                        WorkplaceType.remote => Icons.public_outlined,
                        WorkplaceType.hybrid => Icons.apartment_outlined,
                        WorkplaceType.onsite => Icons.location_city_outlined,
                      };
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: type != WorkplaceType.values.last ? 8 : 0,
                          ),
                          child: _SelectableChipTile(
                            selected: selected,
                            icon: icon,
                            label: s.workplaceLabel(type),
                            onTap: () => setState(() => _workplaceType = type),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(s.employmentContract, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: JobType.values.map((type) {
                      final selected = _jobType == type;
                      return ChoiceChip(
                        label: Text(s.jobTypeLabel(type)),
                        selected: selected,
                        showCheckmark: true,
                        selectedColor: cs.primaryContainer,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : cs.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: cs.surfaceContainer,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        onSelected: (_) => setState(() => _jobType = type),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // SECTION 3: Pipeline Status & Priority
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.flag_outlined,
                    iconBg: cs.tertiaryContainer.withValues(alpha: 0.16),
                    iconFg: cs.tertiary,
                    title: s.pipelineStatusPriority,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.pipelineStage, style: theme.textTheme.labelMedium),
                      if (stageIdx >= 0)
                        Text(
                          s.stageOf(stageIdx + 1, activeStages.length),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: activeStages.map((stage) {
                        final selected = _status == stage;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Material(
                            color: selected
                                ? cs.primaryContainer
                                : cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                            child: InkWell(
                              onTap: () => setState(() => _status = stage),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 44),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.tertiaryFixedLight
                                            : AppColors.stageDotColor(
                                                stage, brightness),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      s.statusLabel(stage),
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: selected
                                            ? Colors.white
                                            : cs.onSurfaceVariant,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(s.applicationUrgency,
                      style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: PriorityLevel.values.map((level) {
                      final selected = _priority == level;
                      final (bg, fg, dot) =
                          AppColors.priorityColors(level, brightness);
                      final sub = switch (level) {
                        PriorityLevel.high => s.topFocus,
                        PriorityLevel.medium => s.standard,
                        PriorityLevel.low => s.backburner,
                      };
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: level != PriorityLevel.values.last ? 8 : 0,
                          ),
                          child: Material(
                            color: selected ? bg : cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => setState(() => _priority = level),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 54),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: dot,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          s.priorityLabel(level),
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: selected
                                                ? fg
                                                : cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sub,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: selected
                                            ? fg.withValues(alpha: 0.85)
                                            : cs.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // SECTION 4: Compensation & Links
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
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
                            final selected = _salaryPeriod == period;
                            final pLabel = period == SalaryPeriod.yearly
                                ? (s.isId ? '/thn' : '/yr')
                                : (s.isId ? '/bln' : '/mo');
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _salaryPeriod = period),
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
                                    color: selected
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                                    fontWeight: selected
                                        ? FontWeight.w700
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
                            onTap: () {
                              setState(() {
                                _currency = _currency == 'IDR' ? 'USD' : 'IDR';
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Text(
                                    _currency == 'IDR'
                                        ? 'IDR (Rp)'
                                        : 'USD (\$)',
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
                          controller: _salaryCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 15,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: InputDecoration(
                            hintText: _currency == 'IDR' ? '25000000' : '120000',
                            suffixText: 'GROSS',
                            suffixStyle: theme.textTheme.labelSmall
                                ?.copyWith(color: cs.outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_status == ApplicationStatus.offering ||
                      _status == ApplicationStatus.offerAccepted ||
                      _status == ApplicationStatus.offerDeclined ||
                      widget.isEditing ||
                      _offeredSalaryCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(s.offeredCompensation,
                        style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _offeredSalaryCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      decoration: InputDecoration(
                        hintText: _currency == 'IDR' ? '30000000' : '140000',
                        prefixIcon: const Icon(Icons.workspace_premium_outlined,
                            size: 20),
                        suffixText: _currency,
                        suffixStyle: theme.textTheme.labelSmall
                            ?.copyWith(color: cs.outline),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(s.jobVacancyLink, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _urlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'https://careers.company.com/job/123',
                      prefixIcon: Icon(Icons.link_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(s.recruiterInfoOptional,
                      style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final nameField = TextFormField(
                        controller: _recruiterNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: s.name,
                          prefixIcon:
                              const Icon(Icons.person_outline, size: 19),
                        ),
                      );
                      final contactField = TextFormField(
                        controller: _recruiterContactCtrl,
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
            ),
            const SizedBox(height: 20),

            // Ergonomic Action Bar
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: Text(
                  widget.isEditing ? s.updateApplication : s.saveApplication,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(s.cancel),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final parsedSalary = double.tryParse(
      _salaryCtrl.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    final parsedOffered = double.tryParse(
      _offeredSalaryCtrl.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    final url = _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim();
    final recName = _recruiterNameCtrl.text.trim().isEmpty
        ? null
        : _recruiterNameCtrl.text.trim();
    final recContact = _recruiterContactCtrl.text.trim().isEmpty
        ? null
        : _recruiterContactCtrl.text.trim();

    if (widget.isEditing) {
      context.read<ApplicationsBloc>().add(
            UpdateApplication(
              existing: widget.existingApplication!,
              companyName: _companyCtrl.text.trim(),
              roleTitle: _roleCtrl.text.trim(),
              location: _locationCtrl.text.trim(),
              workplaceType: _workplaceType,
              jobType: _jobType,
              status: _status,
              priority: _priority,
              currency: _currency,
              salaryPeriod: _salaryPeriod,
              expectedSalary: parsedSalary,
              offeredSalary: parsedOffered,
              vacancyUrl: url,
              recruiterName: recName,
              recruiterContact: recContact,
            ),
          );
    } else {
      context.read<ApplicationsBloc>().add(
            AddApplication(
              companyName: _companyCtrl.text.trim(),
              roleTitle: _roleCtrl.text.trim(),
              location: _locationCtrl.text.trim(),
              workplaceType: _workplaceType,
              jobType: _jobType,
              status: _status,
              priority: _priority,
              currency: _currency,
              salaryPeriod: _salaryPeriod,
              expectedSalary: parsedSalary,
              offeredSalary: parsedOffered,
              vacancyUrl: url,
              recruiterName: recName,
              recruiterContact: recContact,
            ),
          );
    }

    Navigator.of(context).pop(true);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
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

class _SelectableChipTile extends StatelessWidget {
  const _SelectableChipTile({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primaryContainer : cs.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selected ? Colors.white : cs.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
