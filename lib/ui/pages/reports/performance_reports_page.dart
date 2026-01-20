import 'package:flutter/material.dart';
import 'package:lefni/services/firestore/report_service.dart';
import 'package:intl/intl.dart';

class PerformanceReportsPage extends StatelessWidget {
  const PerformanceReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentFormat = NumberFormat.percentPattern('ar');

    return Scaffold(
      body: FutureBuilder(
        future: ReportService().getPerformanceReport(),
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
                title: 'معدل إنجاز المهام',
                value: percentFormat.format((data['taskCompletionRate'] as num) / 100),
                icon: Icons.checklist,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'معدل إنجاز الجلسات',
                value: percentFormat.format((data['sessionCompletionRate'] as num) / 100),
                icon: Icons.event,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'المستخدمون النشطون',
                value: '${data['activeUsers']}',
                icon: Icons.people,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'إجمالي المهام',
                value: '${data['totalTasks']}',
                icon: Icons.task,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'المهام المكتملة',
                value: '${data['completedTasks']}',
                icon: Icons.check_circle,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'إجمالي الجلسات',
                value: '${data['totalSessions']}',
                icon: Icons.event,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'الجلسات المكتملة',
                value: '${data['completedSessions']}',
                icon: Icons.check_circle,
                color: theme.colorScheme.tertiary,
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

