import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'package:lefni/theme/app_theme.dart';

/// Menu item data model
class NavigationItem {
  final String label;
  final IconData icon;
  final String route;
  final bool isPlaceholder;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    this.isPlaceholder = false,
  });
}

/// Navigation Rail Component with responsive behavior
class ResponsiveNavigationRail extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final List<NavigationItem>? customMenuItems;

  const ResponsiveNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.customMenuItems,
  });

  @override
  State<ResponsiveNavigationRail> createState() =>
      _ResponsiveNavigationRailState();

  /// Get the menu items list
  static List<NavigationItem> get menuItems {
    return _ResponsiveNavigationRailState._defaultMenuItems;
  }
}

class _ResponsiveNavigationRailState extends State<ResponsiveNavigationRail> {
  bool _isExpanded = true;

  // Get menu items - use custom if provided, otherwise use default
  List<NavigationItem> get menuItems => 
      widget.customMenuItems ?? _defaultMenuItems;

  // Menu items data array
  // Available UIcons styles:
  // - UIcons.regularStraight.*  (Regular weight, straight edges)
  // - UIcons.regularRounded.*   (Regular weight, rounded edges) - Currently used
  // - UIcons.boldStraight.*      (Bold weight, straight edges)
  // - UIcons.boldRounded.*       (Bold weight, rounded edges)
  // - UIcons.solidStraight.*     (Solid fill, straight edges)
  // - UIcons.solidRounded.*      (Solid fill, rounded edges)
  // - UIcons.brands.*            (Brand icons from Flaticon)
  static final List<NavigationItem> _defaultMenuItems = [
    NavigationItem(
      label: 'اليوم',
      icon: UIcons.regularRounded.home,
      route: '/today',
    ),
    NavigationItem(
      label: 'العقود',
      icon: UIcons.regularRounded.document_signed,
      route: '/contracts',
    ),
    NavigationItem(
      label: 'القضايا',
      icon: UIcons.regularRounded.layers,
      route: '/cases',
    ),
    NavigationItem(
      label: 'الجلسات',
      icon: UIcons.regularRounded.presentation,
      route: '/sessions',
    ),
    NavigationItem(
      label: 'المواعيد',
      icon: UIcons.regularRounded.calendar_check,
      route: '/appointments',
    ),
    NavigationItem(
      label: 'العملاء',
      icon: UIcons.regularRounded.users,
      route: '/clients',
    ),
    NavigationItem(
      label: 'المستندات',
      icon: UIcons.regularRounded.folder,
      route: '/documents',
    ),
    NavigationItem(
      label: 'المهام',
      icon: UIcons.regularRounded.list_check,
      route: '/tasks',
    ),
    NavigationItem(
      label: 'الأدوات',
      icon: UIcons.regularRounded.wrench_simple,
      route: '/tools',
    ),
    NavigationItem(
      label: 'المساعدة',
      icon: UIcons.regularRounded.headset,
      route: '/help',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    if (isMobile) {
      return _buildMobileLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  /// Mobile Layout: Bottom Navigation Bar with Drawer
  Widget _buildMobileLayout() {
    return Scaffold(
      body: widget.child,
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Tablet Layout: Navigation Rail (Icons only)
  Widget _buildTabletLayout() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark
        ? AppTheme.primaryColor.withValues(
            alpha: 0.3,
          ) // Lighter highlight in dark mode
        : AppTheme.primaryColor.withValues(
            alpha: 0.15,
          ); // Lighter highlight in light mode

    return Row(
      children: [
        NavigationRail(
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
          extended: false,
          backgroundColor: theme.colorScheme.surface,
          selectedIconTheme: IconThemeData(
            size: 24,
            color: theme.colorScheme.primary,
          ),
          unselectedIconTheme: IconThemeData(
            size: 24,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7) // White in dark theme
                : theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ), // Dark in light theme
          ),
          selectedLabelTextStyle: TextStyle(
            color: theme.colorScheme.primary,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7) // White in dark theme
                : theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ), // Dark in light theme
          ),
          indicatorColor: selectedColor,
          destinations: menuItems.map((item) {
            return NavigationRailDestination(
              icon: Icon(item.icon, size: 20),
              selectedIcon: Icon(item.icon, size: 20),
              label: Text(item.label),
            );
          }).toList(),
        ),
        VerticalDivider(
          thickness: 1,
          width: 1,
          color: theme.brightness == Brightness.dark
              ? Color.lerp(theme.colorScheme.surface, Colors.black, 0.3)!
              : Color.lerp(theme.colorScheme.surface, Colors.black, 0.15)!,
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  /// Desktop Layout: Expandable Navigation Rail
  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark
        ? AppTheme.primaryColor.withValues(
            alpha: 0.3,
          ) // Lighter highlight in dark mode
        : AppTheme.primaryColor.withValues(
            alpha: 0.15,
          ); // Lighter highlight in light mode

    return Row(
      children: [
        NavigationRail(
          backgroundColor: theme.colorScheme.surface,
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
          extended: _isExpanded,
          selectedIconTheme: IconThemeData(
            size: 20,
            color: theme.colorScheme.primary,
          ),
          unselectedIconTheme: IconThemeData(
            size: 20,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7) // White in dark theme
                : theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ), // Dark in light theme
          ),
          indicatorColor: selectedColor,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Image.asset("assets/branding/lefni.png", height: 35, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
          ),
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: null,
                child: Text("بواسطة The New Universe"),
              ),
            ),
          ),
          destinations: menuItems.map((item) {
            return NavigationRailDestination(
              icon: Icon(item.icon, size: 20),
              selectedIcon: Icon(item.icon, size: 20),
              label: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        VerticalDivider(
          thickness: 1,
          width: 1,
          color: theme.brightness == Brightness.dark
              ? Color.lerp(theme.colorScheme.surface, Colors.black, 0.3)!
              : Color.lerp(theme.colorScheme.surface, Colors.black, 0.15)!,
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  /// Drawer for Mobile
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'لوحة التحكم',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('مرحباً بك', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          ...menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = widget.selectedIndex == index;

            return _buildDrawerItem(
              item: item,
              index: index,
              isSelected: isSelected,
            );
          }),
        ],
      ),
    );
  }

  /// Drawer Item
  Widget _buildDrawerItem({
    required NavigationItem item,
    required int index,
    required bool isSelected,
  }) {
    return ListTile(
      selected: isSelected,
      leading: Icon(item.icon, size: 20),
      title: Text(
        item.label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        widget.onDestinationSelected(index);
      },
    );
  }

  /// Bottom Navigation Bar for Mobile
  Widget _buildBottomNavigationBar() {
    // Show only the first 4 important items + "More" button
    final nonPlaceholderItems = menuItems
        .where((item) => !item.isPlaceholder)
        .toList();
    final displayedItems = nonPlaceholderItems.take(4).toList();
    final remainingItems = nonPlaceholderItems.skip(4).toList();

    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Color.lerp(theme.colorScheme.surface, Colors.black, 0.3)!
                : Color.lerp(theme.colorScheme.surface, Colors.black, 0.15)!,
          ),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Display first 4 items
              ...displayedItems.asMap().entries.map((entry) {
                final index = menuItems.indexOf(entry.value);
                final item = entry.value;
                final isSelected = widget.selectedIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => widget.onDestinationSelected(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // "More" button if there are remaining items
              if (remainingItems.isNotEmpty)
                Expanded(
                  child: InkWell(
                    onTap: () => _showMoreBottomSheet(context, remainingItems),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(UIcons.regularRounded.menu_dots, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            'المزيد',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show bottom sheet with remaining navigation items
  void _showMoreBottomSheet(
    BuildContext context,
    List<NavigationItem> remainingItems,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Remaining items list
            ...remainingItems.map((item) {
              final index = menuItems.indexOf(item);
              final isSelected = widget.selectedIndex == index;

              return ListTile(
                leading: Icon(item.icon, size: 20),
                title: Text(item.label),
                selected: isSelected,
                onTap: () {
                  Navigator.pop(context);
                  widget.onDestinationSelected(index);
                },
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Toggle Button for Desktop (Top)
  Widget _buildToggleButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        icon: Icon(
          _isExpanded
              ? UIcons.regularRounded.angle_left
              : UIcons.regularRounded.angle_right,
          size: 18,
        ),
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        tooltip: _isExpanded ? 'إخفاء' : 'إظهار',
      ),
    );
  }

  /// Collapse Button for Desktop (Bottom)
  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        icon: Icon(
          _isExpanded
              ? UIcons.regularRounded.angle_left
              : UIcons.regularRounded.angle_right,
          size: 18,
        ),
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        tooltip: _isExpanded ? 'إخفاء' : 'إظهار',
      ),
    );
  }
}
