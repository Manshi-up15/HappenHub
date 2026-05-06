/// Matches the EventResponse DTO from the Spring Boot backend.
class EventModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String? mood;
  final String location;
  final String date;      // yyyy-MM-dd
  final String? time;     // HH:mm:ss
  final String? imageUrl;
  final String? createdAt;
  final int createdById;
  final String createdByName;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.mood,
    required this.location,
    required this.date,
    this.time,
    this.imageUrl,
    this.createdAt,
    required this.createdById,
    required this.createdByName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id:            json['id'] as int,
      title:         json['title'] as String,
      description:   json['description'] ?? '',
      category:      json['category'] as String,
      mood:          json['mood'] as String?,
      location:      json['location'] as String,
      date:          json['date'] as String,
      time:          json['time'] as String?,
      imageUrl:      json['imageUrl'] as String?,
      createdAt:     json['createdAt'] as String?,
      createdById:   json['createdById'] as int,
      createdByName: json['createdByName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'title':       title,
    'description': description,
    'category':    category,
    'mood':        mood,
    'location':    location,
    'date':        date,
    'time':        time,
    'imageUrl':    imageUrl,
  };
}
