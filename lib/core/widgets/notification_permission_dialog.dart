import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/app_motion.dart';
import '../services/notification_service.dart';

/// Shows an actionable dialog when OS notification permission is denied or
/// suppressed by Android/iOS ("Don't ask again"), letting the user jump
/// directly to the device's App Notification Settings in one tap.
///
/// Returns `true` if the user tapped "Open Settings", so callers can
/// auto-refresh status when the app resumes.
Future<bool> showNotificationPermissionDialog(BuildContext context) async {
  final s = AppLocaleScope.of(context);
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  final openedSettings = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.primaryFixed,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications_off_rounded,
          color: cs.onPrimaryFixed,
          size: 24,
        ),
      ),
      title: Text(
        s.notifPermissionBlockedTitle,
        textAlign: TextAlign.center,
      ),
      content: Text(
        s.notifPermissionBlockedBody,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
          height: 1.45,
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(s.notNow),
        ),
        FilledButton.icon(
          onPressed: () async {
            AppMotion.selectionHaptic();
            Navigator.of(ctx).pop(true);
            await NotificationService.instance.openNotificationSettings();
          },
          icon: const Icon(Icons.settings_outlined, size: 18),
          label: Text(s.openNotificationSettings),
        ),
      ],
    ),
  );

  return openedSettings ?? false;
}
