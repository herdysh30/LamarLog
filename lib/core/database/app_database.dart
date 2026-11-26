import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class JobApplications extends Table {
  TextColumn get id => text()();
  TextColumn get companyName => text()();
  TextColumn get roleTitle => text()();
  TextColumn get location => text().withDefault(const Constant(''))();
  TextColumn get workplaceType => text().withDefault(const Constant('remote'))();
  TextColumn get jobType => text().withDefault(const Constant('fullTime'))();
  TextColumn get currentStatus => text().withDefault(const Constant('wishlist'))();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  TextColumn get salaryPeriod => text().withDefault(const Constant('monthly'))();
  RealColumn get expectedSalary => real().nullable()();
  RealColumn get offeredSalary => real().nullable()();
  TextColumn get vacancyUrl => text().nullable()();
  TextColumn get sourcePlatform => text().nullable()();
  TextColumn get recruiterName => text().nullable()();
  TextColumn get recruiterContact => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get appliedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class StatusTransitions extends Table {
  TextColumn get id => text()();
  TextColumn get applicationId =>
      text().references(JobApplications, #id, onDelete: KeyAction.cascade)();
  TextColumn get fromStatus => text().nullable()();
  TextColumn get toStatus => text()();
  DateTimeColumn get transitionedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TimelineLogs extends Table {
  TextColumn get id => text()();
  TextColumn get applicationId =>
      text().references(JobApplications, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get loggedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class InterviewSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get applicationId =>
      text().references(JobApplications, #id, onDelete: KeyAction.cascade)();
  TextColumn get roundName => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get meetingUrl => text().nullable()();
  TextColumn get locationNotes => text().nullable()();
  IntColumn get notificationId24h => integer().nullable()();
  IntColumn get notificationId1h => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ResumeAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get applicationId =>
      text().references(JobApplications, #id, onDelete: KeyAction.cascade)();
  TextColumn get originalFileName => text()();
  TextColumn get privateFilePath => text()();
  IntColumn get fileSizeBytes => integer()();
  DateTimeColumn get attachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  JobApplications,
  StatusTransitions,
  TimelineLogs,
  InterviewSchedules,
  ResumeAttachments,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(jobApplications, jobApplications.sourcePlatform);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // --- Application Queries ---
  Stream<List<JobApplication>> watchActiveApplications() {
    return (select(jobApplications)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<List<JobApplication>> getAllApplications() {
    return select(jobApplications).get();
  }

  Future<void> insertApplicationWithTransition(
    JobApplicationsCompanion entry,
    StatusTransitionsCompanion initialTransition,
  ) {
    return transaction(() async {
      await into(jobApplications).insert(entry);
      await into(statusTransitions).insert(initialTransition);
    });
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String fromStatus,
    required String toStatus,
    required StatusTransitionsCompanion transition,
    DateTime? appliedAt,
  }) {
    return transaction(() async {
      await (update(jobApplications)..where((t) => t.id.equals(applicationId)))
          .write(
        JobApplicationsCompanion(
          currentStatus: Value(toStatus),
          appliedAt: appliedAt != null ? Value(appliedAt) : const Value.absent(),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await into(statusTransitions).insert(transition);
    });
  }

  Future<void> updateApplicationDetails(JobApplicationsCompanion entry) {
    return (update(jobApplications)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> touchApplicationUpdatedAt(String applicationId) {
    return (update(jobApplications)..where((t) => t.id.equals(applicationId)))
        .write(JobApplicationsCompanion(updatedAt: Value(DateTime.now().toUtc())));
  }

  Future<int> deleteApplicationById(String id) {
    return (delete(jobApplications)..where((t) => t.id.equals(id))).go();
  }

  Future<List<StatusTransition>> getAllTransitions() {
    return select(statusTransitions).get();
  }

  Stream<List<StatusTransition>> watchAllTransitions() {
    return select(statusTransitions).watch();
  }

  Stream<List<InterviewSchedule>> watchUpcomingInterviews() {
    final now = DateTime.now().toUtc();
    return (select(interviewSchedules)
          ..where((t) => t.scheduledAt.isBiggerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .watch();
  }

  Future<List<TimelineLog>> getAllTimelineLogs() {
    return select(timelineLogs).get();
  }

  Future<List<InterviewSchedule>> getAllInterviewSchedules() {
    return select(interviewSchedules).get();
  }

  Future<List<ResumeAttachment>> getAllResumeAttachments() {
    return select(resumeAttachments).get();
  }

  // --- Timeline & Status History ---
  Stream<List<TimelineLog>> watchTimelineLogs(String applicationId) {
    return (select(timelineLogs)
          ..where((t) => t.applicationId.equals(applicationId))
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
        .watch();
  }

  Future<void> insertTimelineLog(TimelineLogsCompanion entry) {
    return into(timelineLogs).insert(entry);
  }

  Future<void> updateTimelineLog({
    required String id,
    required String title,
    required String note,
  }) {
    return (update(timelineLogs)..where((t) => t.id.equals(id))).write(
      TimelineLogsCompanion(
        title: Value(title),
        note: Value(note),
      ),
    );
  }

  Future<void> deleteTimelineLog(String id) {
    return (delete(timelineLogs)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<StatusTransition>> watchTransitionsForApp(String applicationId) {
    return (select(statusTransitions)
          ..where((t) => t.applicationId.equals(applicationId))
          ..orderBy([(t) => OrderingTerm.desc(t.transitionedAt)]))
        .watch();
  }

  // --- Resume Attachments ---
  Stream<ResumeAttachment?> watchResumeForApp(String applicationId) {
    return (select(resumeAttachments)
          ..where((t) => t.applicationId.equals(applicationId))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<void> upsertResumeAttachment(ResumeAttachmentsCompanion entry) {
    return transaction(() async {
      await (delete(resumeAttachments)
            ..where((t) => t.applicationId.equals(entry.applicationId.value)))
          .go();
      await into(resumeAttachments).insert(entry);
    });
  }

  Future<void> deleteResumeForApp(String applicationId) {
    return (delete(resumeAttachments)
          ..where((t) => t.applicationId.equals(applicationId)))
        .go();
  }

  // --- Interview Schedules ---
  Stream<List<InterviewSchedule>> watchInterviewsForApp(String applicationId) {
    return (select(interviewSchedules)
          ..where((t) => t.applicationId.equals(applicationId))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .watch();
  }

  Future<void> insertInterviewSchedule(InterviewSchedulesCompanion entry) {
    return into(interviewSchedules).insert(entry);
  }

  Future<void> updateInterviewReminderIds({
    required String id,
    int? notificationId24h,
    int? notificationId1h,
  }) {
    return (update(interviewSchedules)..where((t) => t.id.equals(id))).write(
      InterviewSchedulesCompanion(
        notificationId24h: Value(notificationId24h),
        notificationId1h: Value(notificationId1h),
      ),
    );
  }

  Stream<List<InterviewWithApplication>> watchAllInterviewsWithApplications() {
    final query = select(interviewSchedules).join([
      innerJoin(
        jobApplications,
        jobApplications.id.equalsExp(interviewSchedules.applicationId),
      ),
    ])
      ..orderBy([OrderingTerm.asc(interviewSchedules.scheduledAt)]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => InterviewWithApplication(
              schedule: row.readTable(interviewSchedules),
              application: row.readTable(jobApplications),
            ),
          )
          .toList();
    });
  }

  Future<void> deleteInterviewSchedule(String id) {
    return (delete(interviewSchedules)..where((t) => t.id.equals(id))).go();
  }
}

class InterviewWithApplication {
  const InterviewWithApplication({
    required this.schedule,
    required this.application,
  });

  final InterviewSchedule schedule;
  final JobApplication application;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'applyflow.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
