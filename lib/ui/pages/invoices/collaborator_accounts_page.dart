import 'package:flutter/material.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/list_tiles/collaborator_card.dart';

class CollaboratorAccountsPage extends StatefulWidget {
  const CollaboratorAccountsPage({super.key});

  @override
  State<CollaboratorAccountsPage> createState() => _CollaboratorAccountsPageState();
}

class _CollaboratorAccountsPageState extends State<CollaboratorAccountsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        title: 'حسابات المتعاونين',
        searchHint: 'بحث في حسابات المتعاونين...',
        searchController: _searchController,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'محامون'),
              Tab(text: 'طلاب'),
              Tab(text: 'مهندسون'),
              Tab(text: 'محاسبون'),
              Tab(text: 'مترجمون'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRoleList(UserRole.lawyer),
                _buildRoleList(UserRole.student),
                _buildRoleList(UserRole.engineer),
                _buildRoleList(UserRole.accountant),
                _buildRoleList(UserRole.translator),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleList(UserRole role) {
    return StreamBuilder(
      stream: UserService().getUsersByRole(role),
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
                    'لا يوجد متعاونون',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
        }

        var users = snapshot.data!;
        if (_searchController.text.isNotEmpty) {
          users = users.where((u) {
            return u.email
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return CollaboratorCard(collaborator: users[index]);
          },
        );
      },
    );
  }
}

