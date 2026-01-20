import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/payment_method_model.dart';
import 'package:lefni/services/firestore/collection_record_service.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:intl/intl.dart';

class CollectionRecordPage extends StatelessWidget {
  const CollectionRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: SearchAppBar(
        title: 'سجل التحصيل',
        searchHint: 'بحث في سجل التحصيل...',
      ),
      body: Column(
        children: [
          // Summary
          FutureBuilder(
            future: CollectionRecordService().getTotalCollected(
              DateTime(DateTime.now().year, 1, 1),
              DateTime.now(),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: theme.colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي المحصل',
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            currencyFormat.format(snapshot.data!),
                            style: textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: CollectionRecordService().getAllRecords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد سجلات تحصيل',
                      style: textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final record = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListTile(
                        title: Text(
                          currencyFormat.format(record.amount),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('تاريخ الدفع: ${dateFormat.format(record.paymentDate)}'),
                            Text('${AppLocalizations.of(context)!.paymentMethod}: ${PaymentMethod.fromString(record.paymentMethod).localized(AppLocalizations.of(context)!)}'),
                          ],
                        ),
                        trailing: Icon(Icons.receipt),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

