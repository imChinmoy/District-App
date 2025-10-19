class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    location: map['location'],
    date: DateTime.parse(map['date']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'date': date.toIso8601String(),
  };
}
