import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/enums/application_enums.dart';
import '../../../../core/models/pipeline_stage_config.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/stale_application_helper.dart';

part 'applications_event.dart';
part 'applications_state.dart';

class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  ApplicationsBloc(this._db) : super(const ApplicationsState()) {
    on<LoadApplications>(_onLoadApplications);
    on<_ApplicationsUpdated>(_onApplicationsUpdated);
    on<_ApplicationsLoadFailed>(_onApplicationsLoadFailed);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<UpdateFilters>(_onUpdateFilters);
    on<UpdateStageFilter>(_onUpdateStageFilter);
    on<ToggleStaleFilter>(_onToggleStaleFilter);
    on<ResetFilters>(_onResetFilters);
    on<AddApplication>(_onAddApplication);
    on<UpdateApplication>(_onUpdateApplication);
    on<MoveApplicationStatus>(_onMoveApplicationStatus);
    on<ReassignStageApplications>(_onReassignStageApplications);
    on<DeleteApplication>(_onDeleteApplication);
  }

  final AppDatabase _db;
  final _uuid = const Uuid();
  StreamSubscription<List<JobApplication>>? _subscription;

  Future<void> _onLoadApplications(
    LoadApplications event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _subscription?.cancel();
    _subscription = _db.watchActiveApplications().listen(
      (apps) => add(_ApplicationsUpdated(apps)),
      onError: (Object e) => add(_ApplicationsLoadFailed(e.toString())),
    );
  }

  void _onApplicationsUpdated(
    _ApplicationsUpdated event,
    Emitter<ApplicationsState> emit,
  ) {
    emit(state.copyWith(applications: event.applications, isLoading: false));
  }

  void _onApplicationsLoadFailed(
    _ApplicationsLoadFailed event,
    Emitter<ApplicationsState> emit,
  ) {
    emit(state.copyWith(isLoading: false, errorMessage: event.message));
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

  void _onUpdateStageFilter(
    UpdateStageFilter event,
    Emitter<ApplicationsState> emit,
  ) {
    emit(state.copyWith(stageFilter: Set.unmodifiable(event.stageIds)));
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
      stageFilter: const {},
      sortOption: PipelineSortOption.latestMove,
    ));
  }

  void _emitActionError(Emitter<ApplicationsState> emit, Object error) {
    emit(state.copyWith(
      actionErrorMessage: error.toString(),
      actionErrorId: state.actionErrorId + 1,
    ));
  }

  Future<void> _onAddApplication(
    AddApplication event,
    Emitter<ApplicationsState> emit,
  ) async {
    try {
      final now = DateTime.now().toUtc();
      final appId = _uuid.v4();
      final appliedAt =
          event.statusId == ApplicationStatus.wishlist.name ? null : now;

      await _db.insertApplicationWithTransition(
        JobApplicationsCompanion.insert(
          id: appId,
          companyName: event.companyName,
          roleTitle: event.roleTitle,
          location: Value(event.location),
          workplaceType: Value(event.workplaceType.name),
          jobType: Value(event.jobType.name),
          currentStatus: Value(event.statusId),
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
          toStatus: event.statusId,
          transitionedAt: now,
        ),
      );
    } catch (e) {
      _emitActionError(emit, e);
    }
  }

  Future<void> _onUpdateApplication(
    UpdateApplication event,
    Emitter<ApplicationsState> emit,
  ) async {
    try {
      final now = DateTime.now().toUtc();
      final statusChanged = event.existing.currentStatus != event.statusId;
      final movedBackToWishlist =
          event.statusId == ApplicationStatus.wishlist.name;
      final shouldSetAppliedAt = event.existing.appliedAt == null &&
          !movedBackToWishlist;

      await _db.updateApplicationDetails(
        JobApplicationsCompanion(
          id: Value(event.existing.id),
          companyName: Value(event.companyName),
          roleTitle: Value(event.roleTitle),
          location: Value(event.location),
          workplaceType: Value(event.workplaceType.name),
          jobType: Value(event.jobType.name),
          currentStatus: Value(event.statusId),
          priority: Value(event.priority.name),
          currency: Value(event.currency),
          salaryPeriod: Value(event.salaryPeriod.name),
          expectedSalary: Value(event.expectedSalary),
          offeredSalary: Value(event.offeredSalary),
          vacancyUrl: Value(event.vacancyUrl),
          sourcePlatform: Value(event.sourcePlatform),
          recruiterName: Value(event.recruiterName),
          recruiterContact: Value(event.recruiterContact),
          appliedAt: movedBackToWishlist
              ? const Value(null)
              : (shouldSetAppliedAt ? Value(now) : const Value.absent()),
          updatedAt: Value(now),
        ),
      );

      if (statusChanged) {
        await _db.into(_db.statusTransitions).insert(
              StatusTransitionsCompanion.insert(
                id: _uuid.v4(),
                applicationId: event.existing.id,
                fromStatus: Value(event.existing.currentStatus),
                toStatus: event.statusId,
                transitionedAt: now,
              ),
            );
      }
    } catch (e) {
      _emitActionError(emit, e);
    }
  }

  Future<void> _onMoveApplicationStatus(
    MoveApplicationStatus event,
    Emitter<ApplicationsState> emit,
  ) async {
    if (event.application.currentStatus == event.newStatusId) return;

    try {
      final now = DateTime.now().toUtc();
      final movedBackToWishlist =
          event.newStatusId == ApplicationStatus.wishlist.name;
      final shouldSetAppliedAt =
          event.application.appliedAt == null && !movedBackToWishlist;

      await _db.updateApplicationStatus(
        applicationId: event.application.id,
        fromStatus: event.application.currentStatus,
        toStatus: event.newStatusId,
        appliedAt: shouldSetAppliedAt ? now : null,
        clearAppliedAt: movedBackToWishlist,
        transition: StatusTransitionsCompanion.insert(
          id: _uuid.v4(),
          applicationId: event.application.id,
          fromStatus: Value(event.application.currentStatus),
          toStatus: event.newStatusId,
          transitionedAt: now,
        ),
      );
    } catch (e) {
      _emitActionError(emit, e);
    }
  }

  Future<void> _onReassignStageApplications(
    ReassignStageApplications event,
    Emitter<ApplicationsState> emit,
  ) async {
    if (event.fromStageId == event.toStageId) return;
    try {
      final affected = state.applications
          .where((a) => a.currentStatus == event.fromStageId)
          .toList();
      for (final app in affected) {
        final now = DateTime.now().toUtc();
        await _db.updateApplicationStatus(
          applicationId: app.id,
          fromStatus: app.currentStatus,
          toStatus: event.toStageId,
          appliedAt: app.appliedAt == null &&
                  event.toStageId != ApplicationStatus.wishlist.name
              ? now
              : null,
          transition: StatusTransitionsCompanion.insert(
            id: _uuid.v4(),
            applicationId: app.id,
            fromStatus: Value(app.currentStatus),
            toStatus: event.toStageId,
            transitionedAt: now,
          ),
        );
      }
    } catch (e) {
      _emitActionError(emit, e);
    }
  }

  Future<void> _onDeleteApplication(
    DeleteApplication event,
    Emitter<ApplicationsState> emit,
  ) async {
    try {
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
    } catch (e) {
      _emitActionError(emit, e);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
