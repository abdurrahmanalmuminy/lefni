import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uicons/uicons.dart';
import 'package:lefni/models/user_model.dart';

class CollaboratorCard extends StatelessWidget {
  final UserModel collaborator;
  final VoidCallback? onTap;

  const CollaboratorCard({
    super.key,
    required this.collaborator,
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
          backgroundColor: colorScheme.tertiaryContainer,
          child: Icon(
            _getRoleIcon(collaborator.role),
            color: colorScheme.onTertiaryContainer,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                collaborator.email,
                style: textTheme.titleMedium,
              ),
            ),
            Chip(
              label: Text(
                collaborator.isActive ? 'نشط' : 'غير نشط',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              backgroundColor: collaborator.isActive
                  ? Theme.of(context).colorScheme.tertiaryContainer
                  : Theme.of(context).colorScheme.errorContainer,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              _getRoleLabel(collaborator.role),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (collaborator.profile.specialization != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    UIcons.regularRounded.label,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    collaborator.profile.specialization!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            if (collaborator.profile.firmName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    UIcons.regularRounded.building,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    collaborator.profile.firmName!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            if (collaborator.profile.university != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    UIcons.regularRounded.graduation_cap,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    collaborator.profile.university!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            if (collaborator.phoneNumber != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    UIcons.regularRounded.phone_call,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    collaborator.phoneNumber!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
          context.go('/users/${collaborator.uid}');
        },
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.lawyer:
        return UIcons.regularRounded.user;
      case UserRole.student:
        return UIcons.regularRounded.user;
      case UserRole.engineer:
        return UIcons.regularRounded.user;
      case UserRole.accountant:
        return UIcons.regularRounded.calculator;
      case UserRole.translator:
        return UIcons.regularRounded.globe;
      default:
        return UIcons.regularRounded.user;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.lawyer:
        return 'محامي متعاون';
      case UserRole.student:
        return 'طالب';
      case UserRole.engineer:
        return 'مهندس';
      case UserRole.accountant:
        return 'محاسب قانوني';
      case UserRole.translator:
        return 'مترجم';
      default:
        return role.value;
    }
  }
}

