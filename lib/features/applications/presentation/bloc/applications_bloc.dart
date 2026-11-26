import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/stale_application_helper.dart';

enum PipelineSortOption {
  latestMove('Latest Stage Move'),
  salaryHighToLow('Salary (High to Low)');

  const PipelineSortOption(this.label);
  final String label;
}

// --- Events ---
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
    required this.status,
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
  final ApplicationStatus status;
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
        status,
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
    required this.status,
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
  final ApplicationStatus status;
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
        status,
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
    required this.newStatus,
  });

  final JobApplication application;
  final ApplicationStatus newStatus;

  @override
  List<Object?> get props => [application.id, newStatus];
}

class DeleteApplication extends ApplicationsEvent {
  const DeleteApplication(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

// --- State ---
class ApplicationsState extends Equatable {
  const ApplicationsState({
    this.applications = const [],
    this.searchQuery = '',
    this.workplaceFilter,
    this.priorityFilter,
    this.staleOnlyFilter = false,
    this.sortOption = PipelineSortOption.latestMove,
    this.isLoading = true,
    this.errorMessage,
  });

  final List<JobApplication> applications;
  final String searchQuery;
  final WorkplaceType? workplaceFilter;
  final PriorityLevel? priorityFilter;
  final bool staleOnlyFilter;
  final PipelineSortOption sortOption;
  final bool isLoading;
  final String? errorMessage;

  bool get hasActiveFilters =>
      workplaceFilter != null ||
      priorityFilter != null ||
      staleOnlyFilter ||
      sortOption != PipelineSortOption.latestMove;

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

  List<JobApplication> get activeApplications {
    final activeNames =
        ApplicationStatus.activeStages.map((e) => e.name).toSet();
    return filteredApplications
        .where((app) => activeNames.contains(app.currentStatus))
        .toList();
  }

  List<JobApplication> byStatus(ApplicationStatus status) {
    return filteredApplications
        .where((app) => app.currentStatus == status.name)
        .toList();
  }

  List<JobApplication> get terminalApplications {
    final terminalNames =
        ApplicationStatus.terminalOutcomes.map((e) => e.name).toSet();
    return filteredApplications
        .where((app) => terminalNames.contains(app.currentStatus))
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
    PipelineSortOption? sortOption,
    bool? isLoading,
    String? errorMessage,
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
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        applications,
        searchQuery,
        workplaceFilter,
        priorityFilter,
        staleOnlyFilter,
        sortOption,
        isLoading,
        errorMessage,
      ];
}

// --- BLoC ---
class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  ApplicationsBloc(this._db) : super(const ApplicationsState()) {
    on<LoadApplications>(_onLoadApplications);
    on<_ApplicationsUpdated>(_onApplicationsUpdated);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<UpdateFilters>(_onUpdateFilters);
    on<ToggleStaleFilter>(_onToggleStaleFilter);
    on<ResetFilters>(_onResetFilters);
    on<AddApplication>(_onAddApplication);
    on<UpdateApplication>(_onUpdateApplication);
    on<MoveApplicationStatus>(_onMoveApplicationStatus);
    on<DeleteApplication>(_onDeleteApplication);
  }

  final AppDatabase _db;
  final _uuid = const Uuid();
  StreamSubscription<List<JobApplication>>? _subscription;

  Future<void> _onLoadApplications(
    LoadApplications event,
    Emitter<ApplicationsState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _db.watchActiveApplications().listen(
      (apps) => add(_ApplicationsUpdated(apps)),
      onError: (Object e) {
        // Handled cleanly
      },
    );
  }

  void _onApplicationsUpdated(
    _ApplicationsUpdated event,
    Emitter<ApplicationsState> emit,
  ) {
    emit(state.copyWith(applications: event.applications, isLoading: false));
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<ApplicationsState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onUpdateFilters(
    UpdateFilters event,
    Emitter<ApplicationsState> emit,
  ) {
    emit(state.copyWith(
      workplaceFilter: event.workplaceFilter,
      clearWorkplaceFilter: event.workplaceFilter == null,
      priorityFilter: event.priorityFilter,
      clearPriorityFilter: event.priorityFilter == null,
      staleOnlyFilter: event.staleOnlyFilter,
      sortOption: event.sortOption,
    ));
  }

  void _onToggleStaleFilter(
    ToggleStaleFilter event,
    Emitter<ApplicationsState> emit,
  ) {
    emit(state.copyWith(staleOnlyFilter: !state.staleOnlyFilter));
  }

  void _onResetFilters(
    ResetFilters event,
    Emitter<ApplicationsState> emit,
  ) {
    emit(state.copyWith(
      clearWorkplaceFilter: true,
      clearPriorityFilter: true,
      staleOnlyFilter: false,
      sortOption: PipelineSortOption.latestMove,
    ));
  }

  Future<void> _onAddApplication(
    AddApplication event,
    Emitter<ApplicationsState> emit,
  ) async {
    final now = DateTime.now().toUtc();
    final appId = _uuid.v4();
    final appliedAt = event.status == ApplicationStatus.wishlist ? null : now;

    await _db.insertApplicationWithTransition(
      JobApplicationsCompanion.insert(
        id: appId,
        companyName: event.companyName,
        roleTitle: event.roleTitle,
        location: Value(event.location),
        workplaceType: Value(event.workplaceType.name),
        jobType: Value(event.jobType.name),
        currentStatus: Value(event.status.name),
        priority: Value(event.priority.name),
        currency: Value(event.currency),
        salaryPeriod: Value(event.salaryPeriod.name),
        expectedSalary: Value(event.expectedSalary),
        offeredSalary: Value(event.offeredSalary),
        vacancyUrl: Value(event.vacancyUrl),
        sourcePlatform: Value(event.sourcePlatform),
        recruiterName: Value(event.recruiterName),
        recruiterContact: Value(event.recruiterContact),
        appliedAt: Value(appliedAt),
        createdAt: now,
        updatedAt: now,
      ),
      StatusTransitionsCompanion.insert(
        id: _uuid.v4(),
        applicationId: appId,
        fromStatus: const Value(null),
        toStatus: event.status.name,
        transitionedAt: now,
      ),
    );
  }

  Future<void> _onUpdateApplication(
    UpdateApplication event,
    Emitter<ApplicationsState> emit,
  ) async {
    final now = DateTime.now().toUtc();
    final statusChanged = event.existing.currentStatus != event.status.name;
    final shouldSetAppliedAt = event.existing.appliedAt == null &&
        event.status != ApplicationStatus.wishlist;

    await _db.updateApplicationDetails(
      JobApplicationsCompanion(
        id: Value(event.existing.id),
        companyName: Value(event.companyName),
        roleTitle: Value(event.roleTitle),
        location: Value(event.location),
        workplaceType: Value(event.workplaceType.name),
        jobType: Value(event.jobType.name),
        currentStatus: Value(event.status.name),
        priority: Value(event.priority.name),
        currency: Value(event.currency),
        salaryPeriod: Value(event.salaryPeriod.name),
        expectedSalary: Value(event.expectedSalary),
        offeredSalary: Value(event.offeredSalary),
        vacancyUrl: Value(event.vacancyUrl),
        sourcePlatform: Value(event.sourcePlatform),
        recruiterName: Value(event.recruiterName),
        recruiterContact: Value(event.recruiterContact),
        appliedAt: shouldSetAppliedAt ? Value(now) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );

    if (statusChanged) {
      await _db.into(_db.statusTransitions).insert(
            StatusTransitionsCompanion.insert(
              id: _uuid.v4(),
              applicationId: event.existing.id,
              fromStatus: Value(event.existing.currentStatus),
              toStatus: event.status.name,
              transitionedAt: now,
            ),
          );
    }
  }

  Future<void> _onMoveApplicationStatus(
    MoveApplicationStatus event,
    Emitter<ApplicationsState> emit,
  ) async {
    if (event.application.currentStatus == event.newStatus.name) return;

    final now = DateTime.now().toUtc();
    final shouldSetAppliedAt = event.application.appliedAt == null &&
        event.newStatus != ApplicationStatus.wishlist;

    await _db.updateApplicationStatus(
      applicationId: event.application.id,
      fromStatus: event.application.currentStatus,
      toStatus: event.newStatus.name,
      appliedAt: shouldSetAppliedAt ? now : null,
      transition: StatusTransitionsCompanion.insert(
        id: _uuid.v4(),
        applicationId: event.application.id,
        fromStatus: Value(event.application.currentStatus),
        toStatus: event.newStatus.name,
        transitionedAt: now,
      ),
    );
  }

  Future<void> _onDeleteApplication(
    DeleteApplication event,
    Emitter<ApplicationsState> emit,
  ) async {
    // Cancel scheduled interview notifications and remove local PDF before deleting
    final schedules = await (_db.select(_db.interviewSchedules)
          ..where((t) => t.applicationId.equals(event.id)))
        .get();
    for (final s in schedules) {
      await NotificationService.instance
          .cancelReminders(s.notificationId24h, s.notificationId1h);
    }

    final resumes = await (_db.select(_db.resumeAttachments)
          ..where((t) => t.applicationId.equals(event.id)))
        .get();
    for (final r in resumes) {
      final f = File(r.privateFilePath);
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    }

    await _db.deleteApplicationById(event.id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
