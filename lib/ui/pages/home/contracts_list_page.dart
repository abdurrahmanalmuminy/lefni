import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/contract_service.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/list_tiles/contract_list_tile.dart';
import 'package:lefni/ui/widgets/forms/create_contract_form.dart';
import 'package:uicons/uicons.dart';

class ContractsListPage extends StatefulWidget {
  const ContractsListPage({super.key});

  @override
  State<ContractsListPage> createState() => _ContractsListPageState();
}

class _ContractsListPageState extends State<ContractsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all'; // all, active, archived, pending

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
        title: localizations.contracts,
        searchHint: localizations.searchContracts,
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
                  selected: _filter == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'all';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('نشطة'),
                  selected: _filter == 'active',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'active';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('أرشيف'),
                  selected: _filter == 'archived',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'archived';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('في الانتظار'),
                  selected: _filter == 'pending',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'pending';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _filter == 'archived'
                  ? ContractService().getArchivedContracts()
                  : ContractService().getContractsByClient('all'), // TODO: Implement proper filtering
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
                      'لا توجد عقود',
                      style: textTheme.bodyLarge,
                    ),
                  );
                }

                var contracts = snapshot.data!;
                if (_searchController.text.isNotEmpty) {
                  contracts = contracts.where((c) {
                    return c.title
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                  }).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: contracts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return ContractListTile(contract: contracts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ActionFloatingButton(
        labelKey: 'createContract',
        icon: UIcons.regularRounded.plus,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateContractForm(),
          );
        },
      ),
    );
  }
}

