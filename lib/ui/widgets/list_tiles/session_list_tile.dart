import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/session_model.dart';
import 'package:lefni/ui/widgets/status_chip.dart';

class SessionListTile extends StatelessWidget {
  final SessionModel session;
  final VoidCallback? onTap;

  const SessionListTile({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.tertiaryContainer,
          child: Icon(
            UIcons.regularRounded.presentation,
            color: colorScheme.onTertiaryContainer,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                session.type.localized(AppLocalizations.of(context)!),
                style: textTheme.titleMedium,
              ),
            ),
            StatusChip(
              status: session.status,
              type: StatusType.sessionStatus,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  UIcons.regularRounded.calendar,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${dateFormat.format(session.scheduledAt)} ${timeFormat.format(session.scheduledAt)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  UIcons.regularRounded.map_marker,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.location,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: session.status == SessionStatus.scheduled
            ? OutlinedButton.icon(
                onPressed: () {
                  if (session.type == SessionType.courtHearing) {
                    context.go('/sessions/${session.id}/report');
                  } else {
                    context.go('/sessions/${session.id}/join');
                  }
                },
                icon: Icon(
                  session.type == SessionType.courtHearing
                      ? UIcons.regularRounded.file
                      : UIcons.regularRounded.play,
                  size: 16,
                ),
                label: Text(
                  session.type == SessionType.courtHearing ? 'تقرير' : 'انضم',
                  style: textTheme.labelSmall,
                ),
              )
            : Icon(
                UIcons.regularRounded.arrow_right,
                color: colorScheme.onSurfaceVariant,
              ),
        onTap: onTap ?? () {
          context.go('/sessions/${session.id}');
        },
      ),
    );
  }

}

