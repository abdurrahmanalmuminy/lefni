import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/models/task_model.dart';
import 'package:lefni/models/finance_model.dart';
import 'package:lefni/models/session_model.dart';
import 'package:lefni/models/contract_model.dart';

class StatusChip extends StatelessWidget {
  final dynamic status;
  final StatusType type;

  const StatusChip({
    super.key,
    required this.status,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final (label, color, backgroundColor) = _getStatusInfo(context);

    return Chip(
      label: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.visible,
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  (String, Color, Color) _getStatusInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (type) {
      case StatusType.caseStatus:
        final caseStatus = status as CaseStatus;
        final localizations = AppLocalizations.of(context);
        if (localizations == null) {
          // Fallback if localization is not available
          switch (caseStatus) {
            case CaseStatus.prospect:
              return ('محتملة', colorScheme.onSurface, colorScheme.surfaceContainerHighest);
            case CaseStatus.active:
              return ('نشطة', colorScheme.primary, colorScheme.primaryContainer);
            case CaseStatus.closed:
              return ('منتهية', colorScheme.onSurfaceVariant, colorScheme.surfaceVariant);
          }
        }
        switch (caseStatus) {
          case CaseStatus.prospect:
            return (
              caseStatus.localized(localizations),
              colorScheme.onSurface,
              colorScheme.surfaceContainerHighest,
            );
          case CaseStatus.active:
            return (
              caseStatus.localized(localizations),
              colorScheme.primary,
              colorScheme.primaryContainer,
            );
          case CaseStatus.closed:
            return (
              caseStatus.localized(localizations),
              colorScheme.onSurfaceVariant,
              colorScheme.surfaceVariant,
            );
        }

      case StatusType.taskStatus:
        final taskStatus = status as TaskStatus;
        switch (taskStatus) {
          case TaskStatus.pending:
            return (
              'معلقة',
              colorScheme.onSurface,
              colorScheme.surfaceContainerHighest,
            );
          case TaskStatus.inProgress:
            return (
              'قيد التنفيذ',
              colorScheme.primary,
              colorScheme.primaryContainer,
            );
          case TaskStatus.completed:
            return (
              'مكتملة',
              colorScheme.tertiary,
              colorScheme.tertiaryContainer,
            );
          case TaskStatus.cancelled:
            return (
              'ملغاة',
              colorScheme.error,
              colorScheme.errorContainer,
            );
        }

      case StatusType.financeStatus:
        final financeStatus = status as FinanceStatus;
        switch (financeStatus) {
          case FinanceStatus.draft:
            return (
              'مسودة',
              colorScheme.onSurface,
              colorScheme.surfaceContainerHighest,
            );
          case FinanceStatus.unpaid:
            return (
              'غير مدفوعة',
              colorScheme.error,
              colorScheme.errorContainer,
            );
          case FinanceStatus.partial:
            return (
              'مدفوعة جزئياً',
              colorScheme.primary,
              colorScheme.primaryContainer,
            );
          case FinanceStatus.paid:
            return (
              'مدفوعة',
              colorScheme.tertiary,
              colorScheme.tertiaryContainer,
            );
          case FinanceStatus.overdue:
            return (
              'متأخرة',
              colorScheme.error,
              colorScheme.errorContainer,
            );
        }

      case StatusType.sessionStatus:
        final sessionStatus = status as SessionStatus;
        switch (sessionStatus) {
          case SessionStatus.scheduled:
            return (
              'مجدولة',
              colorScheme.primary,
              colorScheme.primaryContainer,
            );
          case SessionStatus.completed:
            return (
              'مكتملة',
              colorScheme.tertiary,
              colorScheme.tertiaryContainer,
            );
          case SessionStatus.cancelled:
            return (
              'ملغاة',
              colorScheme.error,
              colorScheme.errorContainer,
            );
          case SessionStatus.postponed:
            return (
              'مؤجلة',
              colorScheme.onSurface,
              colorScheme.surfaceContainerHighest,
            );
        }

      case StatusType.signatureStatus:
        final signatureStatus = status as SignatureStatusType;
        switch (signatureStatus) {
          case SignatureStatusType.pending:
            return (
              'في الانتظار',
              colorScheme.onSurface,
              colorScheme.surfaceContainerHighest,
            );
          case SignatureStatusType.accepted:
            return (
              'مقبولة',
              colorScheme.tertiary,
              colorScheme.tertiaryContainer,
            );
          case SignatureStatusType.rejected:
            return (
              'مرفوضة',
              colorScheme.error,
              colorScheme.errorContainer,
            );
        }

      case StatusType.priority:
        final priority = status as TaskPriority;
        switch (priority) {
          case TaskPriority.low:
            return (
              'منخفضة',
              colorScheme.onSurfaceVariant,
              colorScheme.surfaceVariant,
            );
          case TaskPriority.medium:
            return (
              'متوسطة',
              colorScheme.primary,
              colorScheme.primaryContainer,
            );
          case TaskPriority.high:
            return (
              'عالية',
              colorScheme.error,
              colorScheme.errorContainer,
            );
        }
    }
  }
}

enum StatusType {
  caseStatus,
  taskStatus,
  financeStatus,
  sessionStatus,
  signatureStatus,
  priority,
}

