import 'package:flutter/material.dart';
import 'package:lefni/services/firestore/expense_service.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:intl/intl.dart';

class ExpensesPaymentsPage extends StatelessWidget {
  const ExpensesPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: SearchAppBar(
        title: 'المصروفات والمدفوعات',
        searchHint: 'بحث في المصروفات...',
      ),
      body: Column(
        children: [
          // Summary
          FutureBuilder(
            future: ExpenseService().getTotalExpenses(
              DateTime(DateTime.now().year, 1, 1),
              DateTime.now(),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي المصروفات',
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            currencyFormat.format(snapshot.data!),
                            style: textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
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
              stream: ExpenseService().getAllExpenses(),
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
                      'لا توجد مصروفات',
                      style: textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final expense = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.errorContainer,
                          child: Icon(
                            Icons.money_off,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        title: Text(
                          expense.category,
                          style: textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currencyFormat.format(expense.amount),
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('تاريخ: ${dateFormat.format(expense.date)}'),
                            if (expense.description != null)
                              Text(expense.description!),
                          ],
                        ),
                        trailing: expense.receiptImageUrl != null
                            ? Icon(Icons.receipt)
                            : null,
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

