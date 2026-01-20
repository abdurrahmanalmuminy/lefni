import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/list_tiles/client_list_tile.dart';
import 'package:lefni/ui/widgets/forms/create_client_form.dart';
import 'package:uicons/uicons.dart';

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  final TextEditingController _searchController = TextEditingController();
  ClientType? _typeFilter;

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
        title: localizations.clients,
        searchHint: 'بحث بالاسم أو رقم الهوية...',
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
                  selected: _typeFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _typeFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('أفراد'),
                  selected: _typeFilter == ClientType.individual,
                  onSelected: (selected) {
                    setState(() {
                      _typeFilter = ClientType.individual;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('شركات'),
                  selected: _typeFilter == ClientType.business,
                  onSelected: (selected) {
                    setState(() {
                      _typeFilter = ClientType.business;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _typeFilter != null
                  ? ClientService().getClientsByType(_typeFilter!)
                  : ClientService().getAllClients(),
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
                      'لا يوجد عملاء',
                      style: textTheme.bodyLarge,
                    ),
                  );
                }

                var clients = snapshot.data!;
                if (_searchController.text.isNotEmpty) {
                  clients = clients.where((c) {
                    return c.name
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()) ||
                        c.identityNumber
                            .contains(_searchController.text);
                  }).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: clients.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return ClientListTile(client: clients[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ActionFloatingButton(
        labelKey: 'addClient',
        icon: UIcons.regularRounded.plus,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateClientForm(),
          );
        },
      ),
    );
  }
}

