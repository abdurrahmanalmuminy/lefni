import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/list_tiles/collaborator_card.dart';
import 'package:lefni/ui/widgets/forms/create_user_form.dart';
import 'package:uicons/uicons.dart';

class UsersListPage extends StatefulWidget {
  final String? userType;

  const UsersListPage({
    super.key,
    this.userType,
  });

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _initialTab = 0;

  @override
  void initState() {
    super.initState();
    // Determine initial tab from route
    _initialTab = _getTabFromRoute(widget.userType);
    _tabController = TabController(length: 5, vsync: this, initialIndex: _initialTab);
  }

  int _getTabFromRoute(String? route) {
    switch (route) {
      case 'lawyers':
        return 0;
      case 'students':
        return 1;
      case 'engineering':
        return 2;
      case 'accountants':
        return 3;
      case 'translators':
        return 4;
      default:
        return 0;
    }
  }

  UserRole _getRoleFromTab(int index) {
    switch (index) {
      case 0:
        return UserRole.lawyer;
      case 1:
        return UserRole.student;
      case 2:
        return UserRole.engineer;
      case 3:
        return UserRole.accountant;
      case 4:
        return UserRole.translator;
      default:
        return UserRole.lawyer;
    }
  }

  String _getLabelKeyFromTab(int index) {
    switch (index) {
      case 0:
        return 'addLawyer';
      case 1:
        return 'addStudent';
      case 2:
        return 'addEngineer';
      case 3:
        return 'addAccountant';
      case 4:
        return 'addTranslator';
      default:
        return 'addUser';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: SearchAppBar(
        title: localizations.usersList,
        searchHint: 'بحث في المستخدمين...',
        searchController: _searchController,
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (index) {
          return _buildRoleList(_getRoleFromTab(index));
        }),
      ),
      floatingActionButton: ActionFloatingButton(
        labelKey: _getLabelKeyFromTab(_tabController.index),
        icon: UIcons.regularRounded.plus,
        onPressed: () {
          final role = _getRoleFromTab(_tabController.index);
          showDialog(
            context: context,
            builder: (context) => CreateUserForm(role: role),
          );
        },
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
                    'لا يوجد مستخدمون',
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

