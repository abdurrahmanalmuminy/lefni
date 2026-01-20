import 'package:flutter/services.dart';

class GeographicService {
  static Map<String, List<String>>? _regionCitiesMap;
  static List<String>? _regions;

  /// Load and parse the geographic data from CSV
  static Future<void> _loadData() async {
    if (_regionCitiesMap != null && _regions != null) {
      return; // Already loaded
    }

    try {
      final String csvString =
          await rootBundle.loadString('assets/GeoAdministrativeUnits.csv');
      final List<String> lines = csvString.split('\n');
      
      // Skip header line
      final dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty).toList();
      
      final Map<String, Set<String>> regionCitiesSet = {};
      
      for (final line in dataLines) {
        final parts = _parseCsvLine(line);
        if (parts.length >= 4) {
          final region = parts[3].trim(); // region_name_ar
          final city = parts[2].trim(); // city_name_ar
          
          if (region.isNotEmpty && city.isNotEmpty) {
            regionCitiesSet.putIfAbsent(region, () => <String>{});
            regionCitiesSet[region]!.add(city);
          }
        }
      }
      
      // Convert Sets to Lists and sort
      _regionCitiesMap = {};
      for (final entry in regionCitiesSet.entries) {
        final cities = entry.value.toList()..sort();
        _regionCitiesMap![entry.key] = cities;
      }
      
      // Extract and sort regions
      _regions = _regionCitiesMap!.keys.toList()..sort();
    } catch (e) {
      throw Exception('Failed to load geographic data: $e');
    }
  }

  /// Parse a CSV line handling quoted fields
  static List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    String current = '';
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current);
        current = '';
      } else {
        current += char;
      }
    }
    result.add(current); // Add last field
    
    return result;
  }

  /// Get all regions
  static Future<List<String>> getRegions() async {
    await _loadData();
    return _regions ?? [];
  }

  /// Get cities for a specific region
  static Future<List<String>> getCitiesForRegion(String region) async {
    await _loadData();
    return _regionCitiesMap?[region] ?? [];
  }

  /// Check if data is loaded
  static bool get isLoaded => _regionCitiesMap != null && _regions != null;
}
