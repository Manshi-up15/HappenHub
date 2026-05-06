import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_exception.dart';

/// Central HTTP client used by all services.
///
/// Responsibilities:
///  - Injects Authorization header automatically
///  - Enforces request timeout (10s)
///  - Normalises every response into either data or [ApiException]
///  - On 401, clears stored credentials so the app can redirect to login
typedef OnUnauthorized = void Function();

class ApiClient {
  static const Duration _timeout = Duration(seconds: 10);

  // Optional callback — set by the app root to redirect on 401.
  static OnUnauthorized? onUnauthorized;

  // ─── Header builder ────────────────────────────────────
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── GET ───────────────────────────────────────────────
  static Future<dynamic> get(String url,
      {Map<String, String>? params, bool auth = true}) async {
    final uri = Uri.parse(url).replace(queryParameters: params);
    try {
      final response =
          await http.get(uri, headers: await _headers(auth: auth)).timeout(_timeout);
      return _parse(response);
    } on TimeoutException {
      throw const ApiException(statusCode: 0, message: 'Request timed out.');
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  // ─── POST ──────────────────────────────────────────────
  static Future<dynamic> post(String url,
      {Object? body, Map<String, String>? params, bool auth = true}) async {
    final uri = params != null
        ? Uri.parse(url).replace(queryParameters: params)
        : Uri.parse(url);
    try {
      final response = await http
          .post(uri, headers: await _headers(auth: auth), body: jsonEncode(body))
          .timeout(_timeout);
      return _parse(response);
    } on TimeoutException {
      throw const ApiException(statusCode: 0, message: 'Request timed out.');
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  // ─── PUT ───────────────────────────────────────────────
  static Future<dynamic> put(String url,
      {Object? body, bool auth = true}) async {
    try {
      final response = await http
          .put(Uri.parse(url), headers: await _headers(auth: auth), body: jsonEncode(body))
          .timeout(_timeout);
      return _parse(response);
    } on TimeoutException {
      throw const ApiException(statusCode: 0, message: 'Request timed out.');
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  // ─── DELETE ────────────────────────────────────────────
  static Future<void> delete(String url, {bool auth = true}) async {
    try {
      final response = await http
          .delete(Uri.parse(url), headers: await _headers(auth: auth))
          .timeout(_timeout);
      _parse(response); // throws if not 2xx
    } on TimeoutException {
      throw const ApiException(statusCode: 0, message: 'Request timed out.');
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  // ─── Response parser ───────────────────────────────────
  /// Returns the `data` field from { success, message, data }.
  /// Throws [ApiException] for any non-2xx status.
  static dynamic _parse(http.Response response) {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // Non-JSON response (e.g. gateway error)
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unexpected server response (${response.statusCode}).',
      );
    }

    // ── 401 → auto-logout ──────────────────────────────
    if (response.statusCode == 401) {
      _clearCredentials();
      onUnauthorized?.call();
      throw ApiException(
        statusCode: 401,
        message: body['message'] ?? 'Session expired.',
      );
    }

    // ── 2xx success ────────────────────────────────────
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'];
    }

    // ── Validation errors (400) ────────────────────────
    Map<String, String>? fieldErrors;
    if (response.statusCode == 400 && body['data'] is Map) {
      fieldErrors = Map<String, String>.from(
        (body['data'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] ?? 'Something went wrong.',
      fieldErrors: fieldErrors,
    );
  }

  static Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
