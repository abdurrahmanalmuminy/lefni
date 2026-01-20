import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';
import 'package:lefni/models/finance_model.dart';
import 'package:lefni/ui/widgets/status_chip.dart';

class FinanceListTile extends StatelessWidget {
  final FinanceModel finance;
  final VoidCallback? onTap;

  const FinanceListTile({
    super.key,
    required this.finance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);
    final dateFormat = DateFormat('yyyy-MM-dd');

    final isOverdue = finance.dueDate != null &&
        finance.dueDate!.isBefore(DateTime.now()) &&
        finance.status != FinanceStatus.paid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOverdue
          ? colorScheme.errorContainer.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            _getFinanceTypeIcon(finance.type),
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _getFinanceTypeLabel(finance.type),
                style: textTheme.titleMedium,
              ),
            ),
            StatusChip(
              status: finance.status,
              type: StatusType.financeStatus,
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
                  UIcons.regularRounded.dollar,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  currencyFormat.format(finance.total),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (finance.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    UIcons.regularRounded.calendar,
                    size: 16,
                    color: isOverdue
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'استحقاق: ${dateFormat.format(finance.dueDate!)}',
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
          ],
        ),
        trailing: Icon(
          UIcons.regularRounded.arrow_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap ?? () {
          context.go('/finances/${finance.id}');
        },
      ),
    );
  }

  IconData _getFinanceTypeIcon(FinanceType type) {
    switch (type) {
      case FinanceType.invoice:
        return UIcons.regularRounded.file_invoice;
      case FinanceType.paymentReceipt:
        return UIcons.regularRounded.receipt;
      case FinanceType.expense:
        return UIcons.regularRounded.money_check;
      case FinanceType.fee:
        return UIcons.regularRounded.dollar;
    }
  }

  String _getFinanceTypeLabel(FinanceType type) {
    switch (type) {
      case FinanceType.invoice:
        return 'فاتورة';
      case FinanceType.paymentReceipt:
        return 'سند قبض';
      case FinanceType.expense:
        return 'مصروف';
      case FinanceType.fee:
        return 'أتعاب';
    }
  }
}

