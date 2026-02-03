import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lefni/utils/logger.dart';

/// Service for loading and accessing Saudi court classifications from JSON
class CourtClassificationsService {
  static Map<String, dynamic>? _classifications;
  static bool _isLoading = false;

  /// Load classifications from JSON asset file
  static Future<Map<String, dynamic>> loadClassifications() async {
    if (_classifications != null) {
      return _classifications!;
    }

    if (_isLoading) {
      // Wait for ongoing load to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _classifications ?? {};
    }

    try {
      _isLoading = true;
      final String jsonString = await rootBundle.loadString(
        'assets/saudi_court_classifications_v1.json',
      );
      _classifications = jsonDecode(jsonString) as Map<String, dynamic>;
      AppLogger.info('Court classifications loaded successfully');
      return _classifications!;
    } catch (e) {
      AppLogger.error('Failed to load court classifications', e);
      return {};
    } finally {
      _isLoading = false;
    }
  }

  /// Get all main categories
  /// Returns list of maps with keys: key, ar, en
  static Future<List<Map<String, String>>> getMainCategories() async {
    final classifications = await loadClassifications();
    final categories = <Map<String, String>>[];

    classifications.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final ar = value['ar'] as String? ?? '';
        final en = value['en'] as String? ?? '';
        categories.add({
          'key': key,
          'ar': ar,
          'en': en,
        });
      }
    });

    return categories;
  }

  /// Get sub-categories for a main category
  /// Returns list of maps with keys: key, ar, en
  static Future<List<Map<String, String>>> getSubCategories(String mainCategory) async {
    final classifications = await loadClassifications();
    final category = classifications[mainCategory] as Map<String, dynamic>?;
    
    if (category == null) {
      return [];
    }

    final subCategories = category['sub_categories'] as Map<String, dynamic>?;
    if (subCategories == null) {
      return [];
    }

    final result = <Map<String, String>>[];
    subCategories.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final ar = value['ar'] as String? ?? '';
        final en = value['en'] as String? ?? '';
        result.add({
          'key': key,
          'ar': ar,
          'en': en,
        });
      }
    });

    return result;
  }

  /// Get case types for a main category and sub-category
  /// Returns list of case type maps with id, ar, en
  static Future<List<Map<String, dynamic>>> getCaseTypes(
    String mainCategory,
    String subCategory,
  ) async {
    final classifications = await loadClassifications();
    final category = classifications[mainCategory] as Map<String, dynamic>?;
    
    if (category == null) {
      return [];
    }

    final subCategories = category['sub_categories'] as Map<String, dynamic>?;
    if (subCategories == null) {
      return [];
    }

    final subCategoryData = subCategories[subCategory] as Map<String, dynamic>?;
    if (subCategoryData == null) {
      return [];
    }

    final cases = subCategoryData['cases'] as List<dynamic>?;
    if (cases == null) {
      return [];
    }

    return cases
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Find case type by ID across all categories
  /// Returns the case type map with id, ar, en, and category info
  static Future<Map<String, dynamic>?> findCaseTypeById(int id) async {
    final classifications = await loadClassifications();

    for (final mainCategoryEntry in classifications.entries) {
      final mainCategoryKey = mainCategoryEntry.key;
      final mainCategoryData = mainCategoryEntry.value as Map<String, dynamic>?;
      
      if (mainCategoryData == null) continue;

      final subCategories = mainCategoryData['sub_categories'] as Map<String, dynamic>?;
      if (subCategories == null) continue;

      for (final subCategoryEntry in subCategories.entries) {
        final subCategoryKey = subCategoryEntry.key;
        final subCategoryData = subCategoryEntry.value as Map<String, dynamic>?;
        
        if (subCategoryData == null) continue;

        final cases = subCategoryData['cases'] as List<dynamic>?;
        if (cases == null) continue;

        for (final caseType in cases) {
          if (caseType is Map<String, dynamic>) {
            final caseId = caseType['id'];
            if (caseId == id) {
              return {
                ...caseType,
                'mainCategory': mainCategoryKey,
                'subCategory': subCategoryKey,
                'mainCategoryAr': mainCategoryData['ar'],
                'mainCategoryEn': mainCategoryData['en'],
                'subCategoryAr': subCategoryData['ar'],
                'subCategoryEn': subCategoryData['en'],
              };
            }
          }
        }
      }
    }

    return null;
  }

  /// Get category display name in Arabic
  static Future<String> getCategoryNameAr(String mainCategory) async {
    final classifications = await loadClassifications();
    final category = classifications[mainCategory] as Map<String, dynamic>?;
    return category?['ar'] as String? ?? mainCategory;
  }

  /// Get category display name in English
  static Future<String> getCategoryNameEn(String mainCategory) async {
    final classifications = await loadClassifications();
    final category = classifications[mainCategory] as Map<String, dynamic>?;
    return category?['en'] as String? ?? mainCategory;
  }

  /// Get sub-category display name in Arabic
  static Future<String> getSubCategoryNameAr(
    String mainCategory,
    String subCategory,
  ) async {
    final classifications = await loadClassifications();
    final category = classifications[mainCategory] as Map<String, dynamic>?;
    if (category == null) return subCategory;
    
    final subCategories = category['sub_categories'] as Map<String, dynamic>?;
    if (subCategories == null) return subCategory;
    
    final subCategoryData = subCategories[subCategory] as Map<String, dynamic>?;
    return subCategoryData?['ar'] as String? ?? subCategory;
  }

  /// Get sub-category display name in English
  static Future<String> getSubCategoryNameEn(
    String mainCategory,
    String subCategory,
  ) async {
    final classifications = await loadClassifications();
    final category = classifications[mainCategory] as Map<String, dynamic>?;
    if (category == null) return subCategory;
    
    final subCategories = category['sub_categories'] as Map<String, dynamic>?;
    if (subCategories == null) return subCategory;
    
    final subCategoryData = subCategories[subCategory] as Map<String, dynamic>?;
    return subCategoryData?['en'] as String? ?? subCategory;
  }
}
