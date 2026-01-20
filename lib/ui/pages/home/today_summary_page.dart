import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/session_service.dart';
import 'package:lefni/services/firestore/task_service.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/services/firestore/system_stats_service.dart';
import 'package:lefni/ui/widgets/list_tiles/session_list_tile.dart';
import 'package:lefni/ui/widgets/list_tiles/task_list_tile.dart';
import 'package:lefni/ui/widgets/list_tiles/case_list_tile.dart';

class TodaySummaryPage extends StatelessWidget {
  const TodaySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.today,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          // Stats Cards
          StreamBuilder(
            stream: SystemStatsService().streamSystemStats(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final stats = snapshot.data!;
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'القضايا النشطة',
                        value: '${stats.cases.active}',
                        icon: Icons.layers,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'الجلسات اليوم',
                        value: '${stats.sessions.today}',
                        icon: Icons.event,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'المهام المعلقة',
                        value: '${stats.sessions.thisWeek}',
                        icon: Icons.checklist,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 32),
          // Today's Sessions
          Text(
            'جلسات اليوم',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: SessionService().getUpcomingSessions(
              startDate: DateTime.now(),
            ),
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
                    'لا توجد جلسات اليوم',
                    style: textTheme.bodyLarge,
                  ),
                );
              }
              final today = DateTime.now();
              final todaySessions = snapshot.data!.where((s) {
                return s.scheduledAt.year == today.year &&
                    s.scheduledAt.month == today.month &&
                    s.scheduledAt.day == today.day;
              }).toList();

              if (todaySessions.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد جلسات اليوم',
                    style: textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todaySessions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return SessionListTile(session: todaySessions[index]);
                },
              );
            },
          ),
          const SizedBox(height: 32),
          // Upcoming Tasks
          Text(
            'المهام القادمة',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: TaskService().getTasksByAssigned('current-user-id'), // TODO: Get from auth
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
                    'لا توجد مهام',
                    style: textTheme.bodyLarge,
                  ),
                );
              }
              final upcomingTasks = snapshot.data!.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingTasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return TaskListTile(task: upcomingTasks[index]);
                },
              );
            },
          ),
          const SizedBox(height: 32),
          // Recent Cases
          Text(
            'القضايا الأخيرة',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: CaseService().getCasesByStatus(CaseStatus.active),
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
                    'لا توجد قضايا',
                    style: textTheme.bodyLarge,
                  ),
                );
              }
              final recentCases = snapshot.data!.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentCases.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return CaseListTile(case_: recentCases[index]);
                },
              );
            },
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

