import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/collection_record_model.dart';
import 'package:lefni/models/payment_method_model.dart';
import 'package:lefni/services/firestore/collection_record_service.dart';
import 'package:lefni/services/firestore/finance_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/ui/widgets/entity_header.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class CollectionRecordDetailPage extends StatelessWidget {
  final String recordId;

  const CollectionRecordDetailPage({
    super.key,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: FutureBuilder<CollectionRecordModel?>(
        future: CollectionRecordService().getRecord(recordId),
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

          final record = snapshot.data;
          if (record == null) {
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
                    'سجل التحصيل غير موجود',
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
                  title: 'سجل التحصيل',
                  subtitle: '${record.amount.toStringAsFixed(2)} ر.س',
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      UIcons.regularRounded.receipt,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
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
                              'المبلغ',
                              '${record.amount.toStringAsFixed(2)} ر.س',
                            ),
                            _buildInfoRow(
                              context,
                              'تاريخ الدفع',
                              DateFormat('yyyy-MM-dd').format(record.paymentDate),
                            ),
                            _buildInfoRow(
                              context,
                              AppLocalizations.of(context)!.paymentMethod,
                              PaymentMethod.fromString(record.paymentMethod).localized(AppLocalizations.of(context)!),
                            ),
                            _buildInfoRow(
                              context,
                              'تاريخ الإنشاء',
                              DateFormat('yyyy-MM-dd').format(record.createdAt),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Related Invoice
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الفاتورة المرتبطة',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder(
                              future: FinanceService().getFinance(record.invoiceId),
                              builder: (context, financeSnapshot) {
                                if (financeSnapshot.hasData && financeSnapshot.data != null) {
                                  final finance = financeSnapshot.data!;
                                  return InkWell(
                                    onTap: () => context.go('/invoices/${finance.id}'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            UIcons.regularRounded.receipt,
                                            size: 20,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'الفاتورة',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                                Text(
                                                  '${finance.total.toStringAsFixed(2)} ${finance.currency}',
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
                                return _buildInfoRow(context, 'الفاتورة', record.invoiceId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (record.receiptUrl != null && record.receiptUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Receipt
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إيصال',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  // TODO: Open receipt
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      UIcons.regularRounded.file,
                                      size: 20,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        record.receiptUrl!,
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
                    const SizedBox(height: 16),
                    // Recorded By
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سجل بواسطة',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder(
                              future: UserService().getUser(record.recordedBy),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData && userSnapshot.data != null) {
                                  final user = userSnapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                                return _buildInfoRow(context, 'المستخدم', record.recordedBy);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/collection-records/edit/$recordId');
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
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
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

