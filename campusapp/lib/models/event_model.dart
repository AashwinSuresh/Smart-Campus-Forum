class EventModel {
  final String id;
  final String title;
  final String description;
  final String image_url;
  final DateTime event_date;
  final String venue;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image_url,
    required this.event_date,
    required this.venue,
  });

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'title': title,
        'description': description,
        'image_url': image_url,
        'event_date': event_date.toIso8601String(),
        'venue': venue,
      };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        image_url: json['image_url'] ?? '',
        event_date: json['event_date'] != null
            ? DateTime.parse(json['event_date'])
            : DateTime.now(),
        venue: json['venue'] ?? '',
      );
}