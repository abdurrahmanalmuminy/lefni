import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uicons/uicons.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/contract_model.dart';
import 'package:lefni/ui/widgets/status_chip.dart';

class ContractListTile extends StatelessWidget {
  final ContractModel contract;
  final VoidCallback? onTap;

  const ContractListTile({
    super.key,
    required this.contract,
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
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            UIcons.regularRounded.document_signed,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          contract.title,
          style: textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  UIcons.regularRounded.label,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  contract.partyType.localized(AppLocalizations.of(context)!),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusChip(
                  status: contract.signatureStatus.status,
                  type: StatusType.signatureStatus,
                ),
                if (contract.signatureStatus.isSigned) ...[
                  const SizedBox(width: 8),
                  Icon(
                    UIcons.regularRounded.check,
                    size: 16,
                    color: colorScheme.tertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Icon(
          UIcons.regularRounded.arrow_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap ?? () {
          context.go('/contracts/${contract.id}');
        },
      ),
    );
  }

}

