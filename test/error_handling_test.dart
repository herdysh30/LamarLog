import 'dart:async';

import 'package:lamarlog/core/database/app_database.dart';
import 'package:lamarlog/core/enums/application_enums.dart';
import 'package:lamarlog/core/widgets/applyflow_widgets.dart';
import 'package:lamarlog/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      JobApplicationsCompanion.insert(
        id: 'fallback',
        companyName: 'Fallback',
        roleTitle: 'Role',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
    registerFallbackValue(
      StatusTransitionsCompanion.insert(
        id: 'tx-fallback',
        applicationId: 'fallback',
        toStatus: 'wishlist',
        transitionedAt: DateTime.utc(2026),
      ),
    );
  });

  group('ApplicationsBloc error handling', () {
    test('surfaces load error instead of infinite loading when DB stream fails',
        () async {
      final db = _MockAppDatabase();
      when(() => db.watchActiveApplications()).thenAnswer(
        (_) => Stream<List<JobApplication>>.error(Exception('sqlite failure')),
      );

      final bloc = ApplicationsBloc(db);
      addTearDown(bloc.close);

      bloc.add(const LoadApplications());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.errorMessage, contains('sqlite failure'));
    });

    test('surfaces transient actionErrorMessage when AddApplication DB fails',
        () async {
      final db = _MockAppDatabase();
      when(() => db.insertApplicationWithTransition(any(), any()))
          .thenThrow(Exception('disk full'));

      final bloc = ApplicationsBloc(db);
      addTearDown(bloc.close);

      bloc.add(
        const AddApplication(
          companyName: 'Acme',
          roleTitle: 'Engineer',
          location: 'Jakarta',
          workplaceType: WorkplaceType.remote,
          jobType: JobType.fullTime,
          statusId: 'applied',
          priority: PriorityLevel.high,
          currency: 'IDR',
          salaryPeriod: SalaryPeriod.monthly,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.actionErrorId, 1);
      expect(bloc.state.actionErrorMessage, contains('disk full'));
    });
  });

  testWidgets('ErrorStateCard renders message and triggers retry callback',
      (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorStateCard(
            title: 'Failed to load',
            detail: 'Disk error',
            retryLabel: 'Retry Now',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Failed to load'), findsOneWidget);
    expect(find.text('Disk error'), findsOneWidget);
    await tester.tap(find.text('Retry Now'));
    expect(retried, isTrue);
  });
}
