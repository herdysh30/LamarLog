import 'package:applyflow/core/database/app_database.dart';
import 'package:applyflow/core/enums/application_enums.dart';
import 'package:applyflow/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

JobApplication _app({
  required String id,
  required String company,
  required String role,
  String status = 'applied',
  String priority = 'medium',
  String workplace = 'remote',
  String? platform,
  double? expectedSalary,
  DateTime? updatedAt,
}) {
  final ts = (updatedAt ?? DateTime.now().toUtc()).toUtc();
  return JobApplication(
    id: id,
    companyName: company,
    roleTitle: role,
    location: 'Jakarta',
    workplaceType: workplace,
    jobType: JobType.fullTime.name,
    currentStatus: status,
    priority: priority,
    currency: 'IDR',
    salaryPeriod: SalaryPeriod.monthly.name,
    expectedSalary: expectedSalary,
    offeredSalary: null,
    vacancyUrl: null,
    sourcePlatform: platform,
    recruiterName: null,
    recruiterContact: null,
    isArchived: false,
    appliedAt: status == 'wishlist' ? null : ts,
    createdAt: ts,
    updatedAt: ts,
  );
}

void main() {
  group('ApplicationsState filtering, search, sorting & pipeline separation', () {
    final now = DateTime.now().toUtc();
    final apps = [
      _app(
        id: '1',
        company: 'Gojek',
        role: 'Mobile Engineer',
        status: ApplicationStatus.applied.name,
        priority: PriorityLevel.high.name,
        workplace: WorkplaceType.hybrid.name,
        platform: 'LinkedIn',
        expectedSalary: 28000000,
        updatedAt: now.subtract(const Duration(days: 16)),
      ),
      _app(
        id: '2',
        company: 'Traveloka',
        role: 'Flutter Developer',
        status: ApplicationStatus.interview.name,
        priority: PriorityLevel.medium.name,
        workplace: WorkplaceType.remote.name,
        platform: 'Glints',
        expectedSalary: 32000000,
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      _app(
        id: '3',
        company: 'Tokopedia',
        role: 'Senior Mobile Dev',
        status: ApplicationStatus.rejected.name,
        priority: PriorityLevel.low.name,
        workplace: WorkplaceType.onsite.name,
        platform: 'JobStreet',
        expectedSalary: 25000000,
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    test('strictly separates active pipeline stages from terminal outcomes', () {
      final state = ApplicationsState(applications: apps, isLoading: false);

      expect(state.activeApplications.map((e) => e.id).toList(),
          containsAll(['1', '2']));
      expect(state.activeApplications.map((e) => e.id), isNot(contains('3')));
      expect(state.terminalApplications.map((e) => e.id).toList(), ['3']);
    });

    test('matches search query by sourcePlatform as well as company & role', () {
      final state = ApplicationsState(
        applications: apps,
        searchQuery: 'glints',
        isLoading: false,
      );

      expect(state.filteredApplications.length, 1);
      expect(state.filteredApplications.first.companyName, 'Traveloka');
    });

    test('filters stale-only applications (>=14 days in Applied/Screening)', () {
      final state = ApplicationsState(
        applications: apps,
        staleOnlyFilter: true,
        isLoading: false,
      );

      expect(state.hasActiveFilters, isTrue);
      expect(state.filteredApplications.length, 1);
      expect(state.filteredApplications.first.id, '1');
    });

    test('sorts by salaryHighToLow accurately', () {
      final state = ApplicationsState(
        applications: apps,
        sortOption: PipelineSortOption.salaryHighToLow,
        isLoading: false,
      );

      expect(
        state.filteredApplications.map((e) => e.id).toList(),
        ['2', '1', '3'],
      );
    });
  });
}
