import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/finance_model.dart';
import 'package:lefni/models/payment_method_model.dart';
import 'package:lefni/services/firestore/finance_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/ui/widgets/entity_header.dart';
import 'package:lefni/ui/widgets/status_chip.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class FinanceDetailPage extends StatelessWidget {
  final String financeId;

  const FinanceDetailPage({
    super.key,
    required this.financeId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: FutureBuilder<FinanceModel?>(
        future: FinanceService().getFinance(financeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ أثناء تحميل البيانات',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          }

          final finance = snapshot.data;
          if (finance == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'السجل المالي غير موجود',
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: EntityHeader(
                  title: _getFinanceTypeLabel(finance.type),
                  subtitle: '${finance.total.toStringAsFixed(2)} ${finance.currency}',
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      UIcons.regularRounded.receipt,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  actions: [
                    StatusChip(
                      status: finance.status,
                      type: StatusType.financeStatus,
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Basic Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعلومات الأساسية',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'النوع',
                              _getFinanceTypeLabel(finance.type),
                            ),
                            _buildInfoRow(
                              context,
                              'الحالة',
                              _getStatusLabel(finance.status),
                            ),
                            _buildInfoRow(
                              context,
                              'العملة',
                              finance.currency,
                            ),
                            _buildInfoRow(
                              context,
                              'تاريخ الإنشاء',
                              DateFormat('yyyy-MM-dd').format(finance.createdAt),
                            ),
                            if (finance.dueDate != null)
                              _buildInfoRow(
                                context,
                                'تاريخ الاستحقاق',
                                DateFormat('yyyy-MM-dd').format(finance.dueDate!),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Financial Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الملخص المالي',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'المجموع الفرعي',
                              '${finance.subtotal.toStringAsFixed(2)} ${finance.currency}',
                            ),
                            _buildInfoRow(
                              context,
                              'ضريبة القيمة المضافة',
                              '${finance.vat.toStringAsFixed(2)} ${finance.currency}',
                            ),
                            Divider(color: colorScheme.outline),
                            _buildInfoRow(
                              context,
                              'الإجمالي',
                              '${finance.total.toStringAsFixed(2)} ${finance.currency}',
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (finance.items.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Items
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'البنود',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DataTable(
                                columns: [
                                  DataColumn(label: Text('الخدمة', style: textTheme.bodySmall)),
                                  if (finance.items.any((item) => item.quantity != null))
                                    DataColumn(label: Text('الكمية', style: textTheme.bodySmall)),
                                  DataColumn(label: Text('السعر', style: textTheme.bodySmall)),
                                ],
                                rows: finance.items.map((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(item.service)),
                                      if (finance.items.any((i) => i.quantity != null))
                                        DataCell(Text(item.quantity?.toString() ?? '-')),
                                      DataCell(Text('${item.price.toStringAsFixed(2)} ${finance.currency}')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Related Entities
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الكيانات المرتبطة',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder(
                              future: ClientService().getClient(finance.clientId),
                              builder: (context, clientSnapshot) {
                                if (clientSnapshot.hasData && clientSnapshot.data != null) {
                                  final client = clientSnapshot.data!;
                                  return InkWell(
                                    onTap: () => context.go('/clients/${client.id}'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            UIcons.regularRounded.user,
                                            size: 20,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'العميل',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                                Text(
                                                  client.name,
                                                  style: textTheme.bodyMedium?.copyWith(
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            UIcons.regularRounded.arrow_left,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return _buildInfoRow(context, 'العميل', finance.clientId);
                              },
                            ),
                            if (finance.caseId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: InkWell(
                                  onTap: () => context.go('/cases/${finance.caseId}'),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.description,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'القضية',
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              finance.caseId!,
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        UIcons.regularRounded.arrow_left,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            FutureBuilder(
                              future: UserService().getUser(finance.createdBy),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData && userSnapshot.data != null) {
                                  final user = userSnapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_add,
                                          size: 20,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'أنشئ بواسطة',
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                user.profile.name ?? user.email,
                                                style: textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return _buildInfoRow(context, 'أنشئ بواسطة', finance.createdBy);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (finance.paidAt != null || finance.paymentMethod != null) ...[
                      const SizedBox(height: 16),
                      // Payment Information
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'معلومات الدفع',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (finance.paidAt != null)
                                _buildInfoRow(
                                  context,
                                  'تاريخ الدفع',
                                  DateFormat('yyyy-MM-dd HH:mm').format(finance.paidAt!),
                                ),
                              if (finance.paymentMethod != null)
                                _buildInfoRow(
                                  context,
                                  AppLocalizations.of(context)!.paymentMethod,
                                  PaymentMethod.fromString(finance.paymentMethod!).localized(AppLocalizations.of(context)!),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (finance.notes != null && finance.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Notes
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ملاحظات',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                finance.notes!,
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (finance.pdfUrl != null && finance.pdfUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // PDF Link
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رابط PDF',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  // TODO: Open PDF
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      size: 20,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        finance.pdfUrl!,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/invoices/edit/$financeId');
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFinanceTypeLabel(FinanceType type) {
    switch (type) {
      case FinanceType.invoice:
        return 'فاتورة';
      case FinanceType.paymentReceipt:
        return 'إيصال دفع';
      case FinanceType.expense:
        return 'مصروف';
      case FinanceType.fee:
        return 'رسوم';
    }
  }

  String _getStatusLabel(FinanceStatus status) {
    switch (status) {
      case FinanceStatus.draft:
        return 'مسودة';
      case FinanceStatus.unpaid:
        return 'غير مدفوعة';
      case FinanceStatus.partial:
        return 'مدفوعة جزئياً';
      case FinanceStatus.paid:
        return 'مدفوعة';
      case FinanceStatus.overdue:
        return 'متأخرة';
    }
  }
}

