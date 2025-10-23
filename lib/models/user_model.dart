class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? phoneNumber;
  final List<String>? bookings;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.phoneNumber,
    this.bookings,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'phoneNumber': phoneNumber,
        'bookings': bookings,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        profileImageUrl: map['profileImageUrl'],
        phoneNumber: map['phoneNumber'] ?? '',
        bookings: List<String>.from(map['bookings'] ?? []),
      );
}
