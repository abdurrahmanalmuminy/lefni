import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';
import 'package:lefni/models/task_model.dart';
import 'package:lefni/ui/widgets/status_chip.dart';

class TaskListTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskListTile({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('yyyy-MM-dd');

    final isOverdue = task.deadlines.end.isBefore(DateTime.now()) &&
        task.status != TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOverdue
          ? colorScheme.errorContainer.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(
            UIcons.regularRounded.list_check,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: textTheme.titleMedium,
              ),
            ),
            StatusChip(
              status: task.status,
              type: StatusType.taskStatus,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              task.description,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusChip(
                  status: task.priority,
                  type: StatusType.priority,
                ),
                const SizedBox(width: 8),
                Icon(
                  UIcons.regularRounded.calendar,
                  size: 16,
                  color: isOverdue
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'انتهاء: ${dateFormat.format(task.deadlines.end)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: isOverdue
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
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
          context.go('/tasks/${task.id}');
        },
      ),
    );
  }
}

