part of 'applications_bloc.dart';

enum PipelineSortOption {
  latestMove('Latest Stage Move'),
  salaryHighToLow('Salary (High to Low)');

  const PipelineSortOption(this.label);
  final String label;
}

abstract class ApplicationsEvent extends Equatable {
  const ApplicationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadApplications extends ApplicationsEvent {
  const LoadApplications();
}

class _ApplicationsUpdated extends ApplicationsEvent {
  const _ApplicationsUpdated(this.applications);
  final List<JobApplication> applications;

  @override
  List<Object?> get props => [applications];
}

class _ApplicationsLoadFailed extends ApplicationsEvent {
  const _ApplicationsLoadFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class SearchQueryChanged extends ApplicationsEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class UpdateFilters extends ApplicationsEvent {
  const UpdateFilters({
    this.workplaceFilter,
    this.priorityFilter,
    this.staleOnlyFilter = false,
    this.sortOption = PipelineSortOption.latestMove,
  });

  final WorkplaceType? workplaceFilter;
  final PriorityLevel? priorityFilter;
  final bool staleOnlyFilter;
  final PipelineSortOption sortOption;

  @override
  List<Object?> get props => [
        workplaceFilter,
        priorityFilter,
        staleOnlyFilter,
        sortOption,
      ];
}

/// Restricts the active pipeline (Kanban columns & List items) to the given
/// stage IDs. An empty set means "all stages". Terminal outcomes in the
/// archive are never affected by this filter.
class UpdateStageFilter extends ApplicationsEvent {
  const UpdateStageFilter(this.stageIds);
  final Set<String> stageIds;

  @override
  List<Object?> get props => [stageIds];
}

class ToggleStaleFilter extends ApplicationsEvent {
  const ToggleStaleFilter();
}

class ResetFilters extends ApplicationsEvent {
  const ResetFilters();
}

class AddApplication extends ApplicationsEvent {
  const AddApplication({
    required this.companyName,
    required this.roleTitle,
    required this.location,
    required this.workplaceType,
    required this.jobType,
    required this.statusId,
    required this.priority,
    required this.currency,
    required this.salaryPeriod,
    this.expectedSalary,
    this.offeredSalary,
    this.vacancyUrl,
    this.sourcePlatform,
    this.recruiterName,
    this.recruiterContact,
  });

  final String companyName;
  final String roleTitle;
  final String location;
  final WorkplaceType workplaceType;
  final JobType jobType;
  final String statusId;
  final PriorityLevel priority;
  final String currency;
  final SalaryPeriod salaryPeriod;
  final double? expectedSalary;
  final double? offeredSalary;
  final String? vacancyUrl;
  final String? sourcePlatform;
  final String? recruiterName;
  final String? recruiterContact;

  @override
  List<Object?> get props => [
        companyName,
        roleTitle,
        location,
        workplaceType,
        jobType,
        statusId,
        priority,
        currency,
        salaryPeriod,
        expectedSalary,
        offeredSalary,
        vacancyUrl,
        sourcePlatform,
        recruiterName,
        recruiterContact,
      ];
}

class UpdateApplication extends ApplicationsEvent {
  const UpdateApplication({
    required this.existing,
    required this.companyName,
    required this.roleTitle,
    required this.location,
    required this.workplaceType,
    required this.jobType,
    required this.statusId,
    required this.priority,
    required this.currency,
    required this.salaryPeriod,
    this.expectedSalary,
    this.offeredSalary,
    this.vacancyUrl,
    this.sourcePlatform,
    this.recruiterName,
    this.recruiterContact,
  });

  final JobApplication existing;
  final String companyName;
  final String roleTitle;
  final String location;
  final WorkplaceType workplaceType;
  final JobType jobType;
  final String statusId;
  final PriorityLevel priority;
  final String currency;
  final SalaryPeriod salaryPeriod;
  final double? expectedSalary;
  final double? offeredSalary;
  final String? vacancyUrl;
  final String? sourcePlatform;
  final String? recruiterName;
  final String? recruiterContact;

  @override
  List<Object?> get props => [
        existing.id,
        companyName,
        roleTitle,
        location,
        workplaceType,
        jobType,
        statusId,
        priority,
        currency,
        salaryPeriod,
        expectedSalary,
        offeredSalary,
        vacancyUrl,
        sourcePlatform,
        recruiterName,
        recruiterContact,
      ];
}

class MoveApplicationStatus extends ApplicationsEvent {
  const MoveApplicationStatus({
    required this.application,
    required this.newStatusId,
  });

  final JobApplication application;
  final String newStatusId;

  @override
  List<Object?> get props => [application.id, newStatusId];
}

class ReassignStageApplications extends ApplicationsEvent {
  const ReassignStageApplications({
    required this.fromStageId,
    required this.toStageId,
  });

  final String fromStageId;
  final String toStageId;

  @override
  List<Object?> get props => [fromStageId, toStageId];
}

class DeleteApplication extends ApplicationsEvent {
  const DeleteApplication(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
