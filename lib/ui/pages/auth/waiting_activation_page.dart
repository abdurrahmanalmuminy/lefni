import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/user_model.dart';

class WaitingActivationPage extends StatelessWidget {
  const WaitingActivationPage({super.key});

  String _getRoleLabel(UserRole role, AppLocalizations localizations) {
    switch (role) {
      case UserRole.admin:
        return 'مدير'; // Admin
      case UserRole.lawyer:
        return localizations.partyTypeLawyer;
      case UserRole.student:
        return 'طالب'; // Student
      case UserRole.engineer:
        return localizations.partyTypeEngineer;
      case UserRole.accountant:
        return localizations.partyTypeAccountant;
      case UserRole.translator:
        return localizations.partyTypeTranslator;
      case UserRole.client:
        return localizations.partyTypeClient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final userSession = Provider.of<UserSessionProvider>(context);
    final userModel = userSession.userModel;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Icon(
                  Icons.hourglass_empty,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'الحساب في انتظار التفعيل',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Message
                Text(
                  'حسابك في انتظار التفعيل. يرجى الانتظار حتى يقوم المسؤول بتفعيل حسابك قبل أن تتمكن من الوصول إلى لوحة التحكم.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // User info
                if (userModel != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.accountInformation,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${localizations.email}: ${userModel.email}'),
                          if (userModel.profile.name != null)
                            Text('${localizations.name}: ${userModel.profile.name}'),
                          Text('${localizations.role}: ${_getRoleLabel(userModel.role, localizations)}'),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Refresh button
                ElevatedButton.icon(
                  onPressed: () async {
                    await userSession.refreshUser();
                    // Check if user is now active
                    if (userSession.userModel?.isActive == true) {
                      if (context.mounted) {
                        context.go('/');
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'حسابك لا يزال في انتظار التفعيل. يرجى المحاولة لاحقاً.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('تحديث الحالة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                // Sign out button
                TextButton.icon(
                  onPressed: () async {
                    await userSession.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(localizations.signOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

