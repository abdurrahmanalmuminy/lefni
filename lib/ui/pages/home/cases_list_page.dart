import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/list_tiles/case_list_tile.dart';
import 'package:lefni/ui/widgets/forms/create_case_form.dart';
import 'package:uicons/uicons.dart';

class CasesListPage extends StatefulWidget {
  const CasesListPage({super.key});

  @override
  State<CasesListPage> createState() => _CasesListPageState();
}

class _CasesListPageState extends State<CasesListPage> {
  final TextEditingController _searchController = TextEditingController();
  CaseStatus? _statusFilter;

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
        title: localizations.cases,
        searchHint: 'بحث برقم القضية...',
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
                  label: const Text('محتملة'),
                  selected: _statusFilter == CaseStatus.prospect,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = CaseStatus.prospect;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('نشطة'),
                  selected: _statusFilter == CaseStatus.active,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = CaseStatus.active;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('منتهية'),
                  selected: _statusFilter == CaseStatus.closed,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = CaseStatus.closed;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _statusFilter != null
                  ? CaseService().getCasesByStatus(_statusFilter!)
                  : CaseService().getCasesByStatus(CaseStatus.active), // TODO: Get all cases
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

                var cases = snapshot.data!;
                if (_searchController.text.isNotEmpty) {
                  cases = cases.where((c) {
                    return c.caseNumber
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                  }).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: cases.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return CaseListTile(case_: cases[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ActionFloatingButton(
        labelKey: 'addCase',
        icon: UIcons.regularRounded.plus,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateCaseForm(),
          );
        },
      ),
    );
  }
}

