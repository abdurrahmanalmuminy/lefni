import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/finance_service.dart';
import 'package:lefni/services/firestore/financial_service.dart';
import 'package:lefni/models/finance_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/list_tiles/finance_list_tile.dart';
import 'package:lefni/ui/widgets/forms/create_finance_form.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class InvoicesRevenuesPage extends StatefulWidget {
  const InvoicesRevenuesPage({super.key});

  @override
  State<InvoicesRevenuesPage> createState() => _InvoicesRevenuesPageState();
}

class _InvoicesRevenuesPageState extends State<InvoicesRevenuesPage> {
  final TextEditingController _searchController = TextEditingController();
  FinanceStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);

    return Scaffold(
      appBar: SearchAppBar(
        title: localizations.invoicesIssued,
        searchHint: 'بحث في الفواتير...',
        searchController: _searchController,
      ),
      body: Column(
        children: [
          // Summary Cards
          FutureBuilder(
            future: FinancialService().getTotalRevenues(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: theme.colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إجمالي الإيرادات',
                                  style: textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currencyFormat.format(snapshot.data!),
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: _statusFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('مدفوعة'),
                  selected: _statusFilter == FinanceStatus.paid,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = FinanceStatus.paid;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('غير مدفوعة'),
                  selected: _statusFilter == FinanceStatus.unpaid,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = FinanceStatus.unpaid;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _statusFilter != null
                  ? FinanceService().getFinancesByStatus(_statusFilter!)
                  : FinanceService().getFinancesByType(FinanceType.invoice),
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
                      'لا توجد فواتير',
                      style: textTheme.bodyLarge,
                    ),
                  );
                }

                var finances = snapshot.data!;
                if (_searchController.text.isNotEmpty) {
                  // Search would be implemented here
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: finances.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return FinanceListTile(finance: finances[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ActionFloatingButton(
        labelKey: 'createInvoice',
        icon: UIcons.regularRounded.plus,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateFinanceForm(),
          );
        },
      ),
    );
  }
}

