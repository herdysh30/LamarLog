part of 'applications_bloc.dart';

class ApplicationsState extends Equatable {
  const ApplicationsState({
    this.applications = const [],
    this.searchQuery = '',
    this.workplaceFilter,
    this.priorityFilter,
    this.staleOnlyFilter = false,
    this.stageFilter = const {},
    this.sortOption = PipelineSortOption.latestMove,
    this.isLoading = true,
    this.errorMessage,
    this.actionErrorMessage,
    this.actionErrorId = 0,
  });

  final List<JobApplication> applications;
  final String searchQuery;
  final WorkplaceType? workplaceFilter;
  final PriorityLevel? priorityFilter;
  final bool staleOnlyFilter;

  /// Active stage IDs to show in the pipeline. Empty = all stages.
  final Set<String> stageFilter;
  final PipelineSortOption sortOption;
  final bool isLoading;
  final String? errorMessage;
  final String? actionErrorMessage;
  final int actionErrorId;

  bool get hasActiveFilters =>
      workplaceFilter != null ||
      priorityFilter != null ||
      staleOnlyFilter ||
      stageFilter.isNotEmpty ||
      sortOption != PipelineSortOption.latestMove;

  bool get hasStageFilter => stageFilter.isNotEmpty;

  /// Whether a stage column / its applications should be visible.
  bool isStageVisible(String stageId) =>
      stageFilter.isEmpty || stageFilter.contains(stageId);

  List<JobApplication> get staleApplications =>
      StaleApplicationHelper.findStale(applications);

  List<JobApplication> get filteredApplications {
    var result = applications.where((app) {
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matches = app.companyName.toLowerCase().contains(q) ||
            app.roleTitle.toLowerCase().contains(q) ||
            app.location.toLowerCase().contains(q) ||
            app.currentStatus.toLowerCase().contains(q) ||
            (app.sourcePlatform?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }
      if (workplaceFilter != null &&
          app.workplaceType != workplaceFilter!.name) {
        return false;
      }
      if (priorityFilter != null && app.priority != priorityFilter!.name) {
        return false;
      }
      if (staleOnlyFilter && !StaleApplicationHelper.isStale(app)) {
        return false;
      }
      return true;
    }).toList();

    switch (sortOption) {
      case PipelineSortOption.latestMove:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case PipelineSortOption.salaryHighToLow:
        result.sort((a, b) {
          final sa = a.expectedSalary ?? 0;
          final sb = b.expectedSalary ?? 0;
          return sb.compareTo(sa);
        });
    }
    return result;
  }

  /// Active (non-terminal) applications matching search & sheet filters,
  /// ignoring the stage filter. Used for "All" counts.
  List<JobApplication> get activeApplicationsAllStages {
    return filteredApplications
        .where((app) => !PipelineStageConfig.isTerminalStatusId(app.currentStatus))
        .toList();
  }

  /// Active applications after every filter, including the stage filter.
  List<JobApplication> get activeApplications {
    final all = activeApplicationsAllStages;
    if (stageFilter.isEmpty) return all;
    return all.where((app) => stageFilter.contains(app.currentStatus)).toList();
  }

  List<JobApplication> byStatusId(String statusId) {
    return filteredApplications
        .where((app) => app.currentStatus == statusId)
        .toList();
  }

  List<JobApplication> byStatus(ApplicationStatus status) =>
      byStatusId(status.name);

  List<JobApplication> get terminalApplications {
    return filteredApplications
        .where((app) => PipelineStageConfig.isTerminalStatusId(app.currentStatus))
        .toList();
  }

  ApplicationsState copyWith({
    List<JobApplication>? applications,
    String? searchQuery,
    WorkplaceType? workplaceFilter,
    bool clearWorkplaceFilter = false,
    PriorityLevel? priorityFilter,
    bool clearPriorityFilter = false,
    bool? staleOnlyFilter,
    Set<String>? stageFilter,
    PipelineSortOption? sortOption,
    bool? isLoading,
    String? errorMessage,
    String? actionErrorMessage,
    int? actionErrorId,
  }) {
    return ApplicationsState(
      applications: applications ?? this.applications,
      searchQuery: searchQuery ?? this.searchQuery,
      workplaceFilter: clearWorkplaceFilter
          ? null
          : (workplaceFilter ?? this.workplaceFilter),
      priorityFilter: clearPriorityFilter
          ? null
          : (priorityFilter ?? this.priorityFilter),
      staleOnlyFilter: staleOnlyFilter ?? this.staleOnlyFilter,
      stageFilter: stageFilter ?? this.stageFilter,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      actionErrorMessage: actionErrorMessage ?? this.actionErrorMessage,
      actionErrorId: actionErrorId ?? this.actionErrorId,
    );
  }

  @override
  List<Object?> get props => [
        applications,
        searchQuery,
        workplaceFilter,
        priorityFilter,
        staleOnlyFilter,
        stageFilter,
        sortOption,
        isLoading,
        errorMessage,
        actionErrorMessage,
        actionErrorId,
      ];
}
