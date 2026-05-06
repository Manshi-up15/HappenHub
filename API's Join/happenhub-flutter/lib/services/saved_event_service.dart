import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saved_event_model.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

/// Handles bookmark/save API calls.
class SavedEventService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Bookmark an event ─────────────────────────────────
  Future<SavedEventModel> saveEvent(int userId, int eventId) async {
    final response = await http.post(
      Uri.parse(AppConstants.savedUrl),
      headers: await _authHeaders(),
      body: jsonEncode({'userId': userId, 'eventId': eventId}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 201) return SavedEventModel.fromJson(body['data']);
    throw Exception(body['message'] ?? 'Failed to save event');
  }

  // ─── Get user's bookmarks ──────────────────────────────
  Future<List<SavedEventModel>> getSavedEvents(int userId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.savedUrl}/$userId'),
      headers: await _authHeaders(),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List data = body['data'] as List;
      return data.map((e) => SavedEventModel.fromJson(e)).toList();
    }
    throw Exception(body['message'] ?? 'Failed to load saved events');
  }

  // ─── Remove bookmark ───────────────────────────────────
  Future<void> removeSavedEvent(int savedEventId) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.savedUrl}/$savedEventId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to remove saved event');
    }
  }
}
