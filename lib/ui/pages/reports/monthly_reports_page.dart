import 'package:flutter/material.dart';
import 'package:lefni/services/firestore/report_service.dart';
import 'package:intl/intl.dart';

class MonthlyReportsPage extends StatefulWidget {
  const MonthlyReportsPage({super.key});

  @override
  State<MonthlyReportsPage> createState() => _MonthlyReportsPageState();
}

class _MonthlyReportsPageState extends State<MonthlyReportsPage> {
  final ReportService _reportService = ReportService();
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);

    return Scaffold(
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isExpanded: true,
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedMonth,
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _reportService.getMonthlyReport(_selectedYear, _selectedMonth),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('لا توجد بيانات'));
                }

                final data = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _StatCard(
                      title: 'القضايا الجديدة',
                      value: '${data['newCases']}',
                      icon: Icons.layers,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      title: 'القضايا المنتهية',
                      value: '${data['closedCases']}',
                      icon: Icons.check_circle,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      title: 'الإيرادات',
                      value: currencyFormat.format(data['revenues']),
                      icon: Icons.trending_up,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      title: 'المصروفات',
                      value: currencyFormat.format(data['expenses']),
                      icon: Icons.trending_down,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      title: 'صافي الربح',
                      value: currencyFormat.format(data['profit']),
                      icon: Icons.account_balance,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      title: 'العملاء الجدد',
                      value: '${data['newClients']}',
                      icon: Icons.people,
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

