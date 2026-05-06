import 'event_model.dart';

/// Matches SavedEventResponse DTO from backend.
class SavedEventModel {
  final int id;
  final int userId;
  final EventModel event;
  final String? savedAt;

  SavedEventModel({
    required this.id,
    required this.userId,
    required this.event,
    this.savedAt,
  });

  factory SavedEventModel.fromJson(Map<String, dynamic> json) {
    return SavedEventModel(
      id:      json['id'] as int,
      userId:  json['userId'] as int,
      event:   EventModel.fromJson(json['event'] as Map<String, dynamic>),
      savedAt: json['savedAt'] as String?,
    );
  }
}
