/// Typed API error — carries HTTP status, message, and field-level errors.
/// Screens catch this instead of generic Exception for precise error display.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, String>? fieldErrors; // validation errors per field

  const ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors,
  });

  /// Whether the token was rejected (expired or invalid).
  bool get isUnauthorized => statusCode == 401;

  /// Whether the user lacks permission (wrong role etc.).
  bool get isForbidden => statusCode == 403;

  /// Whether the resource was not found.
  bool get isNotFound => statusCode == 404;

  /// Whether it's a conflict (e.g. duplicate email, already saved).
  bool get isConflict => statusCode == 409;

  /// Whether it was a network/timeout issue (no HTTP response).
  bool get isNetworkError => statusCode == 0;

  @override
  String toString() => message;

  /// Human-friendly message suitable for a SnackBar.
  String get userMessage {
    if (isNetworkError) return 'Cannot connect to server. Check your network.';
    if (isUnauthorized) return 'Session expired. Please log in again.';
    if (isForbidden)    return 'You don\'t have permission to do this.';
    if (isNotFound)     return 'Resource not found.';
    if (isConflict)     return message; // conflict messages are already user-friendly
    return message;
  }
}
