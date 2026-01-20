import 'package:flutter/material.dart';
import 'package:lefni/services/firestore/report_service.dart';
import 'package:intl/intl.dart';

class ClientReportsPage extends StatelessWidget {
  const ClientReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);

    return Scaffold(
      body: FutureBuilder(
        future: ReportService().getClientReports(null),
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
                title: 'إجمالي العملاء',
                value: '${data['totalClients']}',
                icon: Icons.people,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'أفراد',
                value: '${data['individuals']}',
                icon: Icons.person,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'شركات',
                value: '${data['businesses']}',
                icon: Icons.business,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 24),
              if (data['clients'] != null && (data['clients'] as List).isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل العملاء',
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...(data['clients'] as List).take(10).map((client) {
                          return ListTile(
                            title: Text(client['name'] ?? ''),
                            subtitle: Text(
                              'قضايا نشطة: ${client['activeCases']} | إجمالي الفواتير: ${currencyFormat.format(client['totalInvoiced'] ?? 0)}',
                            ),
                            trailing: Icon(Icons.chevron_right),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
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

