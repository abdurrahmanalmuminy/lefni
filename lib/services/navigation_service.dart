import 'dart:convert';
import 'package:flutter/services.dart';

class NavigationMap {
  final List<TabNavigation> tabs;

  NavigationMap({required this.tabs});

  factory NavigationMap.fromJson(Map<String, dynamic> json) {
    return NavigationMap(
      tabs: (json['tabs'] as List)
          .map((tab) => TabNavigation.fromJson(tab))
          .toList(),
    );
  }
}

class TabNavigation {
  final String tab;
  final List<NavigationItem> navigationItems;

  TabNavigation({
    required this.tab,
    required this.navigationItems,
  });

  factory TabNavigation.fromJson(Map<String, dynamic> json) {
    return TabNavigation(
      tab: json['tab'] as String,
      navigationItems: (json['navigation_items'] as List)
          .map((item) => NavigationItem.fromJson(item))
          .toList(),
    );
  }
}

class NavigationItem {
  final String label;
  final String route;

  NavigationItem({
    required this.label,
    required this.route,
  });

  factory NavigationItem.fromJson(Map<String, dynamic> json) {
    return NavigationItem(
      label: json['label'] as String,
      route: json['route'] as String,
    );
  }
}

class NavigationService {
  static NavigationMap? _navigationMap;

  static Future<NavigationMap> loadNavigationMap() async {
    if (_navigationMap != null) {
      return _navigationMap!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/navigation_map.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _navigationMap = NavigationMap.fromJson(jsonData);
      return _navigationMap!;
    } catch (e) {
      throw Exception('Failed to load navigation map: $e');
    }
  }

  static NavigationMap? get cachedNavigationMap => _navigationMap;
}

