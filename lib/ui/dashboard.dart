import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/ui/navigation_rail.dart';
import 'package:uicons/uicons.dart';

class Dashboard extends StatefulWidget {
  final Function(Locale)? onLocaleChanged;
  final Locale currentLocale;

  const Dashboard({
    super.key,
    this.onLocaleChanged,
    required this.currentLocale,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  int _currentTabIndex = 0; // Default to الرئيسية (Home) tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
          _selectedIndex = 0; // Reset navigation selection when tab changes
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Get menu items based on current tab
  List<NavigationItem> _getMenuItemsForTab() {
    switch (_currentTabIndex) {
      case 0: // الرئيسية (Home) - All current menu items
        return ResponsiveNavigationRail.menuItems;
      
      case 1: // الفواتير (Invoices) - Unique menu items
        return [
          NavigationItem(
            label: 'الفواتير الصادرة',
            icon: UIcons.regularRounded.file_invoice,
            route: '/invoices/issued',
          ),
          NavigationItem(
            label: 'الفواتير المستلمة',
            icon: UIcons.regularRounded.file_invoice_dollar,
            route: '/invoices/received',
          ),
          NavigationItem(
            label: 'الفواتير المعلقة',
            icon: UIcons.regularRounded.receipt,
            route: '/invoices/pending',
          ),
          NavigationItem(
            label: 'الفواتير المدفوعة',
            icon: UIcons.regularRounded.dollar,
            route: '/invoices/paid',
          ),
          NavigationItem(
            label: 'إنشاء فاتورة',
            icon: UIcons.regularRounded.file,
            route: '/invoices/create',
          ),
          NavigationItem(
            label: 'إعدادات الفواتير',
            icon: UIcons.regularRounded.file_spreadsheet,
            route: '/invoices/settings',
          ),
        ];
      
      case 2: // المتعاونين (Partners/Collaborators) - Unique menu items
        return [
          NavigationItem(
            label: 'قائمة المتعاونين',
            icon: UIcons.regularRounded.users_alt,
            route: '/partners/list',
          ),
          NavigationItem(
            label: 'إضافة متعاون',
            icon: UIcons.regularRounded.user_add,
            route: '/partners/add',
          ),
          NavigationItem(
            label: 'عقود المتعاونين',
            icon: UIcons.regularRounded.document_signed,
            route: '/partners/contracts',
          ),
          NavigationItem(
            label: 'مهام المتعاونين',
            icon: UIcons.regularRounded.list_check,
            route: '/partners/tasks',
          ),
          NavigationItem(
            label: 'تقييمات المتعاونين',
            icon: UIcons.regularRounded.star,
            route: '/partners/ratings',
          ),
          NavigationItem(
            label: 'إحصائيات المتعاونين',
            icon: UIcons.regularRounded.people_poll,
            route: '/partners/stats',
          ),
        ];
      
      case 3: // المستخدمين (Users) - Unique menu items
        return [
          NavigationItem(
            label: 'قائمة المستخدمين',
            icon: UIcons.regularRounded.users,
            route: '/users/list',
          ),
          NavigationItem(
            label: 'إضافة مستخدم',
            icon: UIcons.regularRounded.user_add,
            route: '/users/add',
          ),
          NavigationItem(
            label: 'أدوار المستخدمين',
            icon: UIcons.regularRounded.user_time,
            route: '/users/roles',
          ),
          NavigationItem(
            label: 'صلاحيات المستخدمين',
            icon: UIcons.regularRounded.shield_check,
            route: '/users/permissions',
          ),
          NavigationItem(
            label: 'نشاط المستخدمين',
            icon: UIcons.regularRounded.chart_network,
            route: '/users/activity',
          ),
          NavigationItem(
            label: 'إعدادات المستخدمين',
            icon: UIcons.regularRounded.settings,
            route: '/users/settings',
          ),
        ];
      
      case 4: // التقارير (Reports) - Unique menu items
        return [
          NavigationItem(
            label: 'التقارير الشهرية',
            icon: UIcons.regularRounded.chart_line_up,
            route: '/reports/monthly',
          ),
          NavigationItem(
            label: 'التقارير السنوية',
            icon: UIcons.regularRounded.chart_pie,
            route: '/reports/yearly',
          ),
          NavigationItem(
            label: 'إحصائيات القضايا',
            icon: UIcons.regularRounded.chart_histogram,
            route: '/reports/cases-stats',
          ),
          NavigationItem(
            label: 'تقارير العملاء',
            icon: UIcons.regularRounded.chart_area,
            route: '/reports/clients',
          ),
          NavigationItem(
            label: 'التقارير المالية',
            icon: UIcons.regularRounded.file_chart_pie,
            route: '/reports/financial',
          ),
          NavigationItem(
            label: 'تقارير الأداء',
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
    final tabMenuItems = _getMenuItemsForTab();


    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return ResponsiveNavigationRail(
      selectedIndex: _selectedIndex < tabMenuItems.length ? _selectedIndex : 0,
      onDestinationSelected: _onDestinationSelected,
      customMenuItems: tabMenuItems,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.home),
              Tab(text: AppLocalizations.of(context)!.invoices),
              Tab(text: AppLocalizations.of(context)!.partners),
              Tab(text: AppLocalizations.of(context)!.users),
              Tab(text: AppLocalizations.of(context)!.reports),
            ],
          ),
          actions: [
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
            isMobile
                ? IconButton(
                    onPressed: () {},
                    icon: Icon(UIcons.regularRounded.user, size: 20),
                  )
                : TextButton.icon(
                    onPressed: () {},
                    icon: const CircleAvatar(radius: 15),
                    label: const Text("عبدالرحمن حسين"),
                  ),
            IconButton(
              icon: Icon(UIcons.regularRounded.bell, size: 20),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _buildPageContent(),
      ),
    );
  }

  String _getCurrentPageTitle() {
    final tabMenuItems = _getMenuItemsForTab();
    if (_selectedIndex < tabMenuItems.length) {
      return tabMenuItems[_selectedIndex].label;
    }
    return 'لوحة التحكم';
  }

  Widget _buildPageContent() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بك في ${_getCurrentPageTitle()}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(
                0xFF1E293B,
              ).withValues(alpha: 0.1), // slate-800
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'هذه صفحة تجريبية. يمكنك استبدال هذا المحتوى بأي محتوى تريده.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
