import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/enums/application_enums.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/motion/app_motion.dart';
import '../../bloc/applications_bloc.dart';

void showApplicationStatusPickerSheet({
  required BuildContext context,
  required JobApplication app,
  required String currentStatusId,
}) {
  final brightness = Theme.of(context).brightness;
  final cs = Theme.of(context).colorScheme;
  final theme = Theme.of(context);
  final s = AppLocaleScope.of(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.72,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(s.updateStateTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 14),
            Text(s.activeStagesHeader, style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            ...s.pipelineStages.map((stage) {
              final isSelected = stage.id == currentStatusId;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: isSelected ? cs.primaryFixed : null,
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: stage.colorKey.dotColor(brightness),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(stage.label, style: theme.textTheme.titleSmall),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: cs.primary)
                    : null,
                onTap: () {
                  AppMotion.lightHaptic();
                  context.read<ApplicationsBloc>().add(
                        MoveApplicationStatus(
                          application: app,
                          newStatusId: stage.id,
                        ),
                      );
                  Navigator.of(ctx).pop();
                },
              );
            }),
            const SizedBox(height: 14),
            Text(s.terminalOutcomesHeader, style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            ...ApplicationStatus.terminalOutcomes.map((status) {
              final isSelected = status.name == currentStatusId;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: isSelected ? cs.surfaceContainerHigh : null,
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.stageDotColor(status, brightness),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  s.defaultStatusLabel(status),
                  style: theme.textTheme.titleSmall,
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: cs.primary)
                    : null,
                onTap: () {
                  context.read<ApplicationsBloc>().add(
                        MoveApplicationStatus(
                          application: app,
                          newStatusId: status.name,
                        ),
                      );
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    ),
  );
}
