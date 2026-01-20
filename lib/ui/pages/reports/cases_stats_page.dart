import 'package:flutter/material.dart';
import 'package:lefni/services/firestore/report_service.dart';

class CasesStatsPage extends StatelessWidget {
  const CasesStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: FutureBuilder(
        future: ReportService().getCasesStats(),
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
                title: 'إجمالي القضايا',
                value: '${data['total']}',
                icon: Icons.layers,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'قضايا نشطة',
                value: '${data['active']}',
                icon: Icons.play_circle,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'قضايا منتهية',
                value: '${data['closed']}',
                icon: Icons.check_circle,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'قضايا محتملة',
                value: '${data['prospect']}',
                icon: Icons.pending,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'القضايا حسب النوع',
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...(data['byCategory'] as Map<String, dynamic>).entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getCategoryLabel(entry.key),
                                style: textTheme.bodyLarge,
                              ),
                              Text(
                                '${entry.value}',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'civil':
        return 'مدني';
      case 'criminal':
        return 'جنائي';
      case 'labor':
        return 'عمل';
      case 'intellectual_property':
        return 'ملكية فكرية';
      case 'commercial':
        return 'تجاري';
      case 'administrative':
        return 'إداري';
      default:
        return category;
    }
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

