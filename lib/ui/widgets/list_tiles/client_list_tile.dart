import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uicons/uicons.dart';
import 'package:lefni/models/client_model.dart';
import 'package:badges/badges.dart' as badges;

class ClientListTile extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onTap;

  const ClientListTile({
    super.key,
    required this.client,
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
            UIcons.regularRounded.user,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          client.name,
          style: textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${client.type == ClientType.individual ? 'هوية' : 'سجل تجاري'}: ${client.identityNumber}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    client.type == ClientType.individual ? 'فرد' : 'شركة',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 8),
                if (client.stats.activeCases > 0)
                  badges.Badge(
                    badgeContent: Text(
                      '${client.stats.activeCases}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onError,
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        context.go('/cases?clientId=${client.id}');
                      },
                      icon: Icon(
                        UIcons.regularRounded.layers,
                        size: 16,
                      ),
                      label: Text(
                        'القضايا',
                        style: textTheme.labelSmall,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          UIcons.regularRounded.arrow_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap ?? () {
          context.go('/clients/${client.id}');
        },
      ),
    );
  }
}

