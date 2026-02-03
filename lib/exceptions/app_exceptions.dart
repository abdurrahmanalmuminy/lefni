/// Custom exception classes for the Lefni application
/// Provides structured error handling with error codes and user-friendly messages

/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Firestore-related exceptions
class FirestoreException extends AppException {
  const FirestoreException(
    super.message, {
    super.code,
    super.originalError,
  });

  factory FirestoreException.permissionDenied([dynamic originalError]) {
    return FirestoreException(
      'Permission denied. You do not have access to this resource.',
      code: 'PERMISSION_DENIED',
      originalError: originalError,
    );
  }

  factory FirestoreException.notFound(String resourceId, [dynamic originalError]) {
    return FirestoreException(
      'Resource not found: $resourceId',
      code: 'NOT_FOUND',
      originalError: originalError,
    );
  }

  factory FirestoreException.networkError([dynamic originalError]) {
    return FirestoreException(
      'Network error. Please check your internet connection.',
      code: 'NETWORK_ERROR',
      originalError: originalError,
    );
  }

  factory FirestoreException.invalidData(String field, [dynamic originalError]) {
    return FirestoreException(
      'Invalid data format for field: $field',
      code: 'INVALID_DATA',
      originalError: originalError,
    );
  }
}

/// Storage-related exceptions
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
  });

  factory StorageException.uploadFailed(String fileName, [dynamic originalError]) {
    return StorageException(
      'Failed to upload file: $fileName',
      code: 'UPLOAD_FAILED',
      originalError: originalError,
    );
  }

  factory StorageException.downloadFailed(String fileUrl, [dynamic originalError]) {
    return StorageException(
      'Failed to download file: $fileUrl',
      code: 'DOWNLOAD_FAILED',
      originalError: originalError,
    );
  }

  factory StorageException.deleteFailed(String fileUrl, [dynamic originalError]) {
    return StorageException(
      'Failed to delete file: $fileUrl',
      code: 'DELETE_FAILED',
      originalError: originalError,
    );
  }

  factory StorageException.fileTooLarge(int maxSizeMB) {
    return StorageException(
      'File size exceeds maximum allowed size of ${maxSizeMB}MB',
      code: 'FILE_TOO_LARGE',
    );
  }

  factory StorageException.invalidFileType([dynamic originalError]) {
    return StorageException(
      'Invalid file type. Please upload a supported file format.',
      code: 'INVALID_FILE_TYPE',
      originalError: originalError,
    );
  }
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
  });

  factory AuthException.invalidCredentials([dynamic originalError]) {
    return AuthException(
      'Invalid email or password',
      code: 'INVALID_CREDENTIALS',
      originalError: originalError,
    );
  }

  factory AuthException.userNotFound([dynamic originalError]) {
    return AuthException(
      'User account not found',
      code: 'USER_NOT_FOUND',
      originalError: originalError,
    );
  }

  factory AuthException.userDisabled([dynamic originalError]) {
    return AuthException(
      'User account has been disabled',
      code: 'USER_DISABLED',
      originalError: originalError,
    );
  }

  factory AuthException.emailAlreadyInUse([dynamic originalError]) {
    return AuthException(
      'This email is already registered',
      code: 'EMAIL_ALREADY_IN_USE',
      originalError: originalError,
    );
  }

  factory AuthException.weakPassword([dynamic originalError]) {
    return AuthException(
      'Password is too weak. Please use a stronger password.',
      code: 'WEAK_PASSWORD',
      originalError: originalError,
    );
  }

  factory AuthException.invalidVerificationCode([dynamic originalError]) {
    return AuthException(
      'Invalid verification code',
      code: 'INVALID_VERIFICATION_CODE',
      originalError: originalError,
    );
  }

  factory AuthException.invalidPhoneNumber([dynamic originalError]) {
    return AuthException(
      'Invalid phone number format',
      code: 'INVALID_PHONE_NUMBER',
      originalError: originalError,
    );
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
  });

  factory ValidationException.requiredField(String fieldName) {
    return ValidationException(
      '$fieldName is required',
      code: 'REQUIRED_FIELD',
    );
  }

  factory ValidationException.invalidFormat(String fieldName, String expectedFormat) {
    return ValidationException(
      'Invalid format for $fieldName. Expected: $expectedFormat',
      code: 'INVALID_FORMAT',
    );
  }

  factory ValidationException.outOfRange(String fieldName, num min, num max) {
    return ValidationException(
      '$fieldName must be between $min and $max',
      code: 'OUT_OF_RANGE',
    );
  }
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
  });

  factory NetworkException.noConnection([dynamic originalError]) {
    return NetworkException(
      'No internet connection. Please check your network settings.',
      code: 'NO_CONNECTION',
      originalError: originalError,
    );
  }

  factory NetworkException.timeout([dynamic originalError]) {
    return NetworkException(
      'Request timed out. Please try again.',
      code: 'TIMEOUT',
      originalError: originalError,
    );
  }

  factory NetworkException.serverError(int? statusCode, [dynamic originalError]) {
    return NetworkException(
      'Server error${statusCode != null ? ' (Status: $statusCode)' : ''}. Please try again later.',
      code: 'SERVER_ERROR',
      originalError: originalError,
    );
  }
}

/// Cloud Functions exceptions
class CloudFunctionException extends AppException {
  const CloudFunctionException(
    super.message, {
    super.code,
    super.originalError,
  });

  factory CloudFunctionException.unauthorized([dynamic originalError]) {
    return CloudFunctionException(
      'Unauthorized. You do not have permission to perform this action.',
      code: 'UNAUTHORIZED',
      originalError: originalError,
    );
  }

  factory CloudFunctionException.failed(String functionName, [dynamic originalError]) {
    return CloudFunctionException(
      'Failed to execute $functionName',
      code: 'FUNCTION_FAILED',
      originalError: originalError,
    );
  }
}
