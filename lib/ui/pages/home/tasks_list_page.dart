import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/task_service.dart';
import 'package:lefni/models/task_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/list_tiles/task_list_tile.dart';
import 'package:lefni/ui/widgets/forms/create_task_form.dart';
import 'package:uicons/uicons.dart';

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  final TextEditingController _searchController = TextEditingController();
  TaskStatus? _statusFilter;

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

    return Scaffold(
      appBar: SearchAppBar(
        title: localizations.tasks,
        searchHint: 'بحث في المهام...',
        searchController: _searchController,
      ),
      body: Column(
        children: [
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
                  label: const Text('معلقة'),
                  selected: _statusFilter == TaskStatus.pending,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = TaskStatus.pending;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('قيد التنفيذ'),
                  selected: _statusFilter == TaskStatus.inProgress,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = TaskStatus.inProgress;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('مكتملة'),
                  selected: _statusFilter == TaskStatus.completed,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = TaskStatus.completed;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
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

                var tasks = snapshot.data!;
                if (_statusFilter != null) {
                  tasks = tasks.where((t) => t.status == _statusFilter).toList();
                }
                if (_searchController.text.isNotEmpty) {
                  tasks = tasks.where((t) {
                    return t.title
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                  }).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return TaskListTile(task: tasks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ActionFloatingButton(
        labelKey: 'assignTask',
        icon: UIcons.regularRounded.plus,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateTaskForm(),
          );
        },
      ),
    );
  }
}

