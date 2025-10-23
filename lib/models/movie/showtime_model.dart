enum ScreenType { twoD, threeD, imax, fourDX }

class ShowtimeModel {
  final String id;
  final String cinemaName;
  final String address;
  final DateTime time;
  final double price;
  final int availableSeats;
  final int totalSeats;
  final ScreenType screenType;

  ShowtimeModel({
    required this.id,
    required this.cinemaName,
    required this.address,
    required this.time,
    required this.price,
    required this.availableSeats,
    required this.totalSeats,
    required this.screenType,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'cinemaName': cinemaName,
        'address': address,
        'time': time.toIso8601String(),
        'price': price,
        'availableSeats': availableSeats,
        'totalSeats': totalSeats,
        'screenType': screenType.name,
      };

  factory ShowtimeModel.fromMap(Map<String, dynamic> map) => ShowtimeModel(
        id: map['id'] ?? '',
        cinemaName: map['cinemaName'] ?? '',
        address: map['address'] ?? '',
        time: DateTime.parse(map['time']),
        price: (map['price'] ?? 0).toDouble(),
        availableSeats: map['availableSeats'] ?? 0,
        totalSeats: map['totalSeats'] ?? 0,
        screenType: ScreenType.values.firstWhere(
          (e) => e.name == map['screenType'],
          orElse: () => ScreenType.twoD,
        ),
      );
}