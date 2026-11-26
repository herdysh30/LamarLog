import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/services/indonesia_regions_service.dart';
import '../bloc/applications_bloc.dart';
import '../widgets/form/form_compensation_section.dart';
import '../widgets/form/form_core_section.dart';
import '../widgets/form/form_work_and_status_section.dart';

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({
    super.key,
    this.existingApplication,
    this.initialStatusId,
    this.defaultCurrency = 'IDR',
  });

  final JobApplication? existingApplication;
  final String? initialStatusId;
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
  late final TextEditingController _platformCtrl;
  late final TextEditingController _recruiterNameCtrl;
  late final TextEditingController _recruiterContactCtrl;
  final FocusNode _locationFocus = FocusNode();

  late WorkplaceType _workplaceType;
  late JobType _jobType;
  late String _statusId;
  late PriorityLevel _priority;
  late String _currency;
  late SalaryPeriod _salaryPeriod;

  List<RegionSuggestion> _regionSuggestions = const [];
  bool _showRegionSuggestions = false;

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
    _platformCtrl = TextEditingController(text: app?.sourcePlatform ?? '');
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
    _statusId = app?.currentStatus ??
        widget.initialStatusId ??
        ApplicationStatus.wishlist.name;
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

    _locationFocus.addListener(_onLocationFocusChanged);
    IndonesiaRegionsService.instance.ensureLoaded();
  }

  Future<void> _onLocationFocusChanged() async {
    if (_locationFocus.hasFocus) {
      await _updateRegionSuggestions(_locationCtrl.text);
      if (mounted) setState(() => _showRegionSuggestions = true);
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (mounted && !_locationFocus.hasFocus) {
        setState(() => _showRegionSuggestions = false);
      }
    }
  }

  Future<void> _updateRegionSuggestions(String query) async {
    final matches =
        await IndonesiaRegionsService.instance.search(query, limit: 8);
    if (mounted) {
      setState(() {
        _regionSuggestions = matches;
        _showRegionSuggestions = _locationFocus.hasFocus && matches.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _locationFocus.removeListener(_onLocationFocusChanged);
    _locationFocus.dispose();
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _offeredSalaryCtrl.dispose();
    _urlCtrl.dispose();
    _platformCtrl.dispose();
    _recruiterNameCtrl.dispose();
    _recruiterContactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = AppLocaleScope.of(context);
    final activeStages = s.pipelineStages;
    if (!widget.isEditing &&
        !activeStages.any((st) => st.id == _statusId) &&
        activeStages.isNotEmpty) {
      _statusId = activeStages.first.id;
    }

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
              FormCoreSection(
                companyCtrl: _companyCtrl,
                roleCtrl: _roleCtrl,
                locationCtrl: _locationCtrl,
                locationFocus: _locationFocus,
                regionSuggestions: _regionSuggestions,
                showRegionSuggestions: _showRegionSuggestions,
                onLocationChanged: _updateRegionSuggestions,
                onClearLocation: () {
                  _locationCtrl.clear();
                  _updateRegionSuggestions('');
                },
                onSelectRegion: (item) {
                  AppMotion.selectionHaptic();
                  _locationCtrl.text = item.displayLabel;
                  _locationCtrl.selection = TextSelection.collapsed(
                    offset: _locationCtrl.text.length,
                  );
                  setState(() => _showRegionSuggestions = false);
                  _locationFocus.unfocus();
                },
              ),
              const SizedBox(height: 14),
              FormWorkArrangementSection(
                workplaceType: _workplaceType,
                jobType: _jobType,
                onWorkplaceChanged: (v) => setState(() => _workplaceType = v),
                onJobTypeChanged: (v) => setState(() => _jobType = v),
              ),
              const SizedBox(height: 14),
              FormPipelineStatusSection(
                activeStages: activeStages,
                statusId: _statusId,
                priority: _priority,
                onStatusChanged: (v) => setState(() => _statusId = v),
                onPriorityChanged: (v) => setState(() => _priority = v),
              ),
              const SizedBox(height: 14),
              FormCompensationSection(
                salaryCtrl: _salaryCtrl,
                offeredSalaryCtrl: _offeredSalaryCtrl,
                platformCtrl: _platformCtrl,
                urlCtrl: _urlCtrl,
                recruiterNameCtrl: _recruiterNameCtrl,
                recruiterContactCtrl: _recruiterContactCtrl,
                currency: _currency,
                salaryPeriod: _salaryPeriod,
                statusId: _statusId,
                isEditing: widget.isEditing,
                onSalaryPeriodChanged: (v) => setState(() => _salaryPeriod = v),
                onToggleCurrency: () => setState(
                  () => _currency = _currency == 'IDR' ? 'USD' : 'IDR',
                ),
                onPlatformChanged: () => setState(() {}),
                onClearPlatform: () {
                  _platformCtrl.clear();
                  setState(() {});
                },
                onSelectPlatformPreset: (preset) => setState(
                  () => _platformCtrl.text = preset,
                ),
              ),
              const SizedBox(height: 20),
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
                  icon:
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: Text(
                    widget.isEditing
                        ? s.updateApplication
                        : s.saveApplication,
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
    final platform =
        _platformCtrl.text.trim().isEmpty ? null : _platformCtrl.text.trim();
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
              statusId: _statusId,
              priority: _priority,
              currency: _currency,
              salaryPeriod: _salaryPeriod,
              expectedSalary: parsedSalary,
              offeredSalary: parsedOffered,
              vacancyUrl: url,
              sourcePlatform: platform,
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
              statusId: _statusId,
              priority: _priority,
              currency: _currency,
              salaryPeriod: _salaryPeriod,
              expectedSalary: parsedSalary,
              offeredSalary: parsedOffered,
              vacancyUrl: url,
              sourcePlatform: platform,
              recruiterName: recName,
              recruiterContact: recContact,
            ),
          );
    }

    Navigator.of(context).pop(true);
  }
}
