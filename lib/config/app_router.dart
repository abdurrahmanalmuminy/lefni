import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lefni/models/lefbi_onboarding.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/onboarding_service.dart';
import 'package:lefni/ui/dashboard.dart';
import 'package:lefni/ui/pages/auth/landing_page.dart';
import 'package:lefni/ui/pages/auth/login_page.dart';
import 'package:lefni/ui/pages/auth/onboarding_page.dart';
import 'package:lefni/ui/pages/auth/user_profile_page.dart';
import 'package:lefni/ui/pages/auth/waiting_activation_page.dart';
import 'package:lefni/providers/user_session_provider.dart';
// Home pages
import 'package:lefni/ui/pages/home/today_summary_page.dart';
import 'package:lefni/ui/pages/home/contracts_list_page.dart';
import 'package:lefni/ui/pages/home/cases_list_page.dart';
import 'package:lefni/ui/pages/home/sessions_list_page.dart';
import 'package:lefni/ui/pages/home/appointments_list_page.dart';
import 'package:lefni/ui/pages/home/consultations_list_page.dart';
import 'package:lefni/ui/pages/home/clients_list_page.dart';
import 'package:lefni/ui/pages/home/documents_list_page.dart';
import 'package:lefni/ui/pages/home/tasks_list_page.dart';
import 'package:lefni/ui/pages/home/tools_page.dart';
import 'package:lefni/ui/pages/home/help_page.dart';
// Invoices pages
import 'package:lefni/ui/pages/invoices/invoices_revenues_page.dart';
import 'package:lefni/ui/pages/invoices/client_fees_page.dart';
import 'package:lefni/ui/pages/invoices/receipt_vouchers_page.dart';
import 'package:lefni/ui/pages/invoices/collection_record_page.dart';
import 'package:lefni/ui/pages/invoices/expenses_payments_page.dart';
import 'package:lefni/ui/pages/invoices/collaborator_accounts_page.dart';
// Detail pages
import 'package:lefni/ui/pages/details/client_detail_page.dart';
import 'package:lefni/ui/pages/details/case_detail_page.dart';
import 'package:lefni/ui/pages/details/session_detail_page.dart';
import 'package:lefni/ui/pages/details/appointment_detail_page.dart';
import 'package:lefni/ui/pages/details/consultation_detail_page.dart';
import 'package:lefni/ui/pages/details/contract_detail_page.dart';
import 'package:lefni/ui/pages/details/document_detail_page.dart';
import 'package:lefni/ui/pages/details/task_detail_page.dart';
import 'package:lefni/ui/pages/details/finance_detail_page.dart';
import 'package:lefni/ui/pages/details/expense_detail_page.dart';
import 'package:lefni/ui/pages/details/collection_record_detail_page.dart';
import 'package:lefni/ui/pages/details/user_detail_page.dart';
// Edit pages (will show form dialogs)
import 'package:lefni/ui/pages/details/client_edit_page.dart';
import 'package:lefni/ui/pages/details/case_edit_page.dart';
import 'package:lefni/ui/pages/details/session_edit_page.dart';
import 'package:lefni/ui/pages/details/appointment_edit_page.dart';
import 'package:lefni/ui/pages/details/contract_edit_page.dart';
import 'package:lefni/ui/pages/details/document_edit_page.dart';
import 'package:lefni/ui/pages/details/task_edit_page.dart';
import 'package:lefni/ui/pages/details/finance_edit_page.dart';
import 'package:lefni/ui/pages/details/expense_edit_page.dart';
import 'package:lefni/ui/pages/details/collection_record_edit_page.dart';
import 'package:lefni/ui/pages/details/user_edit_page.dart';
// Reports pages
import 'package:lefni/ui/pages/reports/monthly_reports_page.dart';
import 'package:lefni/ui/pages/reports/yearly_reports_page.dart';
import 'package:lefni/ui/pages/reports/cases_stats_page.dart';
import 'package:lefni/ui/pages/reports/client_reports_page.dart';
import 'package:lefni/ui/pages/reports/financial_reports_page.dart';
import 'package:lefni/ui/pages/reports/performance_reports_page.dart';
// Users pages
import 'package:lefni/ui/pages/users/users_list_page.dart';
import 'package:lefni/ui/pages/users/client_profile_page.dart';

class AppRouter {
  static Locale _currentLocale = const Locale('ar');
  static Function(Locale)? _onLocaleChanged;
  static ThemeMode _currentThemeMode = ThemeMode.system;
  static Function(ThemeMode)? _onThemeModeChanged;

  static void setLocaleCallback(Function(Locale) callback) {
    _onLocaleChanged = callback;
  }

  static void updateLocale(Locale locale) {
    _currentLocale = locale;
    _onLocaleChanged?.call(locale);
  }

  static Locale get currentLocale => _currentLocale;

  static void setThemeModeCallback(Function(ThemeMode) callback) {
    _onThemeModeChanged = callback;
  }

  static void updateThemeMode(ThemeMode themeMode) {
    _currentThemeMode = themeMode;
    _onThemeModeChanged?.call(themeMode);
  }

  static ThemeMode get currentThemeMode => _currentThemeMode;

  // Helper function to build all routes
  static List<RouteBase> _buildRoutes() {
    return [
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(
          selectedRoleId: state.uri.queryParameters['role'],
        ),
      ),
      GoRoute(
        path: '/waiting-activation',
        builder: (context, state) => const WaitingActivationPage(),
      ),
      // Dashboard shell route - wraps all content pages
      ShellRoute(
        builder: (context, state, child) {
          return Dashboard(
            onLocaleChanged: (locale) {
              updateLocale(locale);
            },
            currentLocale: _currentLocale,
            onThemeModeChanged: (themeMode) {
              updateThemeMode(themeMode);
            },
            currentThemeMode: _currentThemeMode,
            child: child,
          );
        },
        routes: [
          // Default route (home) - show today summary
          GoRoute(
            path: '/',
            builder: (context, state) => const TodaySummaryPage(),
          ),
          // Home tab routes
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodaySummaryPage(),
          ),
          GoRoute(
            path: '/contracts',
            builder: (context, state) => const ContractsListPage(),
          ),
          GoRoute(
            path: '/contracts/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ContractDetailPage(contractId: id);
            },
          ),
          GoRoute(
            path: '/contracts/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ContractEditPage(contractId: id);
            },
          ),
          GoRoute(
            path: '/cases',
            builder: (context, state) => const CasesListPage(),
          ),
          GoRoute(
            path: '/cases/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CaseDetailPage(caseId: id);
            },
          ),
          GoRoute(
            path: '/cases/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CaseEditPage(caseId: id);
            },
          ),
          GoRoute(
            path: '/sessions',
            builder: (context, state) => const SessionsListPage(),
          ),
          GoRoute(
            path: '/sessions/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return SessionDetailPage(sessionId: id);
            },
          ),
          GoRoute(
            path: '/sessions/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return SessionEditPage(sessionId: id);
            },
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentsListPage(),
          ),
          GoRoute(
            path: '/appointments/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppointmentDetailPage(appointmentId: id);
            },
          ),
          GoRoute(
            path: '/appointments/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppointmentEditPage(appointmentId: id);
            },
          ),
          GoRoute(
            path: '/consultations',
            builder: (context, state) => const ConsultationsListPage(),
          ),
          GoRoute(
            path: '/consultations/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ConsultationDetailPage(consultationId: id);
            },
          ),
          GoRoute(
            path: '/clients',
            builder: (context, state) => const ClientsListPage(),
          ),
          GoRoute(
            path: '/clients/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ClientDetailPage(clientId: id);
            },
          ),
          GoRoute(
            path: '/clients/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ClientEditPage(clientId: id);
            },
          ),
          GoRoute(
            path: '/client-profile',
            builder: (context, state) => const ClientProfilePage(),
          ),
          GoRoute(
            path: '/documents',
            builder: (context, state) => const DocumentsListPage(),
          ),
          GoRoute(
            path: '/documents/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DocumentDetailPage(documentId: id);
            },
          ),
          GoRoute(
            path: '/documents/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DocumentEditPage(documentId: id);
            },
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksListPage(),
          ),
          GoRoute(
            path: '/tasks/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TaskDetailPage(taskId: id);
            },
          ),
          GoRoute(
            path: '/tasks/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TaskEditPage(taskId: id);
            },
          ),
          GoRoute(
            path: '/tools',
            builder: (context, state) => const ToolsPage(),
          ),
          GoRoute(
            path: '/help',
            builder: (context, state) => const HelpPage(),
          ),
          // Invoices tab routes
          GoRoute(
            path: '/invoices/revenues',
            builder: (context, state) => const InvoicesRevenuesPage(),
          ),
          GoRoute(
            path: '/invoices/fees',
            builder: (context, state) => const ClientFeesPage(),
          ),
          GoRoute(
            path: '/invoices/vouchers',
            builder: (context, state) => const ReceiptVouchersPage(),
          ),
          GoRoute(
            path: '/invoices/collection',
            builder: (context, state) => const CollectionRecordPage(),
          ),
          GoRoute(
            path: '/invoices/expenses',
            builder: (context, state) => const ExpensesPaymentsPage(),
          ),
          GoRoute(
            path: '/invoices/collaborators',
            builder: (context, state) => const CollaboratorAccountsPage(),
          ),
          // Detail routes for invoices/finances
          GoRoute(
            path: '/invoices/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return FinanceDetailPage(financeId: id);
            },
          ),
          GoRoute(
            path: '/invoices/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return FinanceEditPage(financeId: id);
            },
          ),
          // Detail routes for expenses
          GoRoute(
            path: '/expenses/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ExpenseDetailPage(expenseId: id);
            },
          ),
          GoRoute(
            path: '/expenses/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ExpenseEditPage(expenseId: id);
            },
          ),
          // Detail routes for collection records
          GoRoute(
            path: '/collection-records/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CollectionRecordDetailPage(recordId: id);
            },
          ),
          GoRoute(
            path: '/collection-records/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CollectionRecordEditPage(recordId: id);
            },
          ),
          // Users tab routes
          GoRoute(
            path: '/users/lawyers',
            builder: (context, state) => const UsersListPage(userType: 'lawyers'),
          ),
          GoRoute(
            path: '/users/students',
            builder: (context, state) => const UsersListPage(userType: 'students'),
          ),
          GoRoute(
            path: '/users/engineering',
            builder: (context, state) => const UsersListPage(userType: 'engineering'),
          ),
          GoRoute(
            path: '/users/accountants',
            builder: (context, state) => const UsersListPage(userType: 'accountants'),
          ),
          GoRoute(
            path: '/users/translators',
            builder: (context, state) => const UsersListPage(userType: 'translators'),
          ),
          // Reports tab routes
          GoRoute(
            path: '/reports/monthly',
            builder: (context, state) => const MonthlyReportsPage(),
          ),
          GoRoute(
            path: '/reports/yearly',
            builder: (context, state) => const YearlyReportsPage(),
          ),
          GoRoute(
            path: '/reports/cases-stats',
            builder: (context, state) => const CasesStatsPage(),
          ),
          GoRoute(
            path: '/reports/clients',
            builder: (context, state) => const ClientReportsPage(),
          ),
          GoRoute(
            path: '/reports/financial',
            builder: (context, state) => const FinancialReportsPage(),
          ),
          GoRoute(
            path: '/reports/performance',
            builder: (context, state) => const PerformanceReportsPage(),
          ),
          // User detail routes
          GoRoute(
            path: '/users/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return UserDetailPage(userId: id);
            },
          ),
          GoRoute(
            path: '/users/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return UserEditPage(userId: id);
            },
          ),
          // Profile route (still inside dashboard)
          GoRoute(
            path: '/profile',
            builder: (context, state) => const UserProfilePage(),
          ),
        ],
      ),
    ];
  }

  // Create router with refreshListenable to listen to auth state changes
  static GoRouter createRouter(UserSessionProvider userSessionProvider) {
    return GoRouter(
      initialLocation: '/landing',
      refreshListenable: userSessionProvider,
      redirect: (context, state) async {
        final onboardingId =
            lefniOnboarding['onboarding_id'] as String? ?? 'lefni_v1';
        final user = FirebaseAuth.instance.currentUser;
        final isLoggedIn = user != null;
        final currentPath = state.uri.path;
        final isGoingToLanding = currentPath == '/landing';
        final isGoingToLogin = currentPath == '/login';
        final isGoingToOnboarding = currentPath == '/onboarding';
        final isGoingToWaiting = currentPath == '/waiting-activation';
        final isClient = userSessionProvider.userRole == UserRole.client;

        // If logged in as client, enforce onboarding before entering the app.
        // We only do this after userModel is loaded to avoid redirect flicker.
        Future<bool> clientNeedsOnboarding() async {
          if (!isLoggedIn || !isClient) return false;
          if (userSessionProvider.isLoading || userSessionProvider.userModel == null) {
            return false;
          }
          final completed = await OnboardingService.isCompleted(
            onboardingId: onboardingId,
            roleId: 'client',
            uid: user.uid,
          );
          return !completed;
        }

        // Allow access to landing, login, onboarding, and waiting-activation pages
        if (isGoingToLanding || isGoingToLogin || isGoingToOnboarding || isGoingToWaiting) {
          // If logged in and going to landing or login, redirect to onboarding/home
          if (isLoggedIn && (isGoingToLanding || isGoingToLogin)) {
            if (await clientNeedsOnboarding()) {
              return '/onboarding?role=client';
            }
            return '/';
          }
          // If client already completed onboarding, don't allow going back to onboarding
          if (isLoggedIn && isGoingToOnboarding && isClient) {
            final completed = await OnboardingService.isCompleted(
              onboardingId: onboardingId,
              roleId: 'client',
              uid: user.uid,
            );
            if (completed) return '/';
          }
          return null; // Allow access to these pages
        }

        // If not logged in and not going to auth pages, redirect to landing
        if (!isLoggedIn) {
          return '/landing';
        }

        // Logged-in client: if onboarding not completed, force onboarding
        if (await clientNeedsOnboarding()) {
          return '/onboarding?role=client';
        }

        return null; // No redirect needed
      },
      routes: _buildRoutes(),
    );
  }

  // Static router for backward compatibility (won't refresh on auth changes)
  // Use createRouter() in main.dart for proper auth state listening
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final currentPath = state.uri.path;
      final isGoingToLanding = currentPath == '/landing';
      final isGoingToLogin = currentPath == '/login';
      final isGoingToOnboarding = currentPath == '/onboarding';
      final isGoingToWaiting = currentPath == '/waiting-activation';

      // Allow access to landing, login, onboarding, and waiting-activation pages
      if (isGoingToLanding || isGoingToLogin || isGoingToOnboarding || isGoingToWaiting) {
        // If logged in and going to landing or login, redirect to home
        if (isLoggedIn && (isGoingToLanding || isGoingToLogin)) {
          return '/';
        }
        return null; // Allow access to these pages
      }

      // If not logged in and not going to auth pages, redirect to landing
      if (!isLoggedIn) {
        return '/landing';
      }

      return null; // No redirect needed
    },
    routes: _buildRoutes(),
  );
}

