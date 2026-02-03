import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for pagination in Firestore queries
class PaginationHelper {
  /// Default page size for list queries
  static const int defaultPageSize = 20;
  
  /// Maximum page size
  static const int maxPageSize = 50;

  /// Get paginated query with limit
  static Query<T> paginateQuery<T>(
    Query<T> query, {
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
  }) {
    var paginatedQuery = query.limit(limit);
    if (startAfter != null) {
      paginatedQuery = paginatedQuery.startAfterDocument(startAfter);
    }
    return paginatedQuery;
  }

  /// Get next page query
  static Query<T> getNextPage<T>(
    Query<T> baseQuery,
    DocumentSnapshot lastDocument, {
    int limit = defaultPageSize,
  }) {
    return baseQuery.startAfterDocument(lastDocument).limit(limit);
  }
}
