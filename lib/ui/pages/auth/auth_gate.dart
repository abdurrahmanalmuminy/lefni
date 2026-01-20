import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/ui/pages/auth/login_page.dart';
import 'package:lefni/ui/dashboard.dart';
import 'package:lefni/config/app_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionProvider>(
      builder: (context, userSession, child) {
        // Show loading indicator while checking auth state
        if (userSession.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show login page if not authenticated
        if (!userSession.isAuthenticated) {
          return const LoginPage();
        }

        // Show dashboard if authenticated
        return Dashboard(
          onLocaleChanged: (locale) {
            AppRouter.updateLocale(locale);
          },
          currentLocale: AppRouter.currentLocale,
        );
      },
    );
  }
}

