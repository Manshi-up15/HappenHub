import '../models/saved_event_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

/// Bookmark / saved-event API calls, using the central ApiClient.
class SavedEventService {

  Future<SavedEventModel> saveEvent(int userId, int eventId) async {
    final data = await ApiClient.post(
      AppConstants.savedUrl,
      body: {'userId': userId, 'eventId': eventId},
    );
    return SavedEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<SavedEventModel>> getSavedEvents(int userId) async {
    final data = await ApiClient.get('${AppConstants.savedUrl}/$userId');
    return (data as List).map((e) => SavedEventModel.fromJson(e)).toList();
  }

  Future<void> removeSavedEvent(int savedEventId) async {
    await ApiClient.delete('${AppConstants.savedUrl}/$savedEventId');
  }
}
