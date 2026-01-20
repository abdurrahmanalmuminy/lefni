import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart' as go_router;
import 'package:provider/provider.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/ui/navigation_rail.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:uicons/uicons.dart';
// Home pages
import 'package:lefni/ui/pages/home/today_summary_page.dart';
import 'package:lefni/ui/pages/home/contracts_list_page.dart';
import 'package:lefni/ui/pages/home/cases_list_page.dart';
import 'package:lefni/ui/pages/home/sessions_list_page.dart';
import 'package:lefni/ui/pages/home/appointments_list_page.dart';
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
// Users pages
import 'package:lefni/ui/pages/users/users_list_page.dart';
// Reports pages
import 'package:lefni/ui/pages/reports/monthly_reports_page.dart';
import 'package:lefni/ui/pages/reports/yearly_reports_page.dart';
import 'package:lefni/ui/pages/reports/cases_stats_page.dart';
import 'package:lefni/ui/pages/reports/client_reports_page.dart';
import 'package:lefni/ui/pages/reports/financial_reports_page.dart';
import 'package:lefni/ui/pages/reports/performance_reports_page.dart';

class Dashboard extends StatefulWidget {
  final Function(Locale)? onLocaleChanged;
  final Locale currentLocale;
  final Widget? child;

  const Dashboard({
    super.key,
    this.onLocaleChanged,
    required this.currentLocale,
    this.child,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  int _currentTabIndex = 0; // Default to الرئيسية (Home) tab
  String? _previousRoute;
  bool _isSyncingFromRoute = false; // Flag to prevent listener conflicts

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // Only handle tab changes if not syncing from route
    if (!_isSyncingFromRoute) {
      final userSession = Provider.of<UserSessionProvider>(context, listen: false);
      final isClient = userSession.userRole == UserRole.client;
      
      // Clients should not be able to change tabs
      if (isClient) {
        return;
      }
      
      final newTabIndex = _tabController.index;
      
      // Only navigate if tab actually changed
      if (newTabIndex != _currentTabIndex) {
        final tabMenuItems = _getMenuItemsForTab(newTabIndex);
        
        // Navigate to first route of the new tab
        if (tabMenuItems.isNotEmpty) {
          final firstRoute = tabMenuItems[0].route;
          context.go(firstRoute);
        }
        
        setState(() {
          _currentTabIndex = newTabIndex;
          _selectedIndex = 0; // Reset navigation selection when tab changes manually
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync navigation with current route
    _syncNavigationWithRoute();
  }

  void _syncNavigationWithRoute() {
    final currentRoute = go_router.GoRouterState.of(context).uri.path;
    
    // Only update if route actually changed
    if (currentRoute == _previousRoute) return;
    _previousRoute = currentRoute;

    // Determine tab index based on route
    int newTabIndex = _getTabIndexFromRoute(currentRoute);
    
    // Set flag to prevent listener from interfering
    _isSyncingFromRoute = true;
    
    // Update tab controller if needed
    if (newTabIndex != _currentTabIndex && newTabIndex != _tabController.index) {
      _tabController.animateTo(newTabIndex);
    }

    // Find menu item index within the current tab
    final tabMenuItems = _getMenuItemsForTab(newTabIndex);
    int newSelectedIndex = _findMenuItemIndex(currentRoute, tabMenuItems);

    // Update state
    if (mounted) {
      setState(() {
        _currentTabIndex = newTabIndex;
        _selectedIndex = newSelectedIndex;
      });
    }
    
    // Reset flag after a short delay to allow animation to complete
    Future.delayed(const Duration(milliseconds: 100), () {
      _isSyncingFromRoute = false;
    });
  }

  int _getTabIndexFromRoute(String route) {
    final userSession = Provider.of<UserSessionProvider>(context, listen: false);
    final isClient = userSession.userRole == UserRole.client;
    
    // Clients can only access home tab routes
    if (isClient) {
      return 0; // Force home tab for clients
    }
    
    if (route.startsWith('/invoices/')) {
      return 1; // Invoices tab
    } else if (route.startsWith('/users/')) {
      return 2; // Users tab
    } else if (route.startsWith('/reports/')) {
      return 3; // Reports tab
    } else {
      return 0; // Home tab (default)
    }
  }

  int _findMenuItemIndex(String route, List<NavigationItem> menuItems) {
    // First try exact match
    for (int i = 0; i < menuItems.length; i++) {
      if (menuItems[i].route == route) {
        return i;
      }
    }
    
    // Special handling for home tab routes
    // '/' should match '/today' (first item in home tab)
    if (route == '/') {
      for (int i = 0; i < menuItems.length; i++) {
        if (menuItems[i].route == '/today') {
          return i;
        }
      }
      // If '/today' not found, return first item
      return 0;
    }
    
    // If '/today' is requested but not found, try to find it
    if (route == '/today') {
      for (int i = 0; i < menuItems.length; i++) {
        if (menuItems[i].route == '/today' || menuItems[i].route == '/') {
          return i;
        }
      }
    }
    
    // Match by prefix for detail pages and edit pages
    // e.g., /clients/:id or /clients/edit/:id should match /clients
    for (int i = 0; i < menuItems.length; i++) {
      final menuRoute = menuItems[i].route;
      
      // Exact match already handled above, so skip if routes are equal
      if (route == menuRoute) continue;
      
      // Check if route starts with menu route followed by '/' or '/edit/'
      // This handles both detail pages (/clients/:id) and edit pages (/clients/edit/:id)
      if (route.startsWith(menuRoute)) {
        final remainingPath = route.substring(menuRoute.length);
        // If remaining path is empty, it's an exact match (already handled)
        // If it starts with '/', it's a sub-route (detail or edit page)
        if (remainingPath.isNotEmpty && remainingPath.startsWith('/')) {
          return i;
        }
      }
    }
    
    // Default to first item if no match found
    return 0;
  }

  bool _canAccessInvoices(UserRole? role) {
    return role == UserRole.admin;
  }

  bool _canAccessReports(UserRole? role) {
    return role == UserRole.admin;
  }

  bool _canAccessUsers(UserRole? role) {
    return role == UserRole.admin;
  }

  Widget _buildAccessDenied() {
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noPermission,
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    final tabMenuItems = _getMenuItemsForTab();
    if (index < tabMenuItems.length) {
      final route = tabMenuItems[index].route;
      context.go(route);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Get menu items based on current tab
  List<NavigationItem> _getMenuItemsForTab([int? tabIndex]) {
    final userSession = Provider.of<UserSessionProvider>(context, listen: false);
    final isClient = userSession.userRole == UserRole.client;
    
    // Clients get home tab menu items plus their profile
    if (isClient) {
      final clientMenuItems = List<NavigationItem>.from(ResponsiveNavigationRail.menuItems);
      // Add client profile item at the end
      clientMenuItems.add(
        NavigationItem(
          label: AppLocalizations.of(context)!.profile,
          icon: UIcons.regularRounded.user,
          route: '/client-profile',
        ),
      );
      return clientMenuItems;
    }
    
    final tab = tabIndex ?? _currentTabIndex;
    switch (tab) {
      case 0: // الرئيسية (Home) - All current menu items
        return ResponsiveNavigationRail.menuItems;
      
      case 1: // الفواتير (Invoices) - Financial module
        return [
          NavigationItem(
            label: AppLocalizations.of(context)!.invoicesAndRevenues,
            icon: UIcons.regularRounded.file_invoice,
            route: '/invoices/revenues',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.clientFees,
            icon: UIcons.regularRounded.dollar,
            route: '/invoices/fees',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.receiptVouchers,
            icon: UIcons.regularRounded.receipt,
            route: '/invoices/vouchers',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.collectionRecord,
            icon: UIcons.regularRounded.file,
            route: '/invoices/collection',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.expensesAndPayments,
            icon: UIcons.regularRounded.money_check,
            route: '/invoices/expenses',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.collaboratorAccounts,
            icon: UIcons.regularRounded.calculator,
            route: '/invoices/collaborators',
          ),
        ];
      
      case 2: // المستخدمين (Users) - User types
        return [
          NavigationItem(
            label: AppLocalizations.of(context)!.cooperatingLawyers,
            icon: UIcons.regularRounded.users_alt,
            route: '/users/lawyers',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.students,
            icon: UIcons.regularRounded.users,
            route: '/users/students',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.engineeringOffices,
            icon: UIcons.regularRounded.building,
            route: '/users/engineering',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.legalAccountants,
            icon: UIcons.regularRounded.calculator,
            route: '/users/accountants',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.translators,
            icon: UIcons.regularRounded.globe,
            route: '/users/translators',
          ),
        ];
      
      
      case 3: // التقارير (Reports) - Unique menu items
        return [
          NavigationItem(
            label: AppLocalizations.of(context)!.monthlyReports,
            icon: UIcons.regularRounded.chart_line_up,
            route: '/reports/monthly',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.yearlyReports,
            icon: UIcons.regularRounded.chart_pie,
            route: '/reports/yearly',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.casesStats,
            icon: UIcons.regularRounded.chart_histogram,
            route: '/reports/cases-stats',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.clientReports,
            icon: UIcons.regularRounded.chart_area,
            route: '/reports/clients',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.financialReports,
            icon: UIcons.regularRounded.file_chart_pie,
            route: '/reports/financial',
          ),
          NavigationItem(
            label: AppLocalizations.of(context)!.performanceReports,
            icon: UIcons.regularRounded.chart_connected,
            route: '/reports/performance',
          ),
        ];
      
      default:
        return ResponsiveNavigationRail.menuItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sync navigation with route on every build (in case route changed externally)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncNavigationWithRoute();
      }
    });
    
    final tabMenuItems = _getMenuItemsForTab();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Check if user is a client
    final userSession = Provider.of<UserSessionProvider>(context, listen: false);
    final isClient = userSession.userRole == UserRole.client;
    
    return ResponsiveNavigationRail(
      selectedIndex: _selectedIndex < tabMenuItems.length ? _selectedIndex : 0,
      onDestinationSelected: _onDestinationSelected,
      customMenuItems: tabMenuItems,
      child: Scaffold(
        appBar: AppBar( 
          elevation: 0,
          centerTitle: true,
          title: isClient
              ? Text(AppLocalizations.of(context)!.home)
              : TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.home),
                    Tab(text: AppLocalizations.of(context)!.invoices),
                    Tab(text: AppLocalizations.of(context)!.users),
                    Tab(text: AppLocalizations.of(context)!.reports),
                  ],
                ),
          actions: [
            isMobile
                ? IconButton(
                    onPressed: () {},
                    icon: Icon(UIcons.regularRounded.user, size: 20),
                  )
                : Consumer<UserSessionProvider>(
                    builder: (context, userSession, child) {
                      final userName = userSession.userModel?.profile.name ??
                          userSession.userModel?.email ??
                          AppLocalizations.of(context)!.userName;
                      return PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'profile') {
                            if (mounted) {
                              context.go('/profile');
                            }
                          } else if (value == 'signOut') {
                            await userSession.signOut();
                            if (mounted) {
                              context.go('/login');
                            }
                          }
                        },
                        itemBuilder: (context) {
                          final localizations = AppLocalizations.of(context)!;
                          return [
                            PopupMenuItem(
                              value: 'profile',
                              child: Text(localizations.profile),
                            ),
                            PopupMenuItem(
                              value: 'signOut',
                              child: Text(localizations.signOut),
                            ),
                          ];
                        },
                        child: TextButton.icon(
                          onPressed: null,
                          icon: const CircleAvatar(radius: 15),
                          label: Text(userName),
                        ),
                      );
                    },
                  ),
            // Language toggle button
            IconButton(
              icon: Icon(UIcons.regularRounded.globe, size: 20),
              tooltip: widget.currentLocale.languageCode == 'ar' ? 'English' : 'العربية',
              onPressed: () {
                if (widget.onLocaleChanged != null) {
                  final newLocale = widget.currentLocale.languageCode == 'ar'
                      ? const Locale('en')
                      : const Locale('ar');
                  widget.onLocaleChanged!(newLocale);
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Check if user is active - redirect to waiting page if not
    final userSession = Provider.of<UserSessionProvider>(context, listen: false);
    final userModel = userSession.userModel;
    
    if (userModel != null && !userModel.isActive) {
      // Redirect to waiting activation page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/waiting-activation');
        }
      });
      // Return empty container while redirecting
      return const SizedBox.shrink();
    }
    
    // If child is provided from ShellRoute, use it with access control
    if (widget.child != null) {
      final currentRoute = go_router.GoRouterState.of(context).uri.path;
      final role = userSession.userRole;
      
      // Clients can only access home tab routes
      if (role == UserRole.client) {
        if (currentRoute.startsWith('/invoices/') ||
            currentRoute.startsWith('/reports/') ||
            currentRoute.startsWith('/users/')) {
          return _buildAccessDenied();
        }
      }
      
      // Check access control for invoices, reports, and users
      if (currentRoute.startsWith('/invoices/')) {
        if (!_canAccessInvoices(role)) {
          return _buildAccessDenied();
        }
      }
      
      if (currentRoute.startsWith('/reports/')) {
        if (!_canAccessReports(role)) {
          return _buildAccessDenied();
        }
      }
      
      if (currentRoute.startsWith('/users/')) {
        if (!_canAccessUsers(role)) {
          return _buildAccessDenied();
        }
      }
      
      // Return child at full width for smooth animations
      // Constraint will be applied inside individual pages if needed
      // Wrap child with max width and center it
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: widget.child!,
        ),
      );
    }
    
    // Fallback to route-based rendering (for backwards compatibility)
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: _buildPageContent(),
      ),
    );
  }

  Widget _buildPageContent() {
    final currentRoute = go_router.GoRouterState.of(context).uri.path;
    final userSession =
        Provider.of<UserSessionProvider>(context, listen: false);
    final role = userSession.userRole;
    
    // Route-based page rendering (fallback if child is not provided)
    switch (currentRoute) {
      // Home tab routes
      case '/today':
        return const TodaySummaryPage();
      case '/contracts':
        return const ContractsListPage();
      case '/cases':
        return const CasesListPage();
      case '/sessions':
        return const SessionsListPage();
      case '/appointments':
        return const AppointmentsListPage();
      case '/clients':
        return const ClientsListPage();
      case '/documents':
        return const DocumentsListPage();
      case '/tasks':
        return const TasksListPage();
      case '/tools':
        return const ToolsPage();
      case '/help':
        return const HelpPage();
      
      // Invoices tab routes
      case '/invoices/revenues':
        if (!_canAccessInvoices(role)) return _buildAccessDenied();
        return const InvoicesRevenuesPage();
      case '/invoices/fees':
        if (!_canAccessInvoices(role)) return _buildAccessDenied();
        return const ClientFeesPage();
      case '/invoices/vouchers':
        if (!_canAccessInvoices(role)) return _buildAccessDenied();
        return const ReceiptVouchersPage();
      case '/invoices/collection':
        if (!_canAccessInvoices(role)) return _buildAccessDenied();
        return const CollectionRecordPage();
      case '/invoices/expenses':
        if (!_canAccessInvoices(role)) return _buildAccessDenied();
        return const ExpensesPaymentsPage();
      case '/invoices/collaborators':
        if (!_canAccessInvoices(role)) return _buildAccessDenied();
        return const CollaboratorAccountsPage();
      
      // Users tab routes
      case '/users/lawyers':
        if (!_canAccessUsers(role)) return _buildAccessDenied();
        return const UsersListPage(userType: 'lawyers');
      case '/users/students':
        if (!_canAccessUsers(role)) return _buildAccessDenied();
        return const UsersListPage(userType: 'students');
      case '/users/engineering':
        if (!_canAccessUsers(role)) return _buildAccessDenied();
        return const UsersListPage(userType: 'engineering');
      case '/users/accountants':
        if (!_canAccessUsers(role)) return _buildAccessDenied();
        return const UsersListPage(userType: 'accountants');
      case '/users/translators':
        if (!_canAccessUsers(role)) return _buildAccessDenied();
        return const UsersListPage(userType: 'translators');
      
      // Reports tab routes
      case '/reports/monthly':
        if (!_canAccessReports(role)) return _buildAccessDenied();
        return const MonthlyReportsPage();
      case '/reports/yearly':
        if (!_canAccessReports(role)) return _buildAccessDenied();
        return const YearlyReportsPage();
      case '/reports/cases-stats':
        if (!_canAccessReports(role)) return _buildAccessDenied();
        return const CasesStatsPage();
      case '/reports/clients':
        if (!_canAccessReports(role)) return _buildAccessDenied();
        return const ClientReportsPage();
      case '/reports/financial':
        if (!_canAccessReports(role)) return _buildAccessDenied();
        return const FinancialReportsPage();
      case '/reports/performance':
        if (!_canAccessReports(role)) return _buildAccessDenied();
        return const PerformanceReportsPage();
      
      // Default dashboard view
      case '/':
      default:
        return Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)!.welcomeTo} ${AppLocalizations.of(context)!.dashboard}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.demoPageMessage,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
    }
  }
}
