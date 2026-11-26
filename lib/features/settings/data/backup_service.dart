import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/pipeline_stage_config.dart';

class UnsupportedBackupSchemaException implements Exception {
  const UnsupportedBackupSchemaException();
}

class StorageStats {
  const StorageStats({
    required this.bytes,
    required this.appCount,
    required this.resumeCount,
  });

  final int bytes;
  final int appCount;
  final int resumeCount;

  String get formattedSize => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB'
      : '${(bytes / 1024).toStringAsFixed(1)} KB';

  static Future<StorageStats> load(AppDatabase db) async {
    final apps = await db.getAllApplications();
    final resumes = await db.getAllResumeAttachments();
    int totalBytes = 0;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, 'lamarlog.sqlite'));
      if (dbFile.existsSync()) {
        totalBytes += dbFile.lengthSync();
      }
      final resumesDir = Directory(p.join(dir.path, 'resumes'));
      if (resumesDir.existsSync()) {
        for (final entity in resumesDir.listSync()) {
          if (entity is File) {
            totalBytes += entity.lengthSync();
          }
        }
      }
    } catch (_) {}

    return StorageStats(
      bytes: totalBytes,
      appCount: apps.length,
      resumeCount: resumes.length,
    );
  }
}

class BackupService {
  const BackupService._();

  static Future<String> buildBackupJson({
    required AppDatabase db,
    required String appVersion,
    required List<PipelineStageConfig> pipelineStages,
  }) async {
    final apps = await db.getAllApplications();
    final transitions = await db.getAllTransitions();
    final logs = await db.getAllTimelineLogs();
    final schedules = await db.getAllInterviewSchedules();

    final payload = {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appVersion': appVersion,
      'pipelineStages': pipelineStages.map((st) => st.toJson()).toList(),
      'applications': apps
          .map((a) => {
                'id': a.id,
                'companyName': a.companyName,
                'roleTitle': a.roleTitle,
                'location': a.location,
                'workplaceType': a.workplaceType,
                'jobType': a.jobType,
                'currentStatus': a.currentStatus,
                'priority': a.priority,
                'currency': a.currency,
                'salaryPeriod': a.salaryPeriod,
                'expectedSalary': a.expectedSalary,
                'offeredSalary': a.offeredSalary,
                'vacancyUrl': a.vacancyUrl,
                'sourcePlatform': a.sourcePlatform,
                'recruiterName': a.recruiterName,
                'recruiterContact': a.recruiterContact,
                'isArchived': a.isArchived,
                'appliedAt': a.appliedAt?.toUtc().toIso8601String(),
                'createdAt': a.createdAt.toUtc().toIso8601String(),
                'updatedAt': a.updatedAt.toUtc().toIso8601String(),
              })
          .toList(),
      'transitions': transitions
          .map((t) => {
                'id': t.id,
                'applicationId': t.applicationId,
                'fromStatus': t.fromStatus,
                'toStatus': t.toStatus,
                'transitionedAt': t.transitionedAt.toUtc().toIso8601String(),
              })
          .toList(),
      'timelineLogs': logs
          .map((l) => {
                'id': l.id,
                'applicationId': l.applicationId,
                'title': l.title,
                'note': l.note,
                'loggedAt': l.loggedAt.toUtc().toIso8601String(),
              })
          .toList(),
      'interviewSchedules': schedules
          .map((sc) => {
                'id': sc.id,
                'applicationId': sc.applicationId,
                'roundName': sc.roundName,
                'scheduledAt': sc.scheduledAt.toUtc().toIso8601String(),
                'meetingUrl': sc.meetingUrl,
                'locationNotes': sc.locationNotes,
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Restores DB rows from a schema v1 JSON backup and returns any persisted
  /// pipeline stages present in the backup.
  static Future<List<PipelineStageConfig>?> restoreFromJson({
    required AppDatabase db,
    required String rawJson,
  }) async {
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    if (decoded['schemaVersion'] != 1) {
      throw const UnsupportedBackupSchemaException();
    }

    List<PipelineStageConfig>? restoredStages;
    final restoredStagesRaw = decoded['pipelineStages'];
    if (restoredStagesRaw is List<dynamic>) {
      restoredStages = PipelineStageConfig.decodeList(
        jsonEncode(restoredStagesRaw),
      );
    }

    await db.transaction(() async {
      await db.delete(db.jobApplications).go();

      final appsList = decoded['applications'] as List<dynamic>? ?? [];
      for (final item in appsList) {
        final m = item as Map<String, dynamic>;
        await db.into(db.jobApplications).insert(
              JobApplicationsCompanion.insert(
                id: m['id'] as String,
                companyName: m['companyName'] as String,
                roleTitle: m['roleTitle'] as String,
                location: Value((m['location'] as String?) ?? ''),
                workplaceType:
                    Value((m['workplaceType'] as String?) ?? 'remote'),
                jobType: Value((m['jobType'] as String?) ?? 'fullTime'),
                currentStatus:
                    Value((m['currentStatus'] as String?) ?? 'wishlist'),
                priority: Value((m['priority'] as String?) ?? 'medium'),
                currency: Value((m['currency'] as String?) ?? 'IDR'),
                salaryPeriod:
                    Value((m['salaryPeriod'] as String?) ?? 'monthly'),
                expectedSalary:
                    Value((m['expectedSalary'] as num?)?.toDouble()),
                offeredSalary: Value((m['offeredSalary'] as num?)?.toDouble()),
                vacancyUrl: Value(m['vacancyUrl'] as String?),
                sourcePlatform: Value(m['sourcePlatform'] as String?),
                recruiterName: Value(m['recruiterName'] as String?),
                recruiterContact: Value(m['recruiterContact'] as String?),
                isArchived: Value((m['isArchived'] as bool?) ?? false),
                appliedAt: Value(m['appliedAt'] != null
                    ? DateTime.parse(m['appliedAt'] as String).toUtc()
                    : null),
                createdAt: DateTime.parse(m['createdAt'] as String).toUtc(),
                updatedAt: DateTime.parse(m['updatedAt'] as String).toUtc(),
              ),
            );
      }

      final transList = decoded['transitions'] as List<dynamic>? ?? [];
      for (final item in transList) {
        final m = item as Map<String, dynamic>;
        await db.into(db.statusTransitions).insert(
              StatusTransitionsCompanion.insert(
                id: m['id'] as String,
                applicationId: m['applicationId'] as String,
                fromStatus: Value(m['fromStatus'] as String?),
                toStatus: m['toStatus'] as String,
                transitionedAt:
                    DateTime.parse(m['transitionedAt'] as String).toUtc(),
              ),
            );
      }

      final logsList = decoded['timelineLogs'] as List<dynamic>? ?? [];
      for (final item in logsList) {
        final m = item as Map<String, dynamic>;
        await db.into(db.timelineLogs).insert(
              TimelineLogsCompanion.insert(
                id: m['id'] as String,
                applicationId: m['applicationId'] as String,
                title: m['title'] as String,
                note: Value((m['note'] as String?) ?? ''),
                loggedAt: DateTime.parse(m['loggedAt'] as String).toUtc(),
              ),
            );
      }

      final schedList = decoded['interviewSchedules'] as List<dynamic>? ?? [];
      for (final item in schedList) {
        final m = item as Map<String, dynamic>;
        await db.into(db.interviewSchedules).insert(
              InterviewSchedulesCompanion.insert(
                id: m['id'] as String,
                applicationId: m['applicationId'] as String,
                roundName: m['roundName'] as String,
                scheduledAt:
                    DateTime.parse(m['scheduledAt'] as String).toUtc(),
                meetingUrl: Value(m['meetingUrl'] as String?),
                locationNotes: Value(m['locationNotes'] as String?),
              ),
            );
      }
    });

    return restoredStages;
  }

  static Future<void> clearAllLocalData(AppDatabase db) async {
    await db.delete(db.jobApplications).go();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final resumesDir = Directory(p.join(dir.path, 'resumes'));
      if (resumesDir.existsSync()) {
        await resumesDir.delete(recursive: true);
      }
    } catch (_) {}
  }
}
