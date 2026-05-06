import '../models/event_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AppliedEventModel {
  final int id;
  final int userId;
  final EventModel event;
  final String? appliedAt;

  AppliedEventModel({
    required this.id,
    required this.userId,
    required this.event,
    this.appliedAt,
  });

  factory AppliedEventModel.fromJson(Map<String, dynamic> json) {
    return AppliedEventModel(
      id:      json['id'] as int,
      userId:  json['userId'] as int,
      event:   EventModel.fromJson(json['event'] as Map<String, dynamic>),
      appliedAt: json['appliedAt'] as String?,
    );
  }
}

class AppliedEventService {
  Future<AppliedEventModel> applyEvent(int userId, int eventId) async {
    final data = await ApiClient.post(
      '${AppConstants.baseUrl}/applied',
      body: {'userId': userId, 'eventId': eventId},
    );
    return AppliedEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AppliedEventModel>> getAppliedEvents(int userId) async {
    final data = await ApiClient.get('${AppConstants.baseUrl}/applied/$userId');
    return (data as List).map((e) => AppliedEventModel.fromJson(e)).toList();
  }

  Future<void> removeAppliedEvent(int appliedId) async {
    await ApiClient.delete('${AppConstants.baseUrl}/applied/$appliedId');
  }
}
