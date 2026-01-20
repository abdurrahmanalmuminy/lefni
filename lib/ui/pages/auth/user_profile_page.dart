import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/services/firestore/user_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _nameController = TextEditingController();
  final _userService = UserService();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userSession = Provider.of<UserSessionProvider>(context, listen: false);
      final user = userSession.userModel;
      if (user != null) {
        final updatedProfile = user.profile.copyWith(
          name: _nameController.text.trim(),
        );
        final updatedUser = user.copyWith(profile: updatedProfile);
        await _userService.updateUser(updatedUser);
        await userSession.refreshUser();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.accountCreated),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final userSession = Provider.of<UserSessionProvider>(context);
    final user = userSession.userModel;

    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.profile.name ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              onPressed: _isSaving ? null : _saveName,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: user == null
          ? Center(
              child: Text(
                'No data found',
                style: textTheme.titleMedium,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 24,
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      user.profile.name ?? user.email,
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      user.role.value,
                      style: textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localizations.name,
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  _isEditing
                      ? TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: localizations.name,
                          ),
                        )
                      : Text(
                          user.profile.name ?? localizations.userName,
                          style: textTheme.bodyMedium,
                        ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.email,
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.role,
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.role.value,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
    );
  }
}


