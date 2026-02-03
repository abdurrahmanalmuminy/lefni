import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uicons/uicons.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/services/court_classifications_service.dart';
import 'package:lefni/ui/widgets/status_chip.dart';

class CaseListTile extends StatelessWidget {
  final CaseModel case_;
  final VoidCallback? onTap;

  const CaseListTile({
    super.key,
    required this.case_,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(
            UIcons.regularRounded.layers,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                case_.caseNumber,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(
              status: case_.status,
              type: StatusType.caseStatus,
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
                  UIcons.regularRounded.building,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${case_.courtDetails.courtName} - ${case_.courtDetails.circuit}',
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
                  UIcons.regularRounded.label,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                FutureBuilder<String>(
                  future: CourtClassificationsService.getCategoryNameAr(case_.category),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? case_.category,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
            if (case_.caseType != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.gavel,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      case_.caseType!['ar'] as String? ?? '',
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
          ],
        ),
        trailing: Icon(
          UIcons.regularRounded.arrow_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap ?? () {
          context.go('/cases/${case_.id}');
        },
      ),
    );
  }

}

