import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/models/reminder_schedule_config.dart';

enum _DurationUnit { minutes, hours, days }

/// Bottom sheet letting the user pick a preset lead time or type a custom
/// duration (minutes / hours / days, clamped to 5m .. 7d).
Future<int?> showReminderDurationSheet({
  required BuildContext context,
  required int initialMinutes,
  int? otherSlotMinutes,
}) async {
  final s = AppLocaleScope.of(context);

  _DurationUnit unit;
  int initialValue;
  if (initialMinutes >= 1440 && initialMinutes % 1440 == 0 && initialMinutes != 1440) {
    unit = _DurationUnit.days;
    initialValue = initialMinutes ~/ 1440;
  } else if (initialMinutes >= 60 && initialMinutes % 60 == 0) {
    unit = _DurationUnit.hours;
    initialValue = initialMinutes ~/ 60;
  } else {
    unit = _DurationUnit.minutes;
    initialValue = initialMinutes;
  }

  final ctrl = TextEditingController(text: '$initialValue');
  String? errorText;

  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;

        int? computeCustomMinutes() {
          final parsed = int.tryParse(ctrl.text.trim());
          if (parsed == null || parsed <= 0) return null;
          return switch (unit) {
            _DurationUnit.minutes => parsed,
            _DurationUnit.hours => parsed * 60,
            _DurationUnit.days => parsed * 1440,
          };
        }

        void applyCustom() {
          final total = computeCustomMinutes();
          if (total == null ||
              total < ReminderScheduleConfig.minMinutes ||
              total > ReminderScheduleConfig.maxMinutes) {
            setSheetState(() => errorText = s.reminderRangeHint);
            return;
          }
          Navigator.of(ctx).pop(total);
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.reminderPickOffsetTitle,
                        style: theme.textTheme.headlineSmall,
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ReminderScheduleConfig.presetMinutes.map((mins) {
                      final isSelected = mins == initialMinutes;
                      final isUsedByOther =
                          otherSlotMinutes != null && mins == otherSlotMinutes;
                      final label = ReminderScheduleConfig.formatDuration(
                        mins,
                        isId: s.isId,
                        short: true,
                      );

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: cs.primaryContainer,
                        backgroundColor: cs.surfaceContainer,
                        side: BorderSide.none,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isUsedByOther
                                  ? cs.outline
                                  : cs.onSurfaceVariant),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: isUsedByOther
                            ? null
                            : (_) => Navigator.of(ctx).pop(mins),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Text(s.reminderCustomTime, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          onChanged: (_) {
                            if (errorText != null) {
                              setSheetState(() => errorText = null);
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: '45',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SegmentedButton<_DurationUnit>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: _DurationUnit.minutes,
                              label: Text(s.reminderUnitMinutes),
                            ),
                            ButtonSegment(
                              value: _DurationUnit.hours,
                              label: Text(s.reminderUnitHours),
                            ),
                            ButtonSegment(
                              value: _DurationUnit.days,
                              label: Text(s.reminderUnitDays),
                            ),
                          ],
                          selected: {unit},
                          onSelectionChanged: (sel) {
                            setSheetState(() {
                              unit = sel.first;
                              errorText = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    errorText ?? s.reminderRangeHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: errorText != null ? cs.error : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: applyCustom,
                      child: Text(s.save),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
