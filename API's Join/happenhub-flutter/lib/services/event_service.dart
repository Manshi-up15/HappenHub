import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

/// Handles all event-related API calls.
class EventService {
  final AuthService _authService = AuthService();

  // ─── Auth header helper ────────────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── GET all events (with optional filters) ────────────
  Future<List<EventModel>> getEvents({
    String? category,
    String? mood,
    String? from,
    String? to,
  }) async {
    final params = <String, String>{};
    if (category != null && category != 'All') params['category'] = category;
    if (mood != null && mood != 'All') params['mood'] = mood;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final uri = Uri.parse(AppConstants.eventsUrl).replace(queryParameters: params);
    final response = await http.get(uri, headers: await _authHeaders());
    return _parseEventList(response);
  }

  // ─── GET single event ──────────────────────────────────
  Future<EventModel> getEventById(int id) async {
    final response = await http.get(
      Uri.parse('${AppConstants.eventsUrl}/$id'),
      headers: await _authHeaders(),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return EventModel.fromJson(body['data']);
    throw Exception(body['message'] ?? 'Failed to load event');
  }

  // ─── GET search results ────────────────────────────────
  Future<List<EventModel>> searchEvents(String keyword) async {
    final uri = Uri.parse('${AppConstants.eventsUrl}/search')
        .replace(queryParameters: {'keyword': keyword});
    final response = await http.get(uri, headers: await _authHeaders());
    return _parseEventList(response);
  }

  // ─── GET upcoming events ───────────────────────────────
  Future<List<EventModel>> getUpcomingEvents() async {
    final response = await http.get(
      Uri.parse('${AppConstants.eventsUrl}/upcoming'),
      headers: await _authHeaders(),
    );
    return _parseEventList(response);
  }

  // ─── POST create event ─────────────────────────────────
  Future<EventModel> createEvent(Map<String, dynamic> data, int createdById) async {
    final uri = Uri.parse(AppConstants.eventsUrl)
        .replace(queryParameters: {'createdById': createdById.toString()});

    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 201) return EventModel.fromJson(body['data']);
    throw Exception(body['message'] ?? 'Failed to create event');
  }

  // ─── PUT update event ──────────────────────────────────
  Future<EventModel> updateEvent(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.eventsUrl}/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return EventModel.fromJson(body['data']);
    throw Exception(body['message'] ?? 'Failed to update event');
  }

  // ─── DELETE event ──────────────────────────────────────
  Future<void> deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.eventsUrl}/$id'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to delete event');
    }
  }

  // ─── Parse list helper ─────────────────────────────────
  List<EventModel> _parseEventList(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List data = body['data'] as List;
      return data.map((e) => EventModel.fromJson(e)).toList();
    }
    throw Exception(body['message'] ?? 'Failed to load events');
  }
}
