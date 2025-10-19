class BookingModel {
  final String id;
  final String userId;
  final String eventId;
  final DateTime date;

  BookingModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.date,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    id: map['id'],
    userId: map['userId'],
    eventId: map['eventId'],
    date: DateTime.parse(map['date']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'eventId': eventId,
    'date': date.toIso8601String(),
  };
}
