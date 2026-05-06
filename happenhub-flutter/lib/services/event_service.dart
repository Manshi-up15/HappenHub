import '../models/event_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

/// All event-related API calls, using the central ApiClient.
class EventService {

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

    final data = await ApiClient.get(
      AppConstants.eventsUrl,
      params: params.isEmpty ? null : params,
      auth: false,
    );
    return (data as List).map((e) => EventModel.fromJson(e)).toList();
  }

  Future<EventModel> getEventById(int id) async {
    final data = await ApiClient.get('${AppConstants.eventsUrl}/$id', auth: false);
    return EventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<EventModel>> searchEvents(String keyword) async {
    final data = await ApiClient.get(
      '${AppConstants.eventsUrl}/search',
      params: {'keyword': keyword},
      auth: false,
    );
    return (data as List).map((e) => EventModel.fromJson(e)).toList();
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    final data = await ApiClient.get('${AppConstants.eventsUrl}/upcoming', auth: false);
    return (data as List).map((e) => EventModel.fromJson(e)).toList();
  }

  Future<List<EventModel>> getEventsByCreator(int userId) async {
    final data = await ApiClient.get('${AppConstants.eventsUrl}/creator/$userId', auth: false);
    return (data as List).map((e) => EventModel.fromJson(e)).toList();
  }

  Future<EventModel> createEvent(Map<String, dynamic> payload, int createdById) async {
    final data = await ApiClient.post(
      AppConstants.eventsUrl,
      body: payload,
      params: {'createdById': createdById.toString()},
    );
    return EventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<EventModel> updateEvent(int id, Map<String, dynamic> payload) async {
    final data = await ApiClient.put('${AppConstants.eventsUrl}/$id', body: payload);
    return EventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteEvent(int id) async {
    await ApiClient.delete('${AppConstants.eventsUrl}/$id');
  }
}
